{******************************************************************************}
{* Demo: Hash large files (>5 GB) with real-time progress                    *}
{* Uses manual Hash.Update() loop with 64 KB blocks to avoid UpdateStream    *}
{* integer overflow on files larger than ~17 GB.                             *}
{* Shows progress (%, MB/s, elapsed time) every 2% of the file.             *}
{******************************************************************************}
program demo_hash_large_file;

{$MODE ObjFPC}{$H+}

uses
  Classes, SysUtils,
  DCPcrypt2,
  DCPmd5, DCPsha256, DCPsha512;

const
  BUFFER_SIZE = 65536;     // 64 KB blocks
  DEFAULT_SIZE_GB = 5;

type
  THashInfo = record
    Name: string;
    HashClass: TDCP_hashclass;
  end;

const
  HashAlgorithms: array[0..2] of THashInfo = (
    (Name: 'MD5';     HashClass: TDCP_md5),
    (Name: 'SHA-256'; HashClass: TDCP_sha256),
    (Name: 'SHA-512'; HashClass: TDCP_sha512)
  );

function DigestToHex(const Digest: array of byte): string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to Length(Digest) - 1 do
    Result := Result + IntToHex(Digest[i], 2);
end;

function FormatSize(Bytes: QWord): string;
begin
  if Bytes >= 1073741824 then
    Result := Format('%.2f GB', [Bytes / 1073741824.0])
  else if Bytes >= 1048576 then
    Result := Format('%.2f MB', [Bytes / 1048576.0])
  else if Bytes >= 1024 then
    Result := Format('%.2f KB', [Bytes / 1024.0])
  else
    Result := Format('%d bytes', [Bytes]);
end;

procedure HashLargeFile(const FileName: string; HashClass: TDCP_hashclass;
  const AlgoName: string);
var
  Hash: TDCP_hash;
  Digest: array of byte;
  Stream: TFileStream;
  Buffer: array[0..BUFFER_SIZE - 1] of byte;
  BytesRead: longint;
  TotalRead: QWord;
  FileSize: QWord;
  NextThreshold: QWord;
  StartTime: TDateTime;
  Elapsed: double;
  Pct: double;
  Speed: double;
begin
  Hash := HashClass.Create(nil);
  try
    SetLength(Digest, Hash.HashSize div 8);
    Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
    try
      FileSize := Stream.Size;
      TotalRead := 0;
      NextThreshold := FileSize div 50;  // 2% steps

      Write('  ', AlgoName:8, ' : hashing ', FormatSize(FileSize), ' ... ');
      if FileSize < 1048576 then
      begin
        // Small file: no progress display needed
        Hash.Init;
        BytesRead := Stream.Read(Buffer, BUFFER_SIZE);
        while BytesRead > 0 do
        begin
          Hash.Update(Buffer, BytesRead);
          BytesRead := Stream.Read(Buffer, BUFFER_SIZE);
        end;
        Hash.Final(Digest[0]);
        WriteLn(LowerCase(DigestToHex(Digest)));
        Exit;
      end;

      WriteLn;
      StartTime := Now;
      Hash.Init;

      BytesRead := Stream.Read(Buffer, BUFFER_SIZE);
      while BytesRead > 0 do
      begin
        Hash.Update(Buffer, BytesRead);
        TotalRead := TotalRead + QWord(BytesRead);

        if TotalRead >= NextThreshold then
        begin
          Elapsed := (Now - StartTime) * 86400.0;  // seconds
          Pct := (TotalRead / FileSize) * 100.0;
          if Elapsed > 0.0 then
            Speed := (TotalRead / 1048576.0) / Elapsed  // MB/s
          else
            Speed := 0.0;
          Write(Format('             %5.1f%%  %7.1f MB/s  elapsed: %.0fs'#13,
            [Pct, Speed, Elapsed]));
          NextThreshold := NextThreshold + (FileSize div 50);
        end;

        BytesRead := Stream.Read(Buffer, BUFFER_SIZE);
      end;

      Hash.Final(Digest[0]);
      Elapsed := (Now - StartTime) * 86400.0;
      if Elapsed > 0.0 then
        Speed := (FileSize / 1048576.0) / Elapsed
      else
        Speed := 0.0;

      WriteLn(Format('             100.0%%  %7.1f MB/s  elapsed: %.1fs',
        [Speed, Elapsed]));
      WriteLn('             digest: ', LowerCase(DigestToHex(Digest)));
    finally
      Stream.Free;
    end;
  finally
    Hash.Free;
  end;
