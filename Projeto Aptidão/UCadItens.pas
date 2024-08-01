unit UCadItens;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.Oracle, FireDAC.Phys.OracleDef, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TFrmCadastroItens = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    EDescProduto: TEdit;
    EQuantidade: TEdit;
    CBCodProd: TComboBox;
    BSalvar: TButton;
    BCancelar: TButton;
    QueryProduto: TFDQuery;
    SourceDb: TDataSource;
    QueryProdutoAux: TFDQuery;
    QueryInsertProd: TFDQuery;
    procedure CBCodProdChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure BSalvarClick(Sender: TObject);
  private
    FModo: string;
  public
    property Modo: string read FModo write FModo;
  end;

var
  FrmCadastroItens: TFrmCadastroItens;

implementation
uses
UCadPedidos,UPesqPedidos;

{$R *.dfm}

procedure TFrmCadastroItens.BCancelarClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmCadastroItens.BSalvarClick(Sender: TObject);
var
  codigo_produto: string;
  quantidade: Integer;
  valor_unitario: Double;
  valor_total: Double;
  id: Integer;
  QueryGetValor: TFDQuery;
  QueryGetID: TFDQuery;
  QueryDb: TFDQuery;
begin
  // Obtenha os valores dos campos
  codigo_produto := CBCodProd.Text;
  quantidade := StrToIntDef(EQuantidade.Text, 0);
  if Modo = 'Incluir' then
  begin
     with QueryProdutoAux do
    begin
    // Obtenha o valor unitário do produto
    SQL.Text := 'SELECT valor_unitario '+
                '  FROM C_Produtos '+
                ' WHERE codigo_produto = :codigo_produto';
    ParamByName('codigo_produto').AsString := codigo_produto;
    Open;
    end;
    // Verifique se a consulta retornou resultados
    if not QueryProdutoAux.IsEmpty then
    begin
      valor_unitario := QueryProdutoAux.FieldByName('valor_unitario').AsFloat;

      // Calcule o valor total
      valor_total := quantidade * valor_unitario;

      with QueryInsertProd do
        begin
          // Obtenha o próximo valor da sequênci
          SQL.Text := 'SELECT seq_id.NEXTVAL '+
                      '    AS new_id'+
                      '  FROM dual';
          Open;
          id := QueryInsertProd.FieldByName('new_id').AsInteger;
        end;
      try
        // Insira os dados na tabela temporária
        with QueryProdutoAux do
        begin
          SQL.Text := 'INSERT INTO T_SAVPROD ' +
                      '(id, codigo_produto, quantidade, valor_unitario, valor_total) ' +
                      '     VALUES (:id, :codigo_produto, :quantidade, :valor_unitario, :valor_total)';

          // Defina os parâmetros
          ParamByName('id').AsInteger := id;
          ParamByName('codigo_produto').AsString := codigo_produto;
          ParamByName('quantidade').AsInteger := quantidade;
          ParamByName('valor_unitario').AsFloat := valor_unitario;
          ParamByName('valor_total').AsFloat := valor_total;
          ExecSQL;
        end;

        try
        ShowMessage('Dados salvos com sucesso!');
        Close;
        except
        on E: Exception do
        ShowMessage('Erro ao salvar o item: ' + E.Message);
        end;
      except
        on E: Exception do
        begin
          // Faça rollback em caso de erro
          ShowMessage('Erro ao salvar os dados: ' + E.Message);
        end;
      end;
    end
    else
    begin
      ShowMessage('Produto não encontrado.');
    end;
  end
  else if Modo = 'Alterar' then
  begin
    // Atualizar apenas a quantidade na tabela temporária
    try
      with QueryInsertProd do
      begin
        // Obtenha o valor unitário do produto
        SQL.Text := 'SELECT valor_unitario'+
                    '  FROM C_Produtos'+
                    ' WHERE codigo_produto = :codigo_produto';
        ParamByName('codigo_produto').AsString := codigo_produto;
        Open;
        valor_unitario := QueryInsertProd.FieldByName('valor_unitario').AsFloat;
      end;
      with QueryProdutoAux do
      begin
        // Calcule o valor total
        valor_total := quantidade * valor_unitario;
        SQL.Text := 'UPDATE T_SAVPROD                                         '+
                    '   SET quantidade = :quantidade,                         '+
                    '       valor_total = :valor_total                        '+
                    ' WHERE codigo_produto = :codigo_produto                  ';
        // Calcule o novo valor total
        valor_unitario := QueryInsertProd.FieldByName('valor_unitario').AsFloat;
        valor_total := quantidade * valor_unitario;

        // Defina os parâmetros
        ParamByName('quantidade').AsInteger := quantidade;
        ParamByName('valor_total').AsFloat := valor_total;
        ParamByName('codigo_produto').AsString := codigo_produto;
        ExecSQL;
      end;
      ShowMessage('Quantidade atualizada com sucesso!');
      Close;
    except
      on E: Exception do
      begin
        ShowMessage('Erro ao atualizar o item: ' + E.Message);
      end;
    end;
  end;
end;

procedure TFrmCadastroItens.CBCodProdChange(Sender: TObject);
begin
  try

    QueryProdutoAux.SQL.Text := 'SELECT * FROM ( '+
                                '       SELECT descricao_produto, valor_unitario ' +
                                '         FROM C_Produtos ' +
                                '        WHERE codigo_produto = :codigo_produto)';
    QueryProdutoAux.ParamByName('codigo_produto').AsString := CBCodProd.Text;
    QueryProdutoAux.Open;

    if not QueryProduto.Eof then
    begin
      QueryProduto.First;
      EDescProduto.Text := QueryProdutoAux.FieldByName('descricao_produto').AsString;
    end
    else
    begin
      EDescProduto.Text := '';
    end;
  finally
  end;
end;



procedure TFrmCadastroItens.FormCreate(Sender: TObject);
begin
  with QueryProduto do
    begin
      SQL.Text := 'SELECT * FROM ( '+
                  '       SELECT codigo_produto, descricao_produto '+
                  '         FROM C_Produtos)';
      Open;
    end;
   CBCodProd.Items.Clear;
  while not QueryProduto.Eof do
  begin
    CBCodProd.Items.Add(QueryProduto.FieldByName('codigo_produto').AsString);
    QueryProduto.Next;
  end;
  QueryProduto.First;
end;

end.
