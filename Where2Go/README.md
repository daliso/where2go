# The Where 2 Go App

## Introduction

This app lets you explore places to visit in a city and schedule days and times when you plan to go there.

## Installation

* Download this repository
* Open the project file in Xcode
* Build/Run the project in your simulator, or connect you iPhone to install it on your device

## Compatibility

This app is designed to work on any iPhone. Note that there is no iPad version.

You will need an Internet connnection to get the full benefits of using this app.

## Getting Started

### Exploring Places
When you first launch the app, you will be taken to the Explore Places map view. The first time you open the app, it will request permission to track your location when using the app. It is recommended that you agree to this, as it will allow you to zoom in immediately to you current location.

You can explore using the standard pinch and pan gestures. As the map region changes new pins will be added to the app indicating places you can visit.

At the top of the mapview, you will see a switch that allows you to change between viewing **Dining** places, and **Entertainment** places. The default is Dining.

Tap on each pin to see the name of the venue in the pin callout, and tap the callout to get more details about the venue.

### Reviewing Detailed Location Information

After tapping on the pin callout on the Explore Places view, the view will switch to the location detail view. Here you will see:

* a rating (if none is available, then the rating will be 0.0/10)
* contact information
* opening hours
* the dates and times for any trips you've scheduled there

To schedule a new Trip, tap the ADD TRIP button on the top right of the screen.

### Scheduling A Trip

After tapping the ADD TRIP button, you will be presented with a modal screen where you can select the Date/Time and also add any notes you want about the trip.

When done, tap the save button and you will be returned to the Location detail screen.

### Viewing Your Scheduled Trips

This can be done from one of two places

* By tapping the trip on the Location Detail screen (see above section: 'Reviewing Detailed Location Information')
* By tapping the trip on the My Trips screen (see below section: 'The My Trips Screen')

### The My Trips screen

At the bottom of all screens, you will see a tab bar with two tabs. The first is **Explore Places** , which is selected by default when you open the app. The second is the **My Trips** tab. If you tap this then you will see a table of all the trips that you've scheduled' tap on any of these to view the details of the trip.

### Editing or Deleting a Trip

From the Trip details view, you will see a button titled **Edit Trip** in the top right corner of the screen. Tap on this and you will be presented with the modal screen for editing or deleting the trip.


## Third Party APIs

This app integrates with Foursquare for the location information.

