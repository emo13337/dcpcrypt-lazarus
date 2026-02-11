unit UnitUtilitaires;

{$MODE ObjFPC}{$H+}

interface

uses
  SysUtils, Classes;

function StringToHex(const S: string): string;
function HexToString(const H: string): string;
function IsHex(const S: string): boolean;
function IsValidFilename(const FileName: string): boolean;
function StringIndex(const aString: string;
                     const aCases: array of string;
                     const aCaseSensitive: boolean = True): integer;

implementation

function IsValidFilename(const FileName: string): boolean;
var
  Dir, Name: string;
  i: integer;
  InvalidChars: set of char;
begin
  Dir := ExtractFilePath(FileName);
  Name := ExtractFileName(FileName);
  if Name = '' then
    Exit(False);
  if (Dir <> '') and not DirectoryExists(Dir) then
    Exit(False);
  InvalidChars := [#0..#31, '<', '>', ':', '"', '/', '\', '|', '?', '*'];
  for i := 1 to Length(Name) do
    if Name[i] in InvalidChars then
      Exit(False);
  Result := True;
end;

function StringIndex(const aString: string;
                     const aCases: array of string;
                     const aCaseSensitive: boolean): integer;
begin
  if aCaseSensitive then
  begin
    for Result := 0 to Pred(Length(aCases)) do
      if AnsiSameText(aString, aCases[Result]) then
        Exit;
  end
  else
  begin
    for Result := 0 to Pred(Length(aCases)) do
      if AnsiSameStr(aString, aCases[Result]) then
        Exit;
  end;
  Result := -1;
end;

function StringToHex(const S: string): string;
var
  i: integer;
begin
  Result := '';
  for i := 1 to Length(S) do
    Result := Result + IntToHex(Ord(S[i]), 2);
end;

function HexToString(const H: string): string;
var
  i: integer;
begin
  Result := '';
  i := 1;
  while i < Length(H) do
  begin
    Result := Result + Chr(StrToInt('$' + Copy(H, i, 2)));
    Inc(i, 2);
  end;
end;

function IsHex(const S: string): boolean;
var
  i: integer;
begin
  Result := True;
  for i := 1 to Length(S) do
    if not (S[i] in ['0'..'9', 'A'..'F', 'a'..'f']) then
    begin
      Result := False;
      Exit;
    end;
end;

end.
