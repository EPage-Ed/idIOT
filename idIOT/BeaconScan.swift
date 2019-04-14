//
//  BeaconScan.swift
//  idIOT
//
//  Created by Edward Arenberg on 4/13/19.
//  Copyright © 2019 Edward Arenberg. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth


class BeaconBroadcaster: NSObject, CBPeripheralManagerDelegate {
    
    static var shared = BeaconBroadcaster()
    var isBroadcasting = false
    
    var _peripheralManager : CBPeripheralManager?
    
    override init() {
        super.init()
        
        _peripheralManager = CBPeripheralManager(delegate: self, queue: DispatchQueue.global())
    }
    
    func startBeacon() -> (success: Bool, error: NSString?, key: String?) {
        let uuid = "B5B182C7-EAB1-4988-AA99-B5C1517008DB"
        
        let major : UInt16 = 1000
        var minor : UInt16 = 0
        if #available(iOS 11.0, *) {
            minor = 11
        } else {
            minor = 10
        }
        
        //        let major = UInt16(arc4random_uniform(UInt32(UInt16.max)))
        //        let minor = UInt16(arc4random_uniform(UInt32(UInt16.max)))
        let power = 127 // 127
        return startBeaconFor(uuid, withMajor: major, withMinor: minor, withPower: power)
    }
    
    func startBeaconFor(_ beaconName: String, withMajor: UInt16, withMinor: UInt16, withPower: Int) -> (success: Bool, error: NSString?, key: String?) {
        
        let beaconUUID: UUID? = UUID(uuidString: beaconName)
        
        var isAdvertising = _peripheralManager!.isAdvertising
        
        // If already advertising, Stop the beacon to flush any previous values
        if (isAdvertising == true) {
            _peripheralManager!.stopAdvertising()
            isAdvertising = false
        }
        
        var i = 0;
        while (i < 1000 && _peripheralManager!.state == .unknown ) {
            Thread.sleep(forTimeInterval: 0.001);
            i += 1;
        }
        
        if (_peripheralManager!.state != .poweredOn) {
            
            let alert = UIAlertController(title: "Bluetooth must be available and enabled to configure your device as an iBeacon", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            if let topWindow = getTopWindow() {
                topWindow.dismiss(animated: true, completion: {
                    topWindow.present(alert, animated: true, completion: nil)
                })
            } else {
                print("topWindow is nil")
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: "iBeaconBroadcastStatus"), object: nil, userInfo: ["broadcastStatus" : false])
            
        } else {
            
            let region = CLBeaconRegion(proximityUUID:beaconUUID!, major:withMajor, minor:withMinor, identifier:"com.AttainR.beacon")
            
            let pow : NSNumber? = withPower == 127 ? nil : NSNumber(value: withPower)
            if let peripheralData = region.peripheralData(withMeasuredPower: pow) as? [String : Any] {
                
                isBroadcasting = true
                _peripheralManager!.startAdvertising(peripheralData)
                
                return (true, nil, "\(withMajor)-\(withMinor)")
                
            } else {
                return (false, "Peripheral region not be initialised", nil)
            }
        }
        
        return (false, "Bluetooth not available", nil)
    }
    
    
    func stopBeacon() {
        
        if (_peripheralManager!.isAdvertising) {
            
            _peripheralManager!.stopAdvertising()
        }
    }
    
    
    func beaconStatus() -> Bool {
        
        return _peripheralManager!.isAdvertising
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        if (peripheral.state == .poweredOn) {
            
            let shouldBroadcast = isBroadcasting
            
            if (peripheral.isAdvertising != shouldBroadcast) {
                
                let notificationPayload = ["broadcastStatus" : shouldBroadcast]
                
                if (shouldBroadcast == true) {
                    startBeacon()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "iBeaconBroadcastStatus"), object: nil, userInfo: notificationPayload)
                } else {
                    stopBeacon()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "iBeaconBroadcastStatus"), object: nil, userInfo: notificationPayload)
                }
            }
        }
    }
    
    
    func getTopWindow()->UIViewController? {
        
        var topViewController : UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        
        while (topViewController?.presentedViewController != nil) {
            topViewController = topViewController?.presentedViewController
        }
        
        return topViewController
    }
}

