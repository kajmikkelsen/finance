unit uselfields;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, CheckLst, StdCtrls,
  ExtCtrls;

type

  { TFSelFields }

  TFSelFields = class(TForm)
    Button1: TButton;
    Button2: TButton;
    CLB1: TCheckListBox;
    Panel1: TPanel;
    procedure CLB1DblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private

  public

  end;

var
  FSelFields: TFSelFields;

implementation

uses
  Global, MyLib;

  {$R *.lfm}

  { TFSelFields }

procedure TFSelFields.FormCreate(Sender: TObject);
begin
  TransCaption(Sender as TForm, rsStrings);
  RestoreForm(Sender as TForm);
end;

procedure TFSelFields.CLB1DblClick(Sender: TObject);
begin
  ShowMessage(IntToStr(clb1.ItemIndex));
end;

procedure TFSelFields.FormDestroy(Sender: TObject);
begin
  SaveForm(Sender as TForm);
end;

end.
