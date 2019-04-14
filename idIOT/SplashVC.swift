//
//  SplashVC.swift
//  idIOT
//
//  Created by Edward Arenberg on 4/13/19.
//  Copyright © 2019 Edward Arenberg. All rights reserved.
//

import UIKit

class SplashVC: UIViewController {

    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            nameLabel.alpha = 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 1.0,
                       animations: { self.nameLabel.alpha = 1 },
                       completion: { finished in
                        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainNC") {
                                self.view.window?.rootViewController = vc
                            }
                        }
        })
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
