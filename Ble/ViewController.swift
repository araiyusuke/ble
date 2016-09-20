import UIKit

class ViewController: UIViewController {


    @IBOutlet var scanSwitch : UISwitch!
    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        scanSwitch.isOn = false
        scanSwitch.addTarget(self, action: #selector(ViewController.onScanTriger), for:.valueChanged)
    }
    
    func onScanTriger(sender: UISwitch){
        
        if sender.isOn {
            start()
        } else {
            stop()
        }
    }
    
    func appendLog( _ message :String) {
        textView.text = message + "\n\n" + textView.text
    }
    
    func clearLog() {
        textView.text = ""
    }
    
    func timeStamp() -> String {
        let now = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "[HH:mm:ss] "
        return formatter.string(from: now as Date)
    }
    
    func start() {
        
        SimpleBleNotify.sharedInstance.scanTime = 7;
        SimpleBleNotify.sharedInstance.serviceUUID = "C1D0F554-A142-4B56-B02D-2BC23DA2DF50"
        SimpleBleNotify.sharedInstance.peripheralUUID = ""
        SimpleBleNotify.sharedInstance.characteristicUUID = ""

        simpleBleNotify { response in
            
            switch response {
                
            case let .device(state):
                self.appendLog(state.description)
                
            case let .scanTimeout(time):
                
                self.alert(title : "Announce",
                           message: "Scan stop ( time :  \(time) )")
                
            case let .read(characteristic):
                let timeStamp = self.timeStamp()
                self.appendLog(timeStamp + "characteristic UUID: \(characteristic.uuid), value: \(characteristic.value)")
            
            case let .fail(error):
                self.appendLog(error!.localizedDescription)
            
            default:
                break
            }
        }
    }
    
    func stop() {
        SimpleBleNotify.sharedInstance.disconnect()
        clearLog()
    }
    
    func alert(title:String, message:String) {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle:  UIAlertControllerStyle.alert)
        
        let defaultAction: UIAlertAction = UIAlertAction(title: "reScan", style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in
            print("reScan")
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "end", style: UIAlertActionStyle.cancel, handler:{
            (action: UIAlertAction!) -> Void in
            print("finish")
        })
        
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
