//
//  AppDelegate.swift
//  iBKSHelloWorld
//
//  Created by Gabriel Codarcea on 20/7/16.
//  Copyright © 2016 Accent Advanced Systems SLU. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var locationManager: CLLocationManager!
    var formattedUuid = ""
    var majorInt = 1
    var minorInt = 1
    var range = 0
    var msg = ""
    var beaconRegion: CLBeaconRegion!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //Request location authorization which is needed for the beacons scan. Don't forget to 
        //define the "Privacy - Location Always Usage Description" in the Info.plist file
        locationManager = CLLocationManager()
        locationManager!.requestAlwaysAuthorization()
        locationManager!.allowsBackgroundLocationUpdates = true
        
        //Request authorization for notifications used for background monitoring
        let notificationSettings = UIUserNotificationSettings(types: [.sound, .alert], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
        
        return true
    }

    
    //This method will be called whenever there is a change on the beacon state
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if(state == .inside){
            //When beacon did enter region, ranging will start. As it is called from background, the ranging will only last 10 seconds max.
            print("DID ENTER REGION")
            locationManager.startRangingBeacons(in: beaconRegion)
        }else if(state == .outside){
            print("DID EXIT REGION")
        }
    }
    

    //Method called when beacon is being ranged from background. It will check the proximity in order to see if it needs to
    //send the local notification or not.
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if(beacons.count > 0){
            print("RANGED \(beacons.count) BEACONS")
            if((beacons[0].proximity == .immediate && range == 0) || (beacons[0].proximity == .near && range == 1) || (beacons[0].proximity == .far && range == 2)){
                let notification = UILocalNotification()
                notification.alertBody = msg
                notification.soundName = "Default"
                UIApplication.shared.scheduleLocalNotification(notification)
                //After notification is sent, stop ranging and keep monitoring.
                locationManager!.stopRangingBeacons(in: beaconRegion)
            }
        }
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        //Application is going to background. Set the region defined in settings and start monitoring. Check first if background monitoring is enabled.
        if(UserDefaults.standard.bool(forKey: "mBGon")){
            setRegion()
            locationManager!.delegate = self
            locationManager!.startMonitoring(for: beaconRegion)
            //RunLoop was necessary in order to work properly inbackground for iPad Mini device with iOS 9.3.1.
            //In some newer devices and iOS versions it may not be necessary.
            //In that case, avoid using it as it is not safe.
            RunLoop.current.run()
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        //Application will go to foreground. Stop monitoring and remove the delegate.
        setRegion()
        locationManager!.delegate = nil
        locationManager!.stopMonitoring(for: beaconRegion)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
        
        //Define the region
        beaconRegion = CLBeaconRegion(proximityUUID: mUUID, major: CLBeaconMajorValue(majorInt), minor: CLBeaconMinorValue(minorInt), identifier: "MyBeacon")
    }

}

