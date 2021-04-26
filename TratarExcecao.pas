unit TratarExcecao;

interface

uses
  System.SysUtils;

type
  TException = class
    private
    FArquivoLog: String;
    public
    constructor Create;
    procedure TrataExcecao(Sender: TObject; E: Exception);
    procedure GravarLog(Mensagem: String);
  end;

  EErroClienteServidor  = class(Exception);

implementation

uses
  Forms, System.Classes, Vcl.Dialogs;

{ TException }

constructor TException.Create;
begin
  FArquivoLog := FormatDateTime('DD-MM-YYYY',Now) + '_' + ExtractFileName(Application.Exename);
  FArquivoLog := ChangeFileExt(FARquivoLog, '.log');
  Application.OnException := TrataExcecao;
end;

procedure TException.GravarLog(Mensagem: String);
var
  txtlog: TextFile;
begin
  AssignFile(txtlog, FArquivoLog);

  if FileExists(FArquivoLog) then
    Append(txtlog)
  else
    ReWrite(txtlog);

  WriteLn(txtlog,Mensagem);
  CloseFile(txtlog);
end;

procedure TException.TrataExcecao(Sender: TObject; E: Exception);
begin

  GravarLog('Data/Hora.......: ' + DateTimeToStr(Now));
  GravarLog('Mensagem........: ' + E.Message);
  GravarLog('Classe Exceção..: ' + E.ClassName);
  GravarLog('Formulário......: ' + Screen.ActiveForm.Name);
  GravarLog('Controle Visual.: ' + Screen.ActiveControl.Name);
  GravarLog(StringOfChar('-', 70));

  ShowMessage(E.Message);
end;

var
  Excecao: TException;

initialization
  Excecao := TException.Create;

finalization
  Excecao.Free;

end.
