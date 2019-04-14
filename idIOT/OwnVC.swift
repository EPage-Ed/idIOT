//
//  OwnVC.swift
//  idIOT
//
//  Created by Edward Arenberg on 4/13/19.
//  Copyright © 2019 Edward Arenberg. All rights reserved.
//

import UIKit

struct IOTDevice {
    var name : String
    var image : String
    var ident : String
}

class DeviceCell : UICollectionViewCell {
    var device : IOTDevice! {
        didSet {
            if let iv = self.viewWithTag(1) as? UIImageView {
                iv.image = UIImage(named: device.image)
                iv.layer.borderColor = UIColor.lightGray.cgColor
                iv.layer.borderWidth = 1
            }
        }
    }
    
}

extension OwnVC: UICollectionViewDelegate {
    
}

extension OwnVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return devices.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DeviceCell", for: indexPath) as! DeviceCell

        cell.device = devices[indexPath.row]
        /*
        if let iv = cell.viewWithTag(1) as? UIImageView {
            iv.image = UIImage(named: "adapter")
        }
         */
        return cell
    }
    
}

extension OwnVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = collectionView.frame.size.width / CGFloat(min(max(devices.count,3),2))
        return CGSize(width: w, height: w)
    }
}

class OwnVC: UIViewController {

    @IBOutlet weak var itemCV: UICollectionView!
    
    var devices = [IOTDevice]() {
        didSet {
            itemCV.reloadData()
        }
    }
    
    func loadDevices(callback:([IOTDevice])->()) {
        let device1 = IOTDevice(name: "Charging Plug", image:"adapter", ident: "AAAA")
        let device2 = IOTDevice(name: "Wall Outlet", image:"outlet", ident: "BBBB")
        callback([device1,device2])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadDevices() { self.devices = $0 }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let vc = segue.destination as? DeviceVC {
            if let cell = sender as? DeviceCell, let indexPath = itemCV.indexPath(for: cell) {
                let device = devices[indexPath.row]
                vc.device = device
            }
        } else if let vc = segue.destination as? AddVC {
            vc.delegate = self
        }
    }

}

extension OwnVC : AddDelegate {
    func addDevice(device: IOTDevice) {
        devices.append(device)
        navigationController?.popViewController(animated: true)
    }
}
