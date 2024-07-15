unit Ukontoplan;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, LCLType;

type

  { TFKontoplan }

  TFKontoplan = class(TForm)
    Button1: TButton;
    Button2: TButton;
    ETil: TEdit;
    EFra: TEdit;
    Emomssats: TComboBox;
    Enavn: TEdit;
    ENummer: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Etyp: TRadioGroup;
    Emomstyp: TRadioGroup;
    Panel1: TPanel;
    procedure Button1Click(Sender: TObject);
    procedure EmomstypClick(Sender: TObject);
    procedure ENummerExit(Sender: TObject);
    procedure ENummerKeyPress(Sender: TObject; var Key: char);
    procedure EtypClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    procedure DisEn;
    function FormOK: boolean;
  public
    status: integer; // 1: opret, 2: ret, 3:slet
    orgkonto: string;


  end;

var
  FKontoplan: TFKontoplan;

implementation

uses
  MyLib, udm1, Global;

  {$R *.lfm}

  { TFKontoplan }

procedure TFKontoplan.FormCreate(Sender: TObject);
begin
  RestoreForm(Sender as TForm);
  //  TranslateForm(Sender as TForm);
  Button1.Caption := rsOK;
  Button2.Caption := rsAfbryd;
  Label1.Caption := rsKontonummer;
  Label2.Caption := rsKontotekst;
  Label3.Caption := rsMomssats;
  Label4.Caption := rsFraKonto;
  Label5.Caption := rsTilKonto;
  Etyp.Caption := rsKontotype;
  Etyp.Items[0] := rsBogforing;
  Etyp.Items[1] := rsOverskrift;
  Etyp.Items[2] := rsSammentelling;
  Emomstyp.Caption := rsMoms;
  Emomstyp.Items[0] := rsIngenmoms;
  Emomstyp.Items[1] := rsIndgaaende;
  Emomstyp.Items[2] := rsUdgaaende;

end;

procedure TFKontoplan.FormActivate(Sender: TObject);
begin
  DisEn;
end;

procedure TFKontoplan.EtypClick(Sender: TObject);
begin
  DisEn;
end;

procedure TFKontoplan.EmomstypClick(Sender: TObject);
begin
  DisEn;
end;

procedure TFKontoplan.Button1Click(Sender: TObject);
begin
  if FormOK then
    ModalResult := mrOk;
end;

procedure TFKontoplan.ENummerExit(Sender: TObject);
begin
  if (orgkonto <> enummer.Text) then
    if konto.KontoExists((Sender as TEdit).Text) then
    begin
       MessageDlg(rsKtoFindes, mtError, [mbOK], 0);
    end;
end;

procedure TFKontoplan.ENummerKeyPress(Sender: TObject; var Key: char);
begin
  KeyPressInt((Sender as TEdit).Text, Key);
end;

procedure TFKontoplan.FormDestroy(Sender: TObject);
begin
  SaveForm(Sender as TForm);
end;

procedure TFKontoplan.DisEn;
Var
  i,i1:Integer;
begin
  case ETyp.ItemIndex of
    0: begin
      EMomstyp.Enabled := True;
      EFra.Enabled := False;
      ETil.Enabled := False;
    end;
    1: begin
      EMomstyp.Enabled := False;
      EMomssats.Enabled := False;
      ;
      EFra.Enabled := False;
      ETil.Enabled := False;
    end;
    2: begin
      EMomstyp.Enabled := False;
      EMomssats.Enabled := False;
      ;
      EFra.Enabled := True;
      ETil.Enabled := True;
    end;
  end;
  if EMomsTyp.ItemIndex > 0 then
    EMomssats.Enabled := True
  else
    EMomssats.Enabled := False;
  i1 := EMomssats.Itemindex;
  Emomssats.Clear;
  EMomssats.Items.Add(FloatToStrf(0,ffFixed,4,2));
//  EMomssats.Text := FloatToStrf(0,ffFixed,4,2);
  For i := 1 to 5 do
  begin
    EMomssats.Items.Add(dm1.Momssatser[i]);
  end;
  EMomssats.Itemindex := i1;
end;

function TFKontoplan.FormOK: boolean;
var
  ok: boolean;
begin
  ok := True;
  if ENummer.Text = '' then
  begin
    MessageDlg(rsKontoTom, mtError, [mbOK], 0);
    ENummer.SetFocus;
    ok := ok and False;
  end;
  if Enavn.Text = '' then
  begin
    MessageDlg(rsNavnTom, mtError, [mbOK], 0);
    ENavn.SetFocus;
    ok := ok and False;
  end;
  if ETyp.ItemIndex = 2 then
  begin
    ok := ok and ((EFra.Text <> '') and (Etil.Text <> ''));
  end;
  Result := ok;
end;

end.
