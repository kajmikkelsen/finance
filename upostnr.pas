unit upostnr;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, DBCtrls,
  ExtCtrls, global;

type

  { TFPostnrEdit }

  TFPostnrEdit = class(TForm)
    Button1: TButton;
    Button2: TButton;
    DBEdit1: TDBEdit;
    DBEdit2: TDBEdit;
    DBEdit3: TDBEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Panel1: TPanel;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
  public

  end;

var
  FPostnrEdit: TFPostnrEdit;

implementation
uses
  mylib;
{$R *.lfm}

{ TFPostnrEdit }

procedure TFPostnrEdit.FormShow(Sender: TObject);
Var
  i: Integer;
begin
  DBEDIT1.DataField:='landekode';
  DbEdit2.DataField := 'postnummer';
  DbEdit3.DataField:='postdistrikt';
  Button1.Caption := rsOK;
  Button2.Caption := rsAfbryd;
  Label1.Caption:= rsLand;
  Label2.Caption := rsPostNummer;
  Label3.Caption := rsPostDistrikt;
  DBEdit1.AnchorSide[akLeft].side := asrRight;
  DBEdit2.AnchorSide[akLeft].side := asrRight;
  DBEdit3.AnchorSide[akLeft].side := asrRight;
  DBEdit1.AnchorSide[akRight].side := asrLeft;
  DBEdit2.AnchorSide[akRight].side := asrLeft;
  DBEdit3.AnchorSide[akRight].side := asrLeft;
  i := 1;
  If Label2.Width > Label1.Width Then
  i  := 2;
  if (i = 2) and (Label3.Width > Label2.Width) Then
  i := 3;
  if (i=1) and (Label3.Width > Label1.Width) then
  i := 3;
  Case i of
  1: DBEdit1.AnchorSide[akLeft].Control := Label1;
  2: DBEdit1.AnchorSide[akLeft].Control := Label2;
  3: DBEdit1.AnchorSide[akLeft].Control := Label3;
  end;
  DBEdit2.AnchorSide[akLeft].Control := DBEdit1.AnchorSide[akLeft].Control;
  DBEdit3.AnchorSide[akLeft].Control := DBEdit1.AnchorSide[akLeft].Control;
  DBEdit1.AnchorSide[akRight].Control := button1;
  DBEdit2.AnchorSide[akRight].Control := button1;
  DBEdit3.AnchorSide[akRight].Control := button1;
end;

procedure TFPostnrEdit.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Saveform(FpostNrEdit);
end;

procedure TFPostnrEdit.FormCreate(Sender: TObject);
begin
  RestoreForm(FPostNrEdit);
end;

end.

