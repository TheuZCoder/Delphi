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
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 156
    Top = 254
    Width = 75
    Height = 25
    Caption = 'Button1'
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
    Top = 216
    Width = 121
    Height = 21
    TabOrder = 2
    Text = 'TptBR.'
  end
  object EditNewPrefix: TEdit
    Left = 8
    Top = 256
    Width = 121
    Height = 21
    TabOrder = 3
    Text = 'TConst'
  end
  object EditUnitName: TEdit
    Left = 392
    Top = 216
    Width = 121
    Height = 21
    TabOrder = 4
    Text = 'c_'
  end
  object EditTypeName: TEdit
    Left = 392
    Top = 256
    Width = 121
    Height = 21
    TabOrder = 5
    Text = 'EditTypeName'
  end
end