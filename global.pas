unit global;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  PostDistrikt = record
    land, nummer, by: string;
  end;

  FinKonto = record
    nummer, Navn, frakto, tilkto: string;
    Typ: integer;
  end;

var
  datadicst, SelHeaders: TStringList;
  lastYMD, lastYM, LastY, LastC: string;
  SelectedKonto: Integer;
  rsStrings: TStringList;

resourcestring
  rsImportZipCode = 'Importer postnummer';
  rsOpenFile = ' åbn fil ';
  rsFiles = 'Kartoteker';
  rsOpen = 'åbn';
  rsPostDistrikt = 'Postdistrikt';
  rsAfbryd = 'Afbryd';
  rsOK = 'OK';
  rsFortryd = 'Fortryd';
  rsSelFields = 'Vælg felter';
  rsAfslut = 'Afslut';
  rsRet = 'Ret';
  rsNy = 'Ny';
  rsSlet = 'Slet';
  rsLand = 'Land';
  rsPostNummer = 'Postnummer';
  rsColname = 'Kolonnenavn';
  rsColType = 'Kolonnetype';
  rsKonto = 'Konto';
  rsTyp = 'Type';
  rsMomssats = 'Momssats';
  rsFirmaoplysninger = 'Firmaoplysninger';
  rsFirmanavn = 'Firmanavn';
  rsNavn = 'Navn';
  rsAdresse = 'Adresse';
  rsAdresse2 = 'Adresse 2';
  rsPostnrBy = 'Postnr By';
  rsTlf = 'Tlf';
  rsMail = 'Mail';
  rsBank = 'Bank';
  rsBankKonto = 'Konto';
  rsCVR = 'CVR';
  rsFinansKonto = 'Konto';
  rsKontoplan = 'Kontoplan';
  rsKontonummer = 'Kontonummer';
  rsKontotekst = 'Kontotekst';
  rsKontotype = 'Kontotype';
  rsBogforing = 'Bogføring';
  rsOverskrift = 'Overskrift';
  rsSammentelling = 'Sammentælling';
  rsMoms = 'Moms';
  rsMoms1 = 'Moms 1';
  rsMoms2 = 'Moms 2';
  rsMoms3 = 'Moms 3';
  rsMoms4 = 'Moms 4';
  rsMoms5 = 'Moms 5';
  rsSats = 'Sats';
  rsMomsInd = 'Indgående' + lineEnding + 'finanskonto';
  rsMomsUd = 'Udgående' + lineEnding + 'finanskonto';
  rsIngenmoms = 'Ingen moms';
  rsIndgaaende = 'Indgående moms (købsmoms)';
  rsUdgaaende = 'Udgående moms (salgsmoms)';
  rsFraKonto = 'Fra konto';
  rsTilKonto = 'Til konto';
  rsKontoTom = 'Kontonummer skal udfyldes';
  rsNavnTom = 'Konteksten skal udfyldes';
  rsTilFraTom = 'Til og fra skal udfyldes, når kontotypen er sammentælling';
  rsImport = 'Importer';
  rsTables = 'Tabeller';
  rsFields = 'Felter';
  rsFil = 'Filnavn';
  rsAabnErr = 'Fejl ved læsning af ';
  rsFirsttLineError = 'Første linie i filen skal kun bestå af tabel navnet.';
  rsIntetFilNavn = 'Ingen valgt fil';
  rsFeltIkkeFundet = 'Felt ikke fundet ';
  rsNoImport = 'Fejl i de to første linier, import har ikke funet sted';
  rsImpWarn = 'Ved import slettes alle eksisterende data i tabellen';
  rsKtoFindes = 'Konto findes allerede';
  rsMomsTyp = 'Moms type';
  rsBilagsNummer = 'Bilagsnummer';
  rsTekst = 'Tekst';
  rsPeriode = 'Periode';
  rsAar = 'Regnskabsår';
  rsDato = 'Dato';
  rsBelob = 'Beløb';
  rsKontoNavn = 'Kontonavn';
  rsBilagsregistrering = 'Bilagsregistrering';
  rsSettings = 'Opsætning';
  rsShortcut = 'Genvej';
  rsMenupunkt = 'menupunkt';
  rsPerioder = 'Perioder';
  rsBogholderi = 'Bogholderi';
  rsMisc = 'Diverse';
  rsAarstart = 'Regnskabsårets start';
  rsVirksomhedsoplysninger = 'Virksomhedsoplysninger';
  rsFejlIDato = 'Forkert datoformat';
  rsPeriodeFejl = 'Dato tilhører et andet regnskabsår';
  rsNoUpdate = 'Noget gik galt, opdaterer ikke';
  rsNextBilagsNummer = 'Seneste bilagsnummer';
  rsBilagCifre = 'Antal cifre i bilagsnummer';
  rsVelg = 'Vælg';
  rsKontofejl = 'Kontnummer findes ikke'+sLineBreak+'Eller er ikke en bogføringskonto';
  rsLinieTilfoj = 'Tilføj til bilag';

implementation

