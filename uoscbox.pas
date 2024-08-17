unit UOSCBox;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls;

type

  { TFOSCBox }

  TFOSCBox = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Image1: TImage;
    Panel1: TPanel;
    Panel2: TPanel;
    procedure Button2Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private

  public
    Filename, thumb: string;
  end;

var
  FOSCBox: TFOSCBox;

implementation

uses
  MyLib, Global, LCLIntf;

  {$R *.lfm}

  { TFOSCBox }

procedure TFOSCBox.FormCreate(Sender: TObject);
begin
  TransCaption(Sender as TForm, rsStrings);
  RestoreForm(Sender as TForm);

end;

procedure TFOSCBox.FormActivate(Sender: TObject);
begin
  image1.Picture.LoadFromFile(thumb);
end;

procedure TFOSCBox.Button2Click(Sender: TObject);
begin
  OpenDocument(FileName);
end;

procedure TFOSCBox.FormDestroy(Sender: TObject);
begin
  SaveForm(Sender as TForm);
end;

end.
