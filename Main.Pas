unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Edit, FMX.Controls.Presentation, System.Bluetooth,
  System.Bluetooth.Components;

const
 UUID_BUTTON_SERVICE          : TBluetoothUUID  = '{E95D9882-251D-470A-A062-FA1922DFA9A8}';
 UUID_BUTTON1_CHARACTERRISTIC : TBluetoothUUID  = '{E95DDA90-251D-470A-A062-FA1922DFA9A8}';
 UUID_BUTTON2_CHARACTERRISTIC : TBluetoothUUID  = '{E95DDA91-251D-470A-A062-FA1922DFA9A8}';

 UUID_UART_SERVICE            : TBluetoothUUID  = '{6E400001-B5A3-F393-E0A9-E50E24DCCA9E}';
 UUID_UART_TX_CHARACTERRISTIC : TBluetoothUUID  = '{6E400003-B5A3-F393-E0A9-E50E24DCCA9E}';

type

  TForm42 = class(TForm)
    Connect: TButton;
    Edit1: TEdit;
    Send: TButton;
    ButtonA: TCircle;
    Label1: TLabel;
    BTLableA: TLabel;
    ButtonB: TCircle;
    BtLabelB: TLabel;
    BluetoothLE1: TBluetoothLE;
    procedure BluetoothLE1CharacteristicRead(const Sender: TObject;
      const ACharacteristic: TBluetoothGattCharacteristic;
      AGattStatus: TBluetoothGattStatus);
    procedure BluetoothLE1EndDiscoverDevices(const Sender: TObject;
      const ADeviceList: TBluetoothLEDeviceList);
    procedure BluetoothLE1EndDiscoverServices(const Sender: TObject;
      const AServiceList: TBluetoothGattServiceList);
    procedure ConnectClick(Sender: TObject);
    procedure SendClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private êÈåæ }
  public
    { public êÈåæ }
  end;

var
  Form42: TForm42;
  GBleDevice         : TBluetoothLEDevice;
  BackColor          : TColor;

implementation

{$R *.fmx}

procedure TForm42.BluetoothLE1CharacteristicRead(const Sender: TObject;
  const ACharacteristic: TBluetoothGattCharacteristic;
  AGattStatus: TBluetoothGattStatus);
begin
  if(ACharacteristic.UUID = UUID_BUTTON1_CHARACTERRISTIC) then
  begin
    if  ACharacteristic.GetValueAsInt8(0) <> 0 then
        ButtonA.Fill.Color := TAlphaColorRec.Red
    else
        ButtonA.Fill.Color := BackColor;
  end
  else
  if(ACharacteristic.UUID = UUID_BUTTON2_CHARACTERRISTIC) then
  begin
    if  ACharacteristic.GetValueAsInt8(0) <> 0 then
        ButtonB.Fill.Color := TAlphaColorRec.Red
    else
        ButtonB.Fill.Color := BackColor;
  end;
end;

procedure TForm42.BluetoothLE1EndDiscoverDevices(const Sender: TObject;
  const ADeviceList: TBluetoothLEDeviceList);
var
i : uint32;   // ARM Ç»ÇÃÇ≈ç≈ìKâª

begin
  if ADeviceList.Count > 0 then begin
    for i := 0 to Pred(ADeviceList.Count) do begin
      if Pos('BBC micro:bit', ADeviceList[i].DeviceName) > 0 then begin
        Label1.Text := ADeviceList[i].DeviceName ;// ' (' + ADeviceList[i].Address + ')';
        BluetoothLE1.CancelDiscovery;
        GBleDevice  :=  ADeviceList[i];
        GBleDevice.DiscoverServices;
        exit;
      end;
    end;
  end;
end;

procedure TForm42.BluetoothLE1EndDiscoverServices(const Sender: TObject;
  const AServiceList: TBluetoothGattServiceList);
var
  i : uint32;   // ARM Ç»ÇÃÇ≈ç≈ìKâª
  LGattService   : TBluetoothGattService;
begin
  LGattService := BluetoothLE1.GetService(GBleDevice, UUID_BUTTON_SERVICE);
  if LGattService <> nil then
  begin
    for i := 0 to Pred(LGattService.Characteristics.Count) do
    begin
        if LGattService.Characteristics[i].UUID = UUID_BUTTON1_CHARACTERRISTIC then
        begin
           GBleDevice.SetCharacteristicNotification(LGattService.Characteristics[i], True);
        end
        else
        if LGattService.Characteristics[i].UUID = UUID_BUTTON2_CHARACTERRISTIC then
        begin

           GBleDevice.SetCharacteristicNotification(LGattService.Characteristics[i], True);
        end;
    end;
  end;

end;

procedure TForm42.ConnectClick(Sender: TObject);
begin
  if( not BluetoothLE1.Enabled ) then
  begin
    BluetoothLE1.Enabled := True;
    BluetoothLE1.DiscoverDevices(1000);  // 10ïb
    Connect.Text := 'Disconnect';
    Label1.Text  := '';
  end
  else
  begin
    BluetoothLE1.CancelDiscovery;
    BluetoothLE1.Enabled := False;
    GBleDevice           := NIL;
    Connect.Text := 'Connect';
  end;
end;

procedure TForm42.FormCreate(Sender: TObject);
begin
    BackColor :=  ButtonA.Fill.Color;
end;

procedure TForm42.SendClick(Sender: TObject);
var
  i : uint32;   // ARM Ç»ÇÃÇ≈ç≈ìKâª
  LGattService : TBluetoothGattService;
  LCharact     : TBluetoothGattCharacteristic;
begin
  if GBleDevice             = NIL   then exit;
  if GBleDevice.IsConnected = false then exit;

  LGattService := BluetoothLE1.GetService(GBleDevice, UUID_UART_SERVICE);
  if  LGattService   = NIL   then exit;
//  LCharact     :=  LGattService.GetCharacteristic(UUID_UART_TX_CHARACTERRISTIC);
  for i := 0 to Pred(LGattService.Characteristics.Count) do
  begin
    if LGattService.Characteristics[i].UUID = UUID_UART_TX_CHARACTERRISTIC then
    begin
       LGattService.Characteristics[i].SetValueAsString(Edit1.Text+'#', True);
       GBleDevice.WriteCharacteristic(LGattService.Characteristics[i]);
       exit;
    end;
  end;
end;

end.
