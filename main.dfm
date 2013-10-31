object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'XMPP'
  ClientHeight = 592
  ClientWidth = 849
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pTop: TPanel
    Left = 0
    Top = 0
    Width = 217
    Height = 573
    Align = alLeft
    BevelOuter = bvNone
    Caption = 'pTop'
    ShowCaption = False
    TabOrder = 0
    object pLeft: TPanel
      Left = 0
      Top = 0
      Width = 216
      Height = 573
      Align = alLeft
      BevelOuter = bvNone
      Caption = 'pLeft'
      ShowCaption = False
      TabOrder = 0
      object pConnection: TPanel
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 210
        Height = 117
        Align = alTop
        Caption = 'pConnection'
        ShowCaption = False
        TabOrder = 0
        object lbHostname: TLabel
          Left = 10
          Top = 62
          Width = 48
          Height = 13
          Caption = 'Hostname'
        end
        object lbPassword: TLabel
          Left = 10
          Top = 35
          Width = 46
          Height = 13
          Caption = 'Password'
        end
        object lbUsername: TLabel
          Left = 8
          Top = 8
          Width = 48
          Height = 13
          Caption = 'Username'
        end
        object btConnect: TButton
          Left = 10
          Top = 86
          Width = 75
          Height = 25
          Caption = 'Connect'
          Default = True
          TabOrder = 3
          OnClick = btConnectClick
        end
        object edHostname: TEdit
          Left = 64
          Top = 59
          Width = 121
          Height = 21
          TabOrder = 2
          Text = 'elorobot.com'
        end
        object edPassword: TEdit
          Left = 62
          Top = 32
          Width = 121
          Height = 21
          TabOrder = 1
          Text = '1234'
        end
        object edUsername: TEdit
          Left = 62
          Top = 5
          Width = 121
          Height = 21
          TabOrder = 0
          Text = 'delphi'
        end
        object btDisconnect: TButton
          Left = 91
          Top = 86
          Width = 75
          Height = 25
          Caption = 'Disconnect'
          Enabled = False
          TabOrder = 4
          OnClick = btDisconnectClick
        end
      end
      object pContacts: TPanel
        Left = 0
        Top = 123
        Width = 216
        Height = 450
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 1
        object btSendMessage: TButton
          Left = 11
          Top = 3
          Width = 121
          Height = 25
          Caption = 'send message'
          TabOrder = 0
          OnClick = btSendMessageClick
        end
      end
    end
  end
  object pBottom: TPanel
    Left = 217
    Top = 0
    Width = 632
    Height = 573
    Align = alClient
    BevelOuter = bvNone
    Caption = 'pBottom'
    ShowCaption = False
    TabOrder = 1
    object smLog: TMemo
      Left = 0
      Top = 0
      Width = 632
      Height = 573
      Align = alClient
      ScrollBars = ssBoth
      TabOrder = 0
    end
  end
  object ConnButton: TButton
    Left = 8
    Top = 173
    Width = 75
    Height = 25
    Caption = 'Connect'
    TabOrder = 2
    OnClick = ConnButtonClick
  end
  object PortButton: TButton
    Left = 96
    Top = 173
    Width = 75
    Height = 25
    Caption = 'Serial Port'
    TabOrder = 3
    OnClick = PortButtonClick
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 573
    Width = 849
    Height = 19
    Panels = <
      item
        Width = 500
      end
      item
        Width = 80
      end
      item
        Width = 80
      end
      item
        Width = 500
      end>
    SimpleText = '...'
  end
  object tmrPing: TTimer
    Interval = 35000
    OnTimer = tmrPingTimer
    Left = 176
    Top = 128
  end
  object ComPort: TComPort
    BaudRate = br115200
    Port = 'COM4'#0'anel'
    Parity.Bits = prNone
    StopBits = sbOneStopBit
    DataBits = dbEight
    DiscardNull = True
    Events = [evRxChar, evTxEmpty, evRxFlag, evRing, evBreak, evCTS, evDSR, evError, evRLSD, evRx80Full]
    FlowControl.OutCTSFlow = False
    FlowControl.OutDSRFlow = False
    FlowControl.ControlDTR = dtrEnable
    FlowControl.ControlRTS = rtsDisable
    FlowControl.XonXoffOut = False
    FlowControl.XonXoffIn = False
    StoredProps = [spBasic]
    TriggersOnRxChar = True
    OnAfterOpen = ComPortAfterOpen
    OnAfterClose = ComPortAfterClose
    OnRxChar = ComPortRxChar
    Left = 136
    Top = 128
  end
end
