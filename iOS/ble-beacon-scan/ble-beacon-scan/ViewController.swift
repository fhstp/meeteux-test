//
//  ViewController.swift
//  ble-beacon-scan
//
//  Created by Kerstin Blumenstein on 31/07/2017.
//  Copyright © 2017 Kerstin Blumenstein. All rights reserved.
//

// MARK: visible in jump bar

// TODO: Do this

// FIXME: Fix this

// MARK: - Add a seperator above this


import UIKit
import CoreLocation
import KontaktSDK
import Darwin


class ViewController: UIViewController {

    var beaconManager: KTKBeaconManager!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var statusLabel: UILabel!
    

    var beaconList:[CLBeacon] = []
    
    
    var exhibits: [[String:Any]] = [
        [
            "ID" : "CFra",
            "location-type" : "onExhibit",
            "ble-major" : 10,
            "ble-minor" : 100,
            "location-name" : "Kerstin on"
        ],
        [
            "ID" : "eGQg",
            "location-type" : "atExhibit",
            "ble-major" : 10,
            "ble-minor" : 101,
            "location-name" : "Kerstin at"
        ],
        [
            "ID" : "IfGo",
            "location-type" : "atExhibit",
            "ble-major" : 10,
            "ble-minor" : 1002,
            "location-name" : "Stud Assi at"
        ],
        [
            "ID" : "FT45",
            "location-type" : "atExhibit",
            "ble-major" : 10,
            "ble-minor" : 1000,
            "location-name" : "Flo at"
        ],
        [
            "ID" : "D7Oj",
            "location-type" : "atExhibit",
            "ble-major" : 10,
            "ble-minor" : 1001,
            "location-name" : "Drucker at"
        ],
        [
            "ID" : "7N9p",
            "location-type" : "atExhibit",
            "ble-major" : 10,
            "ble-minor" : 10,
            "location-name" : "Door office 1"
        ]
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        beaconManager = KTKBeaconManager(delegate: self)
        
        switch KTKBeaconManager.locationAuthorizationStatus() {
            case .notDetermined:
                beaconManager.requestLocationAlwaysAuthorization()
            case .denied, .restricted:
                // No access to Location Service
                print("access denied")
            case .authorizedWhenInUse:
                // For most iBeacon-based app this type of
                // permission is not adequate
                print("access only when in use")
            case .authorizedAlways:
                print("tbd")
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: KTKBeaconManagerDelegate{
    func beaconManager(_ manager: KTKBeaconManager, didChangeLocationAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedAlways{
            // When status changes to CLAuthorizationStatus.authorizedAlways
            // e.g. after calling beaconManager.requestLocationAlwaysAuthorization()
            // we can start region monitoring from here
            if KTKBeaconManager.isMonitoringAvailable() {
                print("start scan")
                startScanning()
            }
            
        }
    }
    
    func startScanning(){
        let myProximityUuid = UUID(uuidString: "f7826da6-4fa2-4e98-8024-bc5b71e0893e")
        let region = KTKBeaconRegion(proximityUUID: myProximityUuid!, identifier: "Beacon region 1")
        
        
        beaconManager.startMonitoring(for: region)
        beaconManager.startRangingBeacons(in: region)
        
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didStartMonitoringFor region: KTKBeaconRegion) {
        // Do something when monitoring for a particular
        // region is successfully initiated
    }
    
    func beaconManager(_ manager: KTKBeaconManager, monitoringDidFailFor region: KTKBeaconRegion?, withError error: NSError?) {
        // Handle monitoring failing to start for your region
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didEnter region: KTKBeaconRegion) {
        // Decide what to do when a user enters a range of your region; usually used
        // for triggering a local notification and/or starting a beacon ranging
        manager.startRangingBeacons(in: region)
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didExitRegion region: KTKBeaconRegion) {
        // Decide what to do when a user exits a range of your region; usually used
        // for triggering a local notification and stoping a beacon ranging
        manager.stopRangingBeacons(in: region)
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didRangeBeacons beacons: [CLBeacon], in region: KTKBeaconRegion) {
        
        beaconList = []
        // Go through beacons, check if it is our and reliable --> push into empty beaconList
        beacons.forEach { beacon in
            if(isOurBeaconReliable(myBeacon: beacon)){
               // if(beaconList.count == 0){
                    beaconList.append(beacon)
               /* }else{
                    for(index, listBeacon) in beaconList.enumerated(){
                        if(beacon.minor == listBeacon.minor){
                            beaconList[index] = (beacon)
                        }else{
                            beaconList.append(beacon)
                        }
                    }
                }*/
            }
        }
        
       /* print("-------")
        
        print(beaconList)*/
        
        if beaconList.count>0{
            //updateDistance(beacons[0].proximity)
            
            //beaconList = beacons;
        
            tableView.reloadData()
            
            
            
            let myBeacon = beaconList[0]

            
            let beacon1 = exhibits.index(where: { (exhibit) -> Bool in
                if(exhibit["ble-minor"] as! Int == myBeacon.minor as! Int){
                    //print("same")
                    //print(exhibit)
                    updateExhibit(myBeacon.proximity, exhibit: exhibit)
                    return true
                }
                return false
            })
            
           // let beacon1 = keyOfBeacon(major: beaconArray[0].major as! Int)
           // print("beacon \(String(describing: beacon1))")

        }/*else{
            updateDistance(.unknown)
        }*/
    }
    
    
    // Check if Beacon is reliable (rssi < 0) and if it is in our range compared to exhibits (later LUT)
    func isOurBeaconReliable(myBeacon: CLBeacon) -> Bool{
        
        var beaconResult:Bool = false
        
        if(myBeacon.rssi < 0){
            exhibits.forEach{exhibit in
                if(exhibit["ble-minor"] as! Int == myBeacon.minor as! Int){
                    beaconResult = true
                }
            }
        }
        
        return beaconResult
    }
    
    func updateExhibit(_ distance: CLProximity, exhibit: [String:Any]){
        
        let locationName = exhibit["location-name"]
        statusLabel.text = "Your are \(locationName!)";
        UIView.animate(withDuration: 0.8){
            switch distance{
            case .far:
                self.view.backgroundColor = UIColor.blue
                
            case .near:
                self.view.backgroundColor = UIColor.orange
                
            case .immediate:
                self.view.backgroundColor = UIColor.red
                
            default:
                self.view.backgroundColor = UIColor.gray
            }
        }
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beaconList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")!

        
        let beacon:CLBeacon = beaconList[indexPath.row]
        let uuid = beacon.proximityUUID.uuidString
        
        
      
        var d = beacon.accuracy
        d = floor(d * 10) / 10
        
        //beacon.rssi
        let txPower = -77
        
        let ratio_dB:Double = Double(txPower - beacon.rssi)
        let ratio_linear:Double = pow(10, (ratio_dB/10))
        let r = round(sqrt(ratio_linear))
        
        let beacon1 = exhibits.index(where: { (exhibit) -> Bool in
            if(exhibit["ble-minor"] as! Int == beacon.minor as! Int){
                cell.textLabel?.text = ("\(exhibit["location-name"]!) | \(d) | \(r) | rssi \(beacon.rssi)| major: \(beacon.major) | minor \(beacon.minor) " )
                
                return true
            }
            cell.textLabel?.text = ("\(d) | \(r) | rssi \(beacon.rssi)| major: \(beacon.major) | minor \(beacon.minor) " )
            return false
        })
        
        
        /*final double ratio_dB = txPower - rssi;
        final double ratio_linear = Math.pow(10, (ratio_dB / 10));
        final double r = Math.sqrt(ratio_linear);*/
        
        
        //cell.textLabel?.text = ("\(d) meters | \(r) | rssi \(beacon.rssi)| major: \(beacon.major) | minor \(beacon.minor) " )
        //cell.textLabel?.text = ("\(r) | rssi \(beacon.rssi)| major: \(beacon.major) | minor \(beacon.minor) " )
        //cell.textLabel?.text = ("\(d) | \(r) | rssi \(beacon.rssi)| major: \(beacon.major) | minor \(beacon.minor) " )
        //cell?.detailTextLabel?.text = ("\(uuid)")
        
        
        return cell
    }
    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
    }*/
   
    
}
