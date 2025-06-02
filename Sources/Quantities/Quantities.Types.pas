unit Quantities.Types;

interface

{$REGION 'Region uses'}
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, VirtualTrees, IABFunctions,
  IABSocketAPI, System.Generics.Collections, BrokerHelperAbstr, Winapi.msxml, Vcl.Graphics, Entity.Sokid,
  {$IFDEF USE_CODE_SITE}CodeSiteLogging, {$ENDIF} IABSocketAPI_const, DebugWriter, HtmlLib, Chart.Trade,
  System.DateUtils, XmlFiles, Data.DB, DaModule, InstrumentList, System.Math, System.Threading,
  Publishers.Interfaces, Generics.Helper, Common.Types, Bleeper, DaModule.Utils, ArrayHelper,
  Global.Types, Publishers, Vcl.Forms, IABFunctions.Helpers, IABFunctions.MarketData, Vcl.ExtCtrls,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.Comp.DataSet;
{$ENDREGION}

type
  TQuantityMode = (qmFixedShares, qmFixedMonetaryAmount, qmPercentOfEquity, qmFixedRiskPercentEquity);

  TQuantityModeHelper = record helper for TQuantityMode
    function ToString: string;
  end;

  PQuantity = ^TQuantity;
  TQuantity = class(TBaseClass)
  private
    FCurrency: string;
    FOrderAmount: Integer;
    FTotalOrderAmount: Integer;
    FMode: TQuantityMode;
    FRiskOrPercentValue: Double;
  public
    function ToString: string; override;
    function ToValueString: string;
    procedure AssignFrom(const aQuantity: TQuantity);
    procedure Clear;
    constructor Create; override;

    procedure FromDB(aID: Integer); override;
    procedure SaveToDB; override;
    class function GetListSQL: string; override;
    class function GetListCaption: string; override;
    class procedure DeleteFromDB(aID: Integer); override;

    property Currency         : string               read FCurrency         write FCurrency;
    property OrderAmount      : Integer              read FOrderAmount      write FOrderAmount;
    property TotalOrderAmount : Integer              read FTotalOrderAmount write FTotalOrderAmount;
    property Mode             : TQuantityMode        read FMode             write FMode;
    property RiskOrPercentValue: Double              read FRiskOrPercentValue write FRiskOrPercentValue;
  end;

implementation

{ TQuantityModeHelper }

function TQuantityModeHelper.ToString: string;
begin
  case Self of
    qmFixedShares: Result := 'Fixed Shares';
    qmFixedMonetaryAmount: Result := 'Fixed Monetary Amount';
    qmPercentOfEquity: Result := 'Percent Of Equity';
    qmFixedRiskPercentEquity: Result := 'Fixed Risk Percent Equity';
  else
    Result := '';
  end;
end;

{ TQuantity }

procedure TQuantity.AssignFrom(const aQuantity: TQuantity);
begin
  Self.Clear;
  Self.RecordId         := aQuantity.RecordId;
  Self.Name             := aQuantity.Name;
  Self.Currency         := aQuantity.Currency;
  Self.OrderAmount      := aQuantity.OrderAmount;
  Self.TotalOrderAmount := aQuantity.TotalOrderAmount;
  Self.Mode             := aQuantity.Mode;
  Self.RiskOrPercentValue := aQuantity.RiskOrPercentValue;
end;

procedure TQuantity.Clear;
begin
  Self.Name             := '';
  Self.RecordId         := -1;
  Self.Currency         := '';
  Self.OrderAmount      := 0;
  Self.TotalOrderAmount := 0;
  Self.Mode             := qmFixedShares; // Default mode
  Self.RiskOrPercentValue := 0.0;
end;

constructor TQuantity.Create;
begin
  inherited;
  Clear;
end;

class procedure TQuantity.DeleteFromDB(aID: Integer);
resourcestring
  C_SQL_DELETE = 'DELETE FROM QUANTITIES WHERE ID=%d';
begin
  DMod.ExecuteSQL(Format(C_SQL_DELETE, [aID]));
end;

procedure TQuantity.FromDB(aID: Integer);
resourcestring
  C_SQL_SELECT_TEXT = 'SELECT * FROM QUANTITIES WHERE ID=:ID';
var
  Query: TFDQuery;
