package at.ac.fhstp.meeteux.blescan2;


import android.Manifest;
import android.os.Bundle;
import android.util.Log;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.kontakt.sdk.android.ble.connection.OnServiceReadyListener;
import com.kontakt.sdk.android.ble.device.BeaconRegion;
import com.kontakt.sdk.android.ble.manager.ProximityManager;
import com.kontakt.sdk.android.ble.manager.ProximityManagerFactory;
import com.kontakt.sdk.android.ble.manager.listeners.IBeaconListener;
import com.kontakt.sdk.android.ble.manager.listeners.ScanStatusListener;
import com.kontakt.sdk.android.ble.manager.listeners.simple.SimpleIBeaconListener;
import com.kontakt.sdk.android.ble.manager.listeners.simple.SimpleScanStatusListener;
import com.kontakt.sdk.android.common.KontaktSDK;
import com.kontakt.sdk.android.common.profile.IBeaconDevice;
import com.kontakt.sdk.android.common.profile.IBeaconRegion;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

import okhttp3.Headers;

import static android.R.id.list;
import static at.ac.fhstp.meeteux.blescan2.R.id.listView;

public class MainActivity extends AbsRuntimePermission {
    private static final int REQUEST_PERMISSION = 10;
    private ProximityManager proximityManager;


    ListView listView;
    String[] beaconItems;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        requestAppPermissions(new String[]{
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.BLUETOOTH,
                Manifest.permission.INTERNET,
                Manifest.permission.BLUETOOTH_ADMIN,
                Manifest.permission.ACCESS_NETWORK_STATE
                },
                R.string.msg,
                REQUEST_PERMISSION);

        listView = (ListView) findViewById(R.id.listView);



    }

    @Override
    public void onPermissionsGranted(int requestCode){
        // Do anything when permission granted
        Toast.makeText(getApplicationContext(), "Permission granted", Toast.LENGTH_LONG).show();

        KontaktSDK.initialize(this);
        proximityManager = ProximityManagerFactory.create(this);


        Collection<IBeaconRegion> beaconRegions = new ArrayList<>();

        IBeaconRegion region1 = new BeaconRegion.Builder()
                .identifier("My Region")
                .proximity(UUID.fromString("f7826da6-4fa2-4e98-8024-bc5b71e0893e"))
                .build();


        beaconRegions.add(region1);

        proximityManager.spaces().iBeaconRegions(beaconRegions);


        /* proximityManager.setIBeaconListener(createIBeaconListener()); */

        proximityManager.setIBeaconListener(new IBeaconListener() {
            @Override
            public void onIBeaconDiscovered(IBeaconDevice iBeacon, IBeaconRegion region) {
                //Beacon discovered
                Log.i("Sample", "Beacon discovered");
                Log.i("Sample", "IBeacon discovered: " + iBeacon.toString());

            }

            @Override
            public void onIBeaconsUpdated(List<IBeaconDevice> iBeacons, IBeaconRegion region) {
                //Beacons updated
                Log.i("Sample", "Beacon updated");
                Log.i("Sample", "IBeacon updated: " + iBeacons.toString());
                //readBeaconData(iBeacons);
                beaconItems = new String[iBeacons.size()];
                List<IBeaconDevice> newList = new ArrayList<>(iBeacons);
                Collections.sort(newList, new Comparator<IBeaconDevice>() {
                    @Override
                    public int compare(IBeaconDevice lhs, IBeaconDevice rhs) {
                        int returnVal = 0;

                        if(lhs.getRssi() < rhs.getRssi()){
                            returnVal =  1;
                        }else if(lhs.getRssi() > rhs.getRssi()){
                            returnVal =  -1;
                        }else if(lhs.getRssi() == rhs.getRssi()){
                            returnVal =  0;
                        }
                        return returnVal;
                    }
                });



                for(int i = 0; i<newList.size();i++) {
                    String beaconName = "Major " + newList.get(i).getMajor() + " " + "Minor " + newList.get(i).getMinor();
                    String beaconRssi = "RSSI " + String.valueOf(newList.get(i).getRssi());
                    beaconItems[i] = beaconName + " " + beaconRssi;
                }
                ArrayAdapter<String> adapter = new ArrayAdapter<String>(getApplicationContext(), android.R.layout.simple_list_item_1, android.R.id.text1, beaconItems);
                listView.setAdapter(adapter);
            }


            @Override
            public void onIBeaconLost(IBeaconDevice iBeacon, IBeaconRegion region) {
                //Beacon lost
                Log.i("Sample", "Beacon lost");
                Log.i("Sample", "IBeacon lost: " + iBeacon.toString());
            }
        });

        proximityManager.setScanStatusListener(createScanStatusListener());

    }

    @Override
    protected void onStart() {
        super.onStart();

        Log.i("Sample", "Start scanning");
        startScanning();
    }

    @Override
    protected void onStop() {
        Log.i("Sample", "Stop scanning");
        proximityManager.stopScanning();
        super.onStop();
    }

    @Override
    protected void onDestroy() {
        proximityManager.disconnect();
        proximityManager = null;
        Log.i("Sample", "Destroy");
        super.onDestroy();
    }

    private void startScanning() {
        proximityManager.connect(new OnServiceReadyListener() {
            @Override
            public void onServiceReady() {
                proximityManager.startScanning();
            }
        });
    }

    private IBeaconListener createIBeaconListener() {
        return new SimpleIBeaconListener() {
            @Override
            public void onIBeaconDiscovered(IBeaconDevice ibeacon, IBeaconRegion region) {
                Log.i("Sample", "Beacon discovered");
                Log.i("Sample", "IBeacon discovered: " + ibeacon.toString());
            }
        };
    }


    private void showToast(final String message) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Toast.makeText(MainActivity.this, message, Toast.LENGTH_SHORT).show();
            }
        });
    }

    private ScanStatusListener createScanStatusListener() {
        return new SimpleScanStatusListener() {
            @Override
            public void onScanStart() {
                showToast("Scanning started");
            }

            @Override
            public void onScanStop() {
                showToast("Scanning stopped");
            }
        };
    }


}
