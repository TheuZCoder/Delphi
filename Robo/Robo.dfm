object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 305
  ClientWidth = 607
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 213
    Width = 49
    Height = 16
    Caption = 'Antigo'
  end
  object Label2: TLabel
    Left = 8
    Top = 259
    Width = 25
    Height = 13
    Caption = 'Novo'
  end
  object Label3: TLabel
    Left = 168
    Top = 213
    Width = 82
    Height = 13
    Caption = 'Nome do Arquivo'
  end
  object Label4: TLabel
    Left = 168
    Top = 259
    Width = 97
    Height = 13
    Caption = 'Defini'#231#227'o parametro'
  end
  object Button1: TButton
    Left = 524
    Top = 276
    Width = 75
    Height = 25
    Caption = 'Iniciar'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 8
    Top = 8
    Width = 591
    Height = 202
    Lines.Strings = (
      'Memo1')
    TabOrder = 1
  end
  object EditReplace: TEdit
    Left = 8
    Top = 232
    Width = 121
    Height = 21
    TabOrder = 2
    Text = 'TptBR.'
  end
  object EditNewPrefix: TEdit
    Left = 8
    Top = 276
    Width = 121
    Height = 21
    TabOrder = 3
    Text = 'TConst'
  end
  object EditUnitName: TEdit
    Left = 168
    Top = 232
    Width = 121
    Height = 21
    TabOrder = 4
    Text = 'c_'
  end
  object EditTypeName: TEdit
    Left = 168
    Top = 276
    Width = 121
    Height = 21
    TabOrder = 5
  end
  object Button2: TButton
    Left = 320
    Top = 230
    Width = 75
    Height = 25
    Caption = 'Button2'
    TabOrder = 6
    OnClick = Button2Click
  end
end
