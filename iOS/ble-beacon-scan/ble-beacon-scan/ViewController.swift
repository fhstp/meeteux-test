//
//  ViewController.swift
//  ble-beacon-scan
//
//  Created by Kerstin Blumenstein on 31/07/2017.
//  Copyright © 2017 Kerstin Blumenstein. All rights reserved.
//

import UIKit
import CoreLocation



class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var locationManager: CLLocationManager!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var statusLabel: UILabel!

    
    var beaconArray:[CLBeacon] = []
    
    var items: [String] = ["We", "Heart", "Swift"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        if status == .authorizedAlways{
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self){
                if CLLocationManager.isRangingAvailable(){
                    startScanning()
                }
            }
        }
    }
    
    func startScanning(){
        let uuid = UUID(uuidString: "f7826da6-4fa2-4e98-8024-bc5b71e0893e")!
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: "MyBeacon")
        
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if beacons.count>0{
            updateDistance(beacons[0].proximity)
            statusLabel.text = "Beacons Visible \(beacons.count)";
            beaconArray = beacons;
            tableView.reloadData()
        } else{
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

