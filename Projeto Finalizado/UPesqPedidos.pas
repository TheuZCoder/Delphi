unit UPesqPedidos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.UITypes, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Data.DB,
  Vcl.Grids, Vcl.DBGrids, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.Oracle,
  FireDAC.Phys.OracleDef, FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client, UCadPedidos,
  ppProd, ppClass, ppReport, ppComm, ppRelatv, ppDB, ppDBPipe, ppBands, ppCache,
  ppDesignLayer, ppParameter, ppVar, ppCtrls, ppPrnabl;

type
  TFrmUPesqPedidos = class(TForm)
    PainelTopo: TPanel;
    Bimprimir: TButton;
    Label1: TLabel;
    ELocalizar: TEdit;
    BLocalizar: TButton;
    BIncluir: TButton;
    BAlterar: TButton;
    BExcluir: TButton;
    DBGPrincipal: TDBGrid;
    DBGSecundario: TDBGrid;
    ConnectDb: TFDConnection;
    QDb: TFDQuery;
    DSSourceDb: TDataSource;
    QAuxiliar: TFDQuery;
    QTabelaAux: TFDQuery;
    DSSourceAux: TDataSource;
    DSReport: TDataSource;
    QReport: TFDQuery;
    ppDBPipeline1: TppDBPipeline;
    ppReport1: TppReport;
    ppDetailBand1: TppDetailBand;
    ppLabel6: TppLabel;
    ppLabel7: TppLabel;
    ppLabel9: TppLabel;
    ppLabel11: TppLabel;
    ppLabel12: TppLabel;
    ppDesignLayers1: TppDesignLayers;
    ppDesignLayer1: TppDesignLayer;
    ppParameterList1: TppParameterList;
    QDbPDD_CODPED: TFMTBCDField;
    QDbPDD_DATEPED: TDateTimeField;
    QDbPDD_TTLPED: TFMTBCDField;
    QTabelaAuxITN_CODITN: TFMTBCDField;
    QTabelaAuxITN_PEDIDOS_ITENS: TFMTBCDField;
    QTabelaAuxITN_PRODUTOS_ITENS: TStringField;
    QTabelaAuxITN_QTD: TFMTBCDField;
    QTabelaAuxITN_VALITENS: TFMTBCDField;
    ppDBText3: TppDBText;
    ppDBText4: TppDBText;
    ppDBText5: TppDBText;
    ppDBText6: TppDBText;
    ppDBText7: TppDBText;
    ppGroup1: TppGroup;
    ppGroupHeaderBand1: TppGroupHeaderBand;
    ppGroupFooterBand1: TppGroupFooterBand;
    ppLabel1: TppLabel;
    ppDBText1: TppDBText;
    ppLabel2: TppLabel;
    ppDBText2: TppDBText;
    ppLabel3: TppLabel;
    ppDBText8: TppDBText;
    ppLabel4: TppLabel;
    ppLabel5: TppLabel;
    ppLabel8: TppLabel;
    ppLabel10: TppLabel;
    ppLabel13: TppLabel;
    procedure BIncluirClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BAlterarClick(Sender: TObject);
    procedure BExcluirClick(Sender: TObject);
    procedure BLocalizarClick(Sender: TObject);
    procedure QDbAfterScroll(DataSet: TDataSet);
    procedure BimprimirClick(Sender: TObject);
  private
    FdNumPed: Double;
    FDDtPed: TDateTime;
    FsFiltroPed: string;
  public
    { Public declarations }
  end;

var
  FrmUPesqPedidos: TFrmUPesqPedidos;
  FrmUCadPedidos: TFrmUCadPedidos;

implementation

{$R *.dfm}

procedure TFrmUPesqPedidos.BAlterarClick(Sender: TObject);
begin
  FdNumPed := QDb.FieldByName('Pdd_CodPed').AsFloat;

  FrmUCadPedidos := TFrmUCadPedidos.Create(Self);
  try
    FrmUCadPedidos.Modo := 'Alterar';

    with QAuxiliar do
    begin
      SQL.Text := 'SELECT Pdd_DatePed                 '+
                  '  FROM C_Pedidos                  '+
                  ' WHERE Pdd_CodPed = :pPK_Pedidos  ';
      ParamByName('pPK_Pedidos').AsFloat := FdNumPed;
      Open;
    end;

    if not QAuxiliar.IsEmpty then
    begin
      FDDtPed := QDb.FieldByName('Pdd_DatePed').AsDateTime;
      FrmUCadPedidos.DTDataPedido.Date := FDDtPed;
      FrmUCadPedidos.ECadPedido.Text := FdNumPed.ToString;
    end
    else
    begin
      ShowMessage('Pedido não encontrado.');
      Exit;
    end;

    with QAuxiliar do
    begin
      Close;

      SQL.Text := 'INSERT INTO T_SavProd (Svp_CodTmp, Svp_Qtd,        '+
                  '                       Svp_ValPrd, Svp_ValItn)    '+
                  '     SELECT c.Itn_Produtos_Itens, c.Itn_Qtd,         '+
                  '            p.Pdt_ValPrd, c.Itn_ValItens            '+
                  '       FROM C_Itens c                              '+
                  '       JOIN C_Produtos p                           '+
                  '         ON c.Itn_Produtos_Itens = p.Pdt_CodPrd    '+
                  '      WHERE c.Itn_Pedidos_Itens = :pFK_Itens_Pedidos';
      ParamByName('pFK_Itens_Pedidos').AsFloat := FdNumPed;
      ExecSQL;
    end;

    with FrmUCadPedidos do
    begin
      ECadPedido.Enabled := False;
      ShowModal;
    end;

  finally
    FrmUCadPedidos.Free;
  end;
