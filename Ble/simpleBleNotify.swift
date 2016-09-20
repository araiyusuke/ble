import CoreBluetooth
import Foundation

public enum SBNResponse {
    case read(CBCharacteristic)
    case fail(Error?)
    case unauthorized
    case scanTimeout(Double)
    case device(CBCentralManager)
}

public var peripheralArray = [CBPeripheral]()

public typealias SBNUpdate = (_ response : SBNResponse) -> Void

open class SimpleBleNotify : NSObject {

    public typealias SBNUpdate = (_ response : SBNResponse) -> Void
    open var scanTime : Double = 10
    open var serviceUUID : String!
    open var peripheralUUID : String!
    open var characteristicUUID : String!
    var centralManager: CBCentralManager!
    var discoveredPeripheral:CBPeripheral!
    var log:Log = Log.sharedInstance
    var bleHandler : SBNUpdate?;
    open static let sharedInstance = SimpleBleNotify()

    open func simpleBLE(_ bleHandler : @escaping SBNUpdate) {
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.bleHandler = bleHandler
    }
    
    override init() {
        super.init()
    }
    
    open func stopScan() {
        Log.debug("scan stop")
        centralManager.stopScan()
        self.bleHandler!(.scanTimeout(scanTime))
    }
    open func disconnect() {
        centralManager.cancelPeripheralConnection(discoveredPeripheral)
        discoveredPeripheral = nil
    }
}

extension SimpleBleNotify: CBPeripheralDelegate {
    
    // サービスを発見した
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        Log.debug("discover service")
        
        if (error != nil) {
            self.bleHandler!(.fail(error))
            return
        }
        //self.peripheral = peripheral
        let services = peripheral.services  as [CBService]!
        peripheral.discoverCharacteristics(nil, for: (services?[0])!)
    }
    
    // キャラクタリスティックを発見した
    public func peripheral(_ peripheral: CBPeripheral,didDiscoverCharacteristicsFor service: CBService,error: Error?) {
        Log.debug("discover characteristics")
        if (error != nil) {
            //print("error: \(error)")
            return
        }
        for characteristic in service.characteristics! {
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    //notifyをONにする。
    public func peripheral(_ peripheral: CBPeripheral,didUpdateNotificationStateFor characteristic: CBCharacteristic,error: Error?) {
        if error != nil {
            //print("Notify状態更新失敗...error: \(error)")
        } else {
            //print("Notify状態更新成功！ isNotifying: \(characteristic.isNotifying)")
        }
    }
    
    //データ受信
    public func peripheral(_ peripheral: CBPeripheral,didUpdateValueFor characteristic: CBCharacteristic,error: Error?) {
        
        if error != nil {
            //bleHandler!(.fail(error))
            //print("データ更新通知エラー: \(error)")
            return
        }
        self.bleHandler!(.read(characteristic))

        
//        print(type(of: characteristic))
//        
//        guard let data = characteristic.value else {
//            return
//        }
//        if let valueString = String(data: data, encoding: String.Encoding.utf8) {
//        }

    }
}

extension SimpleBleNotify: CBCentralManagerDelegate {
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        self.bleHandler!(.device(central))

        switch(central.state) {
        case .poweredOn:            
            Timer.scheduledTimer(timeInterval: scanTime, target: self, selector: #selector(SimpleBleNotify.scanTimeout), userInfo: nil, repeats: false)

            central.scanForPeripherals(withServices: nil, options: nil)
            Log.debug("poweredOn")
        case .poweredOff:
            // BluetoothがOFFになっている。
            Log.debug("powerdOff")
        case .unsupported:
            Log.debug("unsupported")
            // BLEがサポートされていない端末
        case .resetting:
            Log.debug("resetting")
        case .unauthorized:
            // Bluetoothの許可がない
            Log.debug("unauthorized")

        default:
            break
        }
    }
    
    @objc private func scanTimeout() {
        Log.debug("scan timeout")
        stopScan()
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        Log.debug("discover peripheral")
        peripheralArray.append(peripheral as CBPeripheral)
        central.connect(peripheralArray[0], options: nil)
        discoveredPeripheral = peripheralArray[0]
    }
    
    // ペリフェラルへの接続に失敗した。
    public func centralManager(central: CBCentralManager,didFailToConnectPeripheral peripheral: CBPeripheral,error: NSError) {
        bleHandler!(.fail(error))
    }
    
    // ペリフェラルへの接続に成功した。
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //print("didConnect")
        peripheral.delegate = self
        let UUID = CBUUID(string: serviceUUID)
        peripheral.discoverServices([UUID])
        stopScan()
    }
}

public func simpleBleNotify(_ bleHandler : @escaping SBNUpdate) {
    SimpleBleNotify.sharedInstance.simpleBLE(bleHandler)
}
