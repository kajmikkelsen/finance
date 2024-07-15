unit ubilag;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Grids, ExtCtrls,
  StdCtrls, Buttons, ExtDlgs;

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
    StringGrid1: TStringGrid;
    procedure EDatoExit(Sender: TObject);
    procedure EKontoKeyPress(Sender: TObject; var Key: char);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
  private
    Perioder: array [0..12] of int64;
    Aar: String;
    Procedure SetPerioder;
    Function GetPeriode(Dato:String):Integer;
  public

  end;

var
  Fbilag: TFbilag;

implementation

uses
  MyLib, Global, udm1,uselect,mydbmain;

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
  EDato.Text := LastYMD;
  if not dm1.DiverseExists('AarStart') then
    dm1.PutDiverse('AarStart',LastYMD);
end;

procedure TFbilag.EDatoExit(Sender: TObject);
Var
  per,bilagnr,cifre:Integer;
  St: String;
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
    If per = -1 Then
    begin
       MessageDlg(rsPeriodeFejl, mtError, [mbOK], 0);
      EDato.SetFocus;
    end
    else
    begin
      EPeriode.Text := IntToStr(per);
      EAar.Text := Aar;
      BilagNr := StrToInt(DM1.GetDiverse('BilagNr'))+1;
      Cifre := StrToInt(DM1.GetDiverse('BilagCifre'));
      St := IntToStr(BilagNr);
      While (Length(st) < Cifre) Do
        St := '0'+st;
      EBnummer.Text := St;
//      Dm1.PutDiverse('BilagNr',st);

    end;
  end;

end;

procedure TFbilag.EKontoKeyPress(Sender: TObject; var Key: char);
begin
   KeyPressInt((Sender as TEdit).Text, Key);
end;

procedure TFbilag.FormActivate(Sender: TObject);
Var
  St:String;
begin
  SetPerioder;
  St := IntToStr(Perioder[0]);
  Aar := Copy(st,1,4);
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
Var
  Nummer,Navn: String;
begin
  Nummer := '';
  Navn := '';
  udm1.konto.PrepareSelect;
  FSelect.Caption := rsKontoplan;
  FSelect.Button1.Action := FMain.AVelgKto;
  FSelect.Button1.ModalResult:=mrOK;
  FSelect.Button2.Caption:= rsFortryd;
  FSelect.Button2.ModalResult:=mrCancel;
  FSelect.Button2.Action := nil;
  FSelect.Button3.Visible:=False;
  FSelect.Button4.Visible:=False;
  if FSelect.showModal = mrOK Then
  Begin
    If udm1.konto.GetBogfKtoFromID(Nummer,Navn,SelectedKonto) then
    begin
      ENr.Text := Nummer;
      Edit1.Text:= Navn;
      EKonto.Text := IntToStr(SelectedKonto);
      ETekst.SetFocus;
    end
    else
    begin
       MessageDlg(rsKontofejl, mtError, [mbOK], 0);

    ENr.Text := '';
    Edit1.Text:= '';
    EKonto.Text := ''
    end;
  end
  else
    ShowMessage('None selected');
  FSelect.Button1.ModalResult:=mrNone;
  FSelect.Button2.ModalResult:=mrNone;
  FSelect.Button2.Caption := rsRet;
  FSelect.Button3.Visible:=True;
  FSelect.Button4.Visible:=True;
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
      Perioder[i] := y*10000+m*100+d;
      Memo1.Append(IntToStr(Perioder[i]));
    end;
   End;
end;

function TFbilag.GetPeriode(Dato: String): Integer;
Var
  i,res:Integer;
  Dat:LongInt;
begin
  Res := -1;
  Dat :=  StrToInt(Dato);
  If (Dat >= Perioder[0]) and (Dat < Perioder[12]) Then
  Begin
    For i := 1 to 12 do
      If (Dat >= Perioder[i-1]) and (dat < perioder[i]) Then
      res := i;
  end;
  Result := res;
end;

end.
