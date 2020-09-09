package es.esi.techlab.frenchartivitycollector.managers;

import android.app.IntentService;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.le.ScanResult;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Build;
import android.os.IBinder;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;

import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.InputMismatchException;

import es.esi.techlab.automatedmonkseal.AutomatonMonkSeal.AutomatonExceptions.DuplicatedStateException;
import es.esi.techlab.automatedmonkseal.AutomatonMonkSeal.AutomatonExceptions.InitialStateException;
import es.esi.techlab.automatedmonkseal.AutomatonMonkSeal.AutomatonExceptions.NoStateException;
import es.esi.techlab.automatedmonkseal.AutomatonMonkSeal.AutomatonExceptions.NoTransitionException;
import es.esi.techlab.frenchartivitycollector.R;
import es.esi.techlab.frenchartivitycollector.behaviour.AutomatonMiBandManager;
import es.esi.techlab.bluebeetoothmodule.MiBandImplementation.MiBand;
import io.reactivex.functions.Consumer;

/**
 * An {@link IntentService} subclass for handling asynchronous task requests in
 * a service on a separate handler thread.
 * <p>
 * TODO: Customize class - update intent actions, extra parameters and static
 * helper methods.
 */
public class MiBandServiceManager extends Service {
    // Things to work
    private HashMap<String, BluetoothDevice> devices;
    private MiBand miBand;
    private InputOutputManagement inputOutputManager;
    private PhyActivityManager phyActivityManager;
    private boolean setConfig = true;
    private boolean actuallyPaired = false;
    private boolean actuallyEnableFetchAndCharAct = false;
    private String macAddress = "";
    private DatabaseManager databaseManager;

    //private String macAddress = "C1:F5:14:77:BD:48";

//    private String macAddress = "F3:58:E3:AF:65:84";
//    private String macAddress = "CB:75:F8:A9:65:F7";

    private static AutomatonMiBandManager automataConducta;

    public MiBandServiceManager() {
        super();
        devices = new HashMap<>();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.d("START", "On start command!");
        miBand = new MiBand(this, inputOutputManager.readKey());

        macAddress = inputOutputManager.readMacAddress();

        if ((macAddress.equals("") || !macAddress.equals(intent.getStringExtra("macAddress")))) {
            macAddress = intent.getStringExtra("macAddress");
            Log.d("MAC ADDRESS DETECT", String.valueOf(intent.getStringExtra("macAddress")));

            if (!macAddress.equals(null) && !macAddress.equals("")) {
                inputOutputManager.writeMacAddress(macAddress);
            }
        }

        automataConducta = new AutomatonMiBandManager("AutomataMiBandManager", this, getApplicationContext());
        try {
            automataConducta.automatonInit();
        } catch (DuplicatedStateException e) {
            e.printStackTrace();
        } catch (InitialStateException e) {
            e.printStackTrace();
        } catch (NoStateException e) {
            e.printStackTrace();
        }

        if (inputOutputManager.readKey().equals(new byte[]{0x00})){
            try {
                automataConducta.addEvent("go to con");
            } catch (NoTransitionException e) {
                e.printStackTrace();
            }

        } else{
            //IMPORTANTE ESTA TRANSICION NORMALMENTE DEBE DE ESTAR A "go to con"
            //PERO POR MOTIVOS DE DEBUG LA HE CAMBIADO
            try {
                automataConducta.addEvent("go to con");
            } catch (NoTransitionException e) {
                e.printStackTrace();
            }
        }
        return START_STICKY;
    }

    public Consumer<Boolean> handleConnectResult() {
        return new Consumer<Boolean>() {
            @Override
            public void accept(Boolean result) throws Exception {
                Log.i("CONNECTION", "Connected:" + String.valueOf(result));
                if (result) {
                    if (miBand.getKey()[0] == 0x00) {
                        setConfig = true;
                    } else {
                        Log.d("KEY_0x00", String.valueOf(Arrays.toString(miBand.getKey())));
                    }
                    // Enable Notifications (this is the first step preparing pairing/auth...)
                    miBand.setPairRequested(true);
                    automataConducta.addEvent("go to pair");
                } else{
                    Log.d("Connection", "FAIL");
                    actuallyPaired = false;
                    automataConducta.addEvent("go to wait");
                    automataConducta.addEvent("go to con");
                }
            }
        };
    }

    public Consumer<Boolean> handlePairResult() {
        return new Consumer<Boolean>() {
            @Override
            public void accept(Boolean result) throws Exception {
                Log.i("PAIR", "Pairing successful");

                actuallyPaired = true;
                if (result){
                    if (setConfig) {
                        inputOutputManager.writeKey(miBand.getKey());
                        automataConducta.addEvent("go to heart");
                    } else{
                        automataConducta.addEvent("go to fetch");
                    }
                } else{
                    automataConducta.addEvent("go to wait");
                    automataConducta.addEvent("go to con");
                }

            }
        };
    }

    public Consumer<Boolean> handleHeartRateMeasurementResult() {
        return new Consumer<Boolean>() {
            @Override
            public void accept(Boolean result) throws Exception {
                Log.i("HEART_RATE","Measuring successful");

                automataConducta.addEvent("go to time");

            }
        };
    }

