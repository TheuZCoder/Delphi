object FrmUCadPedidos: TFrmUCadPedidos
  Left = 0
  Top = 0
  Caption = 'Manuten'#231#227'o de Pedidos'
  ClientHeight = 442
  ClientWidth = 751
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = True
  OnActivate = FormActivate
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 15
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 751
    Height = 41
    Align = alTop
    Padding.Left = 5
    Padding.Top = 5
    Padding.Right = 5
    Padding.Bottom = 5
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 13
      Width = 74
      Height = 15
      Caption = 'N'#176' do Pedido:'
    end
    object Label2: TLabel
      Left = 256
      Top = 13
      Width = 27
      Height = 15
      Caption = 'Data:'
    end
    object ECadPedido: TEdit
      Left = 96
      Top = 10
      Width = 121
      Height = 23
      ImeName = 'Portuguese (Brazilian ABNT)'
      TabOrder = 0
    end
    object DTDataPedido: TDateTimePicker
      Left = 289
      Top = 10
      Width = 96
      Height = 23
      Date = 45500.000000000000000000
      Time = 0.791825578700809300
      TabOrder = 1
    end
  end
  object PanelSub: TPanel
    Left = 0
    Top = 41
    Width = 751
    Height = 56
    Align = alTop
    Padding.Left = 5
    Padding.Top = 5
    Padding.Right = 5
    Padding.Bottom = 5
    TabOrder = 1
    DesignSize = (
      751
      56)
    object Label3: TLabel
      Left = 360
      Top = 16
      Width = 25
      Height = 15
      Caption = 'Itens'
    end
    object BIncluir: TButton
      Left = 412
      Top = 8
      Width = 105
      Height = 41
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Incluir'
      TabOrder = 0
      OnClick = BIncluirClick
    end
    object BExcluir: TButton
      Left = 634
      Top = 8
      Width = 105
      Height = 41
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Excluir'
      TabOrder = 1
      OnClick = BExcluirClick
    end
    object BAlterar: TButton
      Left = 523
      Top = 8
      Width = 105
      Height = 41
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Alterar'
      TabOrder = 2
      OnClick = BAlterarClick
    end
  end
  object DBGTemporario: TDBGrid
    Left = 0
    Top = 97
    Width = 751
    Height = 287
    Align = alClient
    DataSource = SourceDb
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    ReadOnly = True
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'PK_PRODUTOS'
        Title.Caption = 'CODIGO PRODUTO'
        Width = 125
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'ITNQTD'
        Title.Caption = 'QUANTIDADE'
        Width = 114
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'ITNVALITENS'
        Title.Caption = 'VALOR TOTAL '
        Width = 105
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'PDTVALPROD'
        Title.Caption = 'VALOR UNITARIO'
        Width = 134
        Visible = True
      end>
  end
  object PanelLow: TPanel
    Left = 0
    Top = 384
    Width = 751
    Height = 58
    Align = alBottom
    Padding.Left = 5
    Padding.Top = 5
    Padding.Right = 5
    Padding.Bottom = 5
    TabOrder = 3
    DesignSize = (
      751
      58)
    object BSalvar: TButton
      Left = 523
      Top = 9
      Width = 105
      Height = 41
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Salvar'
      TabOrder = 0
      OnClick = BSalvarClick
    end
    object BCancelar: TButton
      Left = 634
      Top = 9
      Width = 105
      Height = 41
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Cancelar'
      TabOrder = 1
      OnClick = BCancelarClick
    end
  end
  object QCadPedido: TFDQuery
    Connection = FrmUPesqPedidos.ConnectDb
    SQL.Strings = (
      '')
    Left = 96
    Top = 232
  end
  object SourceDb: TDataSource
    DataSet = QCadPedido
    Left = 176
    Top = 280
  end
  object QCadPedidoAux: TFDQuery
    Connection = FrmUPesqPedidos.ConnectDb
    SQL.Strings = (
      'select * from T_SAVPROD')
    Left = 96
    Top = 296
  end
  object QInsertCad: TFDQuery
    Connection = FrmUPesqPedidos.ConnectDb
    SQL.Strings = (
      'select * from T_SAVPROD')
    Left = 96
    Top = 360
  end
end
