//
//  ScanViewController.swift
//  iBKSHelloWorld
//
//  Created by Gabriel Codarcea on 7/2/17.
//  Copyright © 2017 Accent Advanced Systems SLU. All rights reserved.
//

import UIKit
import CoreBluetooth

class ScanViewController: UIViewController, CBCentralManagerDelegate, UITableViewDelegate, UITableViewDataSource, CBPeripheralDelegate {

    @IBOutlet var backBtn: UIImageView!
    @IBOutlet var scannedTableView: UITableView!
    
    var blueToothReady = false
    var centralManager:CBCentralManager!
    var scannedBeacons: [ScannedBeacon] = []
    var updateTimer: Timer?
    var mPeripheral: CBPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.scannedTableView.allowsSelection = false
        
        //Add back button tap gesture
        let backPressedGesture = UITapGestureRecognizer(target: self, action: #selector(self.backBtnPressed(_:)))
        self.backBtn.isUserInteractionEnabled = true
        self.backBtn.addGestureRecognizer(backPressedGesture)
        
        //Add table view and data source delegate
        self.scannedTableView.delegate = self
        self.scannedTableView.dataSource = self
        self.scannedTableView.tableFooterView = UIView()
        
        //Inicialize Central Manager
        startUpCentralManager()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    //Dismiss view on back button pressed
    func backBtnPressed(_ sender:UITapGestureRecognizer){
        centralManager.stopScan()
        self.dismiss(animated: true, completion: nil)
    }
    
    //Inicialize the Central Manager
    func startUpCentralManager() {
        print("Initializing central manager")
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    //Callback where we receive the Central Manager state. When state is "Powered ON" start the scan.
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch (central.state) {
        case .poweredOff:
            print("CoreBluetooth BLE hardware is powered off")
        case .poweredOn:
            print("CoreBluetooth BLE hardware is powered on and ready")
            blueToothReady = true;
            
        default: break
        }
        
        if blueToothReady {
            //Start scanning for devices
            discoverDevices()
        }
    }
    
    
    func discoverDevices() {
        print("Discovering devices")
        //Scan for peripherals
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        //Add a timer which updates the table with devices scanned every half second.
        updateTimer = Timer(timeInterval: 0.5, target: self, selector: #selector(self.updateTable), userInfo: nil, repeats: true)
        RunLoop.current.add(updateTimer!, forMode: RunLoopMode.commonModes)
    }
    
    //Central Manager method called every time a device is scanned. Manage them with an array to add new ones and update data on the old ones.
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var namee = "N/A"
        if(peripheral.name != nil){
            namee = peripheral.name!
        }
        NSLog("\(namee) - \(RSSI)")
        
        //RSSI 127 is an error code which indicates the data received is corrupted. Cannot be treated as RSSI.
        if(RSSI == 127){
            return
        }
        
        var contains = false
        if(scannedBeacons.count>0){
            for i in 0...(scannedBeacons.count-1){
                if(i<scannedBeacons.count && peripheral.identifier.uuidString == scannedBeacons[i].bUUID){
                    scannedBeacons[i] = ScannedBeacon(peri: peripheral, name: namee, uuid: peripheral.identifier.uuidString, rssi: RSSI.intValue)
                    contains = true
                    break
                }
            }
        }
        if(!contains){
            scannedBeacons.append(ScannedBeacon(peri:peripheral, name: namee, uuid: peripheral.identifier.uuidString, rssi: RSSI.intValue))
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scannedBeacons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! MyCustomTableViewCell
        if(scannedBeacons.count<1){
            return cell
        }
        
        //Fill the custom cell with the detected device details.
        
        let dev = scannedBeacons[(indexPath as NSIndexPath).row]
        
        cell.name.text = dev.bName
        cell.rssi.text = "\(dev.bRssi)"
        cell.uuid.text = dev.bUUID
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        centralManager.stopScan()
        updateTimer?.invalidate()
        mPeripheral = scannedBeacons[indexPath.row].mPeri
        mPeripheral.delegate = self
        
        print("Connecting to peripheral: \(scannedBeacons[indexPath.row].bName)")
        centralManager.connect(mPeripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Peripheral connected! Discovering services...")
        peripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            print("Discovering characteristics for service: \(service.uuid.uuidString)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            print("Found characteristic: \(characteristic.uuid.uuidString)")
        }
    }
    
    func updateTable(){
        DispatchQueue.main.async(execute: { self.rldData() })
    }
    
    func rldData(){
        scannedBeacons = scannedBeacons.sorted(){ $0.bRssi > $1.bRssi }
        self.scannedTableView.reloadData()
    }
    
    

}

//Beacon class which defines the structure of the data we need.
class ScannedBeacon {
    
    var mPeri: CBPeripheral
    var bName: String
    var bUUID: String
    var bRssi: Int
    
    
    init(peri: CBPeripheral, name: String, uuid: String, rssi: Int) {
        self.mPeri = peri
        self.bName = name
        self.bUUID = uuid
        self.bRssi = rssi
    }
}