initialization
rsStrings := TStringlist.Create;
rsStrings.append('rsImportZipCode='+ rsImportZipCode);
rsStrings.append('rsOpenFile='+rsOpenFile);
rsStrings.append('rsFiles='+rsFiles);
rsstrings.append('rsOpen='+rsOpen);
rsStrings.Append('rsPostDistrikt='+rsPostDistrikt);
rsStrings.Append('rsAfbryd='+rsAfbryd);
rsStrings.Append('rsOK='+rsOK);
rsStrings.Append('rsFortryd='+rsFortryd);
rsStrings.Append('rsSelFields='+rsSelFields);
rsStrings.Append('rsAfslut='+rsAfslut);
rsStrings.Append('rsRet='+rsRet);
rsStrings.Append('rsNy='+rsNy);
rsStrings.Append('rsSlet='+rsSlet);
rsStrings.Append('rsLand='+rsLand);
rsStrings.Append('rsPostNummer='+rsPostNummer);
rsStrings.Append('rsColname='+rsColname);
rsStrings.Append('rsColType='+rsColType);
rsStrings.Append('rsKonto='+rsKonto);
rsStrings.Append('rsTyp='+rsTyp);
rsStrings.Append('rsMomssats='+rsMomssats);
rsStrings.Append('rsFirmaoplysninger='+rsFirmaoplysninger);
rsStrings.Append('rsFirmanavn='+rsFirmanavn);
rsStrings.Append('rsNavn='+rsNavn);
rsStrings.Append('rsAdresse='+rsAdresse);
rsStrings.Append('rsAdresse2='+rsAdresse2);
rsStrings.Append('rsPostnrBy='+rsPostnrBy);
rsStrings.Append('rsTlf='+rsTlf);
rsStrings.Append('rsMail='+rsMail);
rsStrings.Append('rsBank='+rsBank);
rsStrings.Append('rsBankKonto='+rsBankKonto);
rsStrings.Append('rsCVR='+rsCVR);
rsStrings.Append('rsFinansKonto='+rsFinansKonto);
rsStrings.Append('rsKontoplan='+rsKontoplan);
rsStrings.Append('rsKontonummer='+rsKontonummer);
rsStrings.Append('rsKontotekst='+rsKontotekst);
rsStrings.Append('rsKontotype='+rsKontotype);
rsStrings.Append('rsBogforing='+rsBogforing);
rsStrings.Append('rsOverskrift='+rsOverskrift);
rsStrings.Append('rsSammentelling='+rsSammentelling);
rsStrings.Append('rsMoms='+rsMoms);
rsStrings.Append('rsMoms1='+rsMoms1);
rsStrings.Append('rsMoms2='+rsMoms2);
rsStrings.Append('rsMoms3='+rsMoms3);
rsStrings.Append('rsMoms4='+rsMoms4);
rsStrings.Append('rsMoms5='+rsMoms5);
rsStrings.Append('rsSats='+rsSats);
rsStrings.Append('rsMomsInd='+rsMomsInd);
rsStrings.Append('rsMomsUd='+rsMomsUd);
rsStrings.Append('rsIngenmoms='+rsIngenmoms);
rsStrings.Append('rsIndgaaende='+rsIndgaaende);
rsStrings.Append('rsUdgaaende='+rsUdgaaende);
rsStrings.Append('rsFraKonto='+rsFraKonto);
rsStrings.Append('rsTilKonto='+rsTilKonto);
rsStrings.Append('rsKontoTom='+rsKontoTom);
rsStrings.Append('rsNavnTom='+rsNavnTom);
rsStrings.Append('rsTilFraTom='+rsTilFraTom);
rsStrings.Append('rsImport='+rsImport);
rsStrings.Append('rsTables='+rsTables);
rsStrings.Append('rsFields='+rsFields);
rsStrings.Append('rsFil='+rsFil);
rsStrings.Append('rsAabnErr='+rsAabnErr);
rsStrings.Append('rsFirsttLineError='+rsFirsttLineError);
rsStrings.Append('rsIntetFilNavn='+rsIntetFilNavn);
rsStrings.Append('rsFeltIkkeFundet='+rsFeltIkkeFundet);
rsStrings.Append('rsNoImport='+rsNoImport);
rsStrings.Append('rsImpWarn='+rsImpWarn);
rsStrings.Append('rsKtoFindes='+rsKtoFindes);
rsStrings.Append('rsMomsTyp='+rsMomsTyp);
rsStrings.Append('rsBilagsNummer='+rsBilagsNummer);
rsStrings.Append('rsTekst='+rsTekst);
rsStrings.Append('rsPeriode='+rsPeriode);
rsStrings.Append('rsAar='+rsAar);
rsStrings.Append('rsDato='+rsDato);
rsStrings.Append('rsBelob='+rsBelob);
rsStrings.Append('rsKontoNavn='+rsKontoNavn);
rsStrings.Append('rsBilagsregistrering='+rsBilagsregistrering);
rsStrings.Append('rsSettings='+rsSettings);
rsStrings.Append('rsShortcut='+rsShortcut);
rsStrings.Append('rsMenupunkt='+rsMenupunkt);
rsStrings.Append('rsPerioder='+rsPerioder);
rsStrings.Append('rsBogholderi='+rsBogholderi);
rsStrings.Append('rsMisc='+rsMisc);
rsStrings.Append('rsAarstart='+rsAarstart);
rsStrings.Append('rsVirksomhedsoplysninger='+rsVirksomhedsoplysninger);
rsStrings.Append('rsFejlIDato='+rsFejlIDato);
rsStrings.Append('rsPeriodeFejl='+rsPeriodeFejl);
rsStrings.Append('rsNoUpdate='+rsNoUpdate);
rsStrings.Append('rsNextBilagsNummer='+rsNextBilagsNummer);
rsStrings.Append('rsBilagCifre='+rsBilagCifre);
rsStrings.Append('rsVelg='+rsVelg);
rsStrings.Append('rsKontofejl='+rsKontofejl);
rsStrings.Append('rsLinieTilfoj='+rsLinieTilfoj);

RsStrings.Sort;

finalization
rsstrings.Destroy;
end.
