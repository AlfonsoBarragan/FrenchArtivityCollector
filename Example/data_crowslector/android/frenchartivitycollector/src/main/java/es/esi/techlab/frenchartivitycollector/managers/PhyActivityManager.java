package es.esi.techlab.frenchartivitycollector.managers;

import android.util.Log;

import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;

import es.esi.techlab.bluebeetoothmodule.MiBandImplementation.model.PhyActivity;

public class PhyActivityManager {

    private ArrayList<PhyActivity> activitiesRegister;
    private Date lastSamplePicked;

    private DatabaseReference mFirebaseDatabaseReference;


    public PhyActivityManager(Date lastSamplePicked) {
        this.activitiesRegister = new ArrayList<>();
        this.lastSamplePicked = lastSamplePicked;
        mFirebaseDatabaseReference = FirebaseDatabase.getInstance().getReference();

    }

    public ArrayList<PhyActivity> getActivities(Date initSample, Date lastSample){
        ArrayList<PhyActivity> activities = new ArrayList<>();

        Timestamp timestampInit = new Timestamp(initSample.getTime());
        Timestamp timestampLast = new Timestamp(lastSample.getTime());

        for (PhyActivity act : getActivitiesRegister()){
            if ((act.getActivityTimestamp().after(timestampInit) || act.getActivityTimestamp().equals(timestampInit))
                && (act.getActivityTimestamp().before(timestampLast) || act.getActivityTimestamp().equals(timestampLast))){
                    activities.add(act);
            }
        }

        return activities;
    }

    public int getAccumulatedSteps(PhyActivity[] activities){
        int accumulatedSteps = 0;

        for (PhyActivity act : activities){
            accumulatedSteps += act.getSteps();
        }

        return accumulatedSteps;
    }

    public void addActivitiesToRegister(ArrayList<PhyActivity> phyActivities){
        Calendar calendar = Calendar.getInstance();

        calendar.setTime(lastSamplePicked);

        ArrayList<PhyActivity> newPhyActivityRegister = getActivitiesRegister();
        Log.d("+++ Package data +++", "Counter_pck: " + phyActivities.get(0).getCounterPackage() + "intracounterpck: " + phyActivities.get(0).getIntraCounterPackage());
        // int first_sample = ((phyActivities.get(0).getCounterPackage() - 1) * 4) + phyActivities.get(0).getIntraCounterPackage();
        int minuteFirstSample = calendar.get(Calendar.MINUTE);

        Log.d("+++++ calendar time", String.valueOf(calendar.get(Calendar.MINUTE)));

        int samplesToRemove = ((calendar.get(Calendar.MINUTE)) - minuteFirstSample) % 4;

        Log.d("+++++ samples to Remove", String.valueOf(samplesToRemove));
        Log.d("+++++ calendar time", String.valueOf(calendar.get(Calendar.MINUTE)));

        for (int i = 0; i < samplesToRemove; i++){
            phyActivities.remove(i);
        }

        for (PhyActivity phyActivity : phyActivities){

            if (phyActivities.indexOf(phyActivity) != 0) {

                calendar.add(Calendar.MINUTE, 1);

            }

            Timestamp timestampPck = new Timestamp(calendar.getTime().getTime());
            phyActivity.setActivityTimestamp(timestampPck);

            Log.d("ACT_ADDED: ", String.valueOf(timestampPck.toString()));
            Log.d("ACT_ADDED: ", String.valueOf(phyActivity.toString()));

            if (!newPhyActivityRegister.contains(phyActivity)){
                newPhyActivityRegister.add(phyActivity);
            }

        }

        setActivitiesRegister(newPhyActivityRegister);
        calendar.add(Calendar.MINUTE, 1);
        lastSamplePicked = calendar.getTime();

    }

//    public void addActivityToRegister(int steps, int hearRate, int activityKind, int intensity,
//                                        int pckIndex, int intraPckIndex){
//
//        ArrayList<PhyActivity> newPhyActivityRegister = getActivitiesRegister();
//        Calendar calendar = Calendar.getInstance();
//
//        calendar.setTime(lastSamplePicked);
//        calendar.add(Calendar.MINUTE, ((pckIndex * 4) + intraPckIndex));
//
//        Timestamp timestampPck = new Timestamp(calendar.getTime().getTime());
//
//        PhyActivity act = new PhyActivity(steps, hearRate, activityKind, intensity, timestampPck);
//
//        Log.d("ACT_ADDED: ", String.valueOf(act.toString()));
//
//        if (!newPhyActivityRegister.contains(act)){
//            newPhyActivityRegister.add(act);
//        }
//
//        setActivitiesRegister(newPhyActivityRegister);
//    }

    public ArrayList<PhyActivity> getActivitiesRegister() {
        return activitiesRegister;
    }

    public void setActivitiesRegister(ArrayList<PhyActivity> activitiesRegister) {
        this.activitiesRegister = activitiesRegister;
    }

    public Date getLastSamplePicked() {
        return lastSamplePicked;
    }

    public void setLastSamplePicked(Date lastSamplePicked) {
        this.lastSamplePicked = lastSamplePicked;
    }

    public void communicatePhyActivitiesToFirebase(ArrayList<PhyActivity> phyActivities){
        for (PhyActivity ph : phyActivities){
//            JSONObject jsonPhyActivity = new JSONObject();
//
//            try {
//                jsonPhyActivity.put("heartRate", ph.getHeartRate());
//                jsonPhyActivity.put("intensity", ph.getIntensity());
//                jsonPhyActivity.put("kind", ph.getKindRaw());
//                jsonPhyActivity.put("steps", ph.getSteps());
//                jsonPhyActivity.put("timestamp", ph.getActivityTimestamp());
//
//            } catch (JSONException e) {
//                e.printStackTrace();
//            }
            Log.d("PUSH", "Physical activities");
            mFirebaseDatabaseReference.child("physicalActivities").push().setValue(ph);

        }

    }

    public void removeRegisterActivity(PhyActivity phyActivity) {
        this.activitiesRegister.remove(phyActivity);
    }
}
