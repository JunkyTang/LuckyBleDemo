# LuckyBleDemo

**LuckyBleDemo** is an iOS demo project based on [LuckyBLE.framework](https://github.com/your-repo/LuckyBLE), demonstrating how to use LuckyBLE for thermal printer communication via Bluetooth.

---

## 📦 Introduction to LuckyBLE

`LuckyBLE.framework` is an SDK built on top of the BLE ATT protocol, specifically designed for **thermal printer control** scenarios.

### ✅ Features

- 📡 BLE communication based on the ATT protocol  
- 🧵 Serial communication model (handles requests in order internally)  
- 🖨️ Optimized for thermal printer interaction  
- ⚙️ Lightweight and easy to integrate  

---

## 🧱 Project Structure

This project contains a basic demo that demonstrates:

- Initialization and connection of LuckyBLE  
- Sending print commands  
- Receiving responses from the device  

---

## 📥 Installation

Install required dependencies using CocoaPods:

```ruby
pod 'LuckyPropertyWrapper', :git => 'https://github.com/JunkyTang/LuckyPropertyWrapper.git', :tag => '0.3.2'
pod 'LuckyLogger', :git => 'https://github.com/JunkyTang/LuckyLogger.git', :tag => '0.1.0'
pod 'SafeContinuation', :git => 'https://github.com/JunkyTang/SafeContinuation.git'
```

---


## 🚀 Getting Started

```swift

public class BLEManager: NSObject {

    @CurrentValueSubjectProperty
    public private(set) var state: CBManagerState = .unknown
    
    @CurrentValueSubjectProperty
    public private(set) var scanList: [(CBPeripheral, [String: Any], NSNumber)] = []
    
    @CurrentValueSubjectProperty
    public private(set) var peripheral: CBPeripheral?

    public func scan(serviceId: [CBUUID]? = nil, timeout: TimeInterval = 3) async
    
    public func stopScan()
    
    public func connect(peripheral: CBPeripheral, timeout: TimeInterval = 3) async throws -> Printer
    
    public func disconnect() async throws
}


public protocol BaseFunc: Printer {
    
    func getName() async throws -> String

    func getSN() async throws -> String

    func getMac() async throws -> String
    
    func getModel() async throws -> String
    
    func getBattery() async throws -> UInt8

    func getState() async throws -> UInt8
    
    func getFirmware() async throws -> String
    
    func getStandbyTime() async throws -> UInt8
    
    func set(standbyTime: UInt8) async throws
    
    func getDensity() async throws -> UInt8
    
    func set(density: UInt8) async throws
    
    func set(paper: UInt8) async throws
    
    func enable() async throws
    
    func disable() async throws
    
    func wakeup() async throws
    
    func enterPaper() async throws
    
    func outPaper() async throws
    
    func walkPaper(long: UInt8) async throws
    
    func location() async throws
    
    func send(image: UIImage) async throws
    
    func ota() async throws
}


```
> For complete usage, please refer to the sample code in this project.

## 🧪 Compatibility

* iOS 13+
* Swift 5.5+

## 📝 License

MIT License © JunkyTang
