{ FloatingNote is a "yellow stickie" application

  Copyright (C) 2023 Kaj Mikkelsen float@vgdata.dk

  This source is free software; you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 2 of the License, or (at your option)
  any later version.

  This code is distributed in the hope that it will be useful, but WITHOUT ANY
  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
  details.

  A copy of the GNU General Public License is available on the World Wide Web
  at <http://www.gnu.org/copyleft/gpl.html>. You can also obtain it by writing
  to the Free Software Foundation, Inc., 51 Franklin Street - Fifth Floor,
  Boston, MA 02110-1335, USA.
}
unit UAbout;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls, lclintf, MyLib;

type

  { TFAbout }

  TFAbout = class(TForm)
    Button1: TButton;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Memo1: TMemo;
    PageControl1: TPageControl;
    Panel1: TPanel;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Label1Click(Sender: TObject);
  private

  public

  end;

var
  FAbout: TFAbout;

implementation
  uses
    Global;
{$R *.lfm}

{ TFAbout }

procedure TFAbout.Label1Click(Sender: TObject);
begin
  OpenURL('https://www.flaticon.com/free-icons/message');
end;

procedure TFAbout.FormCreate(Sender: TObject);
begin
  TransCaption(Sender as TForm,rsStrings);
  RestoreForm(Sender as TForm);
  Label2.Caption := VersInfo('FileVersion');

end;

procedure TFAbout.FormDestroy(Sender: TObject);
begin
  SaveForm(Sender as TForm);
end;

procedure TFAbout.Button1Click(Sender: TObject);
begin
  ModalResult := mrOK;
end;

end.
