unit updateform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, StdCtrls, updater;

type

  { TSimbaUpdateForm }

  TSimbaUpdateForm = class(TForm)
    UpdateLog: TMemo;
    UpdateButton: TButton;
    OkButton: TButton;
    CancelButton: TButton;
    DownloadProgress: TProgressBar;
    procedure CancelButtonClick(Sender: TObject);
    procedure CleanUpdateForm(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
    procedure UpdateButtonClick(Sender: TObject);
    function CanUpdate: Boolean;

  private
    { private declarations }

    Updater: TMMLFileDownloader;
    FCancelling: Boolean;
    FSimbaVersion: Integer;

  private
    function OnUpdateBeat: Boolean;
    function GetLatestSimbaVersion: Integer;
  public
    { public declarations }
    procedure PerformUpdate;
  protected
    FCancelled: Boolean;
  end; 

var
  SimbaUpdateForm: TSimbaUpdateForm;

implementation

uses
  internets,  TestUnit;

function TSimbaUpdateForm.CanUpdate: Boolean;
begin
  GetLatestSimbaVersion;

  Writeln('Latest Simba Version: ' + IntToStr(FSimbaVersion));
  Exit(testunit.SimbaVersion < FSimbaVersion);
end;

function TSimbaUpdateForm.GetLatestSimbaVersion: Integer;
begin
  FSimbaVersion := StrToIntDef(Trim(GetPage('http://old.villavu.com/merlijn/Simba'{$IFDEF WINDOWS} +'.exe'{$ENDIF} + '.version')), -1);
  Exit(FSimbaVersion);
end;

procedure TSimbaUpdateForm.UpdateButtonClick(Sender: TObject);
begin
  Self.PerformUpdate;
end;

procedure TSimbaUpdateForm.CancelButtonClick(Sender: TObject);
begin
  if FCancelled then
  begin
    Self.ModalResult:=mrCancel;
    Self.Hide;
  end else
  begin
    FCancelling := True;
  end;
end;

procedure TSimbaUpdateForm.CleanUpdateForm(Sender: TObject);
begin
  Self.DownloadProgress.Position:=0;
  Self.UpdateLog.Clear;
  Self.UpdateLog.Lines.Add('---------- Update Session ----------');
end;

procedure TSimbaUpdateForm.OkButtonClick(Sender: TObject);
begin
  Self.ModalResult:=mrOK;
  Self.Hide;
end;

{ Return true if we have to cancel }
function TSimbaUpdateForm.OnUpdateBeat: Boolean;
var
  Percentage: Integer;
begin
  Application.ProcessMessages;

  Percentage := Updater.GetPercentage();
  if Percentage <> -1 then
    DownloadProgress.Position:=Percentage;

  Result := FCancelling;
end;

procedure TSimbaUpdateForm.PerformUpdate;
begin
  Updater := TMMLFileDownloader.Create;

  FCancelling := False;
  FCancelled := False;

  // Make this a setting later
  Updater.FileURL := 'http://old.villavu.com/merlijn/Simba'{$IFDEF WINDOWS} +'.exe'{$ENDIF};

  //ApplicationName{$IFDEF WINDOWS} +'.exe'{$ENDIF};

  // Should work on Windows as well
  Updater.ReplacementFile := ExtractFileName(Application.ExeName);
  Updater.OnBeat := @Self.OnUpdateBeat;
  Updater.BasePath := ExtractFilePath(Application.ExeName);

  Self.UpdateLog.Lines.Add('Starting download of ' + Updater.FileURL + ' ...');
  try
    Updater.DownloadAndSave;
    Self.UpdateLog.Lines.Add('Downloaded to ' + Updater.ReplacementFile + '_ ...');
    Updater.Replace;
    Self.UpdateLog.Lines.Add('Renaming ' + Updater.ReplacementFile + ' to ' + Updater.ReplacementFile + '_old_');
    Self.UpdateLog.Lines.Add('Renaming ' + Updater.ReplacementFile + '_ to ' + Updater.ReplacementFile);
    Self.UpdateLog.Lines.Add('Deleting ' + Updater.ReplacementFile + '_old_');
    Updater.Free;
  except
    FCancelling := False;
    FCancelled := True;
    Self.UpdateLog.Lines.Add('Download stopped ...');
    // more detailed info
    writeln('EXCEPTION IN UPDATEFORM: We either hit Cancel, or something went wrong with files');
  end;
  Self.UpdateLog.Lines.Add('Done ... ');
  Self.UpdateLog.Lines.Add('Please restart all currently running Simba binaries.');
end;

initialization
  {$I updateform.lrs}

end.

