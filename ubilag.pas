{ <description>

  Copyright (C) <year> <name of author> <contact>

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
unit ubilag;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Grids, ExtCtrls,
  StdCtrls, Buttons, ExtDlgs, lcltype, Types;

type

  { TFbilag }

  TFbilag = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    CalendarDialog1: TCalendarDialog;
    EAar: TEdit;
    Ebnummer: TEdit;
    EDato: TEdit;
    Edit1: TEdit;
    EPeriode: TEdit;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label8: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel5: TPanel;
    SpeedButton1: TSpeedButton;
    sg1: TStringGrid;
    Timer1: TTimer;
    procedure EbelobExit(Sender: TObject);
    procedure EbelobKeyPress(Sender: TObject; var Key: char);
    procedure EDatoExit(Sender: TObject);
    procedure EKontoKeyPress(Sender: TObject; var Key: char);
    procedure ENrExit(Sender: TObject);
    procedure ENrKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure sg1DrawCell(Sender: TObject; aCol, aRow: integer;
      aRect: TRect; aState: TGridDrawState);
    procedure sg1EditingDone(Sender: TObject);
    procedure sg1KeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure sg1Resize(Sender: TObject);
    procedure sg1ValidateEntry(Sender: TObject; aCol, aRow: integer;
      const OldValue: string; var NewValue: string);
    procedure SpeedButton1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    Perioder: array [0..12] of int64;
    r, c: integer;
    Aar: string;
    procedure SetPerioder;
    function GetPeriode(Dato: string): integer;
    procedure BeregnTotal;
    procedure GotoCell(col, row: integer);
    procedure setcolwidths;
  public

  end;

var
  Fbilag: TFbilag;

implementation

uses
  MyLib, Global, udm1,  usel;

  {$R *.lfm}

  { TFbilag }

procedure TFbilag.FormCreate(Sender: TObject);
begin
  (Sender as TForm).Caption := rsBilagsregistrering;
  ClearForm(Sender as TForm);
  TransCaption(Sender as TForm, rsStrings);
  Sg1.Columns[0].Title.Caption := rsKonto;
  Sg1.Columns[1].Title.Caption := rsKontoNavn;
  Sg1.Columns[2].Title.Caption := rsDebet;
  Sg1.Columns[3].Title.Caption := rsKredit;
  Sg1.Columns[4].Title.Caption := 'ID';
  sg1.Columns[4].Visible := False;
  sg1.Cells[0, 1] := rsTotal;
  setColWidths;
  EDato.Text := LastYMD;
  if not dm1.DiverseExists('AarStart') then
    dm1.PutDiverse('AarStart', LastYMD);
  RestoreForm(Sender as TForm);
end;

procedure TFbilag.FormDestroy(Sender: TObject);
begin
  SaveForm(Sender as TForm);
end;

procedure TFbilag.sg1DrawCell(Sender: TObject; aCol, aRow: integer;
  aRect: TRect; aState: TGridDrawState);
begin
  if (acol = 7) and (aRow = 1) then
  begin
    Sg1.Canvas.Pen.Color := clRed;
    Sg1.Canvas.Brush.Color := clGreen;
  end;
end;

procedure TFbilag.sg1EditingDone(Sender: TObject);
var
  sg: TStringGrid;
  navn, Nummer: string;
  id: integer;
  belob: double;
begin
  sg := (Sender as tstringGrid);
  if (sg.col = 2) or (sg.col = 3) then
  begin
    if trystrtofloat(sg1.Cells[2, sg.Row], belob) then
    begin
      sg.cells[2, sg1.row] := formatfloat('#########0.00', belob);
      sg.InsertRowWithValues(sg.row+1, ['', '', '', '', '']);
      gotocell(0, sg.row + 1);
    end;
    if trystrtofloat(sg1.Cells[3, sg.Row], belob) then
    begin
      sg.cells[3, sg1.row] := formatfloat('#########0.00', belob);
      sg.InsertRowWithValues(sg.row+1, ['', '', '', '', '']);
      gotocell(0, sg.row + 1);
    end;
    BeregnTotal;
  end;
  if (sg.Col = 0) and (sg.cells[sg.col, sg.row] <> '') then
  begin
    Nummer := sg.cells[sg.col, sg.row];
    if not udm1.konto.GetBogfKtoFromNr(Nummer,{%H-}navn,{%H-}id) then
    begin
      MessageDlg(rsKontofejl, mtError, [mbOK], 0);
      gotocell(sg.col, sg.row);
    end
    else
    begin
      sg.cells[sg.col+1, sg.row] := navn;
      sg.cells[4, sg.row] := IntToStr(id);
      gotocell(sg.col + 2, sg.row);
    end;
  end;
end;

procedure TFbilag.sg1KeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
var
  Nummer, Navn: string;
  sg: TStringGrid;
begin
  sg := (Sender as tstringgrid);
  if sg.Col = 0 then
  begin
    if key = VK_F3 then
    begin
      key := 0;
      Nummer := '';
      Navn := '';
      //      udm1.konto.PrepareSelect;
      udm1.Konto.PrepareSelect4Search;
      if Fvelg.showModal = mrOk then
      begin
        if udm1.konto.GetBogfKtoFromID(Nummer, Navn, SelectedKonto) then
        begin
          Sg.cells[sg.col, sg.row] := Nummer;
          Sg.cells[sg.col + 1, sg.row] := Navn;
          sg.cells[4, sg.row] := IntToStr(SelectedKonto);
          gotocell(sg.col + 2, sg.row);
        end
        else
        begin
          MessageDlg(rsKontofejl, mtError, [mbOK], 0);
          gotocell(sg.col, sg.row);
        end;
      end
      else
      begin
        ShowMessage('None selected');
        gotocell(sg.col, sg.row);
      end;
      //      udm1.Konto.resetPrepSel;
    end;
  end;
end;

procedure TFbilag.sg1Resize(Sender: TObject);
begin
  setcolwidths;
end;

procedure TFbilag.sg1ValidateEntry(Sender: TObject; aCol, aRow: integer;
  const OldValue: string; var NewValue: string);
begin
  if (acol = 1) then
    ShowMessage('Validate cell ' + IntToStr(arow));
end;

procedure TFbilag.EDatoExit(Sender: TObject);
var
  per, bilagnr, cifre: integer;
  St: string;
begin
  LastYMD := NormalizeDate(EDato.Text, LastYMD);
  if not IsYMDValid(LastYMD) then
  begin
    MessageDlg(rsFejlIDato, mtError, [mbOK], 0);
    EDato.SetFocus;
  end
  else
  begin
    PutStdIni('dates', 'LastYMD', LastYMD);
    EDato.Text := LastYMD;
    per := GetPeriode(LastYMD);
    if per = -1 then
    begin
      MessageDlg(rsPeriodeFejl, mtError, [mbOK], 0);
      EDato.SetFocus;
    end
    else
    begin
      EPeriode.Text := IntToStr(per);
      EAar.Text := Aar;
      BilagNr := StrToInt(DM1.GetDiverse('BilagNr')) + 1;
      Cifre := StrToInt(DM1.GetDiverse('BilagCifre'));
      St := IntToStr(BilagNr);
      while (Length(st) < Cifre) do
        St := '0' + st;
      EBnummer.Text := St;
      sg1.SetFocus;
      sg1.Row := 1;
      //      Dm1.PutDiverse('BilagNr',st);

    end;
  end;

end;

procedure TFbilag.EbelobKeyPress(Sender: TObject; var Key: char);
begin
  KeyPressFloat((Sender as tedit).Text, key);
end;

procedure TFbilag.EbelobExit(Sender: TObject);
var
  saldo: double;
  i: integer;
begin

  if MessageDlg(rsLinieTilfoj, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    //     Sg1.InsertRowWithValues(sg1.rowcount,[EDato.text,EPeriode.text,EAar.text,
    //     EBnummer.text,eNr.text,Edit1.text,ETekst.Text,formatfloat('##########.00',StrToFloat(EBelob.Text)),EKonto.text]);
    ;
    //     ENr.SetFocus;
  end;
  Saldo := 0;
  for i := 1 to Pred(sg1.rowcount) do
  begin
    Saldo := Saldo + StrToFloat(Sg1.Cells[7, i]);
  end;
  Saldo := Saldo * -1;
  //   EBelob.Text:=FloatToStr(Saldo);
end;

procedure TFbilag.EKontoKeyPress(Sender: TObject; var Key: char);
begin
  KeyPressInt((Sender as TEdit).Text, Key);
end;

procedure TFbilag.ENrExit(Sender: TObject);
var
  navn, Nummer: string;
  id: integer;
begin
  //  Nummer := Enr.Text;
  if not udm1.konto.GetBogfKtoFromNr(Nummer,{%H-}navn,{%H-}id) then
  begin
    MessageDlg(rsKontofejl, mtError, [mbOK], 0);
    //    Enr.SetFocus;
  end
  else
  begin
    //Edit1.Text := navn;
    //ENr.Text := Nummer;
    //EKonto.Text := IntToStr(id);
    //ETekst.SetFocus;
  end;
end;

procedure TFbilag.ENrKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if Key = VK_F3 then
  begin
    //    SpeedButton2Click(Sender);
    Key := 0;
  end;
end;

procedure TFbilag.FormActivate(Sender: TObject);
var
  St: string;
begin
  SetPerioder;
  St := IntToStr(Perioder[0]);
  Aar := Copy(st, 1, 4);
  sg1.InsertRowWithValues(sg1.RowCount - 1, ['', '', '', '', '']);
  BeregnTotal;
end;

procedure TFbilag.SpeedButton1Click(Sender: TObject);
begin
  Calendardialog1.Date := YMDDate2date(LastYMD);
  //  Calendardialog1.Date := YMDDate2date('20230314');
  if CalendarDialog1.Execute then
  begin
    EDato.Text := Date2YMDst(Calendardialog1.Date);
    EDato.SetFocus;
  end;
end;

procedure TFbilag.Timer1Timer(Sender: TObject);
begin
  sg1.col := c;
  sg1.row := r;
  timer1.Enabled := False;
end;

//{$hints off}

//{$hints on}

procedure TFbilag.SetPerioder;
var
  Y, M, D: int64;
  i: integer;
  St: string;
begin
  begin
    st := dm1.GetDiverse('AarStart');
    y := StrToInt(copy(st, 1, 4));
    m := StrToInt(copy(st, 5, 2));
    d := StrToInt(copy(st, 7, 2));
    Perioder[0] := StrToInt(St);
    for i := 1 to 12 do
    begin
      if m = 12 then
      begin
        Inc(y);
        m := 1;
      end
      else
        Inc(m);
      Perioder[i] := y * 10000 + m * 100 + d;
    end;
  end;
end;

function TFbilag.GetPeriode(Dato: string): integer;
var
  i, res: integer;
  Dat: longint;
begin
  Res := -1;
  Dat := StrToInt(Dato);
  if (Dat >= Perioder[0]) and (Dat < Perioder[12]) then
  begin
    for i := 1 to 12 do
      if (Dat >= Perioder[i - 1]) and (dat < perioder[i]) then
        res := i;
  end;
  Result := res;
end;

procedure TFbilag.BeregnTotal;
var
  i: integer;
  deb, kred, belob: double;
begin
  deb := 0;
  Kred := 0;
  for i := 1 to sg1.RowCount - 2 do
  begin
    if trystrtofloat(sg1.Cells[2, i], belob) then
      deb := deb + belob;
    if trystrtofloat(sg1.Cells[3, i], belob) then
      kred := kred + belob;
  end;
  sg1.cells[2, sg1.rowcount - 1] := formatfloat('#########0.00', deb);
  sg1.cells[3, sg1.rowcount - 1] := formatfloat('#########0.00', kred);
  Edit1.Text := formatfloat('#########0.00', deb - kred);
end;

procedure TFbilag.GotoCell(col, row: integer);
begin
  r := row;
  c := col;
  timer1.Enabled := True;
  ;

end;

procedure TFbilag.setcolwidths;
var
  w: integer;
begin
  w := sg1.ClientWidth;
  sg1.ColWidths[0] := w * 15 div 100;
  sg1.ColWidths[1] := w * 55 div 100;
  sg1.ColWidths[2] := w * 15 div 100;
  sg1.ColWidths[3] := w * 15 div 100;
end;

end.
