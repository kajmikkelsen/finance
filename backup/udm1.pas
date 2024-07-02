unit udm1;

{$mode ObjFPC}{$H+}
{$m+}

interface

uses
  Classes, SysUtils, SQLite3Conn, SQLDB, DB, Dialogs, Global, uselect, DBGrids;

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
// sqlq3 is to be used for queries withou affecting othe querries
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
    function InitDB(DataBaseName: string): boolean;
    function GetDiverse(Ident: string): string;
    function PutDiverse(Ident, Value: string): boolean;
    function DiverseExists(Ident: string): boolean;
    Function GetMomsSats(nr:Integer): Double;
  end;


  Tpostnr = class
  private
    TblNm: string;
    Dist: PostDistrikt;

  public
    constructor Create(Name: string);
    function NewDistrict(d: PostDistrikt): integer;
    function Search(nr: string): integer;
    function GetDistFromNr(nr: string): string;
    function Delete(id: integer): string;
    function getnr(id: integer): string;
    function getdist(id: integer): string;
    procedure PrepareSelect;

  end;


  TFinKto = class
  private
    TblNm: string;
    kto: FinKonto;
  public
    constructor Create(Name: string);
    procedure PrepareSelect;
    function KontoExists(KtoNummer: string): boolean;
    function Delete(id: integer): string;
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
begin
  Res := True;
  with SQLQ1 do
  begin
    try
      Active := False;
      SQL.Clear;
      Sql.Append('Select * from ' + dbname);
      Active := True;
    except
      on E: EDatabaseError do
      begin
        Res := False;
      end;
    end;
  end;
  Result := res;
end;

procedure TDM1.DataModuleCreate(Sender: TObject);
begin
  DataDicST := TStringList.Create;
  DataDicSt.Sorted := True;
  SelHeaders := TStringList.Create;
  SelHeaders.Sorted := True;
  postnr := TPostnr.Create('postnr');
  konto := TFinkto.Create('konto');
  DM1.InitDB(DatDir + 'FinDB.db');

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
  SqlSt := TStringList.Create;
  sqlqx.Close;
  sqlqx.Active := false;
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
  sqlqx.Active:= True;
  sqlqx.ExecSQL;
  SQLTx.Commit;
  sqlqx.Close;
  SqlSt.Free;
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
  ;
  if i > 0 then
    Result := True
  else
    Result := False;

end;

function TDM1.GetMomsSats(nr: Integer): Double;
Var
  St:String;
  sats: Double;
begin
  St := GetDiverse('Moms'+IntToStr(nr));
  If trystrtofloat(st,sats) Then
  Result := sats
  else
    result := 0;
end;

{ postnr }

constructor Tpostnr.Create(Name: string);
begin
  TblNm := Name;
end;


function Tpostnr.NewDistrict(d: PostDistrikt): integer;
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

function Tpostnr.Delete(id: integer): string;
begin
  DeleteFromDb(id, 'postnr');
end;

function Tpostnr.getnr(id: integer): string;
begin

end;

function Tpostnr.getdist(id: integer): string;
begin

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

function TFinKto.Delete(id: integer): string;
begin
  DeleteFromDb(id, 'konto');
end;


end.
