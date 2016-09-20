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
    var clientEventHandler : SBNUpdate?;
    open static let sharedInstance = SimpleBleNotify()

    open func simpleBLE(_ clientEventHandler : @escaping SBNUpdate) {
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.clientEventHandler = clientEventHandler
    }
    
    override init() {
        super.init()
    }
    
    open func startScan() {
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    open func stopScan() {
        Log.debug("scan stop")
        centralManager.stopScan()
        self.clientEventHandler!(.scanTimeout(scanTime))
    }
    
    open func connect( _ peripheral : CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
    }
    
    open func disconnect() {
        centralManager.cancelPeripheralConnection(discoveredPeripheral)
        discoveredPeripheral = nil
    }
}



extension SimpleBleNotify: CBPeripheralDelegate {
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        Log.debug("discover service")
        
        if (error != nil) {
            clientEventHandler!(.fail(error))
            return
        }
        //self.peripheral = peripheral
        let services = peripheral.services  as [CBService]!
        peripheral.discoverCharacteristics(nil, for: (services?[0])!)
    }
    
    public func peripheral(_ peripheral: CBPeripheral,didDiscoverCharacteristicsFor service: CBService,error: Error?) {
        Log.debug("discover characteristics")
        if (error != nil) {
            clientEventHandler!(.fail(error))
            return
        }
        for characteristic in service.characteristics! {
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    // nofity更新状態結果
    public func peripheral(_ peripheral: CBPeripheral,didUpdateNotificationStateFor characteristic: CBCharacteristic,error: Error?) {
        if error != nil {
            Log.debug("notification error")
            clientEventHandler!(.fail(error))
        } else {
            Log.debug("notification success")
            //Log.debug("Notify状態更新成功！ isNotifying: \(characteristic.isNotifying)")
        }
    }
    
    //データ受信
    public func peripheral(_ peripheral: CBPeripheral,didUpdateValueFor characteristic: CBCharacteristic,error: Error?) {
        Log.debug("characteristic update")
        if error != nil {
            clientEventHandler!(.fail(error))
            return
        }
        clientEventHandler!(.read(characteristic))
    }
}

extension SimpleBleNotify: CBCentralManagerDelegate {
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        clientEventHandler!(.device(central))

        switch(central.state) {
        case .poweredOn:            
            Timer.scheduledTimer(timeInterval: scanTime, target: self, selector: #selector(SimpleBleNotify.scanTimeout), userInfo: nil, repeats: false)
            startScan()
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
        connect(peripheral)
        //central.connect(peripheralArray[0], options: nil)
        discoveredPeripheral = peripheralArray[0]
    }
    
    // ペリフェラルへの接続に失敗した。
    public func centralManager(central: CBCentralManager,didFailToConnectPeripheral peripheral: CBPeripheral,error: NSError) {
        clientEventHandler!(.fail(error))
    }
    
    // ペリフェラルへの接続に成功した。
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        Log.debug("did connect peripheral")
        peripheral.delegate = self
        let UUID = CBUUID(string: serviceUUID)
        peripheral.discoverServices([UUID])
        stopScan()
    }
}

public func simpleBleNotify(_ bleHandler : @escaping SBNUpdate) {
    SimpleBleNotify.sharedInstance.simpleBLE(bleHandler)
}
