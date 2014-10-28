MyoLIFXControl
==============

An iPad app that lets you control LIFX bulbs with a Myo armband. This is more of a proof of concept for the control scheme, but it's pretty fun to play with.

![Screenshot](http://imgur.com/tpavq0Q.jpg)

The interface has a list of connected lights on the left side, a panel to control the selected light manually (toggle power, set the label, change the color in RGB), and a panel to display information about the connected Myo armband, like the current pose, whether it's locked, and motion data.

The LIFX views all reflect the current state of the light, so if you change anything about the light from another device, it'll show up on the iPad.

The app is set up to run in the background, even when the screen is off, and it does do that most of the time.

Control Scheme
--------------

The app won't respond to pose changes from the Myo if it's locked. Unlocking is achieved with the thumb-to-pinky gesture, which is notoriously tricky to actually get consistently. After being unlocked, it'll stay unlocked for a couple seconds before automatically locking. This is to prevent unwanted light shows while you go about your business.

Once unlocked, spreading your fingers will toggle the power. Waving your hand outward and holding it will increase the brightness, and waving your hand inward will lower it.

To change the color of the bulb, unlock it and make a fist. You are now controlling the bulb, and the app will stay unlocked. Feel the power. To pick the base color of the bulb (change its hue), move your arm side to side. To change how colorful the light is (adjust its saturation), move your arm up and down. Relax your hand to finalize the color.

Known Issues - TODO
-------------------

- MyoView breaks MVC all over the place
- There's a funny infinite recursion crash coming from MyoKit whenever you hit "Run" in Xcode if the app is already installed on the device
- The LIFX control decouples from the actual light sometimes, which appears to happen more in busier WiFi areas. This might coming from an issue with LIFXKit, or from something light trying to update the light's color too frequently
- The code could use a cleaning (see MyoView note)
- Make a more useful visualization of the motion data
