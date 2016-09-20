import UIKit

class ViewController: UIViewController {

    @IBOutlet var startBtn :UIButton!
    @IBOutlet var endBtn :UIButton!
    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    @IBAction func startBtnTapped(sender : AnyObject) {
        
        SimpleBleNotify.sharedInstance.scanTime = 7;
        SimpleBleNotify.sharedInstance.serviceUUID = "C1D0F554-A142-4B56-B02D-2BC23DA2DF50"
        SimpleBleNotify.sharedInstance.peripheralUUID = ""
        SimpleBleNotify.sharedInstance.characteristicUUID = ""

        simpleBleNotify { response in
            
            switch response {
                
            case let .device(state):
                self.appendLog(state.description)
                
            case let .scanTimeout(time):
                print(time)
                
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
    
    @IBAction func endBtnTapped(sender : AnyObject) {
        SimpleBleNotify.sharedInstance.disconnect()
        clearLog()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
