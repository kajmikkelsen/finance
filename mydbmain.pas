unit MyDbMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLite3Conn, SQLDB, DB, Forms, Controls, Graphics, Dialogs,
  DBGrids, StdCtrls, Menus, ActnList, LCLTranslator, global, uselect,
  upostnr, ukontoplan;

type

  { TFMain }

  TFMain = class(TForm)
    AAfslut: TAction;
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
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    Separator1: TMenuItem;
    MM1: TMainMenu;
    Memo1: TMemo;
    Memo2: TMemo;
    OD1: TOpenDialog;
    Separator2: TMenuItem;
    procedure AAfslutExecute(Sender: TObject);
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
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private

  public

  end;

var
  FMain: TFMain;


implementation

uses uDM1, MyLib, uFirma, uimport;

  {$R *.lfm}

  { TFMain }

procedure TFMain.FormCreate(Sender: TObject);
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
  RestoreForm(Sender as TForm);
  SetDefaultLang(GetStdIni('Misc', 'Lang', 'da'));
  menuitem1.Caption := rsFiles;
  AImportZip.Caption := rsImportZipCode;
  APostnr.Caption := rsPostDistrikt;
  AAfslut.Caption := rsAfslut;
  APostnrEdit.Caption := rsRet;
  APostnrNy.Caption := rsNy;
  APostnrDel.Caption := rsSlet;
  AFirma.Caption := rsFirmaoplysninger;
  AKonto.Caption := rsKontoplan;
  AKontoNy.Caption := rsNy;
  AImport.Caption := rsImport;
  AKontoEdit.Caption := rsRet;
  AkontoDel.Caption := rsSlet;
end;

procedure TFMain.FormDestroy(Sender: TObject);
begin
  SaveForm(Sender as TForm);
end;

procedure TFMain.AImportZipExecute(Sender: TObject);
var
  fl: TextFile;
  st, st1: string;
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
Var
  st,st1: String;
begin
  ClearForm(FKontoPlan);
  FKontoplan.status := 2;
  FKontoplan.orgkonto := '';
  FKontoplan.orgkonto := DM1.Sqlq1.FieldByName('Nummer').AsString;
  with dm1.sqlq1 do
  begin
    close;
    sql.clear;
    sql.add('select * from konto where Nummer = '+Fkontoplan.orgkonto);
    open;
  end;
  st := DM1.Sqlq1.FieldByName('ID').AsString;
  st1 := DM1.Sqlq1.FieldByName('momssats').AsString;
  showmessage(IntToStr(dm1.SQLQ1.RecordCount));
  fKontoplan.Etyp.itemindex := 1;
  SrcToForm(FKontoPlan, DM1.Sqlq1);
  if uKontoPlan.Fkontoplan.ShowModal = mrOk then
  begin
    dm1.SQLQ1.close;
    dm1.sqlq1.sql.clear;
    st1 := 'select * from konto where ID = '+st;
    dm1.sqlq1.SQL.Add(st1);
    dm1.sqlq1.Open;
    dm1.sqlq1.Edit;
    FormToSrc(FKontoPlan, DM1.Sqlq1);
    dm1.SQLQ1.Post;
    dm1.SQLq1.ApplyUpdates(0);
    dm1.SQLT1.commit;
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
  if MessageDlg('Bekræft', 'Ønsker du at slette ' +
    dm1.SQLQ1.Fields[4].AsString + ' ' + dm1.SQLQ1.Fields[3].AsString,
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
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

procedure TFMain.AFirmaExecute(Sender: TObject);
begin
  FFirma.Caption := rsFirmaoplysninger;
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

procedure TFMain.Button1Click(Sender: TObject);
var
  i: integer;
  sqlst: TStringList;
begin
  dm1.PutDiverse('Kaj','tst');
  with dm1 do
  Begin
  SqlSt := TStringList.Create;
  sqlqx.Close;
  sqlqx.SQL.Clear;
  SqlSt.Add('Select * from misc');
  sqlqx.SQL.Assign(SqlSt);
  sqlqx.Open;
  SqlSt.Free;
  i := DSx.DataSet.RecordCount;
  sqlqx.Close;
  End;
  ShowMessage('her er '+IntToStr(i)+' records');
end;

end.
