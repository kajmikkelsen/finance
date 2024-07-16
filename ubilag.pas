unit ubilag;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Grids, ExtCtrls,
  StdCtrls, Buttons, ExtDlgs, lcltype;

type

  { TFbilag }

  TFbilag = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    CalendarDialog1: TCalendarDialog;
    EDato: TEdit;
    EAar: TEdit;
    Ebnummer: TEdit;
    Ebelob: TEdit;
    Edit1: TEdit;
    EKonto: TEdit;
    ETekst: TEdit;
    ENr: TEdit;
    EPeriode: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Memo1: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    sg1: TStringGrid;
    procedure EbelobKeyPress(Sender: TObject; var Key: char);
    procedure EDatoExit(Sender: TObject);
    procedure EKontoKeyPress(Sender: TObject; var Key: char);
    procedure ENrExit(Sender: TObject);
    procedure ENrKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
  private
    Perioder: array [0..12] of int64;
    Aar: string;
    procedure SetPerioder;
    function GetPeriode(Dato: string): integer;
  public

  end;

var
  Fbilag: TFbilag;

implementation

uses
  MyLib, Global, udm1, uselect;

  {$R *.lfm}

  { TFbilag }

procedure TFbilag.FormCreate(Sender: TObject);
begin
  RestoreForm(Sender as TForm);
  ClearForm(Sender as TForm);
  (Sender as TForm).Caption := rsBilagsregistrering;
  label1.Caption := rsDato;
  Label8.Caption := rsPeriode;
  Label2.Caption := rsAar;
  Label3.Caption := rsBilagsNummer;
  Label4.Caption := rsKonto;
  Label5.Caption := rsKontoNavn;
  Label6.Caption := rsTekst;
  Label7.Caption := rsBelob;
  Button1.Caption := rsOK;
  Button2.Caption := rsFortryd;
  Button3.Caption := rsAfslut;
  sg1.RowCount := 10;
  sg1.AutoSizeColumns;
  Sg1.Columns[0].Title.Caption:= label1.Caption;
  Sg1.Columns[1].Title.Caption := Label8.Caption;
  Sg1.Columns[2].Title.Caption := Label2.Caption;
  Sg1.Columns[3].Title.Caption := Label3.Caption;
  Sg1.Columns[4].Title.Caption := Label4.Caption;
  Sg1.Columns[5].Title.Caption := Label5.Caption;
  Sg1.Columns[6].Title.Caption := Label6.Caption;
  Sg1.Columns[7].Title.Caption := Label7.Caption;
  Sg1.Columns[8].Title.Caption :=  'ID';
  sg1.Columns[8].Visible:=False;
  sg1.AutoSizeColumns;



  EDato.Text := LastYMD;
  if not dm1.DiverseExists('AarStart') then
    dm1.PutDiverse('AarStart', LastYMD);
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
      //      Dm1.PutDiverse('BilagNr',st);

    end;
  end;

end;

procedure TFbilag.EbelobKeyPress(Sender: TObject; var Key: char);
begin
  KeyPressFloat((Sender as tedit).Text, key);
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
  Nummer := Enr.Text;
  if not udm1.konto.GetBogfKtoFromNr(Nummer,{%H-}navn,{%H-}id) then
  begin
    MessageDlg(rsKontofejl, mtError, [mbOK], 0);
    Enr.SetFocus;
  end
  else
  begin
    Edit1.Text := navn;
    ENr.Text := Nummer;
    EKonto.Text := IntToStr(id);
    ETekst.SetFocus;
  end;
end;

procedure TFbilag.ENrKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if Key = VK_F3 then
  begin
    SpeedButton2Click(Sender);
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

//{$hints off}

procedure TFbilag.SpeedButton2Click(Sender: TObject);
var
  Nummer, Navn: string;
begin
  Nummer := '';
  Navn := '';
  udm1.konto.PrepareSelect;
  udm1.Konto.PrepareSelect4Search;
  if FSelect.showModal = mrOk then
  begin
    if udm1.konto.GetBogfKtoFromID(Nummer, Navn, SelectedKonto) then
    begin
      ENr.Text := Nummer;
      Edit1.Text := Navn;
      EKonto.Text := IntToStr(SelectedKonto);
      ETekst.SetFocus;
    end
    else
    begin
      MessageDlg(rsKontofejl, mtError, [mbOK], 0);

      ENr.Text := '';
      Edit1.Text := '';
      EKonto.Text := '';
    end;
  end
  else
    ShowMessage('None selected');
  udm1.Konto.resetPrepSel;
end;

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
    Memo1.Clear;
    Memo1.Append(St);
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
      Memo1.Append(IntToStr(Perioder[i]));
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

end.
