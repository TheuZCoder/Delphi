object FrmUCadItens: TFrmUCadItens
  Left = 0
  Top = 0
  Caption = 'Manuten'#231#227'o de Itens'
  ClientHeight = 185
  ClientWidth = 709
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = True
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 15
  object Panel2: TPanel
    Left = 0
    Top = 135
    Width = 709
    Height = 50
    Align = alBottom
    Padding.Left = 5
    Padding.Right = 5
    Padding.Bottom = 5
    TabOrder = 1
    DesignSize = (
      709
      50)
    object BSalvar: TButton
      Left = 488
      Top = 5
      Width = 97
      Height = 41
      Anchors = [akTop, akRight]
      Caption = 'Salvar'
      TabOrder = 0
      OnClick = BSalvarClick
    end
    object BCancelar: TButton
      Left = 595
      Top = 5
      Width = 97
      Height = 41
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Cancelar'
      TabOrder = 1
      OnClick = BCancelarClick
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 709
    Height = 137
    Align = alTop
    Padding.Left = 5
    Padding.Top = 5
    Padding.Right = 5
    Padding.Bottom = 5
    TabOrder = 0
    DesignSize = (
      709
      137)
    object Label1: TLabel
      Left = 25
      Top = 16
      Width = 105
      Height = 15
      Caption = 'C'#243'digo do Produto:'
    end
    object Label2: TLabel
      Left = 25
      Top = 72
      Width = 65
      Height = 15
      Caption = 'Quantidade:'
    end
    object Label3: TLabel
      Left = 184
      Top = 16
      Width = 117
      Height = 15
      Caption = 'Descri'#231#227'o do Produto:'
    end
    object EDescProduto: TEdit
      Left = 184
      Top = 37
      Width = 465
      Height = 23
      Anchors = [akLeft, akTop, akRight]
      ImeName = 'Portuguese (Brazilian ABNT)'
      ReadOnly = True
      TabOrder = 0
    end
    object EQuantidade: TEdit
      Left = 25
      Top = 93
      Width = 120
      Height = 23
      TabOrder = 1
    end
    object CBCodProd: TComboBox
      Left = 25
      Top = 37
      Width = 145
      Height = 23
      TabOrder = 2
      OnChange = CBCodProdChange
    end
  end
  object QProduto: TFDQuery
    Connection = FrmUPesqPedidos.ConnectDb
    SQL.Strings = (
      
        'SELECT * FROM (SELECT Pdt_CodPrd, Pdt_Dscprd FROM C_Produtos ORD' +
        'ER BY Pdt_CodPrd)')
    Left = 280
    Top = 85
  end
  object SourceDb: TDataSource
    DataSet = QProduto
    Left = 376
    Top = 85
  end
  object QProdutoAux: TFDQuery
    Connection = FrmUPesqPedidos.ConnectDb
    Left = 192
    Top = 85
  end
  object QInsertProd: TFDQuery
    Connection = FrmUPesqPedidos.ConnectDb
    Left = 240
    Top = 141
  end
end
