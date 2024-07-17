unit udm1;

{$mode ObjFPC}{$H+}
{$m+}

interface

uses
  Classes, SysUtils, SQLite3Conn, SQLDB, DB, Dialogs, Global, uselect, DBGrids,Controls;

type

  { TDM1 }
  TDM1 = class(TDataModule)
    DS2: TDataSource;
    DS1: TDataSource;
    DS3: TDataSource;
    DSx: TDataSource;
    lt1: TSQLite3Connection;
    ltx: TSQLite3Connection;
    SQLQ1: TSQLQuery;
    sqlq2: TSQLQuery;
    SQLQ3: TSQLQuery;
    SQLQx: TSQLQuery;
    SQLT1: TSQLTransaction;
    SQLTx: TSQLTransaction;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    procedure FillDataDic(var DataDicSt: TStringList);
    procedure FillExistAndCreate(var DataDicSt, TblExists, TblToCreate: TStringList);
    function TableExist(DBName: string): boolean;
    procedure CreateTables(TblToCreate, DataDicSt: TStringList;
      var TblExists: TStringList);
    procedure AddFieldsIfNeeded(Fields, ActFields, DataDicSt, TblExists,
      CreateSql: TStringList);
  public
    Momssatser: array [0..5] of string;
    function InitDB(DataBaseName: string): boolean;
    function GetDiverse(Ident: string): string;
    function PutDiverse(Ident, Value: string): boolean;
    function DiverseExists(Ident: string): boolean;
    function GetMomsSats(nr: integer): double;
    procedure GetTables(ThisSqlq: TSQlQuery; StL: TStringList);
  end;


  Tpostnr = class
  private
    TblNm: string;
    Dist: PostDistrikt;

  public
    constructor Create(Name: string);
    procedure NewDistrict(d: PostDistrikt);
    function Search(nr: string): integer;
    function GetDistFromNr(nr: string): string;
    procedure Delete(id: integer);
    function getnr(id: integer): string;
    function getdist(id: integer): string;
    procedure PrepareSelect;

  end;


  { TFinKto }

  TFinKto = class
  private
    TblNm: string;
  public
    constructor Create(Name: string);
    procedure PrepareSelect;
    Procedure PrepareSelect4Search;
    Procedure resetPrepSel;
    function KontoExists(KtoNummer: string): boolean;
    procedure Delete(id: integer);
    function GetBogfKtoFromID(Var Nummer, Navn: string; id: integer): boolean;
    function GetBogfKtoFromNr(Var Nummer, Navn: string; Var id: integer): boolean;
  end;

procedure DeleteFromDb(ID: integer; Bas: string);


var
  DM1: TDM1;
  postnr: TPostNr;
  Konto: TFinKto;

implementation

uses
  MyLib, MyDbMain;

procedure DeleteFromDb(ID: integer; Bas: string);
begin
  with dm1.sqlq1 do
  begin
    Close;
    sql.Clear;
    Sql.Add('delete from ' + Bas + ' where ID = ' + IntToStr(ID));
    execSQL;
    ;
    dm1.SQLT1.Commit;
    Close;
  end;

end;


{$R *.lfm}

{ TDM1 }

function TDM1.TableExist(DBName: string): boolean;
var
  Res: boolean;
  TableList: TStringList;
  i: integer;
begin
  TAbleList := TStringList.Create;
  TableList.Sorted := True;
  GetTables(SqlQ1, TableList);
  Res := True;
  if TableList.Find(DBName, i) then
    res := True
  else
    Res := False;
  //with SQLQ1 do
  //begin
  //  try
  //    Active := False;
  //    SQL.Clear;
  //    Sql.Append('Select * from ' + dbname);
  //    Active := True;
  //  except
  //    on E: EDatabaseError do
  //    begin
  //      Res := False;
  //    end;
  //  end;
  //end;
  Result := res;
end;

procedure TDM1.DataModuleCreate(Sender: TObject);
var
  i: integer;
  sats: double;
