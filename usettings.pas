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
    eDatdir: TEdit;
    eConfdir: TEdit;
    eConvertPDF: TEdit;
    eHomedir: TEdit;
    eUserDir: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
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
    DefaultVal: TStringList;
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
  e:TEdit;
  st,st1:String;
begin
  DefaultVal := TStringList.Create;
  With DefaultVal Do
  Begin
    Add('eDatDir='+Datdir);
    Add('eConfdir='+ConfDir);
    Add('eHomedir='+homeDir);
    Add('eUserdir='+UserDir);
    Add('eConvertPDF=convert -thumbnail x300 -background white -alpha remove %s[0] %d');
  end;
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
  for i := 0 to Pred(FSettings.ComponentCount) do
  begin
    if FSettings.Components[i] is tedit then
      Begin
          e:=(FSettings.Components[i] as tedit);
          st := copy(e.Name, 2, length(e.Name) - 1);
          st1 := copy(e.Name, 2, length(e.Name) - 1);
       e.Text := GetStdIni('Options',copy(e.Name, 2, length(e.Name) - 1),DefaultVal.values[e.Name]);
      end;

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
  e: TEdit;
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
  for i := 0 to Pred(FSettings.ComponentCount) do
  begin
    if Fsettings.Components[i] is TEdit Then
    begin
      e := FSettings.Components[i] as TEdit;
      PutStdIni('Options',e.name,e.Text);
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
  DefaultVal.Free;
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
