unit myinputbox;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls;

type

  { TMyInputBox }

  TMyInputBox = class(TForm)
    Button1: TButton;
    Button2: TButton;
    EInput: TEdit;
    Label1: TLabel;
    Panel1: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private

  public
    Function GetInput(fcap,lcap:String; var editst: String): Boolean;
  end;

var
  FMyInputBox: TMyInputBox;

implementation
uses MyLib,Global;

{$R *.lfm}

{ TMyInputBox }

procedure TMyInputBox.FormCreate(Sender: TObject);
begin
  TransCaption(Sender as TForm,rsStrings);
  RestoreForm(Sender as TForm);
end;

procedure TMyInputBox.FormDestroy(Sender: TObject);
begin
  SaveForm(Sender as TForm);
end;

function TMyInputBox.GetInput(fcap, lcap: String; var editst: String): Boolean;
Var
  St: String;
begin
  FMyInputBox.Caption := FCap;
  Label1.Caption := lcap;
  St := editst;
  EInput.Text := st;
  if FMyInputBox.ShowModal = mrOK Then
  Begin
     EditSt := Einput.Text;
     Result := True;
  end
  else
  begin
    Editst := st;
    Result := False;
  end;
end;

end.