begin
  Self.Clear;
  if (aID > 0) then
  begin
    Query := TFDQuery.Create(nil);
    try
      DMod.CheckConnect;
      Query.Connection := DMod.ConnectionStock;
      Query.SQL.Text := C_SQL_SELECT_TEXT;
      Query.ParamByName('ID').AsInteger := aID;
      Query.Open;
      if not Query.IsEmpty then
      begin
        Self.Name             := Query.FieldByName('NAME').AsString;
        Self.Currency         := Query.FieldByName('CURRENCY').AsString;
        Self.OrderAmount      := Query.FieldByName('ORDER_AMOUNT').AsInteger;
        Self.TotalOrderAmount := Query.FieldByName('TOTAL_ORDER_AMOUNT').AsInteger;
        Self.Mode             := TQuantityMode(Query.FieldByName('MODE').AsInteger);
        Self.RiskOrPercentValue := Query.FieldByName('RISK_OR_PERCENT_VALUE').AsFloat;
      end;
      Self.RecordId := aID;
    finally
      FreeAndNil(Query);
    end;
  end;
end;

class function TQuantity.GetListCaption: string;
begin
  Result := 'Quantities list';
end;

class function TQuantity.GetListSQL: string;
begin
  Result := 'SELECT ID, NAME FROM QUANTITIES ORDER BY LOWER(NAME)';
end;

procedure TQuantity.SaveToDB;
resourcestring
  C_SQL_EXISTS_TEXT = 'SELECT COUNT(*) AS CNT FROM QUANTITIES WHERE ID=:ID';
  C_SQL_UPDATE_TEXT = 'UPDATE QUANTITIES SET NAME=:NAME, CURRENCY=:CURRENCY,' + sLineBreak +
                                            'ORDER_AMOUNT=:ORDER_AMOUNT, TOTAL_ORDER_AMOUNT=:TOTAL_ORDER_AMOUNT,' + sLineBreak +
                                            'MODE=:MODE, RISK_OR_PERCENT_VALUE=:RISK_OR_PERCENT_VALUE' + sLineBreak +
                                            'WHERE ID=:ID';

  C_SQL_INSERT_TEXT = 'INSERT INTO QUANTITIES ( ID, NAME, CURRENCY, ORDER_AMOUNT, TOTAL_ORDER_AMOUNT, MODE, RISK_OR_PERCENT_VALUE)' + sLineBreak +
                                     ' VALUES (:ID,:NAME,:CURRENCY,:ORDER_AMOUNT,:TOTAL_ORDER_AMOUNT, :MODE, :RISK_OR_PERCENT_VALUE)';
var
  Query: TFDQuery;
  IsExists: Boolean;
begin
  Query := TFDQuery.Create(nil);
  try
    DMod.CheckConnect;
    Query.Connection := DMod.ConnectionStock;
    Query.Transaction := Query.Connection.Transaction;
    IsExists := False;
    if (Self.RecordId > 0) then
    begin
      Query.SQL.Text := C_SQL_EXISTS_TEXT;
      try
        Query.ParamByName('ID').AsInteger := Self.RecordId;
        Query.Prepare;
        Query.Open;
        IsExists := Query.FieldByName('CNT').AsInteger > 0;
        Query.Close;
      except
        on E: Exception do
        begin
          TPublishers.LogPublisher.Write([ltLogWriter], ddError, 'SaveToDB', 'Quantity', E.Message + TDModUtils.GetQueryInfo(Query));
          raise;
        end;
      end;
    end
    else
      Self.RecordId := DMod.GetNextValue('GEN_QUANTITIES_ID');

    if IsExists then
      Query.SQL.Text := C_SQL_UPDATE_TEXT
    else
      Query.SQL.Text := C_SQL_INSERT_TEXT;

    if Self.Name.IsEmpty or SameText(Self.Name, 'Quantity') then
      Self.Name := 'Quantity nr' + Self.RecordId.ToString;

    Query.ParamByName('ID').AsInteger                 := Self.RecordId;
    Query.ParamByName('NAME').AsString                := Self.Name.Substring(0, 100);
    Query.ParamByName('CURRENCY').AsString            := Self.Currency;
    Query.ParamByName('ORDER_AMOUNT').AsInteger       := Self.OrderAmount;
    Query.ParamByName('TOTAL_ORDER_AMOUNT').AsInteger := Self.TotalOrderAmount;
    Query.ParamByName('MODE').AsInteger               := Ord(Self.Mode);
    Query.ParamByName('RISK_OR_PERCENT_VALUE').AsFloat := Self.RiskOrPercentValue;

    try
      Query.Prepare;
      Query.ExecSQL;
      Query.Transaction.CommitRetaining;
    except
      on E: Exception do
        TPublishers.LogPublisher.Write([ltLogWriter], ddError, 'SaveToDB', 'Quantity', E.Message + TDModUtils.GetQueryInfo(Query));
    end;
  finally
    FreeAndNil(Query);
    DMod.RefreshQuery(DMod.fbqQualifiers);
  end;

end;

function TQuantity.ToString: string;
begin
  Result := 'Total Order Amount: '+ Self.TotalOrderAmount.ToString;
end;

function TQuantity.ToValueString: string;
begin
  Result := '';
end;

end.