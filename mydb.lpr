program MyDb;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, anchordockpkg, lazcontrols, datetimectrls, MyDbMain, udm1, MyLib,
  global, usel, uselfields, upostnr, ufirma, Ukontoplan, uimport, ubilag,
  usettings, uvelgfirma, uselect, uDebKar, myinputbox, UAbout, UOSCBox;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TFmain, Fmain);
  Application.CreateForm(TDM1, DM1);
  Application.CreateForm(TfSelect, fselect);
  Application.CreateForm(Tfvelg, fvelg);
  Application.CreateForm(TFSelFields, FSelFields);
  Application.CreateForm(TFPostnrEdit, FPostnrEdit);
  Application.CreateForm(TFFirma, FFirma);
  Application.CreateForm(TFKontoplan, FKontoplan);
  Application.CreateForm(TFImport, FImport);
  Application.CreateForm(TFbilag, Fbilag);
  Application.CreateForm(TFSettings, FSettings);
  Application.CreateForm(TFVelgFirma, FVelgFirma);
  Application.CreateForm(TFDebKar, FDebKar);
  Application.CreateForm(TMyInputBox, FMyInputBox);
  Application.CreateForm(TFAbout, FAbout);
  Application.CreateForm(TFOSCBox, FOSCBox);
  Application.Run;
end.

