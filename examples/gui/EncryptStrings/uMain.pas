{******************************************************************************}
{* DCPcrypt v2.0 - Lazarus LCL GUI demo                                      *}
{******************************************************************************}
{* String encryption/decryption demo using EncryptStream                      *}
{* Ported from Delphi VCL to Lazarus LCL                                     *}
{* Uses the DCPcrypt library by David Barton                                  *}
{******************************************************************************}
{* Copyright (c) 2026 Nicolas Deoux (NDXDev@gmail.com)                        *}
{* MIT License - see LICENSE file                                             *}
{******************************************************************************}
unit uMain;

{$MODE ObjFPC}{$H+}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, DCPtiger, DCPsha512, DCPsha256, DCPsha1, DCPripemd160,
  DCPripemd128, DCPmd5, DCPmd4, DCPcrypt2, DCPhaval, DCPtwofish, DCPtea,
  DCPserpent, DCPblockciphers, DCPrijndael, DCPrc4, DCPrc2, DCPice, DCPdes,
  DCPcast128, DCPblowfish, StdCtrls, Buttons, ComCtrls, ExtCtrls,
  UnitUtilitaires, Clipbrd;

type

  TfrmMain = class(TForm)
    Panel1: TPanel;
    grpOptions: TGroupBox;
    lblCipher: TLabel;
    lblHash: TLabel;
    lblKeySize: TLabel;
    dblKeySize: TLabel;
    lblPassphrase: TLabel;
    cbxCipher: TComboBox;
    cbxHash: TComboBox;
    boxPassphrase: TEdit;
    btnEncrypt: TButton;
    btnDecrypt: TButton;
    btnClose: TButton;
    btn_Copy: TButton;
    btn_Paste: TButton;
    Panel2: TPanel;
    Panel3: TPanel;
    Memo1: TMemo;
    Progress: TProgressBar;
    procedure FormCreate(Sender: TObject);
    procedure cbxCipherChange(Sender: TObject);
    procedure boxPassphraseChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Pourcentage(Sender: TObject; Value: integer);
    procedure btn_CopyClick(Sender: TObject);
    procedure btn_PasteClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnDecryptClick(Sender: TObject);
    procedure btnEncryptClick(Sender: TObject);
  private
    procedure DisableForm;
    function DoEncryptStringStream(passphrase: string;
                        Hash: TDCP_hash; Cipher: TDCP_cipher): Boolean;
    function DoDecryptStringStream(passphrase: string;
                        Hash: TDCP_hash; Cipher: TDCP_cipher): Boolean;
  public
  end;

var
  frmMain: TfrmMain;
  ConvertRunning: boolean;

implementation

{$R *.lfm}

function Min(a, b: integer): integer;
begin
  if (a < b) then
    Result := a
  else
    Result := b;
end;

