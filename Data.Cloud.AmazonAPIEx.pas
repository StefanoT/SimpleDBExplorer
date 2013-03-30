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
//  extends the TAmazonTableService XE2 class to add support for
//   the GetAttributes API call and XML parsing of Select results
//**********************************************************************

unit Data.Cloud.AmazonAPIEx;

interface

uses Data.Cloud.CloudAPI, Data.Cloud.AmazonAPI, Vcl.Grids, System.Generics.Collections;

type
  TAmazonTableServiceEx = class(TAmazonTableService)
                          function GetAttributesXML(const TableName, RowId: String; const
                                                 ResponseInfo: TCloudResponseInfo): String;
                          function GetAttributes(const TableName, RowId: String; const
                                                 ResponseInfo: TCloudResponseInfo): TCloudTableRow;
                          function SelectRows(const SelectStatement: String; ResponseInfo: TCloudResponseInfo;
                                           const NextToken: String): TList<TCloudTableRow>;
  end;

implementation

uses System.Classes, System.SysUtils, Xml.XMLIntf, Xml.XMLDoc;

function TAmazonTableServiceEx.GetAttributesXML(const TableName, RowId: String; const
                                                 ResponseInfo: TCloudResponseInfo): String;
var
  Response: TCloudHTTP;
  QueryParams: TStringList;
begin
  QueryParams := BuildQueryParameters('GetAttributes');

  QueryParams.Values['DomainName'] := TableName;
  QueryParams.Values['ItemName'] := RowId;

  Response := nil;
  try
    Response := IssueRequest(GetConnectionInfo.TableURL, QueryParams, ResponseInfo, Result);
  finally
    if Assigned(Response) then
      FreeAndNil(Response);
    FreeAndNil(QueryParams);
  end;
end;

function TAmazonTableServiceEx.GetAttributes(const TableName, RowId: String; const
                                                 ResponseInfo: TCloudResponseInfo): TCloudTableRow;
var
  xml: String;
  xmlDoc: IXMLDocument;
  ResultNode, ItemNode, NameNode, ValueNode : IXMLNode;
begin
  xml := GetAttributesXML(TableName, RowID, ResponseInfo);

  Result := nil;

  if xml <> EmptyStr then
  begin
    xmlDoc := TXMLDocument.Create(nil);

    try
      xmlDoc.LoadFromXML(xml);
    except
      Exit(Result);
    end;

    Result := TCloudTableRow.Create;

    ResultNode := xmlDoc.DocumentElement.ChildNodes.FindNode('GetAttributesResult');
    if (ResultNode <> nil) and ResultNode.HasChildNodes then
    begin
      ItemNode := ResultNode.ChildNodes.First;

      while (ItemNode <> nil) do
      begin
        try
          if AnsiSameText(ItemNode.NodeName, 'Attribute') then
          begin
            NameNode := ItemNode.ChildNodes.FindNode('Name');
            ValueNode := ItemNode.ChildNodes.FindNode('Value');
            if (NameNode <> nil) and (NameNode.IsTextElement) and (ValueNode <> nil) and (ValueNode.IsTextElement) then
              Result.SetColumn(NameNode.Text, ValueNode.Text);
          end;
        finally
          ItemNode := ItemNode.NextSibling;
        end;
      end;
    end;
  end;
end;

function TAmazonTableServiceEx.SelectRows(const SelectStatement: String; ResponseInfo: TCloudResponseInfo;
                                           const NextToken: String): TList<TCloudTableRow>;
var
  xml: String;
  xmlDoc: IXMLDocument;
  ResultNode, ItemNode, ColumnNode, NameNode, ValueNode: IXMLNode;
  Row: TCloudTableRow;
begin
  xml := SelectRowsXML(SelectStatement, ResponseInfo, NextToken);

  Result := TList<TCloudTableRow>.Create;

  if xml <> EmptyStr then
  begin
    xmlDoc := TXMLDocument.Create(nil);

    try
      xmlDoc.LoadFromXML(xml);
    except
      Exit(Result);
    end;

    ResultNode := xmlDoc.DocumentElement.ChildNodes.FindNode('SelectResult');
    if (ResultNode <> nil) and ResultNode.HasChildNodes then
    begin
      Result := TList<TCloudTableRow>.Create;

      ItemNode := ResultNode.ChildNodes.First;

      while (ItemNode <> nil) do
      begin
        try
          if AnsiSameText(ItemNode.NodeName, 'Item') then
          begin
            ColumnNode := ItemNode.ChildNodes.FindNode('Name');
            if (ColumnNode <> nil) and ColumnNode.IsTextElement then
            begin
              //Amazon doesn't support column datatype info
              Row := TCloudTableRow.Create(False);
              Result.Add(Row);

              Row.SetColumn('itemName()', ColumnNode.Text);

              ColumnNode := ItemNode.ChildNodes.First;
              while (ColumnNode <> nil) do
              begin
                try
                  if AnsiSameText(ColumnNode.NodeName, 'Attribute') and ColumnNode.HasChildNodes then
                  begin
                    NameNode := ColumnNode.ChildNodes.FindNode('Name');
                    ValueNode := ColumnNode.ChildNodes.FindNode('Value');

                    if (NameNode <> nil) and (ValueNode <> nil) and
                        NameNode.IsTextElement and ValueNode.IsTextElement then
                      Row.SetColumn(NameNode.Text, ValueNode.Text, EmptyStr, False); //don't replace, may have multiple values
                  end;
                finally
                  ColumnNode := ColumnNode.NextSibling;
                end;
              end;
            end;
          end;
        finally
          ItemNode := ItemNode.NextSibling;
        end;
      end;
    end;
  end;
end;

end.
