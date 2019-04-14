//
//  AddVC.swift
//  idIOT
//
//  Created by Edward Arenberg on 4/13/19.
//  Copyright © 2019 Edward Arenberg. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

protocol AddDelegate : class {
    func addDevice(device:IOTDevice)
}

class AddVC: UIViewController, CLLocationManagerDelegate {

    weak var delegate : AddDelegate?
    var alertGenerated = false

    var doneSound = URL(fileURLWithPath: Bundle.main.path(forResource: "done", ofType: "mp3")!)
    var donePlayer : AVAudioPlayer!
    var alertSound = URL(fileURLWithPath: Bundle.main.path(forResource: "alert", ofType: "wav")!)
    var alertPlayer : AVAudioPlayer!

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var deviceIV: UIImageView! {
        didSet {
            deviceIV.alpha = 0
        }
    }
    @IBOutlet weak var addButton: UIButton! {
        didSet {
            addButton.alpha = 0
            addButton.layer.cornerRadius = 10
            addButton.layer.masksToBounds = true
        }
    }
    @IBAction func addHit(_ sender: UIButton) {
        let d = IOTDevice(name: "Arduino Server", image: "arduino", ident: "CCCC")
        delegate?.addDevice(device: d)
    }
    @IBOutlet weak var infoTV: UITextView! {
        didSet {
            infoTV.alpha = 0
            infoTV.layer.borderColor = UIColor.lightGray.cgColor
            infoTV.layer.borderWidth = 1
            infoTV.layer.cornerRadius = 4
            infoTV.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var beaconView: BeaconView! {
        didSet {
            beaconView.isOn = false
        }
    }
    @IBAction func beaconTapped(_ sender: UITapGestureRecognizer) {
        if beaconView.isAnimating { stopBeacon(); beaconView.isOn = false; return }
        beaconView.isAnimating = true
        startBeacon()
        
        /*
        beaconView.isOn = !beaconView.isOn
        if beaconView.isOn {
            startBeacon()
            
        }
        else { stopBeacon() }
         */
    }
    
    func startBeacon() {
//        if beaconView.isOn { return }
        beaconView.isAnimating = true
        beaconScanStart()
        messageLabel.text = "Hold Near Device"
        UIView.animate(withDuration: 0.4) { self.deviceIV.alpha = 0; self.addButton.alpha = 0; self.infoTV.alpha = 0 }
    }
    
    func stopBeacon() {
        if !(beaconView.isOn || beaconView.isAnimating) { return }
        beaconView.isAnimating = false
        beaconView.isOn = false
        beaconScanStop()
        messageLabel.text = "Hold Near Device"
    }

    /*
    @IBAction func serviceHit(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            beaconScanStart()
        } else {
            beaconScanStop()
        }
    }
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
        alertPlayer = try! AVAudioPlayer(contentsOf: alertSound)
        alertPlayer.prepareToPlay()
        donePlayer = try! AVAudioPlayer(contentsOf: doneSound)
        donePlayer.numberOfLoops = -1
        donePlayer.prepareToPlay()

        locManager.delegate = self
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
//            beaconScanStart()
            startBeacon()
        } else {
            locManager.requestWhenInUseAuthorization()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopBeacon()
//        beaconScanStop()
    }
    
    
    // MARK: - Beacon
    
    let locManager = CLLocationManager()
    var beaconRegion : CLBeaconRegion?
    var beaconKey : String?
    
    func beaconScanStart() {
        alertGenerated = false
        let uuid = UUID(uuidString: "B5B182C7-EAB1-4988-AA99-B5C1517008D9")!
        beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: "BeaconScan")
        locManager.startRangingBeacons(in: beaconRegion!)
        let custRegion = CLBeaconRegion(proximityUUID: uuid, major: 30, minor: 115, identifier: "DeviceScan")
        locManager.startMonitoring(for: custRegion)
        
        beaconView.isAnimating = true
        
        //        let (success, error, key) = BeaconBroadcaster.shared.startBeacon()
        //        if let key = key {
        //            self.beaconKey = key
        //        }
        
    }
    
    func beaconScanStop() {
        if let beaconRegion = beaconRegion {
            locManager.stopRangingBeacons(in: beaconRegion)
            self.beaconRegion = nil
            beaconView.isOn = false
        }
        
//        BeaconBroadcaster.shared.stopBeacon()
        self.beaconKey = nil
        
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("DEVICE REGION FOUND")
        // beaconScanStart()
    }
    
    @objc func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        print(beacons)
        if alertGenerated { return }
        
        if let b = try? beacons.first(where: { b in return b.major == 30 && b.minor == 115 }) {
            if b.proximity == .immediate {
                alertPlayer.play()
                alertGenerated = true
                beaconScanStop()
                beaconView.isOn = true
                messageLabel.text = "Arduino Server"
                UIView.animate(withDuration: 0.5, animations: { self.deviceIV.alpha = 1; self.addButton.alpha = 1; self.infoTV.alpha = 1 })
                infoTV.text = "Service: Media Stream\nCost: $0.0010 / MB"
            }
        }
        /*
        var found = false
        for b in beacons { if b.major == 30 && b.minor == 115 { found = true; break }}
        if found {
            alertPlayer.play()
            alertGenerated = true
            beaconScanStop()
            beaconView.isOn = true
            messageLabel.text = "Arduino Server"
            UIView.animate(withDuration: 0.5, animations: { self.deviceIV.alpha = 1; self.addButton.alpha = 1 })
        }
         */
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            startBeacon()
//            beaconScanStart()
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
