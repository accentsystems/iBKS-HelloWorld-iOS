# iBKS-HelloWorld-iOS
**ABSTRACT**

The App demo **iBKS Hello World** is a project that contains the most important functions to begin interacting with a Beacon.

**AUDIENCE**

This document is focused for App developers who has no experience in beacon communication management

# Before you start
All you need to start playing with “iBKS Hello World”:

* XCode 7.0 or higher
* iOS device with 9.0 version or above
* At least one iBKS Beacon
* Download iBKS Hello World for iOS project
* Check folder docs for further information

# Project iBKS Hello World
After downloading de **iBKS Hello World** project, you only have to open it with XCode, sign it with your development provisioning profile and compile it. All the needed libraries and permissions are included.

The project is structured to show three important functionalities, each one on a different class:

* **ScanViewController**: scans and list the beacons that are advertising around and allows discovering services and characteristics.
* **NotificationsViewController**: Show a notification dialog on App triggered by a specific beacon ranged.
* **Background Scan**: Starts background monitoring that allows to detect beacons and send a notification even when the app is stopped (killed).

The first activity started on foreground is **MainViewController** that show the different options of the app and check the app permissions.
