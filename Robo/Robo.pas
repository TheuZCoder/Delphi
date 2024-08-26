unit Robo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.IOUtils;

type
  TForm1 = class(TForm)
    Button1: TButton;
    EditReplace: TEdit;
    EditNewPrefix: TEdit; // Novo TEdit para o prefixo novo
    Memo1: TMemo;
    EditUnitName: TEdit;
    EditTypeName: TEdit; // Novo Label para o EditNewPrefix
    procedure Button1Click(Sender: TObject);
  private
    procedure ProcessFiles(const Directory: string);
    procedure AddUnitIfNeeded(var FileContent: string);
    procedure ReplaceTextInFile(var FileContent: string);
    procedure UpdateLanguageConstFile(const FileName: string);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.ProcessFiles(const Directory: string);
var
  Files: TArray<string>;
  FileContent, FileName: string;
  Encoding: TEncoding;
begin
  // Define a codifica��o ANSI
  Encoding := TEncoding.ANSI;

  // Procura todos os arquivos .pas no diret�rio
  Files := TDirectory.GetFiles(Directory, '*.pas', TSearchOption.soAllDirectories);

  for FileName in Files do
  begin
    // L� o conte�do do arquivo usando codifica��o ANSI
    FileContent := TFile.ReadAllText(FileName, Encoding);

    // Substitui os textos conforme o especificado nos Edits
    ReplaceTextInFile(FileContent);

    // Adiciona a unidade uLanguageConst se necess�rio
    AddUnitIfNeeded(FileContent);

    // Salva o conte�do modificado no arquivo usando codifica��o ANSI
    TFile.WriteAllText(FileName, FileContent, Encoding);
    Memo1.Lines.Add('Arquivo processado: ' + FileName);
  end;

  ShowMessage('Processo conclu�do!');
end;

procedure TForm1.ReplaceTextInFile(var FileContent: string);
var
  OldText, NewText: string;
begin
  // Obt�m os textos do EditReplace e EditNewPrefix
  OldText := EditReplace.Text;
  NewText := EditNewPrefix.Text;

  // Substitui o texto antigo pelo novo no conte�do do arquivo
  FileContent := StringReplace(FileContent, OldText, NewText, [rfReplaceAll]);
end;

procedure TForm1.AddUnitIfNeeded(var FileContent: string);
const
  UnitToAdd = 'uLanguageConst';
var
  UsesPos, TypePos: Integer;
  UsesSection: string;
begin
  // Encontra a posi��o das se��es "uses" e "type"
  UsesPos := Pos('uses', LowerCase(FileContent));
  TypePos := Pos('type', LowerCase(FileContent));

  if (UsesPos > 0) and (TypePos > UsesPos) then
  begin
    // Extrai o texto entre "uses" e "type"
    UsesSection := Copy(FileContent, UsesPos, TypePos - UsesPos);

    // Verifica se a unidade j� foi adicionada (case-insensitive)
    if Pos(LowerCase(UnitToAdd), LowerCase(UsesSection)) = 0 then
    begin
      // Insere a unidade ap�s 'uses' e quebra a linha
      Insert(Format(#13#10'  %s,'#13#10, [UnitToAdd]), FileContent, UsesPos + Length('uses'));
    end;
  end;
end;

procedure TForm1.UpdateLanguageConstFile(const FileName: string);
var
  FileContent: string;
  UsesPos, TypePos, ImplPos: Integer;
  UnitName, TypeName: string;
begin
  // L� o conte�do do arquivo usando codifica��o ANSI
  FileContent := TFile.ReadAllText(FileName, TEncoding.ANSI);

  // Obt�m o nome da unidade e o nome do tipo dos Edits
  UnitName := EditUnitName.Text;
  TypeName := EditTypeName.Text;

  // Adiciona a unidade ap�s a primeira declara��o de "uses"
  UsesPos := Pos('uses', LowerCase(FileContent));
  if UsesPos > 0 then
  begin
    // Adiciona a unidade ap�s a primeira declara��o de "uses"
    Insert(Format(#13#10'  uConst.ptBR.%s,', [LowerCase(UnitName)]), FileContent, UsesPos + Length('uses'));
  end;

  // Adiciona a declara��o de tipo antes da palavra-chave "implementation"
  ImplPos := Pos('implementation', LowerCase(FileContent));
  if ImplPos > 0 then
  begin
    // Adiciona o tipo antes da palavra-chave "implementation"
    Insert(Format('  TConst%s = TptBR%s;'#13#10, [TypeName, TypeName]), FileContent, ImplPos);
  end;

  // Salva o conte�do modificado no arquivo usando codifica��o ANSI
  TFile.WriteAllText(FileName, FileContent, TEncoding.ANSI);

  Memo1.Lines.Add('Arquivo uLanguageConst.pas atualizado: ' + FileName);
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  caminhoDiretorio, outroDiretorio, uLanguageConstFile: string;
begin
  caminhoDiretorio := 'C:\Users\matheus.silva\Documents\Projetos Zucchetti\DebxERP\Master\DebxERP\Server\Controllers';
  outroDiretorio := 'C:\Users\matheus.silva\Documents\Projetos Zucchetti\DebxERP\Master\DebxERP\Server\Models';
  uLanguageConstFile := 'C:\Users\matheus.silva\Documents\Projetos Zucchetti\DebxERP\Master\DebxERP\Server\uLanguageConst.pas';

  if DirectoryExists(caminhoDiretorio) then
    ProcessFiles(caminhoDiretorio)
  else
    ShowMessage('Diret�rio Controller inv�lido.');

  if DirectoryExists(outroDiretorio) then
    ProcessFiles(outroDiretorio)
  else
    ShowMessage('Diret�rio Model inv�lido.');

  if FileExists(uLanguageConstFile) then
    UpdateLanguageConstFile(uLanguageConstFile)
  else
    ShowMessage('Arquivo uLanguageConst.pas n�o encontrado.');
end;

end.
