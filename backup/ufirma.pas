unit ufirma;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls, MaskEdit, Spin, JvValidateEdit, AnchorDockPanel, SpinEx;

type

  { TFFirma }

  TFFirma = class(TForm)
    Button1: TButton;
    Button2: TButton;
    EMoms1: TEdit;
    EMomsuk5: TEdit;
    Emomsik1: TEdit;
    Emomsik2: TEdit;
    Emomsik3: TEdit;
    Emomsik4: TEdit;
    Emomsik5: TEdit;
    EMoms2: TEdit;
    EMoms3: TEdit;
    EMoms4: TEdit;
    EMoms5: TEdit;
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
    Emomsuk1: TEdit;
    Emomsuk2: TEdit;
    Emomsuk3: TEdit;
    EMomsuk4: TEdit;
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
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    PageControl1: TPageControl;
    Momssats: TTabSheet;
    Panel1: TPanel;
    TS1: TTabSheet;
    procedure Button1Click(Sender: TObject);
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
  Button1.Caption := rsOK;
  Button2.Caption := rsAfbryd;
  with TS1 do
  begin
    Caption := rsFirmanavn;
    Label1.Caption := rsNavn;
    Label2.Caption := rsAdresse;
    Label3.Caption := rsAdresse2;
    Label4.Caption := rsPostnrBy;
    Label5.Caption := rsLand;
    Label6.Caption := rsTlf;
    Label7.Caption := rsMail;
    Label8.Caption := rsBank;
    Label9.Caption := rsBankKonto;
    Label10.Caption := rsCVR;
    Label11.Caption := rsMoms1;
    Label12.Caption := rsMoms2;
    Label13.Caption := rsMoms3;
    Label14.Caption := rsMoms4;
    Label15.Caption := rsMoms5;
    Label16.Caption := rsSats;
    Label17.Caption := rsMomsUd;
    Label18.Caption := rsMomsInd;
  end;
  RestoreForm(FFirma);
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

procedure TFFirma.EFirmaPostnrChange(Sender: TObject);
begin
  Efirmaby.Text := postnr.GetDistFromNr(EFirmaPostnr.Text);
end;

procedure TFFirma.EMoms1KeyPress(Sender: TObject; var Key: char);
begin
  KeyPressFloat((Sender as TEdit).Text,Key);
end;

procedure TFFirma.Emomsuk1KeyPress(Sender: TObject; var Key: char);
begin
  KeyPressInt((Sender as TEdit).Text,Key);
end;

procedure TFFirma.FormDestroy(Sender: TObject);
begin
  SaveForm(FFirma);
end;

procedure TFFirma.TS1Show(Sender: TObject);
begin
  EFirmanavn.SetFocus;
end;

end.
