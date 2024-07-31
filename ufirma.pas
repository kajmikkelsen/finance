unit ufirma;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls, MaskEdit, SpinEx;

type

  { TFFirma }

  TFFirma = class(TForm)
    Button1: TButton;
    Button2: TButton;
    EBilagNr: TEdit;
    EBilagCifre: TEdit;
    EFirmaCVR: TEdit;
    EFirmaBankNavn: TEdit;
    EFirmaKonto: TEdit;
    EFirmaBankReg: TEdit;
    EFirmaMail: TEdit;
    EFirmaTlf: TEdit;
    EFirmaLand: TEdit;
    EFirmaBy: TEdit;
    EFirmaPostnr: TEdit;
    EFirmaAdresse2: TEdit;
    EFirmaAdresse: TEdit;
    EFirmaNavn: TEdit;
    EMoms1: TEdit;
    EMoms2: TEdit;
    EMoms3: TEdit;
    EMoms4: TEdit;
    EMoms5: TEdit;
    Emomsik1: TEdit;
    Emomsik2: TEdit;
    Emomsik3: TEdit;
    Emomsik4: TEdit;
    Emomsik5: TEdit;
    Emomsuk1: TEdit;
    Emomsuk2: TEdit;
    Emomsuk3: TEdit;
    EMomsuk4: TEdit;
    EMomsuk5: TEdit;
    EAarStart: TEdit;
    GB1: TGroupBox;
    GB2: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    PageControl1: TPageControl;
    Finans: TTabSheet;
    Panel1: TPanel;
    TabAarPer: TTabSheet;
    TS1: TTabSheet;
    procedure Button1Click(Sender: TObject);
    procedure EAarStartExit(Sender: TObject);
    procedure EFirmaPostnrChange(Sender: TObject);
    procedure EMoms1KeyPress(Sender: TObject; var Key: char);
    procedure Emomsuk1KeyPress(Sender: TObject; var Key: char);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TS1Show(Sender: TObject);
  private

  public

  end;

var
  FFirma: TFFirma;

implementation

uses
  Global, Udm1, Mylib;

  {$R *.lfm}

  { TFFirma }

procedure TFFirma.FormCreate(Sender: TObject);
begin

  TransCaption(Sender as TForm,rsStrings);
  RestoreForm(Sender as TForm);

end;

procedure TFFirma.FormActivate(Sender: TObject);
var
  i: integer;
  St: string;
begin
  for i := 0 to FFirma.ComponentCount - 1 do
    if FFirma.Components[i] is TEdit then
    begin
      St := FFirma.Components[i].Name;
      Delete(St, 1, 1);
      (FFirma.Components[i] as Tedit).Text := DM1.GetDiverse(st);
      (FFirma.Components[i] as Tedit).AutoSelect := False;
    end;
  If EAarstart.Text = '' Then
  Begin
    EAarstart.text := Date2YMDst(Now);
    EAarstart.Modified := True;
  end;
  if EBilagNr.Text = '' Then
  Begin
     EBilagNr.Text := '0000';
     EBilagNr.Modified := True;
  end;
  if EBilagCifre.Text = '' then
  Begin
    EBilagCifre.Text := '4';
    EBilagCifre.Modified:=True;

  end;
  //    (FFirma.Components[i] as Tedit);

end;

procedure TFFirma.Button1Click(Sender: TObject);
var
  i: integer;
  St: string;
begin
  for i := 0 to FFirma.ComponentCount - 1 do
    if FFirma.Components[i] is TEdit then
    begin
      St := FFirma.Components[i].Name;
      if (FFirma.Components[i] as TEdit).Modified then
      begin
        St := FFirma.Components[i].Name;
        Delete(St, 1, 1);
        DM1.PutDiverse(St, (FFirma.Components[i] as TEdit).Text);
        (FFirma.Components[i] as TEdit).Modified := False;
      end;
    end;
  ModalResult := mrOk;
end;

procedure TFFirma.EAarStartExit(Sender: TObject);
begin
  EAarStart.text := NormalizeDate(EAarStart.text,lastYMD);
  If not IsYMDValid(EAarStart.Text) Then
  begin
     MessageDlg(rsFejlIDato, mtError, [mbOK], 0);
    EAarStart.SetFocus;
  end
  else
  EAarstart.Modified:=True;
end;

procedure TFFirma.EFirmaPostnrChange(Sender: TObject);
begin
  Efirmaby.Text := postnr.GetDistFromNr(EFirmaPostnr.Text);
end;

procedure TFFirma.EMoms1KeyPress(Sender: TObject; var Key: char);
begin
  KeyPressFloat((Sender as TEdit).Text, Key);
end;

procedure TFFirma.Emomsuk1KeyPress(Sender: TObject; var Key: char);
begin
  KeyPressInt((Sender as TEdit).Text, Key);
end;

procedure TFFirma.FormDestroy(Sender: TObject);
begin
  SaveForm(Sender as TForm);
end;

procedure TFFirma.TS1Show(Sender: TObject);
begin
  EFirmanavn.SetFocus;
end;

end.
