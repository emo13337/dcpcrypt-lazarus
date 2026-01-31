program EncryptFileUsingThread;

{$MODE Delphi}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Interfaces,
  Forms,
  SysUtils,
  uMain in 'uMain.pas' {frmMain},
  UnitUtilitaires in 'UnitUtilitaires.pas';

{$R *.res}

begin
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
