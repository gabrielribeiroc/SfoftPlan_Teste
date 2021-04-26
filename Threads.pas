unit Threads;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, System.Math, System.SyncObjs, Vcl.ExtCtrls,
  System.Types, System.UITypes, System.Threading, System.Generics.Collections;

type
  ILogOp = interface
    procedure mensagem(const AValue: string);
    procedure atualizarprogresso(const ASender: TObject; const AValue: Integer);
  end;

  TListaThread = class(TThreadList<TThread>)
  strict private
    FOnNotifyItemTerminate: TProc<TThread>;
    procedure OnThreadTerminateHandler(Sender: TObject);
    procedure TerminateThread(const AThread: TThread);
    function recuperarquantidade(): Integer;
  public
    property quantidade: Integer read recuperarquantidade;
    property OnNotifyItemTerminate: TProc<TThread> read FOnNotifyItemTerminate write FOnNotifyItemTerminate;
    procedure Add(const AItem: TThread);
    procedure WithLockList(const AProc: TProc<TList<TThread>>);
    procedure TerminateAll();
  end;

  TfThreads = class(TForm, ILogOp)
    edt_threads: TEdit;
    edt_tempo: TEdit;
    ProgressBar: TProgressBar;
    mmo_result: TMemo;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    btn_executar: TButton;
    Label3: TLabel;
    procedure btn_executarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FThreadMonitoramento: TThread;
    FListaThread: TListaThread;
    function CriarThreadMonitaramento(): TThread;
  strict private
    procedure mensagem(const AValue: string);
    procedure atualizarprogresso(const ASender: TObject; const AValue: Integer);
  strict private
  public
  end;

  TParametrosThread = record
  public
    IntervaloMaximo: Integer;
  end;

  TProcessoThread = class(TThread)
  strict private
    FLog: ILogOp;
    FParametros: TParametrosThread;
    function ObterIntervalo(): Integer;
  strict protected
    procedure Execute(); override;
  public
    constructor Create(const ALog: ILogOp; const AParametros: TParametrosThread);
    destructor Destroy(); override;
    class function New(const ALog: ILogOp; const AParametros: TParametrosThread): TProcessoThread;
  end;

var
  fThreads: TfThreads;

implementation

{$R *.dfm}

procedure TfThreads.atualizarprogresso(const ASender: TObject; const AValue: Integer);
begin
  TThread.Synchronize(nil,
    procedure()
    begin
      ProgressBar.Position := ProgressBar.Position + 1;
    end);
end;

procedure TfThreads.btn_executarClick(Sender: TObject);
var
  parametrosThread: TParametrosThread;
  indice: Integer;
  numeroThreads: Integer;
begin
  mmo_result.Clear();
  ProgressBar.Position := 0;
  numeroThreads := StrToIntDef(edt_threads.Text, 0);
  btn_executar.Enabled := (numeroThreads = 0);
  try
    ProgressBar.Max := numeroThreads * 101;
    parametrosThread.IntervaloMaximo := StrToIntDef(edt_tempo.Text, 0);
    for indice := 1 to numeroThreads do
    begin
      FListaThread.Add(TProcessoThread.New(Self, parametrosThread));
    end;
  except
    btn_executar.Enabled := True;
    raise;
  end;
end;

function TfThreads.CriarThreadMonitaramento(): TThread;
begin
  Result := TThread.CreateAnonymousThread(
    procedure()
    begin
      while (not TThread.CheckTerminated()) do
      begin
        TThread.Sleep(10);
        TThread.Synchronize(nil,
          procedure()
          var
            contador: Integer;
          begin
            contador := FListaThread.quantidade;
            Label3.Caption := Format('Threads rodando %d', [contador]);
            btn_executar.Enabled := (contador = 0);
          end);
      end;
    end);
  Result.FreeOnTerminate := False;
end;

