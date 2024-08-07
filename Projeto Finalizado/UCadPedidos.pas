unit UCadPedidos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.UITypes, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls,
  Data.DB, Vcl.Grids, Vcl.DBGrids, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.Oracle,
  FireDAC.Phys.OracleDef, FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client, UCadItens;

type
  TFrmUCadPedidos = class(TForm)
    PanelTop: TPanel;
    Label1: TLabel;
    ECadPedido: TEdit;
    Label2: TLabel;
    DTDataPedido: TDateTimePicker;
    PanelSub: TPanel;
    Label3: TLabel;
    DBGTemporario: TDBGrid;
    PanelLow: TPanel;
    BSalvar: TButton;
    BCancelar: TButton;
    BIncluir: TButton;
    BAlterar: TButton;
    BExcluir: TButton;
    QCadPedido: TFDQuery;
    SourceDb: TDataSource;
    QCadPedidoAux: TFDQuery;
    QInsertCad: TFDQuery;
    QCadPedidoSVP_CODTMP: TStringField;
    QCadPedidoSVP_QTD: TFMTBCDField;
    QCadPedidoSVP_VALPRD: TFMTBCDField;
    QCadPedidoSVP_VALITN: TFMTBCDField;
    procedure BIncluirClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure BSalvarClick(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure BExcluirClick(Sender: TObject);
    procedure BAlterarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FsModo: string;
    FsCodProd: string;
    FDQtdProd: Double;
    FdValTotal: Double;
    FiNumPed: Integer;
    FiNumPedSom: Integer;
    FiNumPedTab: Integer;
    FDDtPed: TDateTime;
    FiPkItens: Integer;
  public
    property Modo: string read FsModo write FsModo;
  end;

var
  FrmUCadPedidos: TFrmUCadPedidos;
  FrmUCadItens: TFrmUCadItens;

implementation
uses
UPesqPedidos;

{$R *.dfm}

procedure TFrmUCadPedidos.BAlterarClick(Sender: TObject);
begin
  FrmUCadItens := TFrmUCadItens.Create(Self);
  FsCodProd := DBGTemporario.DataSource.DataSet.FieldByName('Svp_CodTmp').AsString;
  FDQtdProd := DBGTemporario.DataSource.DataSet.FieldByName('Svp_Qtd').AsFloat;
  try
    with QCadPedidoAux do
    begin
      SQL.Text := 'SELECT Pdt_Dscprd                 '+
                  '  FROM C_Produtos                 '+
                  ' WHERE Pdt_CodPrd  = :pPK_Produtos';
      ParamByName('pPK_Produtos').AsString := FsCodProd;
      Open;
    end;
    with FrmUCadItens do
    begin
      CBCodProd.Text := FsCodProd;
      EDescProduto.Text := QCadPedidoAux.FieldByName('Pdt_Dscprd').AsString;
      EQuantidade.Text := FloatToStr(FDQtdProd);
      CBCodProd.Enabled := False;
      EDescProduto.Enabled := False;
      Modo := 'Alterar';
      ShowModal;
    end;

  finally
    FrmUCadItens.Free;
    OnActivate(Self);
  end;
end;

procedure TFrmUCadPedidos.BCancelarClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmUCadPedidos.BExcluirClick(Sender: TObject);
begin
  FsCodProd := QCadPedido.FieldByName('Svp_CodTmp').AsString;
  if FsCodProd = '' then
  begin
    ShowMessage('Por favor, selecione um produto para excluir.');
    Exit;
  end;

  if MessageDlg('Tem certeza que deseja excluir este produto?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    try
      with QCadPedidoAux do
      begin
        SQL.Text := 'DELETE FROM T_SAVPROD                  '+
                    '      WHERE Svp_CodTmp = :pPK_Produtos';
        ParamByName('pPK_Produtos').AsString := FsCodProd;
        ExecSQL;
      end;

      with QCadPedido do
      begin
        Refresh;
      end;

      ShowMessage('Produto excluído!');
      except
      on E: Exception do
      begin
        ShowMessage('Erro ao excluir o produto: ' + E.Message);
      end;
    end;
  end;
end;

procedure TFrmUCadPedidos.BIncluirClick(Sender: TObject);
begin
  FrmUCadItens := TFrmUCadItens.Create(Self);
  try
    FrmUCadItens.Modo := 'Incluir';
    FrmUCadItens.ShowModal;
  finally
    FrmUCadItens.Free;
    OnActivate(Self);
  end;
end;

procedure TFrmUCadPedidos.BSalvarClick(Sender: TObject);
begin
  FiNumPed := StrToInt(ECadPedido.Text);
  FDDtPed := DTDataPedido.Date;
  if Modo = 'Incluir' then
  begin
    try
      try
        with QCadPedidoAux do
        begin
          SQL.Text := 'SELECT Pdd_CodPed               '+
                      '  FROM C_Pedidos                '+
                      ' WHERE Pdd_CodPed = :pPK_pedidos';
          ParamByName('pPK_pedidos').AsInteger := FiNumPed;
          Open;
        end;

        if not QCadPedidoAux.IsEmpty then
        begin
          FiNumPedTab := QCadPedidoAux.FieldByName('Pdd_CodPed').AsInteger;
          if FiNumPed = FiNumPedTab then
          begin
            ShowMessage('Pedido já inserido, ' +
                          'Alterar ou Excluir o já existente!');
            Close;
            Exit
          end;
        end;
        finally
        QCadPedidoAux.Close;
      end;

      with QInsertCad do
      begin
        SQL.Text := 'INSERT INTO C_Pedidos (Pdd_CodPed, Pdd_DatePed,'+
                    '            Pdd_TtlPed)                      '+
                    '     VALUES (:pPK_Pedidos, :pPddDatePed,      '+
                    '            :pPddTotalPed)                    ';
        ParamByName('pPK_Pedidos').AsInteger := FiNumPed;
        ParamByName('pPddDatePed').AsDate := FDDtPed;
        ParamByName('pPddTotalPed').AsFloat := 0;
        ExecSQL;
      end;

      FdValTotal := 0;
      QCadPedido.First;

      while not QCadPedido.Eof do
      begin
        with QInsertCad do
        begin
          SQL.Text := 'SELECT SEQ_Itens.NEXTVAL AS new_id FROM dual';
          Open;
          FiPkItens := QInsertCad.FieldByName('new_id').AsInteger;
          Close;

          SQL.Text := 'INSERT INTO C_Itens                                      '+
                      '            (Itn_CodItn, Itn_Pedidos_Itens,                 '+
                      '            Itn_Produtos_Itens, Itn_Qtd, Itn_ValItens)      '+
                      '     VALUES (:pPK_Itens, :pFK_Itens_Pedidos,             '+
                      '            :pFK_Itens_Produtos, :pItnQtd, :pItnValItens)';
          ParamByName('pPK_Itens').AsInteger := FiPkItens;
          ParamByName('pFK_Itens_Pedidos').AsInteger := FiNumPed;
          ParamByName('pFK_Itens_Produtos').AsString := QCadPedido.FieldByName('Svp_CodTmp').AsString;
          ParamByName('pItnQtd').AsFloat := QCadPedido.FieldByName('Svp_Qtd').AsFloat;
          ParamByName('pItnValItens').AsFloat := QCadPedido.FieldByName('Svp_ValPrd').AsFloat * QCadPedido.FieldByName('Svp_Qtd').AsFloat;
          ExecSQL;

          FdValTotal := FdValTotal + QInsertCad.ParamByName('pItnValItens').AsFloat;

          QCadPedido.Next;

        end;
      end;

      with QCadPedidoAux do
      begin
        SQL.Text := 'UPDATE C_Pedidos                  '+
                    '   SET Pdd_TtlPed = :pPddTotalPed'+
                    ' WHERE Pdd_CodPed = :pPK_Pedidos  ';
        ParamByName('pPddTotalPed').AsFloat := FdValTotal;
        ParamByName('pPK_Pedidos').AsInteger := FiNumPed;
        ExecSQL;

        SQL.Text := 'DELETE FROM T_SavProd';
        ExecSQL;
      end;

      with FrmUPesqPedidos do
      begin
        QDb.Refresh;
        QTabelaAux.Refresh;
        QReport.Refresh;
      end;

      ShowMessage('Pedido salvo com sucesso!');
      Close;

    except
      on E: Exception do
      begin
        FrmUPesqPedidos.ConnectDb.Rollback;
        ShowMessage('Erro ao salvar o pedido: ' + E.Message);
      end;
    end;
  end
  else if Modo = 'Alterar' then
  begin
    try
      FdValTotal := 0;
      QCadPedido.First;

      while not QCadPedido.Eof do
      begin
        with QCadPedidoAux do
        begin
          SQL.Text := 'SELECT COUNT(*)                               '+
                      '    AS item_count                             '+
                      '  FROM C_Itens                                '+
                      ' WHERE Itn_Pedidos_Itens = :pFK_Itens_Pedidos  '+
                      '   AND Itn_Produtos_Itens = :pFK_Itens_Produtos';
          ParamByName('pFK_Itens_Pedidos').AsInteger := FiNumPed;
          ParamByName('pFK_Itens_Produtos').AsString := QCadPedido.FieldByName('Svp_CodTmp').AsString;
          Open;
        end;

        if QCadPedidoAux.FieldByName('item_count').AsInteger = 0 then
        begin
          with QInsertCad do
          begin
            SQL.Text := 'SELECT SEQ_Itens.NEXTVAL AS new_id FROM dual';
            Open;
            FiPkItens := QInsertCad.FieldByName('new_id').AsInteger;
            Close;

            SQL.Text := 'INSERT INTO C_Itens                                  '+
                        '            (Itn_CodItn, Itn_Pedidos_Itens,          '+
                        '            Itn_Produtos_Itens, Itn_Qtd,             '+
                        '            Itn_ValItens)                            '+
                        '     VALUES (:pPK_Itens, :pFK_Itens_Pedidos,         '+
                        '            :pFK_Itens_Produtos, :pItnQtd,           '+
                        '            :pItnValItens)                           ';
            ParamByName('pPK_Itens').AsInteger := FiPkItens;
            ParamByName('pFK_Itens_Pedidos').AsInteger := FiNumPed;
            ParamByName('pFK_Itens_Produtos').AsString := QCadPedido.FieldByName('Svp_CodTmp').AsString;
            ParamByName('pItnQtd').AsFloat := QCadPedido.FieldByName('Svp_Qtd').AsFloat;
            ParamByName('pItnValItens').AsFloat := QCadPedido.FieldByName('Svp_ValPrd').AsFloat * QCadPedido.FieldByName('Svp_Qtd').AsFloat;
            ExecSQL;
          end;

        end
        else
        begin
          with QCadPedidoAux do
          begin
            SQL.Text := 'UPDATE C_Itens                                       '+
                        '   SET Itn_Qtd = :pItnQtd, Itn_ValItens = :pItnValItens'+
                        ' WHERE Itn_Pedidos_Itens = :pFK_Itens_Pedidos         '+
                        '   AND Itn_Produtos_Itens = :pFK_Itens_Produtos       ';
            ParamByName('pItnQtd').AsInteger := QCadPedido.FieldByName('Svp_Qtd').AsInteger;
            ParamByName('pItnValItens').AsFloat := QCadPedido.FieldByName('Svp_ValPrd').AsFloat * QCadPedido.FieldByName('Svp_Qtd').AsInteger;
            ParamByName('pFK_Itens_Pedidos').AsInteger := FiNumPed;
            ParamByName('pFK_Itens_Produtos').AsString := QCadPedido.FieldByName('Svp_CodTmp').AsString;
            ExecSQL;
          end;

        end;

        FdValTotal := FdValTotal + QCadPedido.FieldByName('Svp_ValItn').AsFloat;
        QCadPedido.Next;
      end;

      with QCadPedidoAux do
      begin
        SQL.Text := '   DELETE FROM C_Itens                               '+
                  '           WHERE Itn_Pedidos_Itens = :pFK_Itens_Pedidos'+
                  '  AND NOT EXISTS (                                     '+
                  '          SELECT 1                                     '+
                  '            FROM T_SavProd                             '+
                  '           WHERE T_SavProd.Svp_CodTmp =                '+
                  '                 C_Itens.Itn_Produtos_Itens)           ';
        ParamByName('pFK_Itens_Pedidos').AsInteger := FiNumPed;
        ExecSQL;

        SQL.Text := 'UPDATE C_Pedidos                  '+
                    '   SET Pdd_DatePed = :pPddDatePed, '+
                    '       Pdd_TtlPed = :pPddTotalPed'+
                    ' WHERE Pdd_CodPed = :pPK_Pedidos  ';
        ParamByName('pPddDatePed').AsDate := FDDtPed;
        ParamByName('pPddTotalPed').AsFloat := FdValTotal;
        ParamByName('pPK_Pedidos').AsInteger := FiNumPed;
        ExecSQL;

        SQL.Text := 'DELETE FROM T_SavProd';
        ExecSQL;
      end;

      with FrmUPesqPedidos do
      begin
        ConnectDb.Commit;
        QDb.Refresh;
        QTabelaAux.Refresh;
        QReport.Refresh;
      end;

      ShowMessage('Pedido alterado com sucesso!');
      Close;
      except
      on E: Exception do
      begin
        FrmUPesqPedidos.ConnectDb.Rollback;
        ShowMessage('Erro ao alterar o pedido: ' + E.Message);
      end;
    end;
  end;
end;


procedure TFrmUCadPedidos.FormActivate(Sender: TObject);
begin
  FiNumPedSom := 1;
  if QCadPedido.Active then
  QCadPedido.Refresh
  else
  with  QCadPedido do
  begin
      Open;
  end;
  if Modo = 'Incluir' then
  begin
    DTDataPedido.Date := Date;
    with QCadPedidoAux do
    begin
      SQL.Text := 'SELECT MAX(Pdd_CodPed) AS LastPedido'+
                  '  FROM C_Pedidos                    ';
      Open;
        if not IsEmpty then
      begin
        FiNumPed := FieldByName('LastPedido').AsInteger;
        FiNumPed := FiNumPed + FiNumPedSom;
        ECadPedido.Text := IntToStr(FiNumPed);
      end
      else
      begin
        FiNumPed := 1;
        ECadPedido.Text := IntToStr(FiNumPed);
      end;
      Close;
    end;
  end;
end;

procedure TFrmUCadPedidos.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FrmUPesqPedidos.QDb.Refresh;
  with QCadPedidoAux do
  begin
    SQL.Text := 'DELETE FROM T_SavProd';
    ExecSQL;
  end;
end;

end.
