unit ClienteServidor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Datasnap.DBClient, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, TratarExcecao, System.Threading;

type
  TServidor = class
  private
    FPath: AnsiString;
    sequencia_arquivo: integer;
  public
    arquivos_enviados: TStringList;
    constructor Create;
    //Tipo do parâmetro não pode ser alterado
    function SalvarArquivos(AData: OleVariant): Boolean;
    function buscaarquivo:integer;
    procedure apagararquivo(lista: TStringList);
  end;

  TfClienteServidor = class(TForm)
    ProgressBar: TProgressBar;
    btEnviarSemErros: TButton;
    btEnviarComErros: TButton;
    btEnviarParalelo: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btEnviarSemErrosClick(Sender: TObject);
    procedure btEnviarComErrosClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btEnviarParaleloClick(Sender: TObject);
  private
    FPath: AnsiString;
    FServidor: TServidor;

    function InitDataset: TClientDataset;
  public
    cds_paralelo: TFDMemTable;
  end;

var
  fClienteServidor: TfClienteServidor;

const
  QTD_ARQUIVOS_ENVIAR = 100;

implementation

uses
  IOUtils, System.SyncObjs;

{$R *.dfm}

procedure TfClienteServidor.btEnviarComErrosClick(Sender: TObject);
var
  cds: TClientDataset;
  i, TotalBlob: Integer;
begin
  fServidor.arquivos_enviados.Clear;
  cds := InitDataset;
  TotalBlob := 0;
  progressbar.Position := 0;
  progressbar.Max := QTD_ARQUIVOS_ENVIAR;
  try
    try
      for i := 0 to QTD_ARQUIVOS_ENVIAR -1 do
      begin
        progressbar.Position := i + 1;
        cds.Append;
        TBlobField(cds.FieldByName('Arquivo')).LoadFromFile(String(FPath));
        TotalBlob := TotalBlob + TBlobField(cds.FieldByName('Arquivo')).BlobSize;
        cds.Post;

        if (TotalBlob > 102400000) then
        begin
          TotalBlob := 0;
          FServidor.SalvarArquivos(cds.Data);
          cds.EmptyDataSet();
        end;
        Application.ProcessMessages();

        {$REGION Simulação de erro, não alterar}
        if i = (QTD_ARQUIVOS_ENVIAR/2) then
          FServidor.SalvarArquivos(NULL);
        {$ENDREGION}
      end;
    finally
      if (TotalBlob > 0) then
        FServidor.SalvarArquivos(cds.Data);

      FreeAndNil(cds);
    end;
  except
    on E: Exception do
    begin
      fServidor.apagararquivo(fServidor.arquivos_enviados);
      progressbar.Position := 0;
      raise EErroClienteServidor.Create('Falha ao enviar arquivos, a ação será desfeita!');
    end;
  end;
end;

procedure TfClienteServidor.btEnviarParaleloClick(Sender: TObject);
var
  cds: TClientDataset;
  TotalBlob: Integer;
begin
  fServidor.arquivos_enviados.Clear;
  cds := InitDataset;
  TotalBlob := 0;
  progressbar.Position := 0;
  progressbar.Max := QTD_ARQUIVOS_ENVIAR;
  try
    try
      TParallel.&For(0, 10, QTD_ARQUIVOS_ENVIAR,
        procedure(i: integer)
        begin
          TThread.Queue(TThread.CurrentThread,
          procedure
          begin
            progressbar.Position := i;
            cds.Append;
            TBlobField(cds.FieldByName('Arquivo')).LoadFromFile(String(FPath));
            TotalBlob := TotalBlob + TBlobField(cds.FieldByName('Arquivo')).BlobSize;
            cds.Post;

            if (TotalBlob > 102400000) then
            begin
              TotalBlob := 0;
              FServidor.SalvarArquivos(cds.Data);
              cds.EmptyDataSet();
            end;
          end);
        end);
    finally
      if (TotalBlob > 0) then
		    FServidor.SalvarArquivos(cds.Data);

      if Application.MessageBox('Arquivos Enviados com Sucesso!','Envio de Aquivos Sem Erros',MB_OK) = IDOK then
        progressbar.Position := 0;

      FreeAndNil(cds);
    end;
  except
    on E: Exception do
    begin
     raise EErroClienteServidor.Create('Erro ao enviar os Arquivos!');
    end;
  end;
