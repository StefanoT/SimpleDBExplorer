object SimpleDBExplorerForm: TSimpleDBExplorerForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 
    'Amazon SimpleDB Explorer - by Stefano Tommesani (www.tommesani.c' +
    'om)'
  ClientHeight = 868
  ClientWidth = 684
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object AccountInfoGroupBox: TGroupBox
    Left = 8
    Top = 8
    Width = 665
    Height = 73
    Caption = 'Account Info'
    TabOrder = 0
    object AccountNameEdit: TLabeledEdit
      Left = 11
      Top = 40
      Width = 205
      Height = 21
      EditLabel.Width = 69
      EditLabel.Height = 13
      EditLabel.Caption = 'Account Name'
      TabOrder = 0
    end
    object AccountKeyEdit: TLabeledEdit
      Left = 247
      Top = 40
      Width = 314
      Height = 21
      EditLabel.Width = 75
      EditLabel.Height = 13
      EditLabel.Caption = 'AccountKeyEdit'
      PasswordChar = '*'
      TabOrder = 1
    end
    object ConnectButton: TButton
      Left = 576
      Top = 38
      Width = 75
      Height = 25
      Caption = 'Connect'
      TabOrder = 2
      OnClick = ConnectButtonClick
    end
  end
  object DomainsGroupBox: TGroupBox
    Left = 8
    Top = 87
    Width = 225
    Height = 426
    Caption = 'Domains'
    TabOrder = 1
    object DomainsListBox: TListBox
      Left = 2
      Top = 15
      Width = 221
      Height = 210
      Align = alTop
      ItemHeight = 13
      TabOrder = 0
      OnClick = DomainsListBoxClick
    end
    object DomainNameEdit: TLabeledEdit
      Left = 7
      Top = 247
      Width = 209
      Height = 21
      EditLabel.Width = 64
      EditLabel.Height = 13
      EditLabel.Caption = 'Domain name'
      TabOrder = 1
    end
    object CreateDomainButton: TButton
      Left = 7
      Top = 274
      Width = 75
      Height = 25
      Caption = 'Create'
      TabOrder = 2
      OnClick = CreateDomainButtonClick
    end
    object DeleteDomainButton: TButton
      Left = 141
      Top = 274
      Width = 75
      Height = 25
      Caption = 'Delete'
      TabOrder = 3
      OnClick = DeleteDomainButtonClick
    end
    object DomainMetadataListBox: TListBox
      Left = 2
      Top = 305
      Width = 221
      Height = 119
      Align = alBottom
      ItemHeight = 13
      TabOrder = 4
    end
  end
  object LogListBox: TListBox
    Left = 0
    Top = 768
    Width = 684
    Height = 100
    AutoComplete = False
    Align = alBottom
    ItemHeight = 13
    TabOrder = 2
  end
  object DataGroupBox: TGroupBox
    Left = 239
    Top = 87
    Width = 436
    Height = 426
    Caption = 'Data'
    TabOrder = 3
    object ItemsLabel: TLabel
      Left = 16
      Top = 199
      Width = 27
      Height = 13
      Caption = 'Items'
    end
    object AttributesLabel: TLabel
      Left = 200
      Top = 199
      Width = 48
      Height = 13
      Caption = 'Attributes'
    end
    object ItemNameEdit: TLabeledEdit
      Left = 16
      Top = 40
      Width = 241
      Height = 21
      EditLabel.Width = 51
      EditLabel.Height = 13
      EditLabel.Caption = 'Item name'
      TabOrder = 0
    end
    object AttributeNameEdit: TLabeledEdit
      Left = 16
      Top = 88
      Width = 193
      Height = 21
      EditLabel.Width = 72
      EditLabel.Height = 13
      EditLabel.Caption = 'Attribute name'
      TabOrder = 1
    end
    object AttributeValueEdit: TLabeledEdit
      Left = 224
      Top = 88
      Width = 193
      Height = 21
      EditLabel.Width = 72
      EditLabel.Height = 13
      EditLabel.Caption = 'Attribute value'
      TabOrder = 2
    end
    object ReplaceDataCheckBox: TCheckBox
      Left = 16
      Top = 128
      Width = 153
      Height = 17
      Caption = 'replace existing value'
      Checked = True
      State = cbChecked
      TabOrder = 3
    end
    object PutAttributeButton: TButton
      Left = 264
      Top = 124
      Width = 155
      Height = 25
      Caption = 'Put attribute'
      TabOrder = 4
      OnClick = PutAttributeButtonClick
    end
    object DomainItemsListBox: TListBox
      Left = 16
      Top = 215
      Width = 177
      Height = 200
      ItemHeight = 13
      TabOrder = 5
      OnClick = DomainItemsListBoxClick
    end
    object DeleteItemButton: TButton
      Left = 16
      Top = 168
      Width = 178
      Height = 25
      Caption = 'Delete item'
      TabOrder = 6
      OnClick = DeleteItemButtonClick
    end
    object ItemAttributesListBox: TListBox
      Left = 199
      Top = 215
      Width = 218
      Height = 200
      ItemHeight = 13
      TabOrder = 7
    end
    object DeleteAttributeButton: TButton
      Left = 200
      Top = 168
      Width = 217
      Height = 25
      Caption = 'Delete attribute'
      TabOrder = 8
      OnClick = DeleteAttributeButtonClick
    end
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 519
    Width = 667
    Height = 243
    Caption = 'Query'
    TabOrder = 4
    object QueryEdit: TEdit
      Left = 16
      Top = 24
      Width = 545
      Height = 21
      TabOrder = 0
    end
    object SearchButton: TButton
      Left = 576
      Top = 24
      Width = 75
      Height = 25
      Caption = 'Search'
      TabOrder = 1
      OnClick = SearchButtonClick
    end
    object QueryResultStringGrid: TStringGrid
      Left = 2
      Top = 55
      Width = 663
      Height = 186
      Align = alBottom
      ColCount = 20
      DefaultColWidth = 128
      RowCount = 1
      FixedRows = 0
      TabOrder = 2
    end
  end
  object AmazonConnectionInfo: TAmazonConnectionInfo
    Protocol = 'http'
    RequestProxyPort = 0
    ConsistentRead = True
    TableEndpoint = 'sdb.amazonaws.com'
    QueueEndpoint = 'queue.amazonaws.com'
    StorageEndpoint = 's3.amazonaws.com'
    UseDefaultEndpoints = True
    Left = 608
  end
end
