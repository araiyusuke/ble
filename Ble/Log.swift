import Foundation

open class Log {

    open static let sharedInstance = Log()
    public var outputLogLevel: Level = .Peripheral

    public enum Level : Int {
        case Peripheral = 1
        case Service
        case Charactaristic
    }
    
    public class func debug( _ message:String) {
        print("\(message)")
    }
    
}
