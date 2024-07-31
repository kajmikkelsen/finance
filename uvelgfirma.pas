unit uvelgfirma;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls;

type

  { TFVelgFirma }

  TFVelgFirma = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    LB1: TListBox;
    Panel1: TPanel;
    Panel2: TPanel;
    procedure Button3Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    procedure PopulateLb;
    function CreateDirectory: string;
  public

  end;

var
  FVelgFirma: TFVelgFirma;

implementation

uses
  global, mylib, fileutil,MyInputBox;

  {$R *.lfm}

  { TFVelgFirma }

procedure TFVelgFirma.FormCreate(Sender: TObject);
begin
  TransCaption(Sender as TForm, rsStrings);
  RestoreForm(Sender as TForm);
end;

procedure TFVelgFirma.FormDestroy(Sender: TObject);
begin
  SaveForm(Sender as TForm);
end;

procedure TFVelgFirma.PopulateLb;
var
  i: integer;
begin
  lb1.Items.Clear;
  FindAllDirectories(LB1.Items, DatDir, False, ';');
  for i := 0 to Pred(lb1.Items.Count) do
  begin
    lb1.items[i] := RightMostCh('/', lb1.items[i]);
  end;
  if LB1.Items.Count > 0 then
  begin
    Lb1.ItemIndex := 0;
    Button1.Enabled := True;
  end;

end;

function TFVelgFirma.CreateDirectory: string;
var
  st: string;
begin
  St := '';
  if FMyInputBox.GetInput(rsDanNytFirma, rsFirmanavn, St) then
    Result := st
  else
    Result := '';
end;

procedure TFVelgFirma.Button3Click(Sender: TObject);
var
  st: string;
begin
  st := CreateDirectory;
  if St <> '' then
    if createdir(Datdir + St) then
      PopulateLb
    else
      MessageDlg(rsNoFirm, mtError, [mbOK], 0);

end;

procedure TFVelgFirma.FormActivate(Sender: TObject);
begin
  PopulateLb;

end;

end.
