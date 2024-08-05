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
  TFrmUCadItens = class(TForm)
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
    QProduto: TFDQuery;
    SourceDb: TDataSource;
    QProdutoAux: TFDQuery;
    QInsertProd: TFDQuery;
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
  FrmUCadItens: TFrmUCadItens;

implementation
uses
UCadPedidos,UPesqPedidos;

{$R *.dfm}

procedure TFrmUCadItens.BCancelarClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmUCadItens.BSalvarClick(Sender: TObject);
var
  sCodProd: string;
  iQtd: Integer;
  dValUni: Double;
  dValTotal: Double;
  sCodTab: string;
begin
  // Obtenha os valores dos campos
  sCodProd := CBCodProd.Text;
  iQtd := StrToIntDef(EQuantidade.Text, 0);
  if Modo = 'Incluir' then
  begin
    with QProdutoAux do
    begin
      SQL.Text := 'SELECT PK_Produtos               '+
                  '  FROM T_SAVPROD                 '+
                  ' WHERE PK_Produtos = :pPK_Produtos';
      ParamByName('pPK_Produtos').AsString := sCodProd;
      Open;
    end;

    try
    if not QProdutoAux.IsEmpty then
      begin
        sCodTab := QProdutoAux.FieldByName('PK_Produtos').AsString;
        if sCodProd = sCodTab then
        begin
          ShowMessage('Produto j� inserido no Pedido, ' +
                        'Alterar ou Excluir o j� existente!');
          Close;
          Exit
        end;
      end;
      finally
      QProdutoAux.Close;
    end;

     with QProdutoAux do
    begin
    // Obtenha o valor unit�rio do produto
    SQL.Text := 'SELECT PdtValProd                 '+
                '  FROM C_Produtos                 '+
                ' WHERE PK_Produtos = :pPK_Produtos';
    ParamByName('pPK_Produtos').AsString := sCodProd;
    Open;
    end;
    // Verifique se a consulta retornou resultados
    if not QProdutoAux.IsEmpty then
    begin
      dValUni := QProdutoAux.FieldByName('PdtValProd').AsFloat;

      // Calcule o valor total
      dValTotal := iQtd * dValUni;

      try
        // Insira os dados na tabela tempor�ria
        with QProdutoAux do
        begin
          SQL.Text := 'INSERT INTO T_SAVPROD(PK_Produtos, ItnQtd,'+
                      '            PdtValProd, ItnValItens)      '+
                      '     VALUES (:pPK_Produtos, :pItnQtd,     '+
                      '            :pPdtValProd, :pItnValItens)  ';

          // Defina os par�metros
          ParamByName('pPK_Produtos').AsString := sCodProd;
          ParamByName('pItnQtd').AsInteger := iQtd;
          ParamByName('pPdtValProd').AsFloat := dValUni;
          ParamByName('pItnValItens').AsFloat := dValTotal;
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
          // Fa�a rollback em caso de erro
          ShowMessage('Erro ao salvar os dados: ' + E.Message);
        end;
      end;
    end
    else
    begin
      ShowMessage('Produto n�o encontrado.');
    end;
  end
  else if Modo = 'Alterar' then
  begin
    try
      with QInsertProd do
      begin
        // Obtenha o valor unit�rio do produto
        SQL.Text := 'SELECT PdtValProd                 '+
                    '  FROM C_Produtos                 '+
                    ' WHERE PK_Produtos = :pPK_Produtos';
        ParamByName('pPK_Produtos').AsString := sCodProd;
        Open;
      end;
      with QProdutoAux do
      begin
        SQL.Text := 'UPDATE T_SAVPROD                  '+
                    '   SET ItnQtd = :pItnQtd,         '+
                    '       ItnValItens = :pItnValItens'+
                    ' WHERE PK_Produtos = :pPK_Produtos';
        // Calcule o novo valor total
        dValUni := QInsertProd.FieldByName('PdtValProd').AsFloat;
        dValTotal := iQtd * dValUni;

        // Defina os par�metros
        ParamByName('pItnQtd').AsInteger := iQtd;
        ParamByName('pItnValItens').AsFloat := dValTotal;
        ParamByName('pPK_Produtos').AsString := sCodProd;
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

procedure TFrmUCadItens.CBCodProdChange(Sender: TObject);
begin
  try
    with QProdutoAux do
     begin
       SQL.Text := 'SELECT * FROM (                           '+
                   '       SELECT PdtDescProd, PdtValProd     '+
                   '         FROM C_Produtos                  '+
                   '        WHERE PK_Produtos = :pPK_Produtos)';
      ParamByName('pPK_Produtos').AsString := CBCodProd.Text;
      Open;
     end;


    if not QProduto.Eof then
    begin
      QProduto.First;
      EDescProduto.Text := QProdutoAux.FieldByName('PdtDescProd').AsString;
    end
    else
    begin
      EDescProduto.Text := '';
    end;
  finally
  end;
end;



procedure TFrmUCadItens.FormCreate(Sender: TObject);
begin
  with QProduto do
    begin
      SQL.Text := 'SELECT * FROM (                       '+
                  '       SELECT PK_Produtos, PdtDescProd'+
                  '         FROM C_Produtos)             ';
      Open;
    end;
   CBCodProd.Items.Clear;
  while not QProduto.Eof do
  begin
    CBCodProd.Items.Add(QProduto.FieldByName('PK_Produtos').AsString);
    QProduto.Next;
  end;
  QProduto.First;
end;

end.
