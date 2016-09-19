import UIKit

class ViewController: UIViewController {

    
    public enum BLEResponse {
        case locationUpdated(String)
        case locationFail(NSError)
        case unauthorized
    }
    
    //private var peripheralArray = [CBPeripheral]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        simpleBLE { response in
            print("hoge")
        }
        
        
        
//         
//        SimpleBle.sharedInstance.scanTime = 10;
//        SimpleBle.sharedInstance.debug = true;
//
//         SimpleBle { (response) -> Void in
//         
//            switch response {
//                case .DiscoverPeripheral(ペリフェラルデータ一覧):
//                    for (ペリフェラルデータ一覧) {
//                        
//                    }
//                case .LocationFail(let error):
//                case .Unauthorized:
//            }
//         }
 
    }

    

//    
//    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        print("didDiscover")
//       
//        
//        print("name: \(peripheral.name)")
//        print("UUID: \(peripheral.identifier.uuid)")
//        print("advertisementData: \(advertisementData)")
//        print("RSSI: \(RSSI)")
//        self.peripheralArray.append(peripheral as CBPeripheral)
//        self.centralManager.connect(peripheralArray[0], options: nil)
//
//    }
//    
//    
//    // ペリフェラル発見
//    func centralManager(central: CBCentralManager!,
//                        didDiscoverPeripheral peripheral: CBPeripheral!,
//                        advertisementData: [NSObject : AnyObject]!,
//                        RSSI: NSNumber!){
//        print("didDiscoverPeripheral")
//    }
//    
//    // ペリフェラル接続完了
//    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        print("@@@@@")
//        // デリゲートの設定
//        peripheral.delegate = self
//        //peripheral.discoverServices(nil)
//        let UUID = CBUUID(string: "C1D0F554-A142-4B56-B02D-2BC23DA2DF50")
//
//        peripheral.discoverServices([UUID])
//
//        //centralManager.stopScan()
//
//    }
//
//    // services
//    func peripheral(_ peripheral: CBPeripheral!, didDiscoverServices error: Error!) {
//        if (error != nil) {
//            return
//        }
//        let services  = peripheral.services  as [CBService]!
//        peripheral.discoverCharacteristics(nil, for: (services?[0])!)
//
//        print("Found \(services?.count) services! :\(services)")
//
//    }
//    
//    // ペリフェラルへの接続が失敗すると呼ばれる
//    func centralManager(central: CBCentralManager,
//                        didFailToConnectPeripheral peripheral: CBPeripheral,
//                        error: NSError?)
//    {
//        print("failed...")
//    }
//    
//    // 5-2. Characterristic探索結果の受信
//    func peripheral(_ peripheral: CBPeripheral,didDiscoverCharacteristicsFor service: CBService,error: Error?) {
//        print("@@@@@didDiscoverCharacteristicsForService")
//        if (error != nil) {
//            print("error: \(error)")
//            return
//        }
//        
//        for characteristic in service.characteristics! {
//            print("=====")
//            print(characteristic)
//            print("=====")
//            peripheral.setNotifyValue(true, for: characteristic)
//
//
//        }
//      
//    }
//    
//    func peripheral(_ peripheral: CBPeripheral,
//                    didUpdateNotificationStateFor characteristic: CBCharacteristic,
//                    error: Error?) {
//        if let error = error {
//            print("Notify状態更新失敗...error: \(error)")
//        } else {
//            print("Notify状態更新成功！ isNotifying: \(characteristic.isNotifying)")
//        }
//    }
//    
//    func peripheral(_ peripheral: CBPeripheral,
//                    didUpdateValueFor characteristic: CBCharacteristic,
//                    error: Error?)
//    {
//        if let error = error {
//            print("データ更新通知エラー: \(error)")
//            return
//        }
//        
//        print("データ更新！ characteristic UUID: \(characteristic.uuid), value: \(characteristic.value)")
//    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

