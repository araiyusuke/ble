import CoreBluetooth
import Foundation

public enum WAILocationResponse {
    case locationUpdated(CBCharacteristic)
    case read(CBCharacteristic)
    case locationFail(NSError)
    case unauthorized
    case scanTimeout(Double)
    case device(CBCentralManager)
}

public var peripheralArray = [CBPeripheral]()

public typealias WAILocationUpdate = (_ response : WAILocationResponse) -> Void

open class SimpleBleNotify : NSObject {

    public typealias WAILocationUpdate = (_ response : WAILocationResponse) -> Void
    open var scanTime : Double = 10
    open var serviceUUID : String!
    open var peripheralUUID : String!
    open var characteristicUUID : String!
    var centralManager: CBCentralManager!
    var discoveredPeripheral:CBPeripheral!
    var log:Log = Log.sharedInstance
    var locationUpdateHandler : WAILocationUpdate?;
    open static let sharedInstance = SimpleBleNotify()

    open func simpleBLE(_ locationHandler : @escaping WAILocationUpdate) {
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        locationUpdateHandler = locationHandler
    }
    
    override init() {
        super.init()
        print("init")
        //self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    open func stopScan() {
        Log.debug("scan stop")
        centralManager.stopScan()
        self.locationUpdateHandler!(.scanTimeout(scanTime))
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
            return
        }
        //self.peripheral = peripheral
        let services = peripheral.services  as [CBService]!
        print(services!.count)
        peripheral.discoverCharacteristics(nil, for: (services?[0])!)
        
        //print("Found \(services?.count) services! :\(services)")
        
    }
    
    // キャラクタリスティックを発見した
    public func peripheral(_ peripheral: CBPeripheral,didDiscoverCharacteristicsFor service: CBService,error: Error?) {
        //print("didDiscoverCharacteristicsFor")
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
            //print("データ更新通知エラー: \(error)")
            return
        }
        self.locationUpdateHandler!(.read(characteristic))

        
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
        self.locationUpdateHandler!(.device(central))

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
        print("scanTimeout")
        stopScan()

    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        Log.debug("discover peripheral")
        peripheralArray.append(peripheral as CBPeripheral)
        central.connect(peripheralArray[0], options: nil)
        discoveredPeripheral = peripheralArray[0]
    }
    
    // ペリフェラルへの接続に失敗した。
    public func centralManager(central: CBCentralManager,didFailToConnectPeripheral peripheral: CBPeripheral,error: NSError?) {
        //print("didFailToConnectPeripheral")
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

public func simpleBleNotify(_ locationHandler : @escaping WAILocationUpdate) {
    SimpleBleNotify.sharedInstance.simpleBLE(locationHandler)
}
