unit global;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;
Type
  PostDistrikt = record
    land,nummer,by: String;
  end;

  FinKonto = Record
    nummer,Navn,frakto,tilkto: String;
    Typ: Integer;
  end;

    Var
    datadicst,SelHeaders: TStringList;

resourcestring
  rsImportZipCode = 'Importer postnummer';
  rsOpenFile = ' åbn fil ';
  rsFiles = 'Kartoteker';
  rsOpen = 'åbn';
  rsPostDistrikt = 'Postdistrikt';
  rsAfbryd = 'Afbryd';
  rsOK = 'OK';
  rsSelFields = 'Vælg felter';
  rsAfslut = 'Afslut';
  rsRet = 'Ret';
  rsNy  = 'Ny';
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
  rsMomsInd = 'Indgående'+lineEnding+'finanskonto';
  rsMomsUd = 'Udgående'+lineEnding+'finanskonto';
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





implementation

end.
