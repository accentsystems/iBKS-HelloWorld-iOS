//
//  MainViewController.swift
//  iBKSHelloWorld
//
//  Created by Gabriel Codarcea on 20/7/16.
//  Copyright © 2016 Accent Advanced Systems SLU. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    //Declare the button views for scan and notifications views
    @IBOutlet var scanBtn: UIView!
    @IBOutlet var notifBtn: UIView!
    @IBOutlet var backgroundSwitch: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Add gesture for tap on scan button view
        let scanPressedGesture = UITapGestureRecognizer(target: self, action:  #selector (self.scanBtnPressed(_:)))
        self.scanBtn.addGestureRecognizer(scanPressedGesture)

        let notifPressedGesture = UITapGestureRecognizer(target: self, action:  #selector (self.notifBtnPressed(_:)))
        self.notifBtn.addGestureRecognizer(notifPressedGesture)
        
        if(UserDefaults.standard.bool(forKey: "mBGon")){
            backgroundSwitch.isOn = true
        }else{
            backgroundSwitch.isOn = false
        }
        
    }
    
    //Background switch changes
    @IBAction func switchValueChanged(_ sender: Any) {
        if(backgroundSwitch.isOn){
            UserDefaults.standard.set(true, forKey: "mBGon")
        }else{
            UserDefaults.standard.set(false, forKey: "mBGon")
        }
        UserDefaults.standard.synchronize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Start scan demo
    func scanBtnPressed(_ sender:UITapGestureRecognizer){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let showScanView: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "scanViewController")
        self.present(showScanView, animated: true, completion: nil)
    }
    
    //Start notification demo
    func notifBtnPressed(_ sender:UITapGestureRecognizer){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let showScanView: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "notificationsViewController")
        self.present(showScanView, animated: true, completion: nil)
    }


}

