unit usettings;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  StdCtrls, ValEdit;

type

  { TFSettings }

  TFSettings = class(TForm)
    Button1: TButton;
    Button2: TButton;
    CB1: TCheckBox;
    CB2: TCheckBox;
    CB3: TCheckBox;
    CMB1: TComboBox;
    Edit1: TEdit;
    rsStdmapper: TGroupBox;
    PageControl1: TPageControl;
    Panel1: TPanel;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    VLE1: TValueListEditor;
    procedure Button1Click(Sender: TObject);
    procedure CB1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure VLE1Selection(Sender: TObject; aCol, aRow: integer);
  private
    selrow: integer;
    function MakeString: string;
  public

  end;

var
  FSettings: TFSettings;

implementation

{$R *.lfm}

uses
  MyLib, MyDBMain, ActnList, lclproc, Global;

  { TFSettings }

procedure TFSettings.FormCreate(Sender: TObject);
var
  i: integer;
begin
  TransCaption(Sender as TForm,rsStrings);
  RestoreForm(Sender as TForm);
  VLE1.Clear;
  with VLE1.TitleCaptions do
  begin
    Clear;
    append(rsMenupunkt);
    Append(rsShortcut);
  end;
  for i := 0 to pred(FMain.ComponentCount) do
  begin
    if Fmain.Components[i] is taction then
      if (Fmain.Components[i] as taction).Tag = 0 then
        vle1.Strings.Append((fmain.Components[i] as TAction).Caption +
          '=' + ShortCutToText((fmain.Components[i] as TAction).ShortCut));
  end;
  Selrow := 1;
end;

procedure TFSettings.CB1Change(Sender: TObject);
begin
  Vle1.Values[vle1.Keys[SelRow]] := MakeString;
end;

procedure TFSettings.Button1Click(Sender: TObject);
var
  i, i1: integer;
begin
  for i := 1 to Pred(VLE1.RowCount) do
  begin
    for i1 := 0 to pred(FMain.ComponentCount) do
    begin
      if Fmain.Components[i1] is taction then
        if (Fmain.Components[i1] as taction).Caption = vle1.Keys[i] then
        begin
          (Fmain.Components[i1] as taction).ShortCut :=
            TextToShortcut(Vle1.Values[vle1.Keys[i]]);
          PutStdIni('shortcuts', vle1.Keys[i], Vle1.Values[vle1.Keys[i]]);
        end;
    end;
  end;

end;

procedure TFSettings.FormDestroy(Sender: TObject);
begin
  SaveForm(Sender as TForm);
end;

procedure TFSettings.VLE1Selection(Sender: TObject; aCol, aRow: integer);
var
  st, st1: string;
begin
  SelRow := aRow;
  St := vle1.Values[vle1.Keys[arow]];
  CB1.Checked := pos('Ctrl+', st) > 0;
  CB2.Checked := pos('Alt+', st) > 0;
  CB3.Checked := pos('Shift+', st) > 0;
  st1 := RightMostCh('+', st);
  cmb1.Text := St1;
  cmb1.ItemIndex := cmb1.Items.IndexOf(st1);
  Vle1.Values[vle1.Keys[SelRow]] := MakeString;
  //  cmb1.ItemIndex:=0;
end;

function TFSettings.MakeString: string;
var
  St: string;
begin
  St := '';
  if CB1.Checked then St := 'Ctrl+';
  if CB2.Checked then St := St + 'Alt+';
  if CB3.Checked then St := St + 'Shift+';
  if length(st) > 0 then
    St := St + Cmb1.Text
  else
    Cmb1.ItemIndex := 0;
  Result := St;
end;

end.