procedure TfrmMain.DisableForm;
begin
  grpOptions.Enabled := False;
  btnEncrypt.Enabled := False;
  btnDecrypt.Enabled := False;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if ConvertRunning then
    if MessageDlg('Application is working! Are you sure you want to quit?',
                  mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      Repeat
        Application.ProcessMessages;
      Until (not ConvertRunning);
    end
    else
    begin
      CanClose := not ConvertRunning;
    end;
end;

procedure TfrmMain.Pourcentage(Sender: TObject; Value: integer);
begin
  if Value <= 100 then
    if Value >= 0 then
      Progress.Position := Value;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  i: integer;
begin
  Constraints.MinWidth := 600;
  Constraints.MinHeight := 480;

  Randomize;

  // Crypto components are created in code (no design-time package needed)
  // -- Ciphers --
  TDCP_blowfish.Create(Self);
  TDCP_cast128.Create(Self);
  TDCP_des.Create(Self);
  TDCP_3des.Create(Self);
  TDCP_ice.Create(Self);
  TDCP_thinice.Create(Self);
  TDCP_ice2.Create(Self);
  TDCP_rc2.Create(Self);
  TDCP_rc4.Create(Self);
  TDCP_rijndael.Create(Self);
  TDCP_serpent.Create(Self);
  TDCP_tea.Create(Self);
  TDCP_twofish.Create(Self);

  // -- Hashes --
  TDCP_haval.Create(Self);
  TDCP_md4.Create(Self);
  TDCP_md5.Create(Self);
  TDCP_ripemd128.Create(Self);
  TDCP_ripemd160.Create(Self);
  TDCP_sha1.Create(Self);
  TDCP_sha256.Create(Self);
  TDCP_sha384.Create(Self);
  TDCP_sha512.Create(Self);
  TDCP_tiger.Create(Self);

  // Iterate through all owned components and find the ciphers/hashes
  for i := 0 to (ComponentCount - 1) do
  begin
    if (Components[i] is TDCP_cipher) then
      cbxCipher.Items.AddObject(TDCP_cipher(Components[i]).Algorithm, Components[i])
    else if (Components[i] is TDCP_hash) then
      cbxHash.Items.AddObject(TDCP_hash(Components[i]).Algorithm, Components[i]);
  end;

  if (cbxCipher.Items.Count = 0) then
  begin
    MessageDlg('No ciphers were found', mtError, [mbOK], 0);
    DisableForm;
  end
  else
  begin
    cbxCipher.ItemIndex := 0;
    if (cbxHash.Items.Count = 0) then
    begin
      MessageDlg('No hashes were found', mtError, [mbOK], 0);
      DisableForm;
    end
    else
    begin
      cbxHash.ItemIndex := 0;
      cbxCipher.OnChange(cbxCipher);
    end;
  end;
end;

function TfrmMain.DoEncryptStringStream(passphrase: string;
                        Hash: TDCP_hash; Cipher: TDCP_cipher): Boolean;
var
  CipherIV: array of byte;
  HashDigest: array of byte;
  Salt: array[0..7] of byte;
  strmInput, strmOutput: TStringStream;
  i: integer;
begin
  Result := True;
  strmInput := nil;
  strmOutput := nil;
  Cipher.OnProgressEvent := @Pourcentage;
  try
    strmInput := TStringStream.Create(Memo1.Text);
    strmOutput := TStringStream.Create('');

    SetLength(HashDigest, Hash.HashSize div 8);
    for i := 0 to 7 do
      Salt[i] := Random(256);
    strmOutput.WriteBuffer(Salt, SizeOf(Salt));
    Hash.Init;
    Hash.Update(Salt[0], SizeOf(Salt));
    Hash.UpdateStr(passphrase);
    Hash.Final(HashDigest[0]);

    if (Cipher is TDCP_blockcipher) then
    begin
      SetLength(CipherIV, TDCP_blockcipher(Cipher).BlockSize div 8);
      for i := 0 to (Length(CipherIV) - 1) do
        CipherIV[i] := Random(256);
      strmOutput.WriteBuffer(CipherIV[0], Length(CipherIV));
      Cipher.Init(HashDigest[0], Min(Cipher.MaxKeySize, Hash.HashSize), @CipherIV[0]);
      TDCP_blockcipher(Cipher).CipherMode := cmCBC;
    end
    else
      Cipher.Init(HashDigest[0], Min(Cipher.MaxKeySize, Hash.HashSize), nil);

    Cipher.EncryptStream(strmInput, strmOutput, strmInput.Size);
    Cipher.Burn;
    strmOutput.Position := 0;
    Memo1.Text := StringToHex(strmOutput.DataString);
    strmInput.Free;
    strmOutput.Free;
    ConvertRunning := False;
  except
    strmInput.Free;
    strmOutput.Free;
    ConvertRunning := False;
  end;
end;

function TfrmMain.DoDecryptStringStream(passphrase: string;
                        Hash: TDCP_hash; Cipher: TDCP_cipher): Boolean;
var
  CipherIV: array of byte;
  HashDigest: array of byte;
  Salt: array[0..7] of byte;
  strmInput, strmOutput: TStringStream;
begin
  Result := True;
  strmInput := nil;
  strmOutput := nil;
  try
    strmInput := TStringStream.Create(HexToString(Trim(Memo1.Text)));
    strmOutput := TStringStream.Create('');

    SetLength(HashDigest, Hash.HashSize div 8);
    strmInput.ReadBuffer(Salt[0], SizeOf(Salt));
    Hash.Init;
    Hash.Update(Salt[0], SizeOf(Salt));
    Hash.UpdateStr(passphrase);
    Hash.Final(HashDigest[0]);

    if (Cipher is TDCP_blockcipher) then
    begin
      SetLength(CipherIV, TDCP_blockcipher(Cipher).BlockSize div 8);
      strmInput.ReadBuffer(CipherIV[0], Length(CipherIV));
      Cipher.Init(HashDigest[0], Min(Cipher.MaxKeySize, Hash.HashSize), @CipherIV[0]);
      TDCP_blockcipher(Cipher).CipherMode := cmCBC;
    end
    else
      Cipher.Init(HashDigest[0], Min(Cipher.MaxKeySize, Hash.HashSize), nil);

    Cipher.DecryptStream(strmInput, strmOutput, strmInput.Size - strmInput.Position);
    Cipher.Burn;
    strmOutput.Position := 0;
    Memo1.Text := strmOutput.DataString;
    strmInput.Free;
    strmOutput.Free;
    ConvertRunning := False;
  except
    strmInput.Free;
    strmOutput.Free;
    ConvertRunning := False;
  end;
end;

procedure TfrmMain.btn_CopyClick(Sender: TObject);
begin
  Memo1.SelectAll;
  Memo1.CopyToClipboard;
end;

procedure TfrmMain.btn_PasteClick(Sender: TObject);
begin
  Memo1.Clear;
  Memo1.PasteFromClipboard;
end;

procedure TfrmMain.cbxCipherChange(Sender: TObject);
var
  Cipher: TDCP_cipher;
  Hash: TDCP_hash;
begin
  Cipher := TDCP_cipher(cbxCipher.Items.Objects[cbxCipher.ItemIndex]);
  Hash := TDCP_hash(cbxHash.Items.Objects[cbxHash.ItemIndex]);
  if (Cipher.MaxKeySize < Hash.HashSize) then
    dblKeySize.Caption := IntToStr(Cipher.MaxKeySize) + ' bits'
  else
    dblKeySize.Caption := IntToStr(Hash.HashSize) + ' bits';
end;

procedure TfrmMain.boxPassphraseChange(Sender: TObject);
begin
  if (Length(boxPassphrase.Text) > 0) then
  begin
    btnEncrypt.Enabled := True;
    btnDecrypt.Enabled := True;
  end
  else
  begin
    btnEncrypt.Enabled := False;
    btnDecrypt.Enabled := False;
  end;
end;

procedure TfrmMain.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.btnDecryptClick(Sender: TObject);
var
  Hash: TDCP_hash;
  Cipher: TDCP_cipher;
begin
  if ConvertRunning then Exit;
  if Trim(Memo1.Text) = '' then Exit;
  if not IsHex(Trim(Memo1.Text)) then Exit;
  ConvertRunning := True;
  Progress.Position := 0;
  Hash := TDCP_hash(cbxHash.Items.Objects[cbxHash.ItemIndex]);
  Cipher := TDCP_cipher(cbxCipher.Items.Objects[cbxCipher.ItemIndex]);
  DoDecryptStringStream(boxPassphrase.Text, Hash, Cipher);
end;

procedure TfrmMain.btnEncryptClick(Sender: TObject);
var
  Hash: TDCP_hash;
  Cipher: TDCP_cipher;
begin
  if ConvertRunning then Exit;
  if Trim(Memo1.Text) = '' then Exit;

  ConvertRunning := True;
  Progress.Position := 0;

  Hash := TDCP_hash(cbxHash.Items.Objects[cbxHash.ItemIndex]);
  Cipher := TDCP_cipher(cbxCipher.Items.Objects[cbxCipher.ItemIndex]);
  DoEncryptStringStream(boxPassphrase.Text, Hash, Cipher);
end;

end.
