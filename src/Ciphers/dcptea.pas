{===============================================================================
  DCPcrypt v2.0.6 - A binary compatible implementation of Tea

  SPDX-License-Identifier: MIT
  See LICENSE for full license text.

  Copyright (c) 1999-2003 David Barton (crypto@cityinthesky.co.uk)
  Copyright (c) 2006 Barko (Lazarus port)
  Copyright (c) 2009-2010 Graeme Geldenhuys
  Copyright (c) 2022 Werner Pamler
  Copyright (c) 2026 Nicolas Deoux (NDXDev@gmail.com)
===============================================================================}
unit DCPtea;

{$MODE Delphi}

interface
uses
  Classes, Sysutils, DCPcrypt2, DCPconst, DCPblockciphers;

{ TEA (Tiny Encryption Algorithm): 64-bit block cipher, 128-bit key, 64 Feistel rounds.
  Designed by Wheeler and Needham (1994). Simple, fast, minimal code size. }
type
  TDCP_tea= class(TDCP_blockcipher64)
  protected
    KeyData: array[0..3] of dword;  { 128-bit key stored as 4 x 32-bit words }
    procedure InitKey(const Key; Size: longword); override;
  public
    class function GetID: integer; override;
    class function GetAlgorithm: string; override;
    class function GetMaxKeySize: integer; override;
    class function SelfTest: boolean; override;
    procedure Burn; override;
    procedure EncryptECB(const InData; var OutData); override;
    procedure DecryptECB(const InData; var OutData); override;
  end;


implementation
{$R-}{$Q-}

const
  Delta: DWord = $9e3779b9;  { Golden ratio derived constant: (sqrt(5)-1) * 2^31 }
  Rounds= 32;                { 32 cycles = 64 Feistel rounds }

function SwapDword(a: dword): dword;
begin
  Result:= ((a and $FF) shl 24) or ((a and $FF00) shl 8) or ((a and $FF0000) shr 8) or ((a and $FF000000) shr 24);
end;

class function TDCP_tea.GetID: integer;
begin
  Result:= DCP_tea;
end;

class function TDCP_tea.GetAlgorithm: string;
begin
  Result:= 'Tea';
end;

class function TDCP_tea.GetMaxKeySize: integer;
begin
  Result:= 128;
end;

class function TDCP_tea.SelfTest: boolean;
const
  Key: array[0..3] of dword= ($12345678,$9ABCDEF0,$0FEDCBA9,$87654321);
  PT: array[0..1] of dword= ($12345678,$9ABCDEF0);
var
  Data: array[0..1] of dword;
  Cipher: TDCP_tea;
begin
  dcpFillChar(Data, SizeOf(Data), 0);
  Cipher:= TDCP_tea.Create(nil);
  Cipher.Init(Key,Sizeof(Key)*8,nil);
  Cipher.EncryptECB(PT,Data);
  Result:= not CompareMem(@Data,@PT,Sizeof(PT));
  Cipher.DecryptECB(Data,Data);
  Result:= Result and CompareMem(@Data,@PT,Sizeof(PT));
  Cipher.Burn;
  Cipher.Free;
end;

procedure TDCP_tea.InitKey(const Key; Size: longword);
begin
  FillChar(KeyData,Sizeof(KeyData),0);
  Move(Key,KeyData,Size div 8);
  KeyData[0]:= SwapDWord(KeyData[0]); KeyData[1]:= SwapDWord(KeyData[1]);
  KeyData[2]:= SwapDWord(KeyData[2]); KeyData[3]:= SwapDWord(KeyData[3]);
end;

procedure TDCP_tea.Burn;
begin
  FillChar(KeyData,Sizeof(KeyData),0);
  inherited Burn;
end;

procedure TDCP_tea.EncryptECB(const InData; var OutData);
var
  a, b, c, d, x, y, n, sum: dword;
begin
  if not fInitialized then
    raise EDCP_blockcipher.Create('Cipher not initialized');

  x:= SwapDWord(pdword(@InData)^);
  y:= SwapDWord(pdword(pointer(@InData)+4)^);
  sum:= 0; a:= KeyData[0]; b:= KeyData[1]; c:= KeyData[2]; d:= KeyData[3];
  for n:= 1 to Rounds do
  begin
    Inc(sum,Delta);
    Inc(x,(y shl 4) + (a xor y) + (sum xor (y shr 5)) + b);
    Inc(y,(x shl 4) + (c xor x) + (sum xor (x shr 5)) + d);
  end;
  pdword(@OutData)^:= SwapDWord(x);
  pdword(pointer(@OutData)+4)^:= SwapDWord(y);
end;

procedure TDCP_tea.DecryptECB(const InData; var OutData);
var
  a, b, c, d, x, y, n, sum: dword;
begin
  if not fInitialized then
    raise EDCP_blockcipher.Create('Cipher not initialized');

  x:= SwapDWord(pdword(@InData)^);
  y:= SwapDWord(pdword(pointer(@InData)+4)^);
  sum:= Delta shl 5;
  a:= KeyData[0];
  b:= KeyData[1];
  c:= KeyData[2];
  d:= KeyData[3];
  for n:= 1 to Rounds do
  begin
    Dec(y,(x shl 4) + (c xor x) + (sum xor (x shr 5)) + d);
    Dec(x,(y shl 4) + (a xor y) + (sum xor (y shr 5)) + b);
    Dec(sum,Delta);
  end;
  pdword(@OutData)^:= SwapDWord(x);
  pdword(pointer(@OutData)+4)^:= SwapDWord(y);
end;

end.
