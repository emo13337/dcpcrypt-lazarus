{******************************************************************************}
{* Demo: Hash files using all available hash algorithms                      *}
{* Demonstrates the generic TDCP_hashclass API with all 10 hash algorithms   *}
{* Creates a test file, hashes it, and optionally hashes a user-supplied file*}
{******************************************************************************}
program demo_hash_file;

{$MODE ObjFPC}{$H+}

uses
  Classes, SysUtils,
  DCPcrypt2,
  DCPmd4, DCPmd5, DCPsha1, DCPsha256, DCPsha512,
  DCPripemd128, DCPripemd160, DCPhaval, DCPtiger;

type
  THashInfo = record
    Name: string;
    HashClass: TDCP_hashclass;
  end;

const
  HashAlgorithms: array[0..9] of THashInfo = (
    (Name: 'MD4';        HashClass: TDCP_md4),
    (Name: 'MD5';        HashClass: TDCP_md5),
    (Name: 'SHA-1';      HashClass: TDCP_sha1),
    (Name: 'SHA-256';    HashClass: TDCP_sha256),
    (Name: 'SHA-384';    HashClass: TDCP_sha384),
    (Name: 'SHA-512';    HashClass: TDCP_sha512),
    (Name: 'RipeMD-128'; HashClass: TDCP_ripemd128),
    (Name: 'RipeMD-160'; HashClass: TDCP_ripemd160),
    (Name: 'Haval';      HashClass: TDCP_haval),
    (Name: 'Tiger';      HashClass: TDCP_tiger)
  );

function DigestToHex(const Digest: array of byte): string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to Length(Digest) - 1 do
    Result := Result + IntToHex(Digest[i], 2);
end;

procedure HashFile(const FileName: string; HashClass: TDCP_hashclass;
  const AlgoName: string);
var
  Hash: TDCP_hash;
  Digest: array of byte;
  Stream: TFileStream;
begin
  Hash := HashClass.Create(nil);
  try
    SetLength(Digest, Hash.HashSize div 8);
    Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
    try
      Hash.Init;
      Hash.UpdateStream(Stream, Stream.Size);
      Hash.Final(Digest[0]);
    finally
      Stream.Free;
    end;
    WriteLn('  ', AlgoName:12, ' : ', LowerCase(DigestToHex(Digest)));
  finally
    Hash.Free;
  end;
end;

procedure HashAllAlgorithms(const FileName: string);
var
  i: integer;
begin
  for i := Low(HashAlgorithms) to High(HashAlgorithms) do
    HashFile(FileName, HashAlgorithms[i].HashClass, HashAlgorithms[i].Name);
end;

procedure CreateTestFile(const FileName: string; SizeBytes: longword);
var
  f: TFileStream;
  buf: array[0..4095] of byte;
  remaining: longword;
  chunk: longword;
  i: integer;
begin
  f := TFileStream.Create(FileName, fmCreate);
  try
    remaining := SizeBytes;
    while remaining > 0 do
    begin
      if remaining > SizeOf(buf) then
        chunk := SizeOf(buf)
      else
        chunk := remaining;
      for i := 0 to chunk - 1 do
        buf[i] := Random(256);
      f.WriteBuffer(buf, chunk);
      Dec(remaining, chunk);
    end;
  finally
    f.Free;
  end;
end;

var
  TestFile: string;

begin
  WriteLn('=== DCPcrypt File Hashing Demo (Lazarus/FPC) ===');
  WriteLn('Hashes files using all 10 available hash algorithms');
  WriteLn;

  // Part 1: Hash a generated test file
  Randomize;
  TestFile := GetTempDir + 'dcp_hash_test.bin';
  try
    WriteLn('--- Test file (8 KB random data) ---');
    CreateTestFile(TestFile, 8192);
    WriteLn('File: ', TestFile);
    WriteLn;
    HashAllAlgorithms(TestFile);
  finally
    if FileExists(TestFile) then
      DeleteFile(TestFile);
  end;

  // Part 2: Hash a user-supplied file
  if ParamCount >= 1 then
  begin
    WriteLn;
    if not FileExists(ParamStr(1)) then
    begin
      WriteLn('Error: file not found: ', ParamStr(1));
      Halt(1);
    end;
    WriteLn('--- User file ---');
    WriteLn('File: ', ParamStr(1));
    WriteLn;
    HashAllAlgorithms(ParamStr(1));
  end;

  WriteLn;
  WriteLn('Done.');
end.