    public Consumer<Boolean> handleEnableFetchingResult() {
        return new Consumer<Boolean>() {
            @Override
            public void accept(Boolean result) throws Exception {
                Log.i("FETCH","Fetching notifications enabled");
                automataConducta.addEvent("go to char_act");

            }
        };
    }

    public Consumer<Boolean> handleEnableCharActivityResult() {
        return new Consumer<Boolean>() {
            @Override
            public void accept(Boolean result) throws Exception {
                Log.i("CHAR_ACTIVITY","Char activity notifications enabled");


                automataConducta.addEvent("go to st_rec");

            }
        };
    }

    public Consumer<Boolean> handleStartFetchingActivityResult() {
        return new Consumer<Boolean>() {
            @Override
            public void accept(Boolean result) throws Exception {
                Log.i("ST_FETCH_ACTIVITY","Starting fetching activity notifications");


                automataConducta.addEvent("go to rec");

            }
        };


    }

    public Consumer<Boolean> handleFetchingPastDataResult() {
        return new Consumer<Boolean>() {
            @Override
            public void accept(Boolean result) throws Exception {

                Log.i("FETCH_PAST_DATA","Fetching past data");
                if (!result){
                    automataConducta.addEvent("go to wait");
                    automataConducta.addEvent("go to st_rec");
                } else{
                    automataConducta.addEvent("go to send");
                    automataConducta.addEvent("go to wait");
                    automataConducta.addEvent("go to pair");
                }

            }
        };
    }

    public Consumer<Boolean> handleSetTimeResult() {
        return new Consumer<Boolean>() {
            @Override
            public void accept(Boolean result) throws Exception {
                Log.i("SET_TIME","Setting the clock's timing");
                setConfig = false;
                if(result) {
                    automataConducta.addEvent("go to pair");

                }

            }
        };

    }

    public void continueWithPairedDevice() throws InterruptedException {
        try{
            if(!actuallyEnableFetchAndCharAct){
                Thread.sleep(5000);

                Log.d("FLOW", "continueWithPairedDevice");
                automataConducta.addEvent("go to fetch");
            } else{
                automataConducta.addEvent("go to st_rec");
            }
        } catch (InterruptedException e){
            Log.d("Exception OCCURRED", e.getMessage());
        } catch (NoTransitionException e) {
            e.printStackTrace();
        }

    }

    public void continueWithFetchedDevice(){
        try {
            automataConducta.addEvent("go to wait");
        } catch (NoTransitionException e) {
            e.printStackTrace();
        }
        try {
            automataConducta.addEvent("go to pair");
        } catch (NoTransitionException e) {
            e.printStackTrace();
        }

    }

    public Consumer<Throwable> handleError() {
        return new Consumer<Throwable>() {
            @Override
            public void accept(Throwable throwable) throws Exception {
                throwable.printStackTrace();
                Log.d("MainActivity", String.valueOf(throwable));

            }
        };
    }

    public MiBand getMiBand() {
        return miBand;
    }

    public InputOutputManagement getInputOutputManager() {
        return inputOutputManager;
    }

    public PhyActivityManager getPhyActivityManager() {
        return phyActivityManager;
    }

    @Override
    public void onDestroy() {
        Log.d("DESTROY", "DESTRUYENDO");
        super.onDestroy();
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onCreate() {
        Log.d("CREATE", "CREATEANDO");

        phyActivityManager = new PhyActivityManager(new Date());
        inputOutputManager = new InputOutputManagement(this);
        databaseManager = new DatabaseManager(getApplicationContext());

        // Registering BroadcastReceiver MyReceiver
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction("recordingArray");


        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            NotificationCompat.Builder builder = new NotificationCompat.Builder(this, "messages").setContentText("eMOVI is running in background").setContentTitle("eMOVI").setSmallIcon(R.drawable.zapatos);
            startForeground(101, builder.build());
        }
    }

    public String getMacAddress() {
        return macAddress;
    }

    public boolean isActuallyPaired() {
        return actuallyPaired;
    }

    public void setActuallyEnableFetchAndCharAct(boolean actuallyEnableFetchAndCharAct) {
        this.actuallyEnableFetchAndCharAct = actuallyEnableFetchAndCharAct;
    }

    public void checkMiBandConnection(){
        BluetoothDevice aux = miBand.getBluetoothIO().getConnectedDevice();
        Log.d("DEVICE: ", String.valueOf(aux.getName() + aux.getAddress()));
        if(aux.equals(null)) {
            Log.d("NULLIFIED", "TRYING TO RECONECT");
            try {
                automataConducta.addEvent("go to wait");
            } catch (NoTransitionException e) {
                e.printStackTrace();
            }
            try {
                automataConducta.addEvent("go to con");
            } catch (NoTransitionException e) {
                e.printStackTrace();
            }
        }
    }

    public DatabaseManager getDatabaseManager() {
        return databaseManager;
    }

    public HashMap<String, BluetoothDevice> getDevices() {
        return devices;
    }
}