begin
  DataDicST := TStringList.Create;
  DataDicSt.Sorted := True;
  SelHeaders := TStringList.Create;
  SelHeaders.Sorted := True;
  postnr := TPostnr.Create('postnr');
  konto := TFinkto.Create('konto');
  DM1.InitDB(DatDir + 'FinDB.db');
  Momssatser[0] := '0';
  for i := 1 to 5 do
  begin
    sats := dm1.GetMomsSats(i);
    Momssatser[i] := (FloatToStrF(sats, ffFixed, 2, 2));
  end;

end;

procedure TDM1.DataModuleDestroy(Sender: TObject);
begin
  DataDicSt.Free;
  SelHeaders.Free;
end;

///
/// *** Datadictionary
/// tablename,fieldname , field type
/// any changes to the datadictionary will be executed the next ime the application run
/// this goes for bothe creating and changing tables
/// deleted fields and deleted tables will not be done
///

procedure TDM1.FillDataDic(var DataDicSt: TStringList);
begin
  with DataDicSt do
  begin
    Append('misc,colname,varchar(40)');
    Append('misc,colvalue,varchar(40)');
    Append('konto,Nummer,Integer');
    Append('konto,navn,varchar(40)');
    Append('konto,typ,integer');
    Append('konto,momstyp,integer');
    Append('konto,momssats,integer');
    Append('konto,Fra,integer');
    Append('konto,Til,integer');
    Append('postnr,landekode,varchar(10)');
    Append('postnr,postnummer,varchar(40)');
    Append('postnr,postdistrikt,varchar(40)');
    Append('bilag,bnummer,varchar(40)');
    Append('bilag,kontonummer,Integer');
    Append('bilag,tekst,varchar(40)');
    Append('bilag,periode,Integer');
    Append('bilag,aar,Integer');
    Append('bilag,dato,varchar(10)');
    Append('bilag,belob,Real');

  end;
  with SelHeaders do
  begin
    append('colname=' + rsColName);
    append('coltype=' + rsColType);
    append('Nummer=' + rsKontoNummer);
    append('navn=' + rsNavn);
    append('typ=' + rsTyp);
    append('momstyp=' + rsMomsTyp);
    append('Momssats=' + rsMomssats);
    append('Fra=' + rsFraKonto);
    append('Til=' + rsTilKonto);
    append('landekode=' + rsLand);
    append('postnummer=' + rsPostnummer);
    append('postdistrikt=' + rsPostDistrikt);
    append('bnummer=' + rsBilagsNummer);
    append('kontonummer=' + rsKontoNummer);
    append('tekst=' + rsTekst);
    append('periode=' + rsPeriode);
    append('aar=' + rsAar);
    append('dato=' + rsDato);
    append('belob=' + rsBelob);
  end;
end;

procedure TDM1.FillExistAndCreate(var DataDicSt, TblExists, TblToCreate: TStringList);
var
  i, ind: integer;
  St: string;
begin
  //  see which tables exists, and create sql to create those who don't
  for i := 0 to DataDicSt.Count - 1 do
  begin
    st := GetFieldByDelimiter(0, DataDicSt[i], ',');
    if (not TblExists.Find(St, ind)) and (not TblToCreate.Find(st, ind)) then
    begin
      if TableExist(st) then
        TblExists.Add(St)
      else
        TblToCreate.Add(St);
    end;
  end;
end;

procedure TDM1.CreateTables(TblToCreate, DataDicSt: TStringList;
  var TblExists: TStringList);
var
  i, i1: integer;
  CreateSql: TStringList;
begin
  CreateSql := TStringList.Create;
  // create non existing tables
  for i := 0 to TblToCreate.Count - 1 do
  begin
    with CreateSql do
    begin
      Clear;
      Add('Create table ' + TblToCreate[i] + '(');
      Add('ID integer not null, ');
      for i1 := 0 to DataDicst.Count - 1 do
      begin
        if GetFieldByDelimiter(0, DataDicSt[i1], ',') = TblToCreate[i] then
          Add(GetFieldByDelimiter(1, DataDicSt[i1], ',') + ' ' +
            GetFieldByDelimiter(2, DataDicSt[i1], ',') + ',');
      end;
      Add('primary key("ID" autoincrement)');
      Add(');');
    end;

    SQLQ1.SQL.Assign(CreateSql);
    sqlQ1.Close;
    SqlQ1.ExecSQL;
    SqlT1.Commit;
    SqlQ1.Close;
    TblExists.Add(TblToCreate[i]);
  end;
  CreateSql.Free;
