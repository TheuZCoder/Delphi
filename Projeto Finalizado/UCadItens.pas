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
    FsModo: string;
    FsCodProd: string;
    FsCodTab: string;
    FdQtd: Double;
    FdValUni: Double;
    FdValTotal: Double;
  public
    property Modo: string read FsModo write FsModo;
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
begin
  FdQtd := 0;
  FsCodProd := CBCodProd.Text;
  FdQtd := StrToFloat(EQuantidade.Text);
  if Modo = 'Incluir' then
  begin
    with QProdutoAux do
    begin
      SQL.Text := 'SELECT Svp_CodTmp               '+
                  '  FROM T_SAVPROD                 '+
                  ' WHERE Svp_CodTmp = :pPK_Produtos';
      ParamByName('pPK_Produtos').AsString := FsCodProd;
      Open;
    end;

    try
    if not QProdutoAux.IsEmpty then
      begin
        FsCodTab := QProdutoAux.FieldByName('Svp_CodTmp').AsString;
        if FsCodProd = FsCodTab then
        begin
          ShowMessage('Produto já inserido no Pedido, ' +
                        'Alterar ou Excluir o já existente!');
          Close;
          Exit
        end;
      end;
      finally
      QProdutoAux.Close;
    end;

    if EQuantidade.Text = '' then
    begin
      ShowMessage('Produto não pode ser incluido sem quantidade!');
      Close;
      Exit
    end;

    with QProdutoAux do
    begin
      SQL.Text := 'SELECT Pdt_ValPrd                 '+
                  '  FROM C_Produtos                 '+
                  ' WHERE Pdt_CodPrd = :pPK_Produtos';
      ParamByName('pPK_Produtos').AsString := FsCodProd;
      Open;
    end;

    if not QProdutoAux.IsEmpty then
    begin
      FdValUni := QProdutoAux.FieldByName('Pdt_ValPrd').AsFloat;
      FdValTotal := FdQtd * FdValUni;

      try
        with QProdutoAux do
        begin
          SQL.Text := 'INSERT INTO T_SAVPROD(Svp_CodTmp, Svp_Qtd,'+
                      '            Svp_ValPrd, Svp_ValItn)      '+
                      '     VALUES (:pPK_Produtos, :pItnQtd,     '+
                      '            :pPdtValProd, :pItnValItens)  ';

          ParamByName('pPK_Produtos').AsString := FsCodProd;
          ParamByName('pItnQtd').AsFloat := FdQtd;
          ParamByName('pPdtValProd').AsFloat := FdValUni;
          ParamByName('pItnValItens').AsFloat := FdValTotal;
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
    try
      with QInsertProd do
      begin
        SQL.Text := 'SELECT Pdt_ValPrd                 '+
                    '  FROM C_Produtos                 '+
                    ' WHERE Pdt_CodPrd = :pPK_Produtos';
        ParamByName('pPK_Produtos').AsString := FsCodProd;
        Open;
      end;
      with QProdutoAux do
      begin
        SQL.Text := 'UPDATE T_SAVPROD                  '+
                    '   SET Svp_Qtd = :pItnQtd,         '+
                    '       Svp_ValItn = :pItnValItens'+
                    ' WHERE Svp_CodTmp = :pPK_Produtos';

        FdValUni := QInsertProd.FieldByName('Pdt_ValPrd').AsFloat;
        FdValTotal := FdQtd * FdValUni;

        ParamByName('pItnQtd').AsFloat := FdQtd;
        ParamByName('pItnValItens').AsFloat := FdValTotal;
        ParamByName('pPK_Produtos').AsString := FsCodProd;
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
  FsCodProd := CBCodProd.Text;
  try
    with QProdutoAux do
    begin
      SQL.Text := 'SELECT * FROM (                           '+
                  '       SELECT Pdt_Dscprd, Pdt_ValPrd     '+
                  '         FROM C_Produtos                  '+
                  '        WHERE Pdt_CodPrd = :pPK_Produtos)';
      ParamByName('pPK_Produtos').AsString := FsCodProd;
      Open;
    end;

    if not QProdutoAux.Eof then
    begin
      QProduto.First;
      EDescProduto.Text := QProdutoAux.FieldByName('Pdt_Dscprd').AsString;
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
    Open;
  end;
  CBCodProd.Items.Clear;
  QProduto.First;
  while not QProduto.Eof do
  begin
    CBCodProd.Items.Add(QProduto.FieldByName('Pdt_CodPrd').AsString);
    QProduto.Next;
  end;
end;

end.
