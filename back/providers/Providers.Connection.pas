unit Providers.Connection;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.Client, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Phys.IBBase, Vcl.Dialogs, System.JSON,
  DataSet.Serialize;

type
  TProviderConnection = class(TDataModule)
    con: TFDConnection;
    FDPhysFBDriverLink: TFDPhysFBDriverLink;
    FDQuery: TFDQuery;
    FDTransaction: TFDTransaction;
    procedure DataModuleCreate(Sender: TObject);
  private
    procedure ConnectToDatabase;
    procedure HandleConnectionError(E: Exception);
  public
    constructor Create; reintroduce;
    function ExecuteScalar(SQL: string): Variant;
    function ExecuteReader(SQL: string): OleVariant;
    procedure ExecuteCommand(SQL: string; Parametros: array of Variant;
      NomesParametrosSQL: array of string);
  end;

var
  ProviderConnection: TProviderConnection;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

constructor TProviderConnection.Create;
begin
  inherited Create(nil);
end;

procedure TProviderConnection.DataModuleCreate(Sender: TObject);
begin
  Self.ConnectToDatabase();
end;

procedure TProviderConnection.ExecuteCommand(SQL: string;
  Parametros: array of Variant; NomesParametrosSQL: array of string);
begin
  FDQuery.Close;
  FDQuery.SQL.Text := SQL;

  for var i := Low(Parametros) to High(Parametros) do
    FDQuery.ParamByName(NomesParametrosSQL[i]).Value := Parametros[i];

  FDQuery.ExecSQL;
end;

function TProviderConnection.ExecuteReader(SQL: string): OleVariant;
begin
  FDQuery.Close;
  FDQuery.SQL.Text := SQL;
  FDQuery.Open;

  result := FDQuery.Data;
end;

function TProviderConnection.ExecuteScalar(SQL: string): Variant;
begin
  FDQuery.Close;
  FDQuery.SQL.Text := SQL;
  FDQuery.Open;

  result := FDQuery.Fields[0].AsString;
end;

procedure TProviderConnection.ConnectToDatabase;
begin
  try
    con.Connected := True;
  except
    on E: Exception do
      HandleConnectionError(E);
  end;
end;

procedure TProviderConnection.HandleConnectionError(E: Exception);
begin
  var
  auxError := Copy(E.Message, 20, 500);
  MessageDlg('Erro ao conectar com o banco de dados.' + sLineBreak + 'Motivo:' +
    sLineBreak + auxError, TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], 0);
end;

end.