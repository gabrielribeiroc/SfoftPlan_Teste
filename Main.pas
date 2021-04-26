unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.AppEvnts, TratarExcecao;

type
  TfMain = class(TForm)
    btDatasetLoop: TButton;
    btThreads: TButton;
    btStreams: TButton;
    procedure btDatasetLoopClick(Sender: TObject);
    procedure btStreamsClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btThreadsClick(Sender: TObject);
  private
  public
  end;

var
  fMain: TfMain;

implementation

uses
  DatasetLoop, ClienteServidor, Threads;

{$R *.dfm}

procedure TfMain.btDatasetLoopClick(Sender: TObject);
begin
  if not Assigned(fDatasetLoop) then
  begin
    fDatasetLoop := TfDatasetLoop.Create(Self);
    fDatasetLoop.Show;
  end
  else
    fDatasetLoop.Show;
end;

procedure TfMain.btStreamsClick(Sender: TObject);
begin
  if not Assigned(fClienteServidor) then
  begin
    fClienteServidor := TfClienteServidor.Create(Self);
    fClienteServidor.Show;
  end
  else
    fClienteServidor.Show;
end;

procedure TfMain.btThreadsClick(Sender: TObject);
begin
  if not Assigned(fThreads) then
  begin
    fThreads := TfThreads.Create(Self);
    fThreads.Show;
  end
  else
    fThreads.Show;
end;

procedure TfMain.FormDestroy(Sender: TObject);
begin
  fMain := nil;
end;

end.