end;

procedure TFrmUPesqPedidos.BExcluirClick(Sender: TObject);
begin
  FdNumPed := DBGPrincipal.DataSource.DataSet.FieldByName('Pdd_CodPed').AsFloat;
  // Verificar se o pedido está selecionado
  if FdNumPed = Null then
  begin
    ShowMessage('Por favor, selecione um pedido para excluir.');
    Exit;
  end;

  // Confirmar exclusão com o usuário
  if MessageDlg('Tem certeza que deseja excluir este pedido?', mtConfirmation,[mbYes, mbNo], 0) = mrYes then
  begin
    try
      with QAuxiliar do
      begin
        // Excluir itens associados ao pedido da tabela C_Itens
        SQL.Text := 'DELETE FROM C_Itens                              '+
                    '      WHERE Itn_Pedidos_Itens = :pFK_Itens_Pedidos';
        ParamByName('pFK_Itens_Pedidos').AsFloat := FdNumPed;
        ExecSQL;

        // Excluir pedido da tabela C_Pedidos
        SQL.Text := 'DELETE FROM C_Pedidos                '+
                    '      WHERE Pdd_CodPed = :pPK_Pedidos';
        ParamByName('pPK_Pedidos').AsFloat := FdNumPed;
        ExecSQL;
      end;

      ShowMessage('Pedido excluído com sucesso!');
      QTabelaAux.Refresh;
      QDb.Refresh;
      QReport.Refresh;
      except
      on E: Exception do
      begin
        FrmUPesqPedidos.ConnectDb.Rollback;
        ShowMessage('Erro ao excluir o pedido: ' + E.Message);
      end;
    end;
  end;
end;

procedure TFrmUPesqPedidos.BimprimirClick(Sender: TObject);
begin
  if FsFiltroPed = '' then
  begin
    with QReport do
    begin
      SQL.Text :=' SELECT ci.*,'+
               '        cp.Pdd_DatePed,'+
               '        cp.Pdd_TtlPed, '+
               '        p.Pdt_ValPrd,  '+
               '        p.Pdt_Dscprd    '+
               '   FROM C_ITENS ci       '+
               '  INNER JOIN C_PEDIDOS cp   '+
               '     ON ci.Itn_Pedidos_Itens = cp.Pdd_CodPed '+
               '  INNER JOIN C_PRODUTOS p                      '+
               '     ON ci.Itn_Produtos_Itens = p.Pdt_CodPrd     '+
               '  ORDER BY ci.Itn_Pedidos_Itens, ci.Itn_Produtos_Itens ';
      Open;
    end;
  end
  else
  begin
    with QReport do
    begin
      SQL.Text :='SELECT * FROM (SELECT ci.*,                           '+
                 '               cp.Pdd_DatePed,                         '+
                 '               cp.Pdd_TtlPed,                         '+
                 '               p.Pdt_ValPrd,                          '+
                 '               p.Pdt_Dscprd                          '+
                 '         FROM C_ITENS ci                              '+
                 '   INNER JOIN C_PEDIDOS cp                            '+
                 '           ON ci.Itn_Pedidos_Itens = cp.Pdd_CodPed     '+
                 '   INNER JOIN C_PRODUTOS p                            '+
                 '           ON ci.Itn_Produtos_Itens = p.Pdt_CodPrd    '+
                 '        WHERE ci.Itn_Pedidos_Itens = :pFK_Itens_Pedidos'+
                 '     ORDER BY ci.Itn_Produtos_Itens)                   ';
      ParamByName('pFK_Itens_Pedidos').AsFloat := FdNumPed;
      Open;
    end;
  end;
  ppReport1.Print;
end;

procedure TFrmUPesqPedidos.BIncluirClick(Sender: TObject);
begin
  FrmUCadPedidos := TFrmUCadPedidos.Create(Self);
  try
    FrmUCadPedidos.Modo := 'Incluir';
    FrmUCadPedidos.ShowModal
  finally
    FrmUCadPedidos.Free;
  end;

end;

procedure TFrmUPesqPedidos.BLocalizarClick(Sender: TObject);
begin
  FsFiltroPed := ELocalizar.Text;
  with QDb do
  begin
    SQL.Text := 'SELECT * FROM C_PEDIDOS   '+
                '        WHERE Pdd_CodPed  '+
                '         LIKE :pPK_Pedidos'+
                '     ORDER BY Pdd_CodPed  ';
    Params.ParamByName('pPK_Pedidos').AsString := '%' + FsFiltroPed + '%';
    Open;
  end;
  if QDb.IsEmpty then
    ShowMessage('Nenhum pedido encontrado com o número especificado.');
end;

procedure TFrmUPesqPedidos.FormCreate(Sender: TObject);
begin
  with QDb do
  begin
    Open;
    ConnectDb.Connected := True;
    AfterScroll := QDbAfterScroll;
    Open;
  end;
end;

procedure TFrmUPesqPedidos.QDbAfterScroll(DataSet: TDataSet);
begin
  FdNumPed := QDb.FieldByName('Pdd_CodPed').AsFloat;

  with QTabelaAux do
  begin
    Close;
    SQL.Text := '       SELECT *                                     '+
                '         FROM C_ITENS                               '+
                '        WHERE Itn_Pedidos_Itens = :pFK_Itens_Pedidos'+
                '     ORDER BY Itn_Produtos_Itens                   ';
    ParamByName('pFK_Itens_Pedidos').AsFloat := FdNumPed;
    Open;
  end;
end;

end.


