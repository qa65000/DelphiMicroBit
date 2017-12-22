program TestMicroBit;

uses
  System.StartUpCopy,
  FMX.Forms,
  Main in 'Main.Pas' {Form42};

{$R *.res}

begin
  Application.Initialize;
  Application.FormFactor.Orientations := [TFormOrientation.Landscape];
  Application.CreateForm(TForm42, Form42);
  Application.Run;
end.
