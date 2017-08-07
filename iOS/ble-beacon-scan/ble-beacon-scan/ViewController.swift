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


class ViewController: UIViewController, KTKBeaconManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    //var locationManager: CLLocationManager!
    var beaconManager: KTKBeaconManager!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var statusLabel: UILabel!

    
    var beaconArray:[CLBeacon] = []
    
    var items: [String] = ["We", "Heart", "Swift"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //locationManager = CLLocationManager()
        //locationManager.delegate = self
        //locationManager.requestAlwaysAuthorization()
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
            updateDistance(beacons[0].proximity)
            statusLabel.text = "Beacons Visible \(beacons.count)";
            beaconArray = beacons;
            tableView.reloadData()
        }else{
            updateDistance(.unknown)
        }
    }

    func updateDistance(_ distance: CLProximity){
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
        /*final double ratio_dB = txPower - rssi;
        final double ratio_linear = Math.pow(10, (ratio_dB / 10));
        final double r = Math.sqrt(ratio_linear);*/
        
        //cell.textLabel?.text = ("\(uuid)")
        cell.textLabel?.text = ("\(d) meters | rssi \(beacon.rssi)| major: \(beacon.major) | minor \(beacon.minor) " )
        
        
        
        return cell
    }
    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
    }*/
   
}

