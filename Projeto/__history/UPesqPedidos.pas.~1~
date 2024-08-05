unit UPesqPedidos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Data.DB,
  Vcl.Grids, Vcl.DBGrids, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.Oracle,
  FireDAC.Phys.OracleDef, FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client, UCadPedidos,
  ppProd, ppClass, ppReport, ppComm, ppRelatv, ppDB, ppDBPipe, ppBands, ppCache,
  ppDesignLayer, ppParameter, ppVar, ppCtrls, ppPrnabl;

type
  TfrmPedidos = class(TForm)
    PainelTopo: TPanel;
    Bimprimir: TButton;
    Label1: TLabel;
    ELocalizar: TEdit;
    BLocalizar: TButton;
    BIncluir: TButton;
    BAlterar: TButton;
    BExcluir: TButton;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    ConnectDb: TFDConnection;
    QueryDb: TFDQuery;
    SourceDb: TDataSource;
    QueryAuxiliar: TFDQuery;
    QueryTabelaAux: TFDQuery;
    DataSourceAux: TDataSource;
    ppDBPipeline1: TppDBPipeline;
    ppReport1: TppReport;
    DSReport: TDataSource;
    QueryReport: TFDQuery;
    ppParameterList1: TppParameterList;
    ppDesignLayers1: TppDesignLayers;
    ppDesignLayer1: TppDesignLayer;
    ppHeaderBand1: TppHeaderBand;
    ppDetailBand1: TppDetailBand;
    ppFooterBand1: TppFooterBand;
    ppLabel1: TppLabel;
    ppLabel2: TppLabel;
    ppDBText1: TppDBText;
    ppLabel3: TppLabel;
    ppDBText2: TppDBText;
    ppLabel4: TppLabel;
    ppDBText3: TppDBText;
    ppLabel5: TppLabel;
    ppLabel6: TppLabel;
    ppDBText4: TppDBText;
    ppLabel7: TppLabel;
    ppDBText5: TppDBText;
    ppLabel8: TppLabel;
    ppLabel9: TppLabel;
    ppDBText6: TppDBText;
    ppLabel10: TppLabel;
    ppLabel11: TppLabel;
    ppDBText7: TppDBText;
    ppLabel12: TppLabel;
    ppDBText8: TppDBText;
    ppSystemVariable1: TppSystemVariable;
    ppLabel13: TppLabel;
    procedure BIncluirClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BAlterarClick(Sender: TObject);
    procedure BExcluirClick(Sender: TObject);
    procedure BLocalizarClick(Sender: TObject);
    procedure QueryDbAfterScroll(DataSet: TDataSet);
    procedure BimprimirClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPedidos: TfrmPedidos;

implementation

{$R *.dfm}

procedure TfrmPedidos.BAlterarClick(Sender: TObject);
var
  frmManutencaoPedidos: TfrmManutencaoPedidos;
  numero_pedido: Integer;
  data_pedido: TDateTime;
begin
  // Obter o numero_pedido a partir do grid
  numero_pedido := QueryDb.FieldByName('numero_pedido').AsInteger;

  frmManutencaoPedidos := TfrmManutencaoPedidos.Create(Self);
  try
    frmManutencaoPedidos.Modo := 'Alterar';

    with QueryAuxiliar do
    begin
      // Consultar a data_pedido da tabela C_Pedidos
      SQL.Text := 'SELECT data_pedido FROM C_Pedidos WHERE numero_pedido = :numero_pedido';
      ParamByName('numero_pedido').AsInteger := numero_pedido;
      Open;
    end;
    

    // Verificar se a consulta retornou algum resultado
    if not QueryAuxiliar.IsEmpty then
    begin
      data_pedido := QueryDb.FieldByName('data_pedido').AsDateTime;
      // Atribuir valores ao formulário
      frmManutencaoPedidos.DTDataPedido.Date := data_pedido;
      frmManutencaoPedidos.ECadPedido.Text := numero_pedido.ToString;
    end
    else
    begin
      ShowMessage('Pedido não encontrado.');
      Exit;
    end;

    with QueryAuxiliar do
    begin
      Close;

      // Mover os itens existentes do pedido para a tabela temporária T_SavProd
      SQL.Text := 'INSERT INTO T_SavProd (codigo_produto, quantidade, valor_unitario, valor_total) ' +
                  '     SELECT c.codigo_produto, c.quantidade, p.valor_unitario, c.valor_total     ' +
                  '       FROM C_Itens c                                                           ' +
                  '       JOIN C_Produtos p                                                        ' +
                  '         ON c.codigo_produto = p.codigo_produto                                 ' +
                  '      WHERE c.numero_pedido = :numero_pedido                                    ' ;
      ParamByName('numero_pedido').AsInteger := numero_pedido;
      ExecSQL;
    end;

    with frmManutencaoPedidos do 
    begin
      ECadPedido.Enabled := False;
      ShowModal;
    end; 
    
  finally
    frmManutencaoPedidos.Free;
  end;