end;

procedure TDM1.AddFieldsIfNeeded(Fields, ActFields, DataDicSt, TblExists,
  CreateSql: TStringList);
var
  i, i1, ind: integer;
  st: string;
begin
  // check if any tables needs to be changed
  for i := 0 to TblExists.Count - 1 do
  begin
    Fields.Clear;
    for i1 := 0 to DataDicSt.Count - 1 do
    begin
      if GetFieldByDelimiter(0, DataDicST[i1], ',') = TblExists[i] then
        Fields.Add(GetFieldByDelimiter(1, DataDicST[i1], ','));
    end;
    with CreateSql do
    begin
      Clear;
      Add('SELECT p.name as columnName');
      Add('FROM sqlite_master m');
      Add('left outer join pragma_table_info((m.name)) p');
      Add('on m.name <> p.name');
      Add('where m.name = ''' + TblExists[i] + '''');
      Add(';');
    end;
    with sqlq1 do
    begin
      Close;
      sql.Assign(CreateSql);
      Open;
      ActFields.Clear;
      First;
      while not EOF do
      begin
        if FieldByName('ColumnName').AsString <> 'ID' then
          ActFields.Add(FieldByName('ColumnName').AsString);
        Next;
      end;
    end;
    for i1 := 0 to Fields.Count - 1 do
    begin
      if not ActFields.Find(Fields[i1], ind) then
      begin
        DataDicSt.Find(TblExists[i] + ',' + fields[i1] + ',', ind);
        with CreateSQL do
        begin
          Clear;
          Add('Alter table ' + TblExists[i]);
          st := 'Add column ' + Fields[i1] + ' ' + GetFieldByDelimiter(
            2, DataDicSt[ind], ',') + ';';
          Add(st);
        end;
        Fmain.Memo2.Lines.Assign(CreateSql);
        Sqlq1.Close;
        Sqlq1.SQL.Assign(CreateSql);
        SqlQ1.ExecSQL;
        SqlT1.Commit;
        SqlQ1.Close;
      end;
    end;
  end;

end;

function TDM1.InitDB(DataBaseName: string): boolean;
var
  TblExists, TblToCreate, CreateSql, Fields, actFields: TStringList;
begin
  lt1.DatabaseName := DataBaseName;
  ltx.DatabaseName := DataBaseName;
  Fields := TStringList.Create;
  Fields.Sorted := True;
  ActFields := TStringList.Create;
  ActFields.Sorted := True;
  CreateSql := TStringList.Create;
  TblExists := TStringList.Create;
  TblExists.Sorted := True;
  Datadicst.Clear;
  TblToCreate := TStringList.Create;
  TblToCreate.Sorted := True;
  FillDataDic(DataDicSt);
  FillExistAndCreate(DataDicSt, TblExists, TblToCreate);
  CreateTables(TblToCreate, DataDicSt, TblExists);
  AddFieldsIfNeeded(Fields, ActFields, DataDicSt, TblExists, CreateSql);
  TblExists.Free;
  TblToCreate.Free;
  CreateSql.Free;
  Fields.Free;
  actFields.Free;

  Result := True;
end;

function TDM1.GetDiverse(Ident: string): string;
begin
  if DiverseExists(Ident) then
  begin
    sqlQx.Open;
    Result := DSx.Dataset.FieldByName('colvalue').AsString;
    sqlqx.Close;
  end
  else
    Result := '';
end;

function TDM1.PutDiverse(Ident, Value: string): boolean;
var
  SqlSt: TStringList;
begin
  lt1.CloseTransactions;
  SqlSt := TStringList.Create;
  sqlqx.Close;
  sqlqx.SQL.Clear;
  if DiverseExists(Ident) then
  begin
    SqlSt.Add('Update misc set colvalue = ''' + Value + ''' Where colname = ''' +
      Ident + '''');
  end
  else
  begin
    SQlSt.Add('Insert into  misc (colname, colvalue) VALUES (''' +
      Ident + ''',''' + Value + '''' + ');');
  end;
  sqlqx.Sql.Assign(SqlSt);
  sqlqx.ExecSQL;
  SQLTx.Commit;
  sqlqx.Close;
  SqlSt.Free;
  Result := True;
end;

function TDM1.DiverseExists(Ident: string): boolean;
var
  i: integer;
  SqlSt: TStringList;
begin
  SqlSt := TStringList.Create;
  sqlqx.Close;
  sqlqx.SQL.Clear;
  SqlSt.Add('Select * from misc where colname like ''' + Ident + ''';');
  sqlqx.SQL.Assign(SqlSt);
  sqlqx.Open;
  SqlSt.Free;
  i := DSx.DataSet.RecordCount;
  sqlqx.Close;
  ltx.CloseTransactions;
  ;
  if i > 0 then
    Result := True
  else
    Result := False;

end;

function TDM1.GetMomsSats(nr: integer): double;
var
  St: string;
  sats: double;
begin
  St := GetDiverse('Moms' + IntToStr(nr));
  if trystrtofloat(st, sats) then
    Result := sats
  else
    Result := 0;
end;

procedure TDM1.GetTables(ThisSqlq: TSQlQuery; StL: TStringList);
begin
  Stl.Clear;
  with Thissqlq do
  begin
    Close;
    SQL.Clear;
    sql.Add('select * from sqlite_master where type=''table'' and name not like ''sqlite%''');
    Open;
    First;
    while not EOF do
    begin
      Stl.Append(FieldByName('name').AsString);
      Next;
    end;
    Close;
  end;

end;


{ postnr }

constructor Tpostnr.Create(Name: string);
begin
  TblNm := Name;
end;


procedure Tpostnr.NewDistrict(d: PostDistrikt);
var
  InsertSQL: TStringList;
begin
  InsertSQL := TStringList.Create;
  Dist := d;
  InsertSQL.Add('Insert into ' + tblnm + ' (landekode,postnummer,postdistrikt)');
  InsertSQL.Add(' VALUES (''' + Dist.land + '''' + ',''' + dist.nummer +
    ''',' + '''' + dist.by + ''')');
  with DM1 do
  begin
    Sqlq1.Close;
    SQLQ1.sql.Assign(InsertSQL);
    SqlQ1.ExecSQL;
    SqlT1.Commit;
    SqlQ1.Close;
  end;
  InsertSQL.Free;

end;

function Tpostnr.Search(nr: string): integer;
begin
  with dm1 do
  begin
    SQLq1.Close;
    sqlq1.sql.Clear;
    Sqlq1.sql.Add('Select * from  postnr where postnummer like ' + nr);
    SQLQ1.Open;
    if DS1.DataSet.RecordCount > 0 then
      Result := ds1.Dataset.FieldByName('ID').AsInteger
    else
      Result := -1;

  end;
end;

function Tpostnr.GetDistFromNr(nr: string): string;
var
  SqlSt: TStringList;
