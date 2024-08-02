
// version 0.0.0.0 added version controll



{ <description>

  Copyright (C) 2024 Kaj Mikkelsen kmi@vgdata.dk

  This source is free software; you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 2 of the License, or (at your option)
  any later version.

  This code is distributed in the hope that it will be useful, but WITHOUT ANY
  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
  details.

  A copy of the GNU General Public License is available on the World Wide Web
  at <http://www.gnu.org/copyleft/gpl.html>. You can also obtain it by writing
  to the Free Software Foundation, Inc., 51 Franklin Street - Fifth Floor,
  Boston, MA 02110-1335, USA.
}

unit MyDbMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLite3Conn, SQLDB, DB, Forms, Controls, Graphics, Dialogs,
  DBGrids, StdCtrls, Menus, ActnList, LCLTranslator, global, uselect,
  upostnr, ukontoplan, ubilag, lclproc, lclType, ComCtrls;

type

  { TFMain }

  TFMain = class(TForm)
    AAfslut: TAction;
    ABilagsreg: TAction;
    AAbout: TAction;
    AVelgKto: TAction;
    ASettings: TAction;
    AKontoDel: TAction;
    Akontoedit: TAction;
    AImport: TAction;
    AKontoNy: TAction;
    AKonto: TAction;
    AFirma: TAction;
    APostnrDel: TAction;
    APostnrNy: TAction;
    APostnrEdit: TAction;
    APostnr: TAction;
    AImportZip: TAction;
    AL1: TActionList;
    Button1: TButton;
    DBGrid1: TDBGrid;
    Edit1: TEdit;
    il1: TImageList;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    OpenDialog1: TOpenDialog;
    Separator3: TMenuItem;
    Separator1: TMenuItem;
    MM1: TMainMenu;
    Memo1: TMemo;
    Memo2: TMemo;
    OD1: TOpenDialog;
    Separator2: TMenuItem;
    SB1: TStatusBar;
    procedure AAboutExecute(Sender: TObject);
    procedure AAfslutExecute(Sender: TObject);
    procedure ABilagsregExecute(Sender: TObject);
    procedure AVelgKtoExecute(Sender: TObject);
    procedure AFirmaExecute(Sender: TObject);
    procedure AImportExecute(Sender: TObject);
    procedure AImportZipExecute(Sender: TObject);
    procedure AkontoeditExecute(Sender: TObject);
    procedure AKontoExecute(Sender: TObject);
    procedure AKontoNyExecute(Sender: TObject);
    procedure AKontoDelExecute(Sender: TObject);
    procedure APostnrDelExecute(Sender: TObject);
    procedure APostnrEditExecute(Sender: TObject);
    procedure APostnrExecute(Sender: TObject);
    procedure APostnrNyExecute(Sender: TObject);
    procedure ASettingsExecute(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Edit1KeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private

  public

  end;

var
  FMain: TFMain;


implementation

uses uDM1, MyLib, uFirma, uimport, usettings, uvelgfirma, LCLIntf, uabout;

  {$R *.lfm}

  { TFMain }

procedure TFMain.FormCreate(Sender: TObject);
var
  i: integer;
begin
  //    SQLiteLibraryName:='./libsqlite3.so';
  SetAllDirs;
  with Memo1.Lines do
  begin
    add(HomeDir);
    add(DatDir);
    add(poDir);
    add(ConfDir);
    add(GetAppConfigFile(False, True));
  end;
  SetDefaultLang(GetStdIni('Misc', 'Lang', 'da'));
  TransCaption(Sender as TForm, rsStrings);
  RestoreForm(Sender as TForm);
  LastYMD := GetStdIni('dates', 'LastYMD', FormatDateTime('YYYYMMDD', Now));
  LastYM := Copy(LastYMD, 1, 6);
  LastY := Copy(LastYMD, 1, 4);
  LastC := Copy(LastYMD, 1, 2);
  ASettings.ShortCut := TextToShortCut(GetStdIni('shortcuts', ASettings.Caption, ''));
  ABilagsreg.ShortCut := TextToShortCut(GetStdIni('shortcuts', ABilagsreg.Caption, ''));
  AImportZip.ShortCut := TextToShortCut(GetStdIni('shortcuts', AImportZip.Caption, ''));
  APostnr.ShortCut := TextToShortCut(GetStdIni('shortcuts', APostnr.Caption, ''));
  AAfslut.ShortCut := TextToShortCut(GetStdIni('shortcuts', AAfslut.Caption, ''));
  AFirma.ShortCut := TextToShortCut(GetStdIni('shortcuts', AFirma.Caption, ''));
  AKonto.ShortCut := TextToShortCut(GetStdIni('shortcuts', AKonto.Caption, ''));
  AImport.ShortCut := TextToShortCut(GetStdIni('shortcuts', AImport.Caption, ''));
  for i := 0 to Pred(RsStrings.Count) do
  begin
    Memo1.Append(RsStrings.ValueFromIndex[i]);
  end;
  Button1.Caption := rsStrings.values['rsImportZipCode'];

end;

procedure TFMain.FormDestroy(Sender: TObject);
begin
  SaveForm(Sender as TForm);
end;

procedure TFMain.AImportZipExecute(Sender: TObject);
var
  fl: TextFile;
  st: string;
  p: PostDistrikt;
begin
  memo1.Clear;
  //  DM1.InitDB(DatDir + 'FinDB.db');
  if OD1.Execute then
  begin
    AssignFile(fl, OD1.FileName);
    Reset(fl);
    while not EOF(fl) do
    begin
      ReadLn(fl, st);
      p.land := GetFieldByDelimiter(0, st, #9);
      p.nummer := GetFieldByDelimiter(1, st, #9);
      p.by := GetFieldByDelimiter(2, st, #9);
      if udm1.postnr.Search(p.nummer) = -1 then
        udm1.postnr.NewDistrict(p);
      Application.ProcessMessages;
      memo1.Lines.Add(p.nummer);
      Application.ProcessMessages;
    end;
  end;
end;

procedure TFMain.AkontoeditExecute(Sender: TObject);
var
  id: integer;
begin
  ClearForm(FKontoPlan);
  FKontoplan.status := 2;
  FKontoplan.orgkonto := '';
  FKontoplan.orgkonto := DM1.Sqlq1.FieldByName('Nummer').AsString;
  id := DM1.Sqlq1.FieldByName('ID').AsInteger;
  SrcToForm(FKontoPlan, DM1.Sqlq1);
  if uKontoPlan.Fkontoplan.ShowModal = mrOk then
  begin
    if ID <> dm1.sqlq1.FieldByName('ID').AsInteger then
    begin
      MessageDlg(rsNoUpdate, mtInformation, [mbOK], 0);
      dm1.sqlq1.Cancel;
    end
    else
    begin
      dm1.sqlq1.Edit;
      FormToSrc(FKontoPlan, DM1.Sqlq1);
      dm1.SQLQ1.Post;
      dm1.SQLq1.ApplyUpdates(0);
      dm1.SQLT1.commit;
    end;
    fselect.dothesql;
  end
  else
    DM1.sqlq1.Cancel;
end;

procedure TFMain.AKontoExecute(Sender: TObject);
begin
  udm1.konto.PrepareSelect;
  FSelect.Caption := rsKontoplan;
  FSelect.showModal;
  //  FKontoplan.ShowModal;
end;

procedure TFMain.AKontoNyExecute(Sender: TObject);
begin
  ClearForm(FKontoPlan);
  FKontoplan.status := 1;
  FKontoplan.orgkonto := '';
  dm1.sqlq1.Append;
  if uKontoPlan.Fkontoplan.ShowModal = mrOk then
  begin
    FormToSrc(FKontoPlan, dm1.sqlq1);
    dm1.SQLQ1.Post;
    dm1.SQLq1.ApplyUpdates(0);
    dm1.SQLT1.commit;
    fselect.dothesql;
  end
  else
    DM1.sqlq1.Cancel;
end;

procedure TFMain.AKontoDelExecute(Sender: TObject);
var
  ID: integer;
begin
  if MessageDlg('Bekræft', 'Ønsker du at slette ' + dm1.SQLQ1.Fields[4].AsString +
    ' ' + dm1.SQLQ1.Fields[3].AsString, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    ID := DM1.SQLQ1.FieldByName('id').AsInteger;
    konto.Delete(ID);
    fselect.dothesql;
  end;

end;

procedure TFMain.APostnrDelExecute(Sender: TObject);
var
  ID: integer;
begin
  if MessageDlg('Bekræft', 'Ønsker du at slette ' + dm1.SQLQ1.Fields[1].AsString +
    ' ' + dm1.SQLQ1.Fields[3].AsString + ' ' + dm1.SQLQ1.Fields[2].AsString,
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    ID := DM1.SQLQ1.FieldByName('id').AsInteger;
    postnr.Delete(ID);
    fselect.dothesql;
  end;

end;

procedure TFMain.AAfslutExecute(Sender: TObject);
begin
  Application.terminate;
end;

procedure TFMain.AAboutExecute(Sender: TObject);
begin
  FAbout.ShowModal;
end;

procedure TFMain.ABilagsregExecute(Sender: TObject);
begin
  FBilag.ShowModal;
end;

procedure TFMain.AVelgKtoExecute(Sender: TObject);
begin
  SelectedKonto := DM1.SQLQ1.FieldByName('id').AsInteger;
end;

procedure TFMain.AFirmaExecute(Sender: TObject);
begin
  //  FFirma.Caption := rsFirmaoplysninger;
  FFirma.ShowModal;
end;

procedure TFMain.AImportExecute(Sender: TObject);
begin
  FImport.ShowModal;
end;

procedure TFMain.APostnrEditExecute(Sender: TObject);
begin
  if upostnr.FPostnrEdit.ShowModal = mrOk then
  begin
    dm1.SQLQ1.Post;
    dm1.SQLq1.ApplyUpdates(0);
    dm1.SQLT1.commit;
    fselect.dothesql;
  end
  else
    dm1.SQLQ1.Cancel;
end;

procedure TFMain.APostnrExecute(Sender: TObject);
begin
  udm1.postnr.PrepareSelect;
  FSelect.Caption := rsPostDistrikt;
  FSelect.showModal;
end;

procedure TFMain.APostnrNyExecute(Sender: TObject);
begin
  dm1.sqlq1.Append;
  if upostnr.FPostnrEdit.ShowModal = mrOk then
  begin
    dm1.SQLQ1.Post;
    dm1.SQLq1.ApplyUpdates(0);
    dm1.SQLT1.commit;
    fselect.dothesql;
  end
  else
    DM1.sqlq1.Cancel;
end;

procedure TFMain.ASettingsExecute(Sender: TObject);
begin
  FSettings.ShowModal;
end;

procedure TFMain.Button1Click(Sender: TObject);
begin
  fvelgfirma.showModal;
  //  if OpenDialog1.Execute then openurl(OpendIalog1.FileName)
end;

procedure TFMain.Edit1KeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if ssCtrl in Shift then ShowMessage('Ctrl was pressed');
  if ssAlt in Shift then ShowMessage('Alt was pressed');
  if (ssCtrl in Shift) and (ssAlt in shift) then ShowMessage('Both was pressed');
  if key = VK_ACCEPT then;

end;

procedure TFMain.FormActivate(Sender: TObject);
var
  st: string;
  w: integer;
begin
  if orgdir = datdir then
    if fvelgfirma.showmodal = mrCancel then
      AAfslut.Execute
    else
    begin
      st := fvelgfirma.LB1.Items[fvelgfirma.lb1.ItemIndex];
      Datdir := datdir + st + '/';
      st := rsFirma + ': ' + st;
      w := sb1.Canvas.GetTextWidth(st);
      sb1.Panels[0].Width := w + 16;
      sb1.Panels[0].Text := st;

      dm1.initdb(DatDir + 'FinDB.db');
    end;
end;

end.