end;

procedure TfrmPedidos.BExcluirClick(Sender: TObject);
var
  numero_pedido: Integer;
begin
  numero_pedido := DBGrid1.DataSource.DataSet.FieldByName('numero_pedido').AsInteger;
  // Verificar se o pedido está selecionado
  if numero_pedido = Null then
  begin
    ShowMessage('Por favor, selecione um pedido para excluir.');
    Exit;
  end;

  // Confirmar exclusão com o usuário
  if MessageDlg('Tem certeza que deseja excluir este pedido?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    try

      with QueryAuxiliar do
      begin
        // Excluir itens associados ao pedido da tabela C_Itens
        SQL.Text := 'DELETE FROM C_Itens WHERE numero_pedido = :numero_pedido';
        ParamByName('numero_pedido').AsInteger := numero_pedido;
        ExecSQL;

        // Excluir pedido da tabela C_Pedidos
        SQL.Text := 'DELETE FROM C_Pedidos WHERE numero_pedido = :numero_pedido';
        ParamByName('numero_pedido').AsInteger := numero_pedido;
        ExecSQL;
      end;

      // Informar o usuário e atualizar a visualização
      ShowMessage('Pedido excluído com sucesso!');
      QueryDb.Refresh;
    except
      on E: Exception do
      begin
        // Desfazer transação em caso de erro
        frmPedidos.ConnectDb.Rollback;
        ShowMessage('Erro ao excluir o pedido: ' + E.Message);
      end;
    end;
  end;
end;

procedure TfrmPedidos.BimprimirClick(Sender: TObject);
var
  numero_pedido: integer;
begin
  numero_pedido := QueryDb.FieldByName('numero_pedido').AsInteger;

  with QueryReport do
  begin
    SQL.Text :='SELECT * FROM (                                               '+
               '       SELECT ci.*,                                           '+
               '               cp.data_pedido,                                '+
               '               cp.valor_total "TOTAL PEDIDOS",                '+
               '               p.valor_unitario,                              '+
               '               p.descricao_produto                            '+
               '         FROM C_ITENS ci                                      '+
               '   INNER JOIN C_PEDIDOS cp                                    '+
               '           ON ci.numero_pedido = cp.numero_pedido             '+
               '   INNER JOIN C_PRODUTOS p                                    '+
               '           ON ci.codigo_produto = p.codigo_produto            '+
               '        WHERE ci.numero_pedido = :numero_pedido               '+
               '     ORDER BY ci.numero_pedido)                               ';
    ParamByName('numero_pedido').AsInteger := numero_pedido;
    Open;
    end;
    ppReport1.DataPipeline := ppDBPipeline1;
    ppReport1.Print;
end;

procedure TfrmPedidos.BIncluirClick(Sender: TObject);
var
  frmManutencaoPedidos: TfrmManutencaoPedidos;
begin
  frmManutencaoPedidos := TfrmManutencaoPedidos.Create(Self);
  try     
    frmManutencaoPedidos.Modo := 'Incluir';
    frmManutencaoPedidos.ShowModal
  finally
    frmManutencaoPedidos.Free;
  end;

end;

procedure TfrmPedidos.BLocalizarClick(Sender: TObject);
var
  numeroPedido: string;
begin
  numeroPedido := ELocalizar.Text;

  with QueryDb do
  begin
    SQL.Text := 'SELECT * FROM C_PEDIDOS '+
                '        WHERE numero_pedido '+
                '         LIKE :numero_pedido'+
                '     ORDER BY numero_pedido';
    Params.ParamByName('numero_pedido').AsString := '%' + numeroPedido + '%';
    Open;
  end;
  if QueryDb.IsEmpty then
    ShowMessage('Nenhum pedido encontrado com o número especificado.');
end;

procedure TfrmPedidos.FormCreate(Sender: TObject);
begin
  with QueryDb do
  begin
    SQL.Text := 'SELECT * FROM (              '+
                '       SELECT *              '+
                '         FROM C_PEDIDOS      '+
                '     ORDER BY numero_pedido) ';
    Open;
    AfterScroll := QueryDbAfterScroll;
    Open;
  end;
end;
procedure TfrmPedidos.QueryDbAfterScroll(DataSet: TDataSet);
var
  numero_pedido: string;
begin
  // Obter o número do pedido selecionado
  numero_pedido := QueryDb.FieldByName('numero_pedido').AsString;

  // Atualizar a consulta dos itens
  with QueryTabelaAux do
  begin
    Close;
    SQL.Text := 'SELECT * FROM (                                '+
                '       SELECT *                                '+
                '         FROM C_ITENS                          '+
                '        WHERE numero_pedido = :numero_pedido   '+
                '     ORDER BY codigo_produto)';
    ParamByName('numero_pedido').AsString := numero_pedido;
    Open;
  end;
end;

end.


