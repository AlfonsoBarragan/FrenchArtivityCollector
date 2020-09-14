# FrenchArtivityCollector

<h1 align="center">
    <img src="resources/Logo.png">
</h1>

[![DOI](https://img.shields.io/badge/DOI-WIP-blueviolet)]()
![Last release](https://img.shields.io/badge/Last%20release-PeintureDeLaRenaissance-1a295d)
[![Package status](https://img.shields.io/badge/Package%20status-up%20to%20date!-blue)](https://pypi.org/project/pandas/)
![Last commit](https://img.shields.io/github/last-commit/AlfonsoBarragan/Techdeck)
![Coverage](https://img.shields.io/badge/Coverage-0%25-red)
[![License](https://img.shields.io/badge/License-GPL-brightgreen)](https://github.com/pandas-dev/pandas/blob/master/LICENSE)

Resource package synergy between BlueBeeTooth and AutomatonMonkSeal to recollect activity data from MiBand3

* Added two examples, one creating a new module an transfering the classes handmade and other importing the library throught an AAR package.

# Requirements

This module requires the next libraries in the build.gradle (module level) of the app that will use it:

* [Reactivex.io](http://reactivex.io/)
* [Apache Commons Lang](http://commons.apache.org/proper/commons-lang/)
* [BlueBeeTooth](https://github.com/AlfonsoBarragan/BlueBeeTooth)
* [AutomatonMonkSeal](https://github.com/AlfonsoBarragan/AutomatonMonkSeal)
* [Firebase](https://firebase.google.com/docs)

The actual versios used in the example are the following. Do not forget to add them to build.gradle at app level.

```gradle

    implementation project(path: ':frenchartivitycollector-release')

    implementation 'com.google.firebase:firebase-firestore:21.4.3'
    implementation 'com.google.firebase:firebase-config:19.1.4'
    implementation 'com.google.firebase:firebase-analytics:17.2.3'
    implementation 'com.google.firebase:firebase-core:17.0.0'
    implementation 'com.google.firebase:firebase-database:19.2.0'
    implementation 'com.google.firebase:firebase-storage:17.0.0'
    implementation 'org.apache.commons:commons-lang3:3.6'
    implementation 'io.reactivex.rxjava2:rxjava:2.2.16'

    implementation project(path: ':automatedmonkseal-release')
    implementation project(path: ':bluebeetoothmodule-release')

```

# Install proccess

The install proccess will be as follows:

* Download the actual release files (this will be an .arr file)
* In Android Studio go to **File** >> **Project Structure**
* Then click on the **+** icon, next selects **Import .JAR/.AAR Package**
* Finally in your **build.gradle (at module level)** add the line **implementation project(path: ':frenchartivitycollector-release')** to the dependencies

Do the same process with **BlueBeeTooth module** and **AutomatonMonkSeal module**.

Now you had access to several classes, that can be classified in two categories:

* Behaviour
  * AutomatonMiBandManager; A class throught the library [AutomatonMonkSeal](https://github.com/AlfonsoBarragan/AutomatonMonkSeal) implements an automaton that models the communication flow between the wearable device (**MiBand3**) from its pairing and the recollection of data. This communication flow is graphically modelate in the next figure.
**(METER IMAGEN)**

* Managers
  * DatabaseManager; A class to manage the communication with the firebase database.
  * PhyActivityManager; A class to manage the raw data taking from the wearable device and converse it into a JSON more easy to treat and store.
  * InputOutputManagement; A class to manage internal input-output calls in the smartphone.
  * MiBandServiceManager; A class to manage the result of the bluetooth communications based on the communication flow that follows **AutomatonMiBandManager**.


# Usage

See the [example app (AAR integration)](https://github.com/AlfonsoBarragan/FrenchArtivityCollector/tree/AAR-integration/Example/data_crowslector) / [example app (Handmade module integration)](https://github.com/AlfonsoBarragan/FrenchArtivityCollector/tree/master/Example/data_crowslector) that mades an app for communicating the MiBand3 with an android smartphone, recollect all the activities and up to a cloud firestore database.

In this example we part from an empty flutter project, and implemented the logic of the communication with the MiBand3 and the smartphone throught the **FrenchArtivityCollector module**. In the android app part, we only made the MainActivity and MyApplication class.

* MainActivity. In this class we preparate the app for communicating with the flutter interface, concretly just pass the MAC address of MiBand3, in order that **FrenchArtivityCollector module** can perfom the communications with it.

* MyApplication. This class will permits the creation of the channels to communicate flutter and android.

After creating this main classes we should make some special settings to can communicate with firebase and made background process in android smartphone.

* To prepare the firebase backend, consult the wiki page: [Settings to firebase data management](https://github.com/AlfonsoBarragan/FrenchArtivityCollector/wiki/Settings-to-firebase-data-management)

* To prepare the final settings in the app side, consult wiki page: [Settings to the app to make it work](https://github.com/AlfonsoBarragan/FrenchArtivityCollector/wiki/Settings-to-the-app-to-make-it-work)
