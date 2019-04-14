//
//  DeviceVC.swift
//  idIOT
//
//  Created by Edward Arenberg on 4/13/19.
//  Copyright © 2019 Edward Arenberg. All rights reserved.
//

import UIKit

struct LedgerEntry {
    var device : String
    var other : String
    var date : Date
    var text : String
    var amount : Double
}

class LedgerCell : UITableViewCell {
    
    @IBOutlet weak var deviceIV: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    var entry : LedgerEntry! {
        didSet {
            if entry.other == "Plug" {
                deviceIV.image = UIImage(named: "adapter")
            } else {
                deviceIV.image = UIImage(named: "outlet")
            }
            descriptionLabel.text = entry.text
            let df = DateFormatter()
            df.dateStyle = .medium
            dateLabel.text = df.string(from: entry.date)
            let nf = NumberFormatter()
            nf.numberStyle = .currency
            nf.minimumFractionDigits = 4
            amountLabel.text = nf.string(for: entry.amount)
            amountLabel.textColor = entry.amount < 0 ? UIColor.red : UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0)
        }
    }
}

extension DeviceVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension DeviceVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LedgerCell", for: indexPath) as! LedgerCell
        
        let entry = entries[indexPath.row]
        
        cell.entry = entry
        
        return cell
    }
}

class DeviceVC: UIViewController {
    
    var device : IOTDevice! {
        didSet {
            navigationItem.title = device.name
            if let b = navigationItem.rightBarButtonItem?.customView as? UIButton, let img = UIImage(named: device.image) {
                let bi = imageWithImage(image: img, scaledToSize: CGSize(width: 30, height: 30))
                
                b.setBackgroundImage(bi, for: .normal)
                b.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                //            b.setImage(bi, for: .normal)
            }
        }
    }
    var entries = [LedgerEntry]() {
        didSet {
            ledgerTV.reloadData()
        }
    }
    
    @IBOutlet weak var ledgerTV: UITableView!
    
    func loadEntries(callback:([LedgerEntry])->()) {
        if device.ident == "AAAA" {
        
            let entry = LedgerEntry(device: "Plug", other:"Outlet", date: Date(), text: "Charging at Cross Campus Downtown LA", amount: -0.004)
            
            callback([entry])
        } else if device.ident == "BBBB" {
            let entry = LedgerEntry(device: "Outlet", other:"Plug", date: Date(), text: "Provided power to Plug owned by Ed A", amount: 0.004)
            
            callback([entry])

        } else {
            
        }
    }
    
    func addEntry(positive:Bool) {
        let amt = Double(arc4random_uniform(200)) / 10000.0 * (positive ? 1.0 : -1.0)
        
        let entry = LedgerEntry(device: "Plug", other:"Outlet", date: Date(), text: "Charging at Cross Campus Downtown LA", amount: amt)

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        loadEntries() { res in self.entries = res }
        
        postRequest(username: "username", password: "password") { (result, error) in
            if let result = result {
                print("success: \(result)")
            } else if let error = error {
                print("error: \(error.localizedDescription)")
            }
        }

    }
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
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

extension DeviceVC {
    func postRequest(username: String, password: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
        
        //declare parameter as a dictionary which contains string as key and value combination.
        let parameters = ["accountnumber": "123456", "cardid": "654321"]
        
        //create the url with NSURL
        let url = URL(string: "http://10.54.0.235:8000/api/memberData")!
        
        //create the session object
        let session = URLSession.shared
        
        //now create the Request object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to data object and set it as request body
        } catch let error {
            print(error.localizedDescription)
            completion(nil, error)
        }
        
        //HTTP Headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "dataNilError", code: -100001, userInfo: nil))
                return
            }
            
            do {
                //create json object from data
                guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else {
                    completion(nil, NSError(domain: "invalidJSONTypeError", code: -100009, userInfo: nil))
                    return
                }
                print(json)
                completion(json, nil)
            } catch let error {
                print(error.localizedDescription)
                completion(nil, error)
            }
        })
        
        task.resume()
    }
    
    @objc func submitAction(_ sender: UIButton) {
        //call postRequest with username and password parameters
        postRequest(username: "username", password: "password") { (result, error) in
            if let result = result {
                print("success: \(result)")
            } else if let error = error {
                print("error: \(error.localizedDescription)")
            }
        }
    }
}
