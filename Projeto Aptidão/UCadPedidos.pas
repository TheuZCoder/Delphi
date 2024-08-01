unit UCadPedidos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls,
  Data.DB, Vcl.Grids, Vcl.DBGrids, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.Oracle,
  FireDAC.Phys.OracleDef, FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client, UCadItens;

type
  TfrmManutencaoPedidos = class(TForm)
    PanelTop: TPanel;
    Label1: TLabel;
    ECadPedido: TEdit;
    Label2: TLabel;
    DTDataPedido: TDateTimePicker;
    PanelSub: TPanel;
    Label3: TLabel;
    DBGrid1: TDBGrid;
    PanelLow: TPanel;
    BSalvar: TButton;
    BCancelar: TButton;
    BIncluir: TButton;
    BAlterar: TButton;
    BExcluir: TButton;
    QueryCadPedido: TFDQuery;
    SourceDb: TDataSource;
    QueryCadPedidoAux: TFDQuery;
    QueryInsertCad: TFDQuery;
    procedure BIncluirClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure BSalvarClick(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure BExcluirClick(Sender: TObject);
    procedure BAlterarClick(Sender: TObject);
  private
    FModo: string;
    FNumeroPedido: string;
    FDataPedido: TDateTime;
  public
    property Modo: string read FModo write FModo;
    property NumeroPedido: string read FNumeroPedido write FNumeroPedido;
    property DataPedido: TDateTime read FDataPedido write FDataPedido;
  end;

var
  frmManutencaoPedidos: TfrmManutencaoPedidos;

implementation
uses
UPesqPedidos;

{$R *.dfm}

procedure TfrmManutencaoPedidos.BAlterarClick(Sender: TObject);
var
  frmCadItens: TFrmCadastroItens;
  codigo_produto: string;
  descricao_produto: string;
  quantidade_produto: string;
begin
 frmCadItens := TFrmCadastroItens.Create(Self);
 codigo_produto := DBGrid1.DataSource.DataSet.FieldByName('codigo_produto').AsString;
 quantidade_produto := DBGrid1.DataSource.DataSet.FieldByName('quantidade').AsString;
 try
  with QueryCadPedidoAux do
  begin
    SQL.Text := 'SELECT descricao_produto '+
                '  FROM C_Produtos '+
                ' WHERE codigo_produto = :codigo_produto';
    ParamByName('codigo_produto').AsString := codigo_produto;
    Open;
  end;
  frmCadItens.CBCodProd.Text := codigo_produto;
  frmCadItens.EDescProduto.Text := QueryCadPedidoAux.FieldByName('descricao_produto').AsString;
  frmCadItens.EQuantidade.Text := quantidade_produto;
  frmCadItens.CBCodProd.Enabled := False;
  frmCadItens.EDescProduto.Enabled := False;
  frmCadItens.Modo := 'Alterar';
  frmCadItens.ShowModal;
 finally
  frmCadItens.Free;
  OnActivate(Self);
 end;
end;

procedure TfrmManutencaoPedidos.BCancelarClick(Sender: TObject);
begin
  frmPedidos.QueryDb.Refresh;
  QueryCadPedidoAux.SQL.Text := 'DELETE FROM T_SavProd';
  QueryCadPedidoAux.ExecSQL;
  Close;
end;

procedure TfrmManutencaoPedidos.BExcluirClick(Sender: TObject);
var
  codigo_produto: string;
begin
  codigo_produto := QueryCadPedido.FieldByName('codigo_produto').AsString;
  if codigo_produto = '' then
  begin
    ShowMessage('Por favor, selecione um produto para excluir.');
    Exit;
  end;

  // Confirmar exclusão com o usuário
  if MessageDlg('Tem certeza que deseja excluir este produto?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    try
    with QueryCadPedidoAux do
    begin
      // Excluir produtos associados a tabela T_SAVPROD
      SQL.Text := 'DELETE FROM T_SAVPROD '+
                  '      WHERE codigo_produto = :codigo_produto';
      ParamByName('codigo_produto').AsString := codigo_produto;
      ExecSQL;
    end;

      with QueryCadPedido do
        begin
          Refresh;
        end;

      // Informar o usuário e atualizar a visualização
      ShowMessage('Produto excluído!');
    except
      on E: Exception do
      begin
        // Desfazer transação em caso de erro
        ShowMessage('Erro ao excluir o produto: ' + E.Message);
      end;
    end;
  end;
end;

procedure TfrmManutencaoPedidos.BIncluirClick(Sender: TObject);
var
  frmCadItens: TFrmCadastroItens;
begin
 frmCadItens := TFrmCadastroItens.Create(Self);
 try
  frmCadItens.Modo := 'Incluir';
  frmCadItens.ShowModal;
 finally
  frmCadItens.Free;
  OnActivate(Self);
 end;
end;

procedure TfrmManutencaoPedidos.BSalvarClick(Sender: TObject);
var
  valor_total: Double;
  numero_pedido: Integer;
  data_pedido: TDateTime;
  id: Integer;
begin
  numero_pedido := StrToInt(ECadPedido.Text);
  data_pedido := DTDataPedido.Date;

  if Modo = 'Incluir' then
  begin
    try
      with QueryInsertCad do
        begin
            // Inserir o novo pedido na tabela C_Pedidos
          SQL.Text := 'INSERT INTO C_Pedidos (numero_pedido, data_pedido, valor_total) ' +
                      '     VALUES (:numero_pedido, :data_pedido, :valor_total)';
          ParamByName('numero_pedido').AsInteger := numero_pedido;
          ParamByName('data_pedido').AsDate := data_pedido;
          ParamByName('valor_total').AsFloat := 0; // Valor total inicial, atualizado mais tarde
          ExecSQL;
        end;

      valor_total := 0;
      QueryCadPedido.First;

      while not QueryCadPedido.Eof do
      begin
       with QueryInsertCad do
       begin
        // Obter o próximo valor da sequência para a tabela C_Itens
        SQL.Text := 'SELECT c_itens_id.NEXTVAL '+
                    '    AS new_id '+
                    '  FROM dual';
        Open;
        id := QueryInsertCad.FieldByName('new_id').AsInteger;
        Close;

        // Inserir os itens na tabela C_Itens
        SQL.Text := 'INSERT INTO C_Itens ' +
                    '(id, numero_pedido, codigo_produto, quantidade, valor_total) ' +
                    '     VALUES (:id, :numero_pedido, :codigo_produto, :quantidade, :valor_total)';
        ParamByName('id').AsInteger := id;
        ParamByName('numero_pedido').AsInteger := numero_pedido;
        ParamByName('codigo_produto').AsString := QueryCadPedido.FieldByName('codigo_produto').AsString;
        ParamByName('quantidade').AsInteger := QueryCadPedido.FieldByName('quantidade').AsInteger;
        ParamByName('valor_total').AsFloat := QueryCadPedido.FieldByName('valor_unitario').AsFloat * QueryCadPedido.FieldByName('quantidade').AsInteger;
        ExecSQL;

        // Atualizar o valor total do pedido
        valor_total := valor_total + QueryInsertCad.ParamByName('valor_total').AsFloat;

        QueryCadPedido.Next;

       end;

      end;

      with QueryCadPedidoAux do
      begin
         // Atualizar o valor total do pedido na tabela C_Pedidos
      SQL.Text := 'UPDATE C_Pedidos ' +
                  '   SET valor_total = :valor_total ' +
                  ' WHERE numero_pedido = :numero_pedido';
      ParamByName('valor_total').AsFloat := valor_total;
      ParamByName('numero_pedido').AsInteger := numero_pedido;
      ExecSQL;

      // Deletar todos os itens da tabela temporária T_SavProd
      SQL.Text := 'DELETE FROM T_SavProd';
      ExecSQL;
      end;

      with frmPedidos do
      begin
        QueryDb.Refresh;
        QueryTabelaAux.Refresh;
      end;

      ShowMessage('Pedido salvo com sucesso!');
      Close;

    except
      on E: Exception do
      begin
        // Desfazer transação em caso de erro
        frmPedidos.ConnectDb.Rollback;
        ShowMessage('Erro ao salvar o pedido: ' + E.Message);
      end;
    end;
  end
  else if Modo = 'Alterar' then
  begin
    try
      valor_total := 0;
      QueryCadPedido.First;

      // Atualizar itens existentes e adicionar novos
      while not QueryCadPedido.Eof do
      begin
        with QueryCadPedidoAux do
         begin
          SQL.Text := 'SELECT COUNT(*)'+
                      '    AS item_count '+
                      '  FROM C_Itens ' +
                      ' WHERE numero_pedido = :numero_pedido '+
                      '   AND codigo_produto = :codigo_produto';
          ParamByName('numero_pedido').AsInteger := numero_pedido;
          ParamByName('codigo_produto').AsString := QueryCadPedido.FieldByName('codigo_produto').AsString;
          Open;
         end;


        if QueryCadPedidoAux.FieldByName('item_count').AsInteger = 0 then
        begin
          with QueryInsertCad do
           begin
            SQL.Text := 'SELECT c_itens_id.NEXTVAL '+
                        '    AS new_id '+
                        '  FROM dual';
            Open;
            id := QueryInsertCad.FieldByName('new_id').AsInteger;
            Close;
            // Inserir novo item
            SQL.Text := 'INSERT INTO C_Itens ' +
                        '(id, numero_pedido, codigo_produto, quantidade, valor_total) ' +
                        '     VALUES (:id, :numero_pedido, :codigo_produto, :quantidade, :valor_total)';
            ParamByName('id').AsInteger := id;
            ParamByName('numero_pedido').AsInteger := numero_pedido;
            ParamByName('codigo_produto').AsString := QueryCadPedido.FieldByName('codigo_produto').AsString;
            ParamByName('quantidade').AsInteger := QueryCadPedido.FieldByName('quantidade').AsInteger;
            ParamByName('valor_total').AsFloat := QueryCadPedido.FieldByName('valor_unitario').AsFloat * QueryCadPedido.FieldByName('quantidade').AsInteger;
            ExecSQL;
           end;

        end
        else
        begin
          with QueryCadPedidoAux do
           begin
           // Atualizar item existente
            SQL.Text := 'UPDATE C_Itens ' +
                        '   SET quantidade = :quantidade, valor_total = :valor_total ' +
                        ' WHERE numero_pedido = :numero_pedido '+
                        '   AND codigo_produto = :codigo_produto';
            ParamByName('quantidade').AsInteger := QueryCadPedido.FieldByName('quantidade').AsInteger;
            ParamByName('valor_total').AsFloat := QueryCadPedido.FieldByName('valor_unitario').AsFloat * QueryCadPedido.FieldByName('quantidade').AsInteger;
            ParamByName('numero_pedido').AsInteger := numero_pedido;
            ParamByName('codigo_produto').AsString := QueryCadPedido.FieldByName('codigo_produto').AsString;
            ExecSQL;
           end;

        end;

        valor_total := valor_total + QueryCadPedido.FieldByName('valor_total').AsFloat;
        QueryCadPedido.Next;
      end;

      with QueryCadPedidoAux do
       begin

        // Remover itens que não estão mais na tabela temporária
        SQL.Text := 'DELETE FROM C_Itens ' +
                    '      WHERE numero_pedido = :numero_pedido '+
                    '        AND codigo_produto '+
                    '     NOT IN '+
                    '    (SELECT codigo_produto '+
                    '       FROM T_SavProd '+
                    '      WHERE numero_pedido = :numero_pedido)';
        ParamByName('numero_pedido').AsInteger := numero_pedido;
        ExecSQL;

        // Atualizar o valor total do pedido na tabela C_Pedidos
        SQL.Text := 'UPDATE C_Pedidos ' +
                    '   SET data_pedido = :data_pedido, '+
                    '       valor_total = :valor_total ' +
                    ' WHERE numero_pedido = :numero_pedido';
        ParamByName('data_pedido').AsDate := data_pedido;
        ParamByName('valor_total').AsFloat := valor_total;
        ParamByName('numero_pedido').AsInteger := numero_pedido;
        ExecSQL;

        // Deletar todos os itens da tabela temporária T_SavProd
        SQL.Text := 'DELETE FROM T_SavProd';
        ExecSQL;
       end;

      // Confirmar transação
      with frmPedidos do
      begin
        ConnectDb.Commit;
        QueryDb.Refresh;
        QueryTabelaAux.Refresh;
      end;

      ShowMessage('Pedido alterado com sucesso!');
      Close;
    except
      on E: Exception do
      begin
        // Desfazer transação em caso de erro
        frmPedidos.ConnectDb.Rollback;
        ShowMessage('Erro ao alterar o pedido: ' + E.Message);
      end;
    end;
  end;
end;


procedure TfrmManutencaoPedidos.FormActivate(Sender: TObject);
begin
    if QueryCadPedido.Active then
      QueryCadPedido.Refresh
    else
      with  QueryCadPedido do
      begin
        SQL.Text := 'SELECT * FROM (              '+
                    '       SELECT *              '+
                    '         FROM T_SAVPROD      '+
                    '     ORDER BY codigo_produto)';
        Open;
      end;

end;
end.
