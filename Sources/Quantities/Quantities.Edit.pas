unit Quantities.Edit;

interface

{$REGION 'Region uses'}
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Vcl.Samples.Spin, System.Math, Vcl.DBCtrls,
  System.Generics.Collections, {$IFDEF USE_CODE_SITE}CodeSiteLogging, {$ENDIF} CustomForms, IABFunctions, IABSocketAPI,
  IABSocketAPI_const, Quantities.Types, Vcl.ComCtrls, MessageDialog, DaModule, System.Actions, Vcl.ActnList,
  Search.Instruments,  VirtualTrees, Entity.Sokid, Data.DB, Scanner.Types, Monitor.Types, Document,
  System.DateUtils, BrokerHelperAbstr, Common.Types, DaImages, Global.Types, Vcl.Imaging.pngimage, Vcl.VirtualImage,
  Global.Resources, IABFunctions.Helpers, Vcl.NumberBox, Publishers.Interfaces, Publishers, InstrumentList,
  IABFunctions.MarketData, Utils, ListForm;
{$ENDREGION}

// Quantities.Types is already included via the uses clause above.

type
  TfrmQuantityEdit = class(TCustomForm)
    ActionListMain: TActionList;
    aSave: TAction;
    btnCancel: TBitBtn;
    btnSave: TBitBtn;
    edtName: TEdit;
    lblName: TLabel;
    pnlBottom: TPanel;
    pnlTypeCondition: TPanel;
    edTotalOrderAmount: TNumberBox;
    edSingleOrderAmount: TNumberBox;
    lblSingleOrderAmount: TLabel;
    lblTotalOrderAmount: TLabel;
    cbOrderCurrency: TComboBox;
    lblCurrency: TLabel;
    cbQuantityMode: TComboBox;
    edRiskOrPercentValue: TNumberBox;
    lblQuantityMode: TLabel;
    lblRiskOrPercentValue: TLabel;
    procedure aSaveExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cbQuantityModeChange(Sender: TObject);
  private
    FQuantity: TQuantity;
    procedure UpdateControlsBasedOnMode;
    function CheckData: Boolean;
    procedure LoadParamsFromXml;
    procedure SaveParamsToXml;
  private const
    C_SECTION_SCANNER_MAIN     = 'ScannerMain';
    C_KEY_ORDER_CURRENCY       = 'OrderCurrency';
    C_KEY_ORDER_CURRENCY_LIST  = 'OrderCurrencyList';
  public
    class function ShowEditForm(aItem: TBaseClass; aDialogMode: TDialogMode): TModalResult; override;
    procedure Initialize;
    procedure Denitialize;
  end;

implementation

{$R *.dfm}

class function TfrmQuantityEdit.ShowEditForm(aItem: TBaseClass; aDialogMode: TDialogMode): TModalResult;
begin
  with TfrmQuantityEdit.Create(nil) do
  try
    DialogMode := aDialogMode;
    FQuantity.AssignFrom(TQuantity(aItem));
    Initialize;
    Result := ShowModal;
    SaveParamsToXml;
    if (Result = mrOk) then
    begin
      Denitialize;
      TQuantity(aItem).AssignFrom(FQuantity);
    end;
  finally
    Free;
  end;
end;

procedure TfrmQuantityEdit.FormCreate(Sender: TObject);
var
  Mode: TQuantityMode;
begin
  FQuantity := TQuantity.Create;

  // Populate cbQuantityMode
  cbQuantityMode.Items.Clear;
  for Mode := Low(TQuantityMode) to High(TQuantityMode) do
    cbQuantityMode.Items.Add(Mode.ToString);
  
  // Assign OnChange event handler for cbQuantityMode
  cbQuantityMode.OnChange := cbQuantityModeChange;
end;

procedure TfrmQuantityEdit.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FQuantity);
end;

procedure TfrmQuantityEdit.Initialize;
resourcestring
  rsCaption = '%s (v.%s)';
begin
  LoadParamsFromXml;

  if FQuantity.Name.IsEmpty then
    edtName.Text := 'Quantity'
  else
    edtName.Text := FQuantity.Name;
  edTotalOrderAmount.ValueInt := FQuantity.TotalOrderAmount;
  edSingleOrderAmount.ValueInt := FQuantity.OrderAmount;
  if not FQuantity.Currency.IsEmpty then
    cbOrderCurrency.Text := FQuantity.Currency;

  cbQuantityMode.ItemIndex := Ord(FQuantity.Mode);
  edRiskOrPercentValue.ValueFloat := FQuantity.RiskOrPercentValue;

  UpdateControlsBasedOnMode;

  case DialogMode of
    dmInsert:
      Self.Caption := Format(rsCaption, ['New Quantity', General.ModuleVersion]);
    dmUpdate:
      Self.Caption := Format(rsCaption, ['Edit Quantity', General.ModuleVersion]);
  end;
