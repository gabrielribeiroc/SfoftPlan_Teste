object fThreads: TfThreads
  Left = 0
  Top = 0
  Caption = 'fThreads'
  ClientHeight = 550
  ClientWidth = 423
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 423
    Height = 550
    Align = alClient
    TabOrder = 0
    object Label1: TLabel
      Left = 4
      Top = 51
      Width = 78
      Height = 13
      Caption = 'Threads Criadas'
    end
    object Label2: TLabel
      Left = 131
      Top = 51
      Width = 105
      Height = 13
      Caption = 'Tempo entre Itera'#231#227'o'
    end
    object Label3: TLabel
      AlignWithMargins = True
      Left = 4
      Top = 11
      Width = 415
      Height = 24
      Margins.Top = 10
      Align = alTop
      Caption = 'Threads'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -20
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ExplicitWidth = 72
    end
    object ProgressBar: TProgressBar
      AlignWithMargins = True
      Left = 4
      Top = 529
      Width = 415
      Height = 17
      Align = alBottom
      TabOrder = 3
    end
    object mmo_result: TMemo
      AlignWithMargins = True
      Left = 4
      Top = 100
      Width = 415
      Height = 423
      Align = alBottom
      TabOrder = 4
    end
    object edt_tempo: TEdit
      Left = 131
      Top = 70
      Width = 121
      Height = 21
      NumbersOnly = True
      TabOrder = 1
      Text = '100'
    end
    object edt_threads: TEdit
      Left = 4
      Top = 70
      Width = 121
      Height = 21
      NumbersOnly = True
      TabOrder = 0
      Text = '10'
    end
    object btn_executar: TButton
      Left = 258
      Top = 66
      Width = 75
      Height = 25
      Caption = 'Executar'
      TabOrder = 2
      OnClick = btn_executarClick
    end
  end
end
