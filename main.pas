unit main;

interface


uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, ExtCtrls, Generics.Collections,
  dorXMPPClient, CPortCtl, ComCtrls, CPort,IniFiles;

type
  TForm1 = class(TForm)
    pTop: TPanel;
    pLeft: TPanel;
    pConnection: TPanel;
    lbHostname: TLabel;
    lbPassword: TLabel;
    lbUsername: TLabel;
    btConnect: TButton;
    edHostname: TEdit;
    edPassword: TEdit;
    edUsername: TEdit;
    btDisconnect: TButton;
    pBottom: TPanel;
    pContacts: TPanel;
    tmrPing: TTimer;
    smLog: TMemo;
    ConnButton: TButton;
    PortButton: TButton;
    StatusBar1: TStatusBar;
    ComPort: TComPort;
    btSendMessage: TButton;
    procedure btConnectClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btDisconnectClick(Sender: TObject);
    procedure tmrPingTimer(Sender: TObject);
    procedure btSendMessageClick(Sender: TObject);
    procedure ComPortAfterClose(Sender: TObject);
    procedure ComPortAfterOpen(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure PortButtonClick(Sender: TObject);
    procedure ConnButtonClick(Sender: TObject);
    procedure ComPortRxChar(Sender: TObject; Count: Integer);
  private
    { Déclarations privées }
    FXMPP: IXMPPClient;
    FPresence: TDictionary<string, Boolean>;
    FIQCallBack: TDictionary<RawByteString, TProc<IXMPPIQ>>;
    { Private declarations }
    FInitFlag:Boolean;
    FIni:TMemIniFile;
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;

implementation

uses
  dorXML;

{$R *.dfm}
const
  STATES: array[TXMPPReadyState] of string = (
   'Offline', 'Connecting', 'Connected', 'Authenticating', 'Authenticated', 'Open', 'Closing'
  );


var
 tempStr1,tempStr2 : string;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FPresence.Free;
  FIQCallBack.Free;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
 if not FInitFlag then begin
   FInitFlag := true;
   FIni := TMemIniFile.Create( ExtractFilePath(Application.ExeName)+'terminal.ini');
   ComPort.Port := FIni.ReadString('ComPort', 'ComPort',ComPort.Port);
   ComPort.BaudRate := StrToBaudRate( FIni.ReadString('ComPort','BaudRate', '19200'));
   ComPort.FlowControl.FlowControl := StrToFlowControl( FIni.ReadString('ComPort','FlowControl', 'Hardware'));
//   ConnButton.Click;
 end;
end;

procedure TForm1.PortButtonClick(Sender: TObject);
begin
  ComPort.ShowSetupDialog;
end;

procedure TForm1.tmrPingTimer(Sender: TObject);

  function DomainName: string;
  var
    P: Integer;
  begin
    P := Pos('@', edUsername.Text);
    Result := Copy(edUsername.Text, P + 1, MaxInt);
  end;

var
  iq: IXMPPIQ;
begin
  if (FXMPP <> nil) and (FXMPP.ReadyState = rsOpen) then
  begin
    iq := TXMPPMessage.CreateIQ(iqGet, DomainName);
    iq.Append('ping').Attributes.Add('xmlns', 'urn:xmpp:ping');
    FXMPP.SendIQ(iq,
      procedure(const iq_response: IXMPPIQ)
      begin
        if iq_response.Kind = iqError then
          tmrPing.Enabled := False;
      end
    );
  end;
end;

procedure TForm1.btConnectClick(Sender: TObject);
begin
  FXMPP.Open(edUsername.Text, edPassword.Text, '', edHostname.Text);
end;

procedure TForm1.btDisconnectClick(Sender: TObject);
begin
  FXMPP.Close;
end;

procedure TForm1.btSendMessageClick(Sender: TObject);
var
  msg: IXMPPMessage;
begin

 msg := TXMPPMessage.CreateMessage(mtChat,'desktop@elorobot.com');
 msg.Append('body').Text :=  'hello';
 FXMPP.SendXML(msg);

end;


procedure TForm1.ComPortAfterClose(Sender: TObject);
begin
  ConnButton.Caption := 'Connect';
end;

procedure TForm1.ComPortAfterOpen(Sender: TObject);
begin
  ConnButton.Caption := 'Disconnect';
end;

procedure TForm1.ComPortRxChar(Sender: TObject; Count: Integer);
var
 Str:String;
 msg: IXMPPMessage;
begin
  ComPort.ReadStr(Str, Count);
//  smLog.Text := smLog.Text + Str;
  smLog.Lines.Add(str);

(*
 msg := TXMPPMessage.CreateMessage(mtChat,'desktop@elorobot.com');
 msg.Append('body').Text :=  str;//'hello';
 FXMPP.SendXML(msg);
*)
end;

procedure TForm1.ConnButtonClick(Sender: TObject);
begin
  if ComPort.Connected then
    ComPort.Close
  else
    ComPort.Open;
end;


procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   if Assigned(FIni) then
   begin
     FIni.WriteString('ComPort', 'ComPort', ComPort.Port );
     FIni.WriteString('ComPort','BaudRate', BaudRateToStr( ComPort.BaudRate ) );
     FIni.WriteString('ComPort','FlowControl', FlowControlToStr(ComPort.FlowControl.FlowControl ));
     FIni.UpdateFile;
     FIni.Free;
   end;
end;

procedure CallBack1(iq:IXMPPIQ);
begin
 form1.smLog.Lines.Add('***6');
 form1.FXmpp.SendXML(iq.Reply);
end;

procedure CallBack2(Dir: TXMPPTraceDirection; const data: string);
    var
      l: TStringList;
    begin
     form1.smLog.Lines.Add('***3');
     form1.smLog.Lines.Add(data);
    end;

procedure CallBack3(const xmpp: IXMPPClient);
    begin
     form1.smLog.Lines.Add('***2');

     form1.Caption := 'XMPP - ' + STATES[xmpp.ReadyState];
     form1.btConnect.Enabled := xmpp.ReadyState in [rsOffline, rsClosing];
     form1.btDisconnect.Enabled := not form1.btConnect.Enabled;
     form1.tmrPing.Enabled := xmpp.ReadyState = rsOpen;
     if xmpp.ReadyState = rsClosing then
     begin

     end;

      if xmpp.ReadyState = rsOpen then
        xmpp.SendXML(TXMPPMessage.CreatePresence(ptNone2, psChat));

      if xmpp.ReadyState = rsClosing then
      begin
        xmpp.SendXML(TXMPPMessage.CreatePresence(ptUnavailable));
        form1.FPresence.Clear;
      end;
    end;

procedure TForm1.FormCreate(Sender: TObject);
begin

  tempStr1 := '';

  FXMPP := TXMPPClient.Create;
  FPresence := TDictionary<string, Boolean>.Create;
  FIQCallBack := TDictionary<RawByteString, TProc<IXMPPIQ>>.Create;

  FIQCallBack.Add('get@ping@urn:xmpp:ping',CallBack1);

  FIQCallBack.Add('get@query@jabber:iq:version',
    procedure(iq: IXMPPIQ)
    var
      resp: IXMPPIQ;
    begin
     smLog.Lines.Add('***5');
      resp := iq.Reply;
      with resp.FirstChild('query') do
      begin
        Append('name').Text := 'Delphi Client';
        Append('version').Text := '1.0';
      end;
      FXmpp.SendXML(resp);
    end);

  FIQCallBack.Add('get@query@http://jabber.org/protocol/disco#info',
    procedure(iq: IXMPPIQ)
    var
      resp: IXMPPIQ;
    begin
     smLog.Lines.Add('***4');
      resp := iq.Reply;
      with resp.FirstChild('query') do
      begin
        with Append('identity').Attributes do
        begin
          Add('category', 'client');
          Add('type', 'pc');
          Add('name', 'Delphi Client');
        end;
        Append('feature').Attributes.Add('var', 'urn:xmpp:ping');
        Append('feature').Attributes.Add('var', 'jabber:iq:version');
      end;
      FXmpp.SendXML(resp);
    end);

  FXMPP.OnTrace := CallBack2;
  FXMPP.OnReadyStateChange := CallBack3;


  FXmpp.OnIQ := procedure(const iq: IXMPPIQ)
    var
      q: IXMLNode;
      str: string;
      ev: TProc<IXMPPIQ>;
    begin
     smLog.Lines.Add('***1');
      q := iq.ChildNodes.First;
      if (q <> nil) and q.Attributes.TryGetValue('xmlns', str)
        and FIQCallBack.TryGetValue(
          RawByteString(iq.Attributes['type']) + '@' + q.Name + '@' + RawByteString(str), ev) then
        ev(iq) else
        FXmpp.SendXML(iq.Error(etCancel));
    end;

  FXMPP.OnPresence := procedure(const node: IXMPPPresence)
    var
      iq: IXMPPIQ;
      I: Integer;
    begin
     smLog.Lines.Add('***0');
      case node.Kind of
        ptNone2:
          begin
            if FPresence.ContainsKey(node.Src) then Exit;
            if node.src = FXMPP.JID then Exit;

            iq := TXMPPMessage.CreateIQ(iqGet, node.Src);
            iq.Append('query').Attributes.Add('xmlns', 'http://jabber.org/protocol/disco#info');
            FXmpp.SendIQ(iq,
              procedure (const iq: IXMPPIQ)
              var
                n: IXMLNode;
                list: TXMLNodeList;
              begin
                if (iq.Kind = iqResult) then
                begin
                  n := iq.FirstChild('query').FirstChild('identity');
                  if (n <> nil) and (iq.FirstChild('query').FindChildNodes('feature', list) > 0) then
                    for n in list do
                    begin
                      //lbContacts.Items.Add(iq.Src);
                      FPresence.AddOrSetValue(node.Src, True);
                    end;
                end;
              end
            );
          end;
        ptUnavailable:
        begin
          FPresence.Remove(node.Src);
          //for I := 0 to lbContacts.Items.Count - 1 do
          //  if lbContacts.Items[I] = node.Src then
          //    lbContacts.Items.Delete(I);
        end;
//        ptSubscribe:
//          begin
//            FXmpp.SendXML(TXMPPMessage.CreatePresence(ptSubscribed, psNone, '', 0, node.Src));
//            FXmpp.SendXML(TXMPPMessage.CreatePresence(ptSubscribe, psNone, '', 0, node.Src));
//          end;
//        ptUnsubscribe:
//          FXmpp.SendXML(TXMPPMessage.CreatePresence(ptUnsubscribe, psNone, '', 0, node.Src))
      end;
    end;
end;


end.
