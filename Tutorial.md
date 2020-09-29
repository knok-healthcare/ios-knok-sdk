# Tutorial

This tutorial will walk you through the steps of setting up a basic iOS client.

## Overview

In this tutorial, you will be utilizing the Knok SDK for iOS devices, to quickly and easily build an application with real time interactive video appointments.

## Requirements
-  Knok Client Account
- Xcode

Step 1: Creating a new project
Step 2: Adding Knok iOS SDK
Step 3: Setting up authentication
Step 4: Requesting permissions
Step 5: Connecting to the session
Step 6: Adjusting the sample app UI
Step 7: Publishing a stream to the session
Step 8: Subscribing to other client streams
Step 9: Running the app

## Step 1: Creating a new project

1.  Open Xcode and select  **New Project**  from the  **File**  menu.
2. Select **iOS** and **App**.
3. Enter a name for your app.

## Step 2: Adding Knok iOS SDK

1. Add a file named **Podfile** in the same directory as your .xcodeproj file:
```ruby
platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

target "yourappname" do
	pod 'knokSDK'
end
```
2. Run **pod install** from your command line in the same directory as your Podfile (you need cocoapods installed on your machine - https://cocoapods.org).
3. This will create a new file with **.xcodeworkspace** extension. Close the .xcodeproj if you have it opened and open the .xcodeworkspace one.

## Step 3: Setting up authentication

In order to connect to a Video Session, the client will need access to some authentication credentials.

In the ViewController class, add static variables to store the Knok API key, session id and token:
```swift
class ViewController: UIViewController {

private let KNOK_API_KEY = ""
private let sessionId = ""
private let sessionToken = ""
...
```

## Step 4: Requesting permissions

Because our app uses audio and video from the user's device, we’ll need to add two keys to our app's **Info.plist** file:
- NSCameraUsageDescription
- NSMicrophoneUsageDescription

Insert a description for each key (ex: "This feature is required to use video calls.").

## Step 5: Connecting to the session

Next, we will connect to the Knok video session. You must do this before you can publish your audio-video stream to the session or view other participants streams.

1. Import the sdk at the top of the file:
```swift
import knokSDK
```
2.  Add a  `knok` property to the ViewControler class (right after the last lines you added in  **Step 3**):
```swift
private let knok: Knok!
```
3. Add a `viewDidAppear` method and setup `knok` instance:
```swift
override func viewDidAppear(_ animated: Bool) {
  super.viewDidAppear(animated)
  knok = Knok(with: KNOK_API_KEY, sessionId: sessionId, sessionToken: sessionToken)
  knok.setup(listener: self)
}
```
The constructor takes three parameters:
- The Knok API key
- The session ID
- The session token

The  `knok.setup(listener: self)`  method sets the object that will implement the  `SetupListener`  protocol. This interface includes callback methods that are called in response to setup-related events after the sdk requests permissions to access camera and microphone.

4. Change the ViewControler class declaration to have it implement the  `SetupListener`  protocol:
```swift
class ViewController: UIViewController, SetupListener {
...
```

5. Implement the `onSetupSuccess` and `onSetupError` delegate methods:
```swift
func onSetupSuccess() {
}

func onSetupError(message: String) {
  let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: message, preferredStyle: UIAlertController.Style.alert)
  alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok"), style: .cancel))
  present(alert, animated: true, completion: nil)
}
```

6. We can now setup the session and start the video appointment. Modify the `onSetupSuccess()` method:
```swift
func onSetupSuccess() {
  knok.setSessionListener(videoSessionListener: self)
  knok.startVideoAppointment()
}
```
The  `knok.startVideoAppointment()`  method connects the client application to the OpenTok session. You must connect before sending or receiving audio-video streams in the session (or before interacting with the session in any way).

4. Change the ViewControler class declaration to have it implement the  `SessionListener`  protocol:
```swift
class ViewController: UIViewController, SetupListener, SessionListener {
...
```
 
 5. Implement the delegate methods of the  `SessionListener`  protocol. Add the following code to the end of the  `ViewController`  class (before the closing bracket of the class):
```swift
func onConnected(videoPublisher: VideoPublisher) {
}

func onStreamReceived(videoSubscriber: VideoSubscriber) {
}

func onStreamDropped() {
}
```
-   When the client connects to the Knok video session, the implementation of the  `onConnected()`  method is called.
-   When another client publishes a stream to the Knok video session, the implementation of the  `onStreamReceived()`  method is called.
-   When another client stops publishing a stream to the Knok video session, the implementation of the  `onStreamDropped()`  method is called.

## Step 6: Adjusting the sample app UI

1. Declare 2 view properties at the top of the class:
```swift
class ViewController: UIViewController, SetupListener, SessionListener {
  ...
  @IBOutlet weak var publisherView : UIView!
  @IBOutlet weak var subscriberView : UIView!
  ...
```
2. Open `Main.storyboard` file and add two `UIView` objects to the ViewController parent view. Make one occupy the entire screen and another one as a smaller rectangle above the latter. Open Xcode right panel inspector and assign the `publisherView` and `subscriberView` outlets to the views you've just created.

## Step 7: Publishing a stream to the session

When the app connects to the Knok video session, we want it to publish an audio-video stream to the session, using the camera and microphone:

1.  Add a  `publisher`  property to the ViewController class (after the declaration of the  `knok`  property):
```swift
private var publisher: VideoPublisher!
```
2. Modify the implementation of the  `onConnected()`  method to include code to publish a stream to the session:
```swift
func onConnected(videoPublisher: VideoPublisher) {
  publisher = videoPublisher
  publisher.container!.view!.frame = CGRect(x: 0, y: 0, width: publisherView.frame.width, height: publisherView.frame.height)
  publisherView?.addSubview(publisher.container!.view!)
  view.bringSubviewToFront(publisherView)
  knok.publish(videoPublisher: publisher)
}
```
The code passes the VideoPublisher object in as a parameter of the  `knok.publish()`  method. This method publishes an audio-video stream to the session, using the camera and microphone of the iOS device. (Note that in an iOS simulator, the Knok iOS SDK uses a test video when publishing a stream).

The Publisher object has a  `container`  property, which in its turn contains a UIView object. This view displays the video captured from the device’s camera. The code adds this view as a subview of the  `publisherView`  object.

## Step 8: Subscribing to other client streams

We want clients to be able to  **subscribe**  to (or view) other clients’ streams in the session:

1.  Add a  `subscriber`  property to the ViewController class (after the declaration of the  `publisher`  property):
```swift
private var subscriber: VideoSubscriber!
```
The VideoSubscriber class defines an object that a client uses to subscribe to (view) a stream published by another client.

2.  Modify the implementation of the  `onStreamReceived()`  method (one of the SessionListener callbacks) to include code to subscribe to other clients’ streams of the session:
```swift
func onStreamReceived(videoSubscriber: VideoSubscriber) {
  subscriber = videoSubscriber
  knok.subscribe(videoSubscriber: subscriber!)
  subscriber.container!.view!.frame = subscriberView.frame
  subscriberView?.addSubview(subscriber.container!.view!)
}
```
The  `knok.subscribe()`  method subscribes to the stream that was just received. `subscriberView.addSubview(subscriber.container!.view!)`  places the new subscribed stream's view on the screen.

3.  Modify the implementation of the  `onStreamDropped()`  method (another one of the SessionListener callbacks):
```swift
func onStreamDropped() {
  if (subscriber != nil) {
    subscriber = nil
    subscriberView?.removeFromSuperview()
  }
}
```
`subscriberView?.removeFromSuperview()`  removes a subscriber's view once the stream has dropped.

## Step 9: Running the app

Now that your code is complete, you can run the app in the Xcode simulator. This will create a simulated publisher video — since the simulator cannot access your webcam, the publisher video will display an animated graphic instead of your camera feed.

To add a second publisher (which will display as a subscriber in your emulator), run the app a second time in a connected iOS device.