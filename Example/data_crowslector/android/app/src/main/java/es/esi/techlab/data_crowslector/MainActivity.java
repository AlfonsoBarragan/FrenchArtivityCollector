package es.esi.techlab.data_crowslector;

import android.app.PendingIntent;
import android.content.IntentFilter;
import android.os.Bundle;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import android.content.Intent;
import android.os.Build;
import android.util.Log;
import java.util.Arrays;

import es.esi.techlab.frenchartivitycollector.managers.InputOutputManagement;
import io.flutter.view.FlutterView;

public class MainActivity extends FlutterActivity {

    private PendingIntent pendingIntent;

    private static FlutterView flutterView;
    private static final String CHANNEL_STARTSERVICE = "es.uclm.mami.init_miband_service";

    private static MethodChannel methodChannelStartService;
    private static MethodChannel methodChannelSendActivities;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        flutterView=getFlutterView();
        GeneratedPluginRegistrant.registerWith(this);
        InputOutputManagement keymanager = new InputOutputManagement(this);
        // Registering BroadcastReceiver MyReceiver
//        IntentFilter intentFilter = new IntentFilter();
//        intentFilter.addAction("sendingActivities");
//        registerReceiver(new MyReceiver(),intentFilter);



        methodChannelStartService = new MethodChannel(flutterView, "es.uclm.esi.mami.macAddress");
        methodChannelStartService.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {

                Log.d("SERVICE", "INIT SERVICE TEST");
                Intent serviceIntent = new Intent(MainActivity.this, es.esi.techlab.frenchartivitycollector.managers.MiBandServiceManager.class);
                Log.d("DATA", String.valueOf(methodCall.method));

                if (!methodCall.method.equals("old"))
                    serviceIntent.putExtra("macAddress", methodCall.method);
                else
                    serviceIntent.putExtra("macAddress", "");

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    Log.d("FOREGROUND", "Start Foreground Service");
                    startForegroundService(serviceIntent);
                } else {
                    startService(serviceIntent);

                }

            }
        });

        methodChannelSendActivities = new MethodChannel(flutterView, "es.uclm.esi.mami.phyActivities");

    }

    static void sendtoFlutterActivities(String[] phyActivities) {
        Log.d("SEND TO FLUTTER METHOD", "BEGIN");
        Log.d("PHYACTIVITIES", Arrays.toString(phyActivities));
        for (String phyActivity : phyActivities){
            methodChannelSendActivities.invokeMethod("lastRecording", phyActivity);
        }
    }

}