begin
  SqlSt := TStringList.Create;
  SqlSt.Add('Select * from  postnr where postnummer like ''' + nr + '''');
  with dm1 do
  begin
    SQLq1.Close;
    sqlq1.sql.Clear;
    Sqlq1.sql.Assign(SqlSt);
    SQLQ1.Open;
    SqlSt.Free;
    if DS1.DataSet.RecordCount > 0 then
      Result := ds1.Dataset.FieldByName('postdistrikt').AsString
    else
      Result := '';
  end;

end;

procedure Tpostnr.Delete(id: integer);
begin
  DeleteFromDb(id, 'postnr');
end;

function Tpostnr.getnr(id: integer): string;
begin
  //Dummystatement
  Result := IntToStr(id);
end;

function Tpostnr.getdist(id: integer): string;
begin
  //Dummystatement
  Result := IntToStr(id);

end;



procedure Tpostnr.PrepareSelect;
begin
  FSelect.tblnm := 'postnr';
  FSelect.DefFields := 'postnummer,postdistrikt';
  FSelect.Caption := rsPostDistrikt;
  FSelect.Button2.Action := fmain.APostnrEdit;
  FSelect.Button1.Action := fmain.APostnrNy;
  FSelect.button3.Action := fmain.APostnrDel;
  with dm1.sqlq2 do
  begin
    Close;
    sql.Clear;
    sql.add('select * from ' + tblnm);
    Open;
  end;
end;

{ TFinKto }

constructor TFinKto.Create(Name: string);
begin
  TblNm := Name;
end;

procedure TFinKto.PrepareSelect;
begin
  FSelect.tblnm := 'konto';
  FSelect.DefFields := 'Nummer,navn';
  FSelect.Caption := rsFinansKonto;
  FSelect.Button2.Action := fmain.AKontoEdit;
  FSelect.Button1.Action := fmain.AKontoNy;
  FSelect.button3.Action := fmain.AkontoDel;
  with dm1.sqlq2 do
  begin
    Close;
    sql.Clear;
    sql.add('select * from ' + tblnm);
    Open;
  end;

end;

procedure TFinKto.PrepareSelect4Search;
begin
  udm1.konto.PrepareSelect;
  FSelect.Caption := rsKontoplan;
  FSelect.Button1.Action := FMain.AVelgKto;
  FSelect.Button1.ModalResult:=mrOK;
  FSelect.Button1.Default:=False;;
  FSelect.Button2.Caption:= rsFortryd;
  FSelect.Button2.ModalResult:=mrCancel;
  FSelect.Button2.Default:=False;;
  FSelect.Button2.Action := nil;
  FSelect.Button3.Visible:=False;
  FSelect.Button4.Visible:=False;

end;

procedure TFinKto.resetPrepSel;
begin
    FSelect.Button1.ModalResult:=mrNone;
  FSelect.Button2.ModalResult:=mrNone;
  FSelect.Button2.Caption := rsRet;
  FSelect.Button3.Visible:=True;
  FSelect.Button4.Visible:=True;
  FSelect.Button1.Default:=False;;
  FSelect.Button2.Default:=False;;
end;

function TFinKto.KontoExists(KtoNummer: string): boolean;
begin
  with dm1.sqlq3 do
  begin
    Close;
    sql.Clear;
    sql.add('select * from ' + tblnm + ' where nummer = ' + KtoNummer + ';');
    Open;
    Result := (dm1.sqlq3.RecordCount > 0);
  end;
end;

procedure TFinKto.Delete(id: integer);
begin
  DeleteFromDb(id, 'konto');
end;

function TFinKto.GetBogfKtoFromID(var Nummer, Navn: string; id: integer
  ): boolean;
Var
  res: Boolean;
begin
  with Dm1.Sqlq3 do
  begin
    Close;
    sql.Clear;
    sql.add('select * from ' + tblnm + ' where ID = ' + IntToStr(id) + ';');
    Open;
    if dm1.sqlq3.RecordCount = 0 then
      res := False
    else
    begin
      First;
      If FieldByName('typ').AsString = '0' Then
      Begin
        res := True;
      Nummer := FieldByName('Nummer').AsString;
      Navn := FieldByName('navn').AsString;
      end
      else
      Begin
        Res := False;
        Nummer := '';
        Navn := '';
      end;

    end;
  end;
  Result := res;
end;

function TFinKto.GetBogfKtoFromNr(var Nummer, Navn: string; var id: integer
  ): boolean;
Var
  res: Boolean;
begin
  with Dm1.Sqlq3 do
  begin
    Close;
    sql.Clear;
    sql.add('select * from ' + tblnm + ' where nummer = ' + Nummer + ';');
    Open;
    if dm1.sqlq3.RecordCount = 0 then
      res := False
    else
    begin
      First;
      If FieldByName('typ').AsString = '0' Then
      Begin
        res := True;
      ID := FieldByName('Nummer').AsInteger;
      Nummer := FieldByName('Nummer').AsString;
      Navn := FieldByName('navn').AsString;
      end
      else
      Begin
        Res := False;
        ID := -1;
        Nummer := '';
        Navn := '';
      end;

    end;
  end;
  Result := res;

end;


end.
