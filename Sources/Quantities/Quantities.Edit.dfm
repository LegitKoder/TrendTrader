object frmQuantityEdit: TfrmQuantityEdit
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Quantity'
  ClientHeight = 300
  ClientWidth = 356
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  ShowHint = True
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pnlBottom: TPanel
    Left = 0
    Top = 255
    Width = 356
    Height = 45
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      356
      45)
    object btnSave: TBitBtn
      Left = 254
      Top = 2
      Width = 100
      Height = 40
      Action = aSave
      Anchors = [akTop, akRight]
      Caption = 'Save'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      Images = DMImage.vil32
      ParentFont = False
      TabOrder = 0
    end
    object btnCancel: TBitBtn
      Left = 153
      Top = 2
      Width = 100
      Height = 40
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Cancel'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      Images = DMImage.vil32
      ModalResult = 2
      ParentFont = False
      TabOrder = 1
    end
  end
  object pnlTypeCondition: TPanel
    Left = 0
    Top = 0
    Width = 356
    Height = 255
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      356
      255)
    object lblName: TLabel
      Left = 17
      Top = 7
      Width = 38
      Height = 16
      Alignment = taRightJustify
      Caption = 'Name:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblQuantityMode: TLabel
      Left = 17
      Top = 105
      Width = 80
      Height = 16
      Alignment = taRightJustify
      Caption = 'Sizing Mode:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblRiskOrPercentValue: TLabel
      Left = 17
      Top = 151
      Width = 120
      Height = 16
      Alignment = taRightJustify
      Caption = 'Risk/Percent Value:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblSingleOrderAmount: TLabel
      Left = 17
      Top = 197
      Width = 122
      Height = 16
      Alignment = taRightJustify
      Caption = 'Single order amount:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblTotalOrderAmount: TLabel
      Left = 17
      Top = 56
      Width = 116
      Height = 16
      Alignment = taRightJustify
      Caption = 'Total order amount:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblCurrency: TLabel
      Left = 17
      Top = 243
      Width = 56
      Height = 16
      Alignment = taRightJustify
      Caption = 'Currency:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object edtName: TEdit
      Left = 17
      Top = 29
      Width = 320
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
    end
    object edTotalOrderAmount: TNumberBox
      Left = 17
      Top = 78
      Width = 120
      Height = 21
      AcceptExpressions = True
      TabOrder = 1
      SpinButtonOptions.Placement = nbspCompact
      UseMouseWheel = True
      NegativeValueColor = clRed
    end
    object cbQuantityMode: TComboBox
      Left = 17
      Top = 127
      Width = 180
      Height = 21
      Style = csDropDownList
      TabOrder = 2
    end
    object edRiskOrPercentValue: TNumberBox
      Left = 17
      Top = 173
      Width = 120
      Height = 21
      AcceptExpressions = True
      ValueType = vtFloat
      TabOrder = 3
      SpinButtonOptions.Placement = nbspCompact
      UseMouseWheel = True
      NegativeValueColor = clRed
    end
    object edSingleOrderAmount: TNumberBox
      Left = 17
      Top = 219
      Width = 120
      Height = 21
      AcceptExpressions = True
      TabOrder = 4
      SpinButtonOptions.Placement = nbspCompact
      UseMouseWheel = True
      NegativeValueColor = clRed
    end
    object cbOrderCurrency: TComboBox
      Left = 17
      Top = 261
      Width = 120
      Height = 21
      CharCase = ecUpperCase
      TabOrder = 5
    end
  end
  object ActionListMain: TActionList
    Images = DMImage.vil32
    Left = 232
    Top = 87
    object aSave: TAction
      Caption = 'Save'
      ImageIndex = 46
      ImageName = 'tick'
      ShortCut = 16467
      OnExecute = aSaveExecute
    end
  end
end
