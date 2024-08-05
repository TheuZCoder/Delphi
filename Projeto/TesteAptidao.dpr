program TesteAptidao;

uses
  Vcl.Forms,
  UPesqPedidos in 'UPesqPedidos.pas' {FrmUPesqPedidos},
  UCadPedidos in 'UCadPedidos.pas' {FrmUCadPedidos},
  UCadItens in 'UCadItens.pas' {FrmUCadItens};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmUPesqPedidos, FrmUPesqPedidos);
  Application.Run;
end.
