unit usel;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, DBGrids, StdCtrls,
  Menus, ActnList, DBCtrls, ExtCtrls, LR_PGrid, LR_Class, uselfields, lcltype;

type

  { Tfvelg }

  Tfvelg = class(TForm)
    APrint: TAction;
    ASelectFields: TAction;
    ActionList1: TActionList;
    Button1: TButton;
    Button2: TButton;
    dbg1: TDBGrid;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    Panel1: TPanel;
    PG1: TFrPrintGrid;
    MenuItem1: TMenuItem;
    PopupMenu1: TPopupMenu;
    procedure APrintExecute(Sender: TObject);
    procedure ASelectFieldsExecute(Sender: TObject);
    procedure dbg1DblClick(Sender: TObject);
    procedure dbg1KeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure dbg1TitleClick(Column: TColumn);
    procedure Edit1Change(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private
    procedure SaveGrid;
  public
    procedure dothesql;
  var
    tblnm, DefFields: string;
  end;

var
  fvelg: Tfvelg;

implementation

uses
  MyLib, udm1, global, Mydbmain;

  {$R *.lfm}

  { Tfvelg }

procedure Tfvelg.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  SaveForm(fvelg);
  SaveGrid;
end;

procedure Tfvelg.dbg1TitleClick(Column: TColumn);
var
  st: string;
begin
  savegrid;
  PutStdIni('Sort', tblnm, Column.fieldname);
  Label1.Caption := Column.fieldname;
  St := GetStdIni('Sortorder', tblnm, '');
  if st = 'ASC' then
  begin
    putStdIni('Sortorder', tblnm, 'DESC');
  end
  else
    putStdIni('Sortorder', tblnm, 'ASC');
  DoTheSQL;

end;

procedure Tfvelg.Edit1Change(Sender: TObject);
begin
  DoTheSQL;
end;

procedure Tfvelg.FormActivate(Sender: TObject);
begin
  DoTheSQL;
  TransCaption(Sender as TForm, rsStrings);
  RestoreForm(fvelg);

end;

procedure Tfvelg.ASelectFieldsExecute(Sender: TObject);
var
  i: integer;
  st: string;
  fields: TStringList;
begin
  Fields := TStringList.Create;
  FSelfields.clb1.Clear;
  for i := 0 to DataDicst.Count - 1 do
  begin
    st := getfieldbydelimiter(0, DataDicSt[i], ',');
    if st = tblnm then
    begin
      St := getfieldbydelimiter(1, DataDicSt[i], ',');
      Fields.Add(St);
      FSelFields.clb1.items.add(SelHeaders.Values[st]);
      if pos(st, deffields) > 0 then
        FSelfields.CLB1.Checked[fselfields.clb1.items.Count - 1] := True
      else
        FSelfields.CLB1.Checked[fselfields.clb1.items.Count - 1] := False;

    end;
  end;
  if FselFields.ShowModal = mrOk then
  begin
    DefFields := '';
    for i := 0 to FSelFields.clb1.Count - 1 do
      if FselFields.clb1.Checked[i] then
      begin
        if DefFields <> '' then DefFields := DefFields + ',';
        //        DefFields := DefFields + FselFields.clb1.items[i];
        DefFields := DefFields + Fields[i];
      end;
    PutStdIni('BrowseFields', tblnm, DefFields);
    DoTheSQL;
  end;
  Fields.Free;
end;

procedure Tfvelg.dbg1DblClick(Sender: TObject);
begin
  if button1.Action = FMain.AVelgKto then
  begin
    Button1.Action.Execute;
    ModalResult := mrOk;
  end
  else
    Button2.Action.Execute;
end;

procedure Tfvelg.dbg1KeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if key = vk_return then
  begin
    button1.Click;
    //      ModalResult := mrOk;
  end;
  if key = vk_escape then
  begin
    button2.Click;
  end;
end;

procedure Tfvelg.APrintExecute(Sender: TObject);
begin
  pg1.PreviewReport;

end;

procedure Tfvelg.dothesql;
var
  st, st1, st2, st3, st4, tmpst: string;
  i: integer;
begin
  St := GetStdIni('BrowseFields', tblnm, DefFields);
  DefFields := st;
  St1 := GetStdIni('Sort', tblnm, '');
  St2 := GetStdIni('Sortorder', tblnm, '');
  St3 := GetStdIni('ColWidth', tblnm, '');
  if St2 <> '' then
    label1.Caption := St1
  else
    label1.Caption := getfieldbydelimiter(0, DefFields, ',');
  DBG1.DataSource := DM1.DS1;
  with DM1 do
  begin
    SQLQ1.Close;
    SQLQ1.sql.Clear;
    SQLQ1.SQL.add('Select  * from ' + tblnm);
    if edit1.Text <> '' then
    begin
      tmpst := ' WHERE ' + label1.Caption + ' LIKE ''%' + edit1.Text + '%''';
      sqlq1.sql.add(tmpst);
    end;
    if St1 <> '' then
    begin

      if (St2 = 'ASC') or (st2 = 'DESC') then
        St4 := st1 + ' ' + st2;
      sqlq1.sql.Add(' ORDER BY ' + st4);
    end;
    try
      SQLQ1.Open;
      dbg1.Columns.Clear;
      for i := 0 to st.CountChar(',') do
      begin
        dbg1.Columns.Add;
        tmpst := GetFieldByDelimiter(i, st, ',');
        dbg1.columns[i].fieldname := tmpst;
        dbg1.columns[i].Title.Caption := SelHeaders.Values[tmpst];
        if tmpst = st1 then
        begin
          if st2 = 'ASC' then
            dbg1.Columns[i].Title.Caption :=
              DBG1.Columns[i].Title.Caption + ' ▲'
          else
            dbg1.Columns[i].Title.Caption :=
              DBG1.Columns[i].Title.Caption + ' ▼';
        end;

      end;
    except
    end;
  end;
  for i := 0 to DBG1.Columns.Count - 1 do
  begin
    st := GetFieldByDelimiter(i, st3, ',');
    if St <> '' then
      DBG1.Columns[i].Width := StrToInt(St);
  end;
end;

procedure Tfvelg.SaveGrid;
var
  i: integer;
  st, st1: string;
begin
  st := '';
  st1 := '';
  for i := 0 to DBG1.Columns.Count - 1 do
  begin
    if st <> '' then
    begin
      St := st + ',';
      St1 := St1 + ',';
    end;
    St := st + DBG1.Columns[i].fieldname;
    deffields := st;
    St1 := St1 + IntToStr(DBG1.Columns[i].Width);
  end;
  PutStdIni('BrowseFields', tblnm, st);
  PutStdIni('ColWidth', tblnm, st1);

end;

end.
