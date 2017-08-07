//
//  ViewController.swift
//  ble-beacon-scan
//
//  Created by Kerstin Blumenstein on 31/07/2017.
//  Copyright © 2017 Kerstin Blumenstein. All rights reserved.
//

import UIKit
import CoreLocation
import KontaktSDK
import Darwin


class ViewController: UIViewController {

    var beaconManager: KTKBeaconManager!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var statusLabel: UILabel!
    

    
    var beaconArray:[CLBeacon] = []
    
    var items: [String] = ["We", "Heart", "Swift"]
    
    var exhibits: [[String:Any]] = [
        [
            "ID" : "CFra",
            "location-type" : "onExhibit",
            "ble-major" : 52372,
            "ble-minor" : 37234,
            "location-name" : "Kerstin on"
        ],
        [
            "ID" : "eGQg",
            "location-type" : "atExhibit",
            "ble-major" : 18975,
            "ble-minor" : 22350,
            "location-name" : "Kerstin at"
        ],
        [
            "ID" : "IfGo",
            "location-type" : "atExhibit",
            "ble-major" : 25341,
            "ble-minor" : 47129,
            "location-name" : "Stud Assi at"
        ],
        [
            "ID" : "FT45",
            "location-type" : "atExhibit",
            "ble-major" : 58992,
            "ble-minor" : 26963,
            "location-name" : "Flo at"
        ],
        [
            "ID" : "D7Oj",
            "location-type" : "atExhibit",
            "ble-major" : 35168,
            "ble-minor" : 49217,
            "location-name" : "Drucker at"
        ],
        [
            "ID" : "7N9p",
            "location-type" : "atExhibit",
            "ble-major" : 59834,
            "ble-minor" : 59993,
            "location-name" : "Door office 1"
        ]
    ]
    
    /*
 
     CFra - onExhibit - 52372 37234 - Kerstin
     eGQg - atExhibit - 18975 22350 - Kerstin
     
     IfGo - atExhibit - 25341	47129 - Studi-Assis
     
     FT45  - atExhibit - 58992	26963 - Flo
     D7Oj  - atExhibit - 35168	49217 - Drucker
     7N9p  - door - 59834	59993 - office 1
     
 */
    
    
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
        if beacons.count>0{
            //updateDistance(beacons[0].proximity)
            
            beaconArray = beacons;
            tableView.reloadData()
            
            let myBeacon = beaconArray[0]
            let myMajor = beaconArray[0].major
            print("Major \(myMajor)")
            
            let beacon1 = exhibits.index(where: { (exhibit) -> Bool in
                if(exhibit["ble-major"] as! Int == myBeacon.major as! Int){
                    print("same")
                    print(exhibit)
                    
                    updateExhibit(myBeacon.proximity, exhibit: exhibit)

                    return true
                }
                /*print(exhibit["ble-major"] as! Int)
                print(myBeacon.major as! Int)*/
                return false
            })
            
           // let beacon1 = keyOfBeacon(major: beaconArray[0].major as! Int)
            print("beacon \(beacon1)")

        }/*else{
            updateDistance(.unknown)
        }*/
    }
    /*
    func keyOfBeacon(major: Int) -> String {
        return exhibits.index { (exhibit) -> Bool in
            return exhibit["major"] as? Int == major
            } ?? NSNotFound
    }*/
    
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
        return beaconArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")!

        
        let beacon:CLBeacon = beaconArray[indexPath.row]
        let uuid = beacon.proximityUUID.uuidString
        
        
      
        var d = beacon.accuracy
        d = floor(d * 10) / 10
        
        //beacon.rssi
        let txPower = -77
        
        let ratio_dB:Double = Double(txPower - beacon.rssi)
        let ratio_linear:Double = pow(10, (ratio_dB/10))
        let r = round(sqrt(ratio_linear))
        
        let beacon1 = exhibits.index(where: { (exhibit) -> Bool in
            if(exhibit["ble-major"] as! Int == beacon.major as! Int){
                print("same")
                print(exhibit)
                
                
                cell.textLabel?.text = ("\(exhibit["location-name"]!) | \(d) | \(r) | rssi \(beacon.rssi)| major: \(beacon.major) | minor \(beacon.minor) " )
                
                return true
            }
            /*print(exhibit["ble-major"] as! Int)
             print(myBeacon.major as! Int)*/
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
