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
  global, uselect, uselfields, upostnr, ufirma, Ukontoplan, uimport, ubilag,
  usettings;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TFmain, Fmain);
  Application.CreateForm(TDM1, DM1);
  Application.CreateForm(TFSelect, FSelect);
  Application.CreateForm(TFSelFields, FSelFields);
  Application.CreateForm(TFPostnrEdit, FPostnrEdit);
  Application.CreateForm(TFFirma, FFirma);
  Application.CreateForm(TFKontoplan, FKontoplan);
  Application.CreateForm(TFImport, FImport);
  Application.CreateForm(TFbilag, Fbilag);
  Application.CreateForm(TFSettings, FSettings);
  Application.Run;
end.

