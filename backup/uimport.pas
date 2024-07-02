unit uimport;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls;

type

  { TFImport }

  TFImport = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lb1: TListBox;
    lb2: TListBox;
    Memo1: TMemo;
    OD1: TOpenDialog;
    Panel1: TPanel;
    procedure Button1Click(Sender: TObject);
    procedure Edit1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lb1Click(Sender: TObject);
  private
    FlNM, tblnm: string;
    ImpFields: TStringList;
    procedure getFields(Table: string; MyFields: TStringList; OnlyFields: boolean);
    procedure DoTheImport;
    function CheckParms: boolean;
  public

  end;

var
  FImport: TFImport;

implementation

uses
  Mylib, Global, udm1;

  {$R *.lfm}

  { TFImport }

procedure TFImport.FormCreate(Sender: TObject);
begin
  RestoreForm(Sender as TForm);
  FImport.Caption := rsImport;
  Button1.Caption := rsOpen;
  Button2.Caption := rsAfslut;
  Label1.Caption := rsFields;
  Label2.Caption := rsTables;
  Label3.Caption := rsFil;
  ImpFields := TStringList.Create;
end;

procedure TFImport.Edit1Click(Sender: TObject);
begin
  if OD1.Execute then edit1.Text := od1.FileName;
end;

procedure TFImport.Button1Click(Sender: TObject);
begin
  if CheckParms then
    ShowMessage('We are good')
  else
    ShowMessage('Errors are found');
end;

procedure TFImport.FormActivate(Sender: TObject);
begin
  lb1.Clear;
  with DM1.sqlq1 do
  begin
    Close;
    SQL.Clear;
    sql.Add('select * from sqlite_master where type=''table'' and name not like ''sqlite%''');
    Open;
    First;
    while not EOF do
    begin
      lb1.Items.Add(FieldByName('name').AsString);
      Next;
    end;
  end;
  if OD1.Execute then
  begin
    edit1.Text := od1.FileName;
    if CheckParms then
    begin
      if MessageDlg(rsImpWarn, mtWarning, [mbCancel, mbOK], 0) = mrOk then
        DoTheImport;
    end
    else
      ShowMessage(rsNoImport);
  end;

end;

procedure TFImport.FormDestroy(Sender: TObject);
begin
  SaveForm(Sender as TForm);
  ImpFields.Free;
end;

procedure TFImport.lb1Click(Sender: TObject);
var
  st: string;
  StList: TStringList;
begin
  stList := TStringList.Create;
  st := lb1.GetSelectedText;
  getFields(st, StList, False);
  LB2.items.Assign(stList);
  stList.Free;
end;

procedure TFImport.getFields(Table: string; MyFields: TStringList; OnlyFields: boolean);
var
  st: string;
begin
  lb2.Clear;
  st := '''' + Table + '''';
  if OnlyFields then
    st := 'SELECT name FROM PRAGMA_TABLE_INFO(' + st + ')'
  else
    st := 'SELECT name,type FROM PRAGMA_TABLE_INFO(' + st + ')';
  with DM1.SQLQ1 do
  begin
    Close;
    sql.Clear;
    sql.Add(st);
    Open;
    First;
    while not EOF do
    begin
      if OnlyFields then
        st := FieldByName('name').AsString
      else
        st := FieldByName('name').AsString + ' ; ' + FieldByName('type').AsString;
      MyFields.add(st);
      Next;
    end;
  end;

end;

procedure TFImport.DoTheImport;
var
  InsertSQL: TStringList;
  fl: TextFile;
  i: integer;
  St, st1, st2: string;
begin
      with DM1 do
    begin
      Sqlq1.Close;
      SQLQ1.sql.clear;
      sqlq1.SQL.Add('delete from '+tblnm);
      SqlQ1.ExecSQL;
      SqlT1.Commit;
      SqlQ1.Close;
    end;

  InsertSQL := TStringList.Create;
  Assignfile(fl, OD1.FileName);
  Reset(fl);
  Readln(Fl);
  ReadLn(fl);
  St := 'Insert into ' + tblnm + ' (';
  for i := 0 to pred(ImpFields.Count) do
  begin
    st := st + ImpFields[i];
    if i < pred(ImpFields.Count) then
      st := st + ','
    else
      st := st + ')';
  end;

  while not EOF(fl) do
  begin
    Readln(fl, st1);
    InsertSQL.Clear;
    InsertSQL.Add(st);
    st2 := ' VALUES (''';
    for i := 0 to pred(ImpFields.Count) do
    begin
      St2 := St2 + GetFieldByDelimiter(i, st1, ';');
      if i < pred(ImpFields.Count) then
        st2 := st2 + '''' + ','''
      else
        st2 := St2 + ''')';
    end;
    InsertSQL.Add(st2);
    with DM1 do
    begin
      Sqlq1.Close;
      SQLQ1.sql.Assign(InsertSQL);
      SqlQ1.ExecSQL;
      SqlT1.Commit;
      SqlQ1.Close;
    end;
    memo1.Lines.Add(St);
    Memo1.Lines.Add(st2);
  end;
  InsertSQL.Free;

end;

function TFImport.CheckParms: boolean;
var
  fl: Textfile;
  St, st1: string;
  i, i1: integer;
  FieldsInBase: TStringList;
  error, slut: boolean;
begin
  error := False;
  if Edit1.Text = '' then
  begin
    MessageDlg(rsIntetFilNavn, mtError, [mbOK], 0);
    Error := True;
  end
  else
  begin
    FlNm := OD1.FileName;
    ImpFields.Clear;
    FieldsInBase := TStringList.Create;
    FieldsInBase.Sorted := True;
    memo1.Clear;
    try
      Assignfile(fl, OD1.FileName);
      Reset(fl);
      Readln(fl, st);
      if lb1.items.IndexOf(st) = -1 then
      begin
        MessageDlg(rsFirsttLineError, mtError, [mbOK], 0);
        CloseFile(fl);
        error := True;
      end
      else
      begin
        tblnm := St;
        Readln(fl, st1);
        CloseFile(fl);
        ImpFields.delimiter := ';';
        ImpFields.StrictDelimiter := True;
        ImpFields.delimitedText := st1;
        memo1.Lines.Assign(ImpFields);
        GetFields(st, FieldsInBase, True);
        slut := False;
        error := False;
        for i := 0 to pred(ImpFields.Count) do
        begin
          if not Slut then
          begin
            if not FieldsInBase.Find(ImpFields[i], i1) then
            begin
              if MessageDlg(rsFeltIkkeFundet + ImpFields[i], mtError,
                [mbOK, mbCancel], 0) = mrCancel then
                Slut := True;
              error := True;
            end;
          end;
        end;
        ShowMessage('der er ' + IntToStr(ImpFields.Count));
      end;
    except
      Memo1.Append(rsAabnErr + od1.filename);
    end;
    FieldsInBase.Free;
  end;
  Result := not Error;
end;

end.