end;

procedure CreateLargeTestFile(const FileName: string; SizeBytes: QWord);
var
  f: TFileStream;
  buf: array[0..BUFFER_SIZE - 1] of byte;
  remaining: QWord;
  chunk: longint;
  i: integer;
  NextThreshold: QWord;
  Pct: double;
begin
  WriteLn('Generating test file: ', FileName);
  WriteLn('Size: ', FormatSize(SizeBytes));

  // Remove any leftover file from a previous run
  if FileExists(FileName) then
  begin
    WriteLn('  (removing leftover file from previous run)');
    if not DeleteFile(FileName) then
    begin
      WriteLn('Error: cannot delete existing file: ', FileName);
      WriteLn('  Remove it manually and try again.');
      Halt(1);
    end;
  end;

  try
    f := TFileStream.Create(FileName, fmCreate);
  except
    on E: Exception do
    begin
      WriteLn;
      WriteLn('Error: cannot create file: ', FileName);
      WriteLn('  ', E.Message);
      WriteLn;
      WriteLn('Possible causes:');
      WriteLn('  - Directory does not exist or is read-only');
      WriteLn('  - Temp directory is a RAM disk with insufficient space');
      WriteLn('  - File system error or permissions issue');
      WriteLn;
      WriteLn('Try specifying a different directory with --dir=<path>');
      WriteLn('  Example: ', ParamStr(0), ' --dir=', GetTempDir);
      Halt(1);
    end;
  end;

  try
    remaining := SizeBytes;
    NextThreshold := SizeBytes div 20;  // 5% steps
    while remaining > 0 do
    begin
      if remaining > BUFFER_SIZE then
        chunk := BUFFER_SIZE
      else
        chunk := remaining;
      for i := 0 to chunk - 1 do
        buf[i] := Random(256);
      f.WriteBuffer(buf, chunk);
      Dec(remaining, chunk);

      if (SizeBytes - remaining) >= NextThreshold then
      begin
        Pct := ((SizeBytes - remaining) / SizeBytes) * 100.0;
        Write(Format('  generating... %5.1f%%'#13, [Pct]));
        NextThreshold := NextThreshold + (SizeBytes div 20);
      end;
    end;
  except
    on E: Exception do
    begin
      f.Free;
      WriteLn;
      WriteLn('Error: write failed after ', FormatSize(SizeBytes - remaining));
      WriteLn('  ', E.Message);
      WriteLn;
      WriteLn('The disk may be full. Try a smaller size (--size=1) or a');
      WriteLn('different directory (--dir=<path>).');
      // Clean up partial file
      if FileExists(FileName) then
        DeleteFile(FileName);
      Halt(1);
    end;
  end;
  f.Free;
  WriteLn('  generating... done.   ');
  WriteLn('File created successfully.');
  WriteLn;
end;

function ParseSizeArg: QWord;
var
  i: integer;
  Arg: string;
  GB: integer;
begin
  Result := QWord(DEFAULT_SIZE_GB) * 1073741824;
  for i := 1 to ParamCount do
  begin
    Arg := ParamStr(i);
    if Copy(Arg, 1, 7) = '--size=' then
    begin
      GB := StrToIntDef(Copy(Arg, 8, Length(Arg) - 7), DEFAULT_SIZE_GB);
      if GB < 1 then
        GB := 1;
      Result := QWord(GB) * 1073741824;
    end;
  end;
end;

function ParseDirArg: string;
var
  i: integer;
  Arg: string;
begin
  Result := '';
  for i := 1 to ParamCount do
  begin
    Arg := ParamStr(i);
    if Copy(Arg, 1, 6) = '--dir=' then
    begin
      Result := Copy(Arg, 7, Length(Arg) - 6);
      // Ensure trailing path separator
      if (Result <> '') and (Result[Length(Result)] <> DirectorySeparator) then
        Result := Result + DirectorySeparator;
    end;
  end;
end;

function HasHelpArg: boolean;
var
  i: integer;
  Arg: string;
begin
  Result := False;
  for i := 1 to ParamCount do
  begin
    Arg := ParamStr(i);
    if (Arg = '-h') or (Arg = '--help') then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

procedure PrintUsage;
begin
  WriteLn('Usage:');
  WriteLn('  ', ExtractFileName(ParamStr(0)), ' [options] [file]');
  WriteLn;
  WriteLn('Modes:');
  WriteLn('  <file>        Hash an existing file with MD5, SHA-256, SHA-512');
  WriteLn('  (no file)     Generate a test file, hash it, then delete it');
  WriteLn;
  WriteLn('Options:');
  WriteLn('  --size=N      Size of generated test file in GB (default: ', DEFAULT_SIZE_GB, ')');
  WriteLn('  --dir=<path>  Directory for the test file (default: system temp)');
  WriteLn('  -h, --help    Show this help message');
  WriteLn;
  WriteLn('Examples:');
  WriteLn('  ', ExtractFileName(ParamStr(0)), ' /path/to/large/file');
  WriteLn('  ', ExtractFileName(ParamStr(0)), ' --size=1');
  WriteLn('  ', ExtractFileName(ParamStr(0)), ' --size=2 --dir=/home/user');
end;

function FindFileArg: string;
var
  i: integer;
  Arg: string;
begin
  Result := '';
  for i := 1 to ParamCount do
  begin
    Arg := ParamStr(i);
    if (Copy(Arg, 1, 1) <> '-') then
    begin
      Result := Arg;
      Exit;
    end;
  end;
end;

var
  UserFile: string;
  TestFile: string;
  TestDir: string;
  SizeBytes: QWord;
  i: integer;

begin
  if HasHelpArg then
  begin
    PrintUsage;
    Halt(0);
  end;

  WriteLn('=== DCPcrypt Large File Hashing Demo (Lazarus/FPC) ===');
  WriteLn('Hashes large files using MD5, SHA-256, SHA-512');
  WriteLn('Uses manual Update() loop with 64 KB blocks (no UpdateStream)');
  WriteLn;

  UserFile := FindFileArg;

  if UserFile <> '' then
  begin
    // Hash a user-supplied file
    if not FileExists(UserFile) then
    begin
      WriteLn('Error: file not found: ', UserFile);
      Halt(1);
    end;
    WriteLn('--- Hashing user file ---');
    WriteLn('File: ', UserFile);
    WriteLn;
    for i := Low(HashAlgorithms) to High(HashAlgorithms) do
      HashLargeFile(UserFile, HashAlgorithms[i].HashClass, HashAlgorithms[i].Name);
  end
  else
  begin
    // Generate a test file, hash it, then delete it
    Randomize;
    SizeBytes := ParseSizeArg;
    TestDir := ParseDirArg;
    if TestDir = '' then
      TestDir := GetTempDir;
    if not DirectoryExists(TestDir) then
    begin
      WriteLn('Error: directory does not exist: ', TestDir);
      Halt(1);
    end;
    TestFile := TestDir + 'dcp_large_hash_test.bin';

    WriteLn('--- Generating test file ---');
    CreateLargeTestFile(TestFile, SizeBytes);
    try
      WriteLn('--- Hashing test file ---');
      WriteLn;
      for i := Low(HashAlgorithms) to High(HashAlgorithms) do
        HashLargeFile(TestFile, HashAlgorithms[i].HashClass, HashAlgorithms[i].Name);
    finally
      WriteLn;
      Write('Cleaning up test file... ');
      if FileExists(TestFile) then
        DeleteFile(TestFile);
      WriteLn('done.');
    end;
  end;

  WriteLn;
  WriteLn('Done.');
end.
