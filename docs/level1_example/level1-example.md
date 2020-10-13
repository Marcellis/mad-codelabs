author: HvA
summary: Mad Level 1 Example
id: level1-example
categories: Apps
tags: apps
status: Published
feedback link: https://github.com/SolaceDev/solace-dev-codelabs/tree/master/markdown/codelab-4-codelab
analytics account: UA-3921398-10

# MAD Level 1 - Example

## Overview

### Requirements

The client needs a simple quiz that presents a picture and asks the user what kind of animal is displayed.

### Solution
Below you will find the necessary steps to build this app. If you encounter problems you
can always check [Github](https://github.com/Marcellis/MadLevel1Example) where you can find the whole solution.

**Resources:**
* For this example, a video recording is available.
In the recording, an expert performs the steps below. The recording can be found here:
[Mad level 1 Example video recording](https://www.youtube.com/watch?v=hzxYwad7cWw&feature=youtu.be)

## Create a new project
Duration: 0:30:00  

### Android Studio

Firstly, download and install [Android Studio](https://developer.android.com/studio)  

Once you have successfully downloaded and installed Android Studio you need to "Start a new Project":

- First steps
- Second step

Positive
: Exporting your codelab will create the html static files under the `codelabs/<name-of-codelab>` directory

🚀  Go ahead to the **Step 7** and add your codelabs on the main repo

### Emulator

The app needs to run either on an [emulator](https://developer.android.com/studio/run/emulator.html) or a real device. It is preferred to use a real device. To use a real device you will need to attach the device to your computer and configure the device for Android development. Instructions for this can be found [here](https://developer.android.com/studio/debug/dev-options).
This is the best option if you do not have a high spec machine to develop your code.
The emulator can be very slow but is a good option if you have a fast machine or don't have an Android device.

Run the app to check that it is working.

## Build the layout

### WIP
Duration: 0:20:00

``` xml
<string name="giraffe">Giraffe</string>
<string name="correct">Correct!</string>
<string name="incorrect">Incorrect, the correct answer is Giraffe!</string>
```

## Building the Activity
Duration: 0:30:00

### WIP

``` java
private lateinit var binding: ActivityMainBinding

override fun onCreate(savedInstanceState: Bundle?) {
   super.onCreate(savedInstanceState)
   binding = ActivityMainBinding.inflate(layoutInflater)
   setContentView(binding.root) // Sets the activity layout resource file.

   // Using the id given in the layout file you can access the component.
   // Set an action when the user clicks on the confirm button.
   binding.btnConfirm.setOnClickListener {
       checkAnswer()
   }
}
```