end;

procedure TfClienteServidor.btEnviarSemErrosClick(Sender: TObject);
var
  cds: TClientDataset;
  i, TotalBlob: Integer;
begin
  fServidor.arquivos_enviados.Clear;
  cds := InitDataset;
  TotalBlob := 0;
  progressbar.Position := 0;
  progressbar.Max := QTD_ARQUIVOS_ENVIAR;
  try
    try
      for i := 0 to QTD_ARQUIVOS_ENVIAR - 1 do
      begin
        progressbar.Position := i + 1;
        cds.Append;
        TBlobField(cds.FieldByName('Arquivo')).LoadFromFile(String(FPath));
		    TotalBlob := TotalBlob + TBlobField(cds.FieldByName('Arquivo')).BlobSize;
        cds.Post;

        if (TotalBlob > 102400000) then
        begin
          TotalBlob := 0;
          FServidor.SalvarArquivos(cds.Data);
          cds.EmptyDataSet();
        end;
        Application.ProcessMessages();
      end;
    finally
      if (TotalBlob > 0) then
		    FServidor.SalvarArquivos(cds.Data);
      if Application.MessageBox('Arquivos Enviados com Sucesso!','Envio de Aquivos Sem Erros',MB_OK) = IDOK then
        progressbar.Position := 0;

      FreeAndNil(cds);
    end;
  except
    on E: Exception do
    begin
     raise EErroClienteServidor.Create('Erro ao enviar os Arquivos!');
    end;
  end;
end;

procedure TfClienteServidor.FormCreate(Sender: TObject);
begin
  inherited;
  FPath := AnsiString(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'pdf.pdf');
  FServidor := TServidor.Create;
end;

procedure TfClienteServidor.FormDestroy(Sender: TObject);
begin
  fClienteServidor := nil;
  FreeAndNil(FServidor.arquivos_enviados);
  FreeAndNil(FServidor);
end;

function TfClienteServidor.InitDataset: TClientDataset;
begin
  Result := TClientDataset.Create(nil);
  Result.FieldDefs.Add('Arquivo', ftBlob);
  Result.CreateDataSet;
end;

{ TServidor }

procedure TServidor.apagararquivo(lista: TStringList);
var
  busca: TSearchRec;
  i: integer;
begin
  for i := 0 to lista.Count - 1 do
  begin
    if FindFirst(lista[i], faAnyFile, busca) = 0 then
      DeleteFile(lista[i]);

    FindNext(busca);
  end;
end;

function TServidor.buscaarquivo: integer;
var
  busca: TSearchRec;
  lista: TStringList;
  arq_encontrado: boolean;
begin
  lista := TStringList.Create;
  lista.Create;
  try
    arq_encontrado := FindFirst(String(FPath) +'\*.PDF', faAnyFile, busca) = 0;
    while arq_encontrado do
    begin
      lista.Add(busca.Name);
      arq_encontrado := FindNext(busca) = 0;
    end;
    FindClose(busca);
  finally
    Result := lista.Count;
    FreeAndNil(lista);
  end;
end;

constructor TServidor.Create;
begin
  FPath := AnsiString(ExtractFilePath(ParamStr(0)) + 'Servidor\');
  arquivos_enviados := TStringList.Create;
  arquivos_enviados.Create;
end;

function TServidor.SalvarArquivos(AData: OleVariant): Boolean;
var
  cds: TClientDataSet;
  FileName: string;
begin
  try
    try
      sequencia_arquivo := buscaarquivo;
      cds := TClientDataset.Create(nil);
      cds.Data := AData;

      {$REGION Simulação de erro, não alterar}
      if cds.RecordCount = 0 then
        Exit();
      {$ENDREGION}

      cds.First;
      while not cds.Eof do
      begin
        inc(sequencia_arquivo);
        FileName := String(FPath) + IntToStr(sequencia_arquivo) + '.pdf';
        arquivos_enviados.Add(FileName);

        if not DirectoryExists(String(FPath)) then
          ForceDirectories(String(FPath));

        if TFile.Exists(FileName) then
          TFile.Delete(FileName);

        TBlobField(cds.FieldByName('Arquivo')).SaveToFile(FileName);
        cds.Next;
      end;

    finally
      Result := True;
      FreeAndNil(cds);
    end;
  except
    raise;
  end;
end;

end.