end;

procedure TfrmQuantityEdit.UpdateControlsBasedOnMode;
var
  SelectedMode: TQuantityMode;
begin
  if cbQuantityMode.ItemIndex < 0 then
  begin
    // Default to disabling/hiding percent/risk value if nothing is selected
    lblRiskOrPercentValue.Visible := False;
    edRiskOrPercentValue.Visible := False;
    edRiskOrPercentValue.Enabled := False;
    lblSingleOrderAmount.Caption := 'Single order amount:';
    edSingleOrderAmount.Enabled := True;
    Exit;
  end;

  SelectedMode := TQuantityMode(cbQuantityMode.ItemIndex);

  case SelectedMode of
    qmFixedShares:
    begin
      lblRiskOrPercentValue.Visible := False;
      edRiskOrPercentValue.Visible := False;
      edRiskOrPercentValue.Enabled := False;
      lblSingleOrderAmount.Caption := 'Shares per Order:';
      edSingleOrderAmount.Enabled := True;
      edSingleOrderAmount.Visible := True;
      lblSingleOrderAmount.Visible := True;
    end;
    qmFixedMonetaryAmount:
    begin
      lblRiskOrPercentValue.Visible := False;
      edRiskOrPercentValue.Visible := False;
      edRiskOrPercentValue.Enabled := False;
      lblSingleOrderAmount.Caption := 'Monetary Amount per Order:';
      edSingleOrderAmount.Enabled := True;
      edSingleOrderAmount.Visible := True;
      lblSingleOrderAmount.Visible := True;
    end;
    qmPercentOfEquity:
    begin
      lblRiskOrPercentValue.Caption := 'Equity %:';
      lblRiskOrPercentValue.Visible := True;
      edRiskOrPercentValue.Visible := True;
      edRiskOrPercentValue.Enabled := True;
      // Optionally hide or disable edSingleOrderAmount, or use it as a cap
      lblSingleOrderAmount.Visible := False; // Example: Hide it
      edSingleOrderAmount.Visible := False; // Example: Hide it
      edSingleOrderAmount.Enabled := False;
    end;
    qmFixedRiskPercentEquity:
    begin
      lblRiskOrPercentValue.Caption := 'Risk %:';
      lblRiskOrPercentValue.Visible := True;
      edRiskOrPercentValue.Visible := True;
      edRiskOrPercentValue.Enabled := True;
      // Optionally hide or disable edSingleOrderAmount, or use it as a cap
      lblSingleOrderAmount.Visible := False; // Example: Hide it
      edSingleOrderAmount.Visible := False; // Example: Hide it
      edSingleOrderAmount.Enabled := False;
    end;
  end;
end;

procedure TfrmQuantityEdit.cbQuantityModeChange(Sender: TObject);
begin
  UpdateControlsBasedOnMode;
end;

procedure TfrmQuantityEdit.SaveParamsToXml;
begin
  General.XMLFile.WriteString(C_SECTION_SCANNER_MAIN, C_KEY_ORDER_CURRENCY, cbOrderCurrency.Text);
  General.XMLFile.WriteString(C_SECTION_SCANNER_MAIN, C_KEY_ORDER_CURRENCY_LIST, cbOrderCurrency.Items.Text);
end;

procedure TfrmQuantityEdit.LoadParamsFromXml;
begin
  cbOrderCurrency.Items.Text := General.XMLFile.ReadString(C_SECTION_SCANNER_MAIN, C_KEY_ORDER_CURRENCY_LIST, C_DEFAULT_CURRENCY);
  cbOrderCurrency.Text       := General.XMLFile.ReadString(C_SECTION_SCANNER_MAIN, C_KEY_ORDER_CURRENCY, C_DEFAULT_CURRENCY);
end;

procedure TfrmQuantityEdit.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := True;
  if (ModalResult = mrOk) then
  begin
    Denitialize;
    CanClose := CheckData;
  end;
end;

