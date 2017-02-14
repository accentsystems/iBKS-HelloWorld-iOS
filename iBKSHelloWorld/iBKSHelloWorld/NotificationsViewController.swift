//
//  NotificationsViewController.swift
//  iBKSHelloWorld
//
//  Created by Gabriel Codarcea on 7/2/17.
//  Copyright © 2017 Accent Advanced Systems SLU. All rights reserved.
//

import UIKit
import CoreLocation

class NotificationsViewController: UIViewController, CAAnimationDelegate, SettingsDelegate, CLLocationManagerDelegate {

    @IBOutlet var backBtn: UIImageView!
    @IBOutlet var ibksSettingsBtn: UIButton!
    @IBOutlet var waveImage: UIImageView!
    
    var locationManager: CLLocationManager!
    var formattedUuid = ""
    var majorInt = 1
    var minorInt = 1
    var range = 0
    var msg = ""
    var beaconRegion: CLBeaconRegion!
    
    //Delegat function
    func didSetNewSettings() {
        print("DELEGATE FUNCTION CALLED")
        //Stop the scan, reload the settings and start the scan again.
        setRegion()
        startScanning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add back button tap gesture
        let backPressedGesture = UITapGestureRecognizer(target: self, action: #selector(self.backBtnPressed(_:)))
        self.backBtn.isUserInteractionEnabled = true
        self.backBtn.addGestureRecognizer(backPressedGesture)

        //Add radar animation
        self.waveImage.rotate360Degrees(completionDelegate: self)
        
        //Inicialize and set location manager delegate
        locationManager = CLLocationManager()
        locationManager.delegate = self
        //Request location authorization which is needed for the beacons scan. Don't forget to
        //define the "Privacy - Location Usage Description" in the Info.plist file
        locationManager.requestAlwaysAuthorization()
    }
    
    //After the location autorization check start the ranging
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == .authorizedAlways){
            if(CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self)){
                if(CLLocationManager.isRangingAvailable()){
                    setRegion()
                    startScanning()
                }
            }
        }
    }
    
    //Set the monitoring region to scan
    func setRegion(){
        //Get UUID
        var mUuid = UserDefaults.standard.object(forKey: "mUuid")
        if(mUuid == nil){
            mUuid = "00000000000000000000000000000000"
        }

        //Format UUID
        let uuidStr = mUuid as! String
        formattedUuid = "\(uuidStr.substring(with: 0..<8))-\(uuidStr.substring(with: 8..<12))-\(uuidStr.substring(with: 12..<16))-\(uuidStr.substring(with: 16..<20))-\(uuidStr.substring(with: 20..<32))"
        
        print("FORMATTED UUID: \(formattedUuid)")
        
        //Get Major
        var mMajor = UserDefaults.standard.object(forKey: "mMajor")
        if(mMajor == nil){
            mMajor = "0001"
        }
        
        //Convert HEX Major to Int
        majorInt = Int(mMajor as! String, radix: 16)!

        //Get Minor
        var mMinor = UserDefaults.standard.object(forKey: "mMinor")
        if(mMinor == nil){
            mMinor = "0001"
        }
        
        //Convert HEX Minor to Int
        minorInt = Int(mMinor as! String, radix: 16)!
        
        //Get notification message
        var mMsg = UserDefaults.standard.object(forKey: "mMsg")
        if(mMsg == nil){
            mMsg = "This is a notification text example!"
        }
        
        //Assign message
        msg = mMsg as! String
        
        //Get range
        var mRange = UserDefaults.standard.integer(forKey: "mRange")
        if(mRange != 0 && mRange != 1 && mRange != 2){
            mRange = 0
        }
        
        //Assign range
        range = mRange
        
        let mUUID = UUID(uuidString: formattedUuid)!
        beaconRegion = CLBeaconRegion(proximityUUID: mUUID, major: CLBeaconMajorValue(majorInt), minor: CLBeaconMinorValue(minorInt), identifier: "MyBeacon")
    }
    
    func startScanning(){
        //locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    func stopScanning(){
        //locationManager.stopMonitoring(for: beaconRegion)
        locationManager.stopRangingBeacons(in: beaconRegion)
    }

    //All the beacons scanned compiling the region will be detected here. After proximity check, the notification dialog will be shown.
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if(beacons.count > 0){
            print("Found \(beacons.count) beacon(s) at \(beacons[0].accuracy) m.")
            if((beacons[0].proximity == .immediate && range == 0) || (beacons[0].proximity == .near && range == 1) || (beacons[0].proximity == .far && range == 2)){
                self.showNotificationDialog()
                self.stopScanning()
            }
        }
    }
    
    //Dialog shown when the beacon is detected on ranging.
    func showNotificationDialog(){
        let dialog = UIAlertController(title: "Beacon detected!", message: msg, preferredStyle: .alert)
        
        dialog.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
            self.startScanning()
        }))
        
        DispatchQueue.main.async {
            self.present(dialog, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Dismiss view on back button pressed
    func backBtnPressed(_ sender:UITapGestureRecognizer){
        stopScanning()
        locationManager.delegate = nil
        self.dismiss(animated: true, completion: nil)
    }

    
    @IBAction func settingsBtnPressed(_ sender: Any) {
        //Stop scanning and show settings controller. Deleget it here to receive the changes made on the settings data.
        stopScanning()
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let showScanView = mainStoryboard.instantiateViewController(withIdentifier: "settingsViewController") as! SettingsViewController
        showScanView.delegate = self
        self.present(showScanView, animated: true, completion: nil)
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.waveImage.rotate360Degrees(completionDelegate: self)
    }
}

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
}


//Rotation animation for the radar view.
extension UIView {
    func rotate360Degrees(duration: CFTimeInterval = 4.0, completionDelegate: CAAnimationDelegate? = nil) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(2*M_PI)
        rotateAnimation.duration = duration
        
        if let delegate: CAAnimationDelegate = completionDelegate {
            rotateAnimation.delegate = delegate
        }
        
        
        self.layer.add(rotateAnimation, forKey: nil)
    }
}
