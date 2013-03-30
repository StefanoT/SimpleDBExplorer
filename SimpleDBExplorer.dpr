program SimpleDBExplorer;

uses
  Vcl.Forms,
  SimpleDBExplorerUnit in 'SimpleDBExplorerUnit.pas' {SimpleDBExplorerForm},
  Data.Cloud.AmazonAPIEx in 'Data.Cloud.AmazonAPIEx.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TSimpleDBExplorerForm, SimpleDBExplorerForm);
  Application.Run;
end.