function TfrmQuantityEdit.CheckData: Boolean;
resourcestring
  rsTotalOrderAmount = 'Total order amount is 0';
  rsRiskOrPercentValuePositive = 'Risk/Percent value must be greater than zero for the selected mode.';

  function CheckRequired: Boolean;
  var
    Problems: string;
    SelectedMode: TQuantityMode;
  begin
    Problems := '';

    // Name check (remains the same)
    if FQuantity.Name.IsEmpty then
    begin
      SetFocusSafely(edtName);
      Problems := Format(rcRequiredValue, ['Name']);
    end;

    // Total Order Amount check (remains the same, or could be conditional)
    if (FQuantity.TotalOrderAmount = 0) then
    begin
      if Problems.IsEmpty then SetFocusSafely(edTotalOrderAmount);
      Problems := Problems + sLineBreak + Format(rcRequiredValue, ['Total order amount']);
    end;

    // Currency check (remains the same)
    if FQuantity.Currency.IsEmpty then
    begin
      if Problems.IsEmpty then SetFocusSafely(cbOrderCurrency);
      Problems := Problems + sLineBreak + Format(rcRequiredValue, ['Order Currency']);
    end;

    // Mode-specific checks
    if cbQuantityMode.ItemIndex >= 0 then
    begin
      SelectedMode := TQuantityMode(cbQuantityMode.ItemIndex);
      case SelectedMode of
        qmFixedShares, qmFixedMonetaryAmount:
        begin
          // Use FQuantity.OrderAmount which was set in Denitialize
          if (FQuantity.OrderAmount = 0) then
          begin
            if Problems.IsEmpty then SetFocusSafely(edSingleOrderAmount);
            Problems := Problems + sLineBreak + Format(rcRequiredValue, [lblSingleOrderAmount.Caption.Replace(':', '')]);
          end;
        end;
        qmPercentOfEquity, qmFixedRiskPercentEquity:
        begin
          // Use FQuantity.RiskOrPercentValue which was set in Denitialize
          if (FQuantity.RiskOrPercentValue <= 0) then
          begin
            if Problems.IsEmpty then SetFocusSafely(edRiskOrPercentValue);
            Problems := Problems + sLineBreak + rsRiskOrPercentValuePositive;
          end;
          // OrderAmount check might be skipped or different if it's derived or a cap
          // For instance, if FQuantity.OrderAmount is expected to be 0 for these modes
          // unless explicitly used as a cap (which we set to 0 in Denitialize if edSingleOrderAmount is disabled)
        end;
      end;
    end
    else
    begin
       // Should not happen, but good to have a fallback
       if Problems.IsEmpty then SetFocusSafely(cbQuantityMode);
       Problems := Problems + sLineBreak + Format(rcRequiredValue, ['Quantity Sizing Mode']);
    end;

    Result := Problems.TrimLeft.IsEmpty;
    if not Result then
      TMessageDialog.ShowWarning(Problems.TrimLeft);
  end;

begin
  Result := CheckRequired;
end;

procedure TfrmQuantityEdit.Denitialize;
var
  SelectedMode: TQuantityMode;
begin
  FQuantity.Name := edtName.Text;
  FQuantity.TotalOrderAmount := edTotalOrderAmount.ValueInt; // This might need re-evaluation based on mode
  FQuantity.Currency := cbOrderCurrency.Text;

  if cbQuantityMode.ItemIndex >= 0 then
  begin
    SelectedMode := TQuantityMode(cbQuantityMode.ItemIndex);
    FQuantity.Mode := SelectedMode;

    case SelectedMode of
      qmFixedShares, qmFixedMonetaryAmount:
      begin
        FQuantity.OrderAmount := edSingleOrderAmount.ValueInt;
        FQuantity.RiskOrPercentValue := 0.0; // Not applicable for these modes
      end;
      qmPercentOfEquity, qmFixedRiskPercentEquity:
      begin
        FQuantity.RiskOrPercentValue := edRiskOrPercentValue.ValueFloat;
        // OrderAmount might be derived or not used directly, or used as a cap.
        // For now, let's set it to 0 or what's in edSingleOrderAmount if it's visible/enabled.
        if edSingleOrderAmount.Enabled then
          FQuantity.OrderAmount := edSingleOrderAmount.ValueInt
        else
          FQuantity.OrderAmount := 0; // Or handle as per specific logic for these modes
      end;
    else
      // Should not happen if ComboBox is populated and has a selection
      FQuantity.OrderAmount := edSingleOrderAmount.ValueInt;
      FQuantity.RiskOrPercentValue := 0.0;
    end;
  end
  else
  begin
    // Default behavior if no mode is selected (should ideally not happen)
    FQuantity.Mode := qmFixedShares; // Or some other default
    FQuantity.OrderAmount := edSingleOrderAmount.ValueInt;
    FQuantity.RiskOrPercentValue := 0.0;
  end;
end;

procedure TfrmQuantityEdit.aSaveExecute(Sender: TObject);
begin
  ModalResult := mrOk;
end;

initialization
  ListFormFactory.RegisterList(ntQuantities, TQuantity, TfrmQuantityEdit);

end.
