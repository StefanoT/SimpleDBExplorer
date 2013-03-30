//**********************************************************************
//  Copyright(c) Stefano Tommesani 2012
//  License: Code Project Open License (CPOL) 1.02
//     http://www.codeproject.com/info/cpol10.aspx
//     - Source Code and Executable Files can be used in commercial
//       applications;
//     - Source Code and Executable Files can be redistributed;
//     - Source Code can be modified to create derivative works.
//     - No claim of suitability, guarantee, or any warranty whatsoever
//       is provided. The software is provided "as-is".
//     - The Article(s) accompanying the Work may not be distributed or
//       republished without the Author's consent
//
//
//  Author: Stefano Tommesani
//  Revision History:
//    June 30th, 2012: first release
//**********************************************************************
//  Purpose:
//  Amazon SimpleDB demo
//**********************************************************************

unit SimpleDBExplorerUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Data.Cloud.CloudAPI, Data.Cloud.AmazonAPI, Data.Cloud.AmazonAPIEx, Vcl.Grids, System.Generics.Collections;

type
  TSimpleDBExplorerForm = class(TForm)
    AmazonConnectionInfo: TAmazonConnectionInfo;
    AccountInfoGroupBox: TGroupBox;
    AccountNameEdit: TLabeledEdit;
    AccountKeyEdit: TLabeledEdit;
    ConnectButton: TButton;
    DomainsGroupBox: TGroupBox;
    DomainsListBox: TListBox;
    DomainNameEdit: TLabeledEdit;
    CreateDomainButton: TButton;
    DeleteDomainButton: TButton;
    LogListBox: TListBox;
    DomainMetadataListBox: TListBox;
    DataGroupBox: TGroupBox;
    ItemNameEdit: TLabeledEdit;
    AttributeNameEdit: TLabeledEdit;
    AttributeValueEdit: TLabeledEdit;
    ReplaceDataCheckBox: TCheckBox;
    PutAttributeButton: TButton;
    DomainItemsListBox: TListBox;
    DeleteItemButton: TButton;
    ItemAttributesListBox: TListBox;
    ItemsLabel: TLabel;
    AttributesLabel: TLabel;
    DeleteAttributeButton: TButton;
    GroupBox1: TGroupBox;
    QueryEdit: TEdit;
    SearchButton: TButton;
    QueryResultStringGrid: TStringGrid;
    procedure ConnectButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CreateDomainButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DeleteDomainButtonClick(Sender: TObject);
    procedure DomainsListBoxClick(Sender: TObject);
    procedure PutAttributeButtonClick(Sender: TObject);
    procedure DomainItemsListBoxClick(Sender: TObject);
    procedure DeleteItemButtonClick(Sender: TObject);
    procedure DeleteAttributeButtonClick(Sender: TObject);
    procedure SearchButtonClick(Sender: TObject);
  private
    SimpleDBService : TAmazonTableServiceEx;
    procedure RefreshDomainsList;
    procedure LogMessage(MessageText : string);
    procedure LogResponseInfo(ResponseInfo : TCloudResponseInfo);
    procedure RefreshDomainMetadata(DomainName : string);
    procedure RefreshDomainItems(DomainName : string);
    procedure RefreshItemAttributes(DomainName : string; ItemName : string);
  public
    { Public declarations }
  end;

var
  SimpleDBExplorerForm: TSimpleDBExplorerForm;

implementation

uses Xml.XMLIntf, Xml.XMLDoc;

{$R *.dfm}

// TSimpleDBExplorerForm

procedure TSimpleDBExplorerForm.ConnectButtonClick(Sender: TObject);
begin
  AmazonConnectionInfo.AccountName := AccountNameEdit.Text;
  AmazonConnectionInfo.AccountKey := AccountKeyEdit.Text;

  SimpleDBService := TAmazonTableServiceEx.Create(AmazonConnectionInfo);
  RefreshDomainsList();
end;

procedure TSimpleDBExplorerForm.CreateDomainButtonClick(Sender: TObject);
var DomainName : string;
    ResponseInfo : TCloudResponseInfo;
begin
  if Assigned(SimpleDBService) then
        begin
          DomainName := DomainNameEdit.Text;
          LogMessage('Creating domain ' + DomainName);
          ResponseInfo := TCloudResponseInfo.Create();
          try
            SimpleDBService.CreateTable(DomainName, ResponseInfo);
            LogResponseInfo(ResponseInfo);
          finally
            ResponseInfo.Free;
          end;
          RefreshDomainsList();
        end;
end;

procedure TSimpleDBExplorerForm.DeleteAttributeButtonClick(Sender: TObject);
var DomainName : string;
    ItemName : string;
    AttributeName : string;
    ResponseInfo: TCloudResponseInfo;
    ColumnList : TStringList;
begin
  if Assigned(SimpleDBService) and (DomainsListBox.ItemIndex >= 0) and (DomainItemsListBox.ItemIndex >= 0) and (ItemAttributesListBox.ItemIndex >= 0) then
     begin
       DomainName := DomainsListBox.Items[DomainsListBox.ItemIndex];
       ItemName := DomainItemsListBox.Items[DomainItemsListBox.ItemIndex];
       AttributeName := ItemAttributesListBox.Items.Names[ItemAttributesListBox.ItemIndex];
       LogMessage('Deleting attribute ' + AttributeName + ' of item ' + ItemName + ' from domain ' + DomainName);
       ResponseInfo := TCloudResponseInfo.Create();
       try
         ColumnList := TStringList.Create;
         try
           ColumnList.Add(AttributeName);
           SimpleDBService.DeleteColumns(DomainName, ItemName, ColumnList, ResponseInfo);
           LogResponseInfo(ResponseInfo);
         finally
           ColumnList.Free;
         end;
       finally
         ResponseInfo.Free;
       end;
       RefreshDomainMetadata(DomainName);
       RefreshDomainItems(DomainName);
       RefreshItemAttributes(DomainName, ItemName);
     end;
end;

procedure TSimpleDBExplorerForm.DeleteDomainButtonClick(Sender: TObject);
var ResponseInfo: TCloudResponseInfo;
    DomainName : string;
begin
  if Assigned(SimpleDBService) and (DomainsListBox.ItemIndex >= 0) then
        begin
          DomainName := DomainsListBox.Items[DomainsListBox.ItemIndex];
          LogMessage('Deleting domain ' + DomainName);
          ResponseInfo := TCloudResponseInfo.Create();
          try
            SimpleDBService.DeleteTable(DomainName, ResponseInfo);
            LogResponseInfo(ResponseInfo);
          finally
            ResponseInfo.Free;
          end;
          RefreshDomainsList();
        end;
end;

procedure TSimpleDBExplorerForm.DeleteItemButtonClick(Sender: TObject);
var DomainName : string;
    ItemName : string;
    ResponseInfo: TCloudResponseInfo;
begin
  if Assigned(SimpleDBService) and (DomainsListBox.ItemIndex >= 0) and (DomainItemsListBox.ItemIndex >= 0) then
     begin
       DomainName := DomainsListBox.Items[DomainsListBox.ItemIndex];
       ItemName := DomainItemsListBox.Items[DomainItemsListBox.ItemIndex];
       LogMessage('Deleting item ' + ItemName + ' from domain ' + DomainName);
       ResponseInfo := TCloudResponseInfo.Create();
       try
         SimpleDBService.DeleteRow(DomainName, ItemName, ResponseInfo);
         LogResponseInfo(ResponseInfo);
       finally
         ResponseInfo.Free;
       end;
       RefreshDomainMetadata(DomainName);
       RefreshDomainItems(DomainName);
     end;
end;

procedure TSimpleDBExplorerForm.DomainItemsListBoxClick(Sender: TObject);
var ItemName : string;
    DomainName : string;
begin
  if DomainItemsListBox.ItemIndex >= 0 then
     begin
       ItemName := DomainItemsListBox.Items[DomainItemsListBox.ItemIndex];
       ItemNameEdit.Text := ItemName;

       if DomainsListBox.ItemIndex >= 0 then
          begin
          DomainName := DomainsListBox.Items[DomainsListBox.ItemIndex];
          RefreshItemAttributes(DomainName, ItemName);
          end;
     end;
end;

procedure TSimpleDBExplorerForm.DomainsListBoxClick(Sender: TObject);
var DomainName : string;
begin
  if DomainsListBox.ItemIndex >= 0 then
     begin
     DomainName := DomainsListBox.Items[DomainsListBox.ItemIndex];
     RefreshDomainMetadata(DomainName);
     RefreshDomainItems(DomainName);
     QueryEdit.Text := 'SELECT * FROM ' + DomainName;
     end;
end;

procedure TSimpleDBExplorerForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if Assigned(SimpleDBService) then
        begin
          SimpleDBService.Free();
        end;
end;

procedure TSimpleDBExplorerForm.FormCreate(Sender: TObject);
begin
  SimpleDBService := nil;
end;

procedure TSimpleDBExplorerForm.RefreshDomainsList;
var ResponseInfo : TCloudResponseInfo;
    TablesList : TStrings;
begin
  DomainsListBox.Items.Clear;
  if Assigned(SimpleDBService) then
        begin
        LogMessage('Querying domains');
        ResponseInfo := TCloudResponseInfo.Create();
        try
          TablesList := SimpleDBService.QueryTables('', 0, ResponseInfo);
          if Assigned(TablesList) then
             begin
             DomainsListBox.Items.AddStrings(TablesList);
             TablesList.Free;
             end;
          LogResponseInfo(ResponseInfo);
        finally
          ResponseInfo.Free;
        end;
        end;
end;

procedure TSimpleDBExplorerForm.LogMessage(MessageText : string);
begin
  LogListBox.Items.Insert(0, '[' + DateTimeToStr(Now()) + '] - ' + MessageText);
end;

procedure TSimpleDBExplorerForm.LogResponseInfo(ResponseInfo : TCloudResponseInfo);
begin
  LogMessage(ResponseInfo.StatusMessage + '(' + IntToStr(ResponseInfo.StatusCode) + ')');
end;

procedure TSimpleDBExplorerForm.PutAttributeButtonClick(Sender: TObject);
var ResponseInfo : TCloudResponseInfo;
    DomainName : string;
    AttributeName : string;
    AttributeValue : string;
    ItemName : string;
    ReplaceData : boolean;
    NewRow: TCloudTableRow;
begin
  if Assigned(SimpleDBService) then
        begin
        DomainName := DomainsListBox.Items[DomainsListBox.ItemIndex];
        ItemName := ItemNameEdit.Text;
        AttributeName := AttributeNameEdit.Text;
        AttributeValue := AttributeValueEdit.Text;
        ReplaceData := ReplaceDataCheckBox.Checked;

        LogMessage('Putting attribute ' + AttributeName + ' = ' + AttributeValue + ' of item ' + ItemName);
        ResponseInfo := TCloudResponseInfo.Create();
        try
          NewRow := TCloudTableRow.Create();
          try
             NewRow.SetColumn(AttributeName, AttributeValue, '', ReplaceData);
             SimpleDBService.InsertRow(DomainName, ItemName, NewRow, nil, false, ResponseInfo);
             LogResponseInfo(ResponseInfo);
          finally
            NewRow.Free;
          end;
        finally
          ResponseInfo.Free;
        end;
        RefreshDomainMetadata(DomainName);
        RefreshDomainItems(DomainName);
        RefreshItemAttributes(DomainName, ItemName);
        end;
end;

procedure TSimpleDBExplorerForm.RefreshDomainMetadata(DomainName : string);
var ResponseInfo : TCloudResponseInfo;
    TableMetadata : TStrings;
begin
  DomainMetadataListBox.Items.Clear;
  if Assigned(SimpleDBService) then
        begin
        LogMessage('Getting metadata for domain ' + DomainName);
        ResponseInfo := TCloudResponseInfo.Create();
        try
          TableMetadata := SimpleDBService.GetTableMetadata(DomainName, ResponseInfo);
          if Assigned(TableMetadata) then
             begin
             DomainMetadataListBox.Items.AddStrings(TableMetadata);
             TableMetadata.Free;
             end;
          LogResponseInfo(ResponseInfo);
        finally
          ResponseInfo.Free;
        end;
        end;
end;

procedure TSimpleDBExplorerForm.RefreshDomainItems(DomainName : string);
var ResponseInfo : TCloudResponseInfo;
    DomainList : TStrings;
begin
  DomainItemsListBox.Items.Clear;
  if Assigned(SimpleDBService) then
        begin
        LogMessage('Getting item IDs for domain ' + DomainName);
        ResponseInfo := TCloudResponseInfo.Create();
        try
          DomainList := SimpleDBService.GetRowIDs(DomainName, 0, ResponseInfo);
          if Assigned(DomainList) then
             begin
             DomainItemsListBox.Items.AddStrings(DomainList);
             DomainList.Free;
             end;
          LogResponseInfo(ResponseInfo);
        finally
          ResponseInfo.Free;
        end;
        end;
end;

procedure TSimpleDBExplorerForm.RefreshItemAttributes(DomainName : string; ItemName : string);
var ResponseInfo : TCloudResponseInfo;
    RowResult : TCloudTableRow;
    AttributeCounter : integer;
begin
  ItemAttributesListBox.Items.Clear;
  if Assigned(SimpleDBService) then
        begin
        LogMessage('Getting attributes for item ' + ItemName + ' of domain ' + DomainName);
        ResponseInfo := TCloudResponseInfo.Create();
        try
          RowResult := SimpleDBService.GetAttributes(DomainName, ItemName, ResponseInfo);
          LogResponseInfo(ResponseInfo);
          for AttributeCounter := 0 to Pred(RowResult.Columns.Count) do
              ItemAttributesListBox.Items.Add(RowResult.Columns[AttributeCounter].Name + '=' + RowResult.Columns[AttributeCounter].Value);
          RowResult.Free;
        finally
          ResponseInfo.Free;
        end;
        end;
end;

procedure TSimpleDBExplorerForm.SearchButtonClick(Sender: TObject);
var ResponseInfo : TCloudResponseInfo;
    QueryResultRows : TList<TCloudTableRow>;
    QueryResultRow : TCloudTableRow;
    RowIndex : integer;
    AttributeCounter: Integer;
begin
  QueryResultStringGrid.RowCount := 0;
  if Assigned(SimpleDBService) then
        begin
        LogMessage('Run Query ' + QueryEdit.Text);
        ResponseInfo := TCloudResponseInfo.Create();
        try
          QueryResultRows := SimpleDBService.SelectRows(QueryEdit.Text, ResponseInfo, '');
          if Assigned(QueryResultRows) then
          begin
            try
              QueryResultStringGrid.RowCount := QueryResultRows.Count;
              LogMessage('Rows in query result ' + IntToStr(QueryResultRows.Count));
              for RowIndex := 0 to Pred(QueryResultRows.Count) do
                  begin
                  QueryResultRow := QueryResultRows[RowIndex];
                  for AttributeCounter := 0 to Pred(QueryResultRow.Columns.Count) do
                      QueryResultStringGrid.Cells[AttributeCounter, RowIndex] := QueryResultRow.Columns[AttributeCounter].Name + '=' + QueryResultRow.Columns[AttributeCounter].Value;
                  QueryResultRow.Free;
                  end;
            finally
              QueryResultRows.Free;
            end;
          end;
          LogResponseInfo(ResponseInfo);
        finally
          ResponseInfo.Free;
        end;
        end;
end;

end.