procedure TfThreads.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
  if FListaThread.quantidade > 0 then
  begin
    if MessageDlg('Deseja encerrar todas as Threads?',mtError, mbOKCancel, 0) = mrOK then
    begin
      FListaThread.TerminateAll();
      CanClose := True;
    end;
  end
  else
   CanClose := True;
end;

procedure TfThreads.FormCreate(Sender: TObject);
begin
  FListaThread := TListaThread.Create();
  FListaThread.OnNotifyItemTerminate :=
    procedure(AThread: TThread)
    begin
      if Assigned(AThread.FatalException) then
      begin
        mensagem(Format('A Thread %d finalizou com uma exceção %s', [AThread.ThreadID, Exception(AThread.FatalException).Message]));
      end;
    end;
  FThreadMonitoramento := CriarThreadMonitaramento();
  FThreadMonitoramento.Start();
end;

procedure TfThreads.FormDestroy(Sender: TObject);
begin
  FThreadMonitoramento.Terminate();
  FThreadMonitoramento.WaitFor();
  FreeAndNil(FThreadMonitoramento);
  FListaThread.TerminateAll();
  FreeAndNil(FListaThread);
end;

procedure TfThreads.mensagem(const AValue: string);
begin
  TThread.Synchronize(nil,
    procedure()
    begin
      mmo_result.Lines.Add(Format('[%s] %s', [DateTimeToStr(Now()), AValue]));
    end);
end;

{ TProcessoThread }

constructor TProcessoThread.Create(const ALog: ILogOp; const AParametros: TParametrosThread);
begin
  inherited Create(True);
  FreeOnTerminate := True;
  FLog := ALog;
  FParametros := AParametros;
end;

destructor TProcessoThread.Destroy();
begin
  inherited Destroy();
end;

procedure TProcessoThread.Execute();
var
  progresso: Integer;
begin
  Randomize();
  FLog.mensagem(Format('%d - Iniciando processamento', [ThreadID]));
  for progresso := 0 to 100 do
  begin
    if Terminated then
      Break;
    TThread.Sleep(ObterIntervalo());
    FLog.atualizarprogresso(Self, progresso);
  end;
  FLog.mensagem(Format('%d - Processamento finalizado', [ThreadID]));
end;

class function TProcessoThread.New(const ALog: ILogOp; const AParametros: TParametrosThread): TProcessoThread;
begin
  Result := TProcessoThread.Create(ALog, AParametros);
  Result.Start();
end;

function TProcessoThread.ObterIntervalo(): Integer;
begin
  Result := Random(FParametros.IntervaloMaximo);
end;

{ TListaThread<T> }

procedure TListaThread.Add(const AItem: TThread);
begin
  AItem.OnTerminate := OnThreadTerminateHandler;
  inherited Add(AItem);
end;

function TListaThread.recuperarquantidade(): Integer;
var
  LResult: Integer;
begin
  WithLockList(
    procedure(AList: TList<TThread>)
    begin
      LResult := AList.Count;
    end);
  Result := LResult;
end;

procedure TListaThread.TerminateAll();
begin
  WithLockList(
    procedure(AList: TList<TThread>)
    begin
      while (AList.Count > 0) do
      begin
        TerminateThread(AList.ExtractAt(0));
      end;
    end);
end;

procedure TListaThread.TerminateThread(const AThread: TThread);
begin
  AThread.FreeOnTerminate := False;
  AThread.Terminate();
  AThread.WaitFor();
  AThread.DisposeOf();
end;

procedure TListaThread.OnThreadTerminateHandler(Sender: TObject);
begin
  FOnNotifyItemTerminate(TThread(Sender));
  Remove(TThread(Sender));
end;

procedure TListaThread.WithLockList(const AProc: TProc<TList<TThread>>);
var
  LList: TList<TThread>;
begin
  LList := LockList();
  try
    AProc(LList);
  finally
    UnlockList();
  end;
end;

end.

