author: HvA
summary: Mad Level 2 - Task 1
id: level2-task1
categories: Apps
tags: apps
status: Published
feedback link: https://github.com/pmeijer-hva/mad-codelabs/issues
analytics account: UA-180951198-1

# MAD Level 2 - Task 1

## Overview

### Requirements

We need to build an app to make up a list of places. 

// GIF Not working correctly 
<img src="assets/test.gif" width="265" height="450"/><br>

### Solution

If you encounter problems you can always check [Marcellis/MadLevel2Task1](https://github.com/Marcellis/MadLevel2Task1/blob/master/app/src/main/java/com/example/madlevel2task1/PlaceAdapter.kt) for the whole solution.

### Setup a new project

Make sure ones you get started with this example the following steps were taken in advance: 

1. Select the ‘Empty Activity’
2. Name the ‘MadLevel2Task1’
3. Choose language ‘Kotlin’
4. Choose API 23
5. Press finish getting started.

## Setting up the Model and Adapter

### Create a place model

Create a new data class and call it `Place`. A place has a name and an image resource id.

``` kotlin
data class Place(
   var name: String,
   @DrawableRes var imageResId: Int
)
```

This class will be the data model for each object that will be shown in the RecyclerView. 
The `imageResId` has been annotated with `@DrawableRes` which indicates to Android 
we expect this variable to be a Drawable Resource Id.

Add two static arrays using a companion object. The arrays should contain the names of the places and the drawable resources for those places.

``` kotlin
data class Place(
   var name: String,
   @DrawableRes var imageResId: Int
) {
   companion object {
       val PLACE_NAMES = arrayOf(
           "Amsterdam Dam",
           "Amsterdam Weesperplein",
           "Rotterdam Euromast",
           "Den Haag Binnenhof",
           "Utrecht Dom",
           "Groningen Martinitoren",
           "Maastricht Vrijthof",
           "New York Vrijheidsbeeld",
           "San Francisco Golden Gate",
           "Yellowstone Old Faithful",
           "Yosemite Half Dome",
           "Washington White House",
           "Ottawa Parliament Hill",
           "Londen Tower Bridge",
           "Brussel Manneken Pis",
           "Berlijn Reichstag",
           "Parijs Eiffeltoren",
           "Barcelona Sagrada Familia",
           "Rome Colosseum",
           "Pompeii",
           "Kopenhagen",
           "Oslo",
           "Stockholm",
           "Helsinki",
           "Moskou Rode Plein",
           "Beijing Verboden Stad",
           "Kaapstad Tafelberg",
           "Rio de Janeiro Copacabana",
           "Sydney Opera",
           "Hawaii Honolulu",
           "Alaska Denali"
       )

       val PLACE_RES_DRAWABLE_IDS = arrayOf(
           R.drawable.amsterdam_dam,
           R.drawable.amsterdam_weesperplein,
           R.drawable.rotterdam_euromast,
           R.drawable.den_haag_binnenhof,
           R.drawable.utrecht_dom,
           R.drawable.groningen_martinitoren,
           R.drawable.maastricht_vrijthof,
           R.drawable.new_york_vrijheidsbeeld,
           R.drawable.san_francisco_golden_gate,
           R.drawable.yellowstone_old_faithful,
           R.drawable.yosemite_half_dome,
           R.drawable.washington_white_house,
           R.drawable.ottawa_parliament_hill,
           R.drawable.london_tower_bridge,
           R.drawable.brussel_manneken_pis,
           R.drawable.berlijn_reichstag,
           R.drawable.parijs_eiffeltoren,
           R.drawable.barcelona_sagrada_familia,
           R.drawable.rome_colosseum,
           R.drawable.pompeii,
           R.drawable.kopenhagen,
           R.drawable.oslo,
           R.drawable.stockholm,
           R.drawable.helsinki,
           R.drawable.moskou_rode_plein,
           R.drawable.beijing_verboden_stad,
           R.drawable.kaapstad_tafelberg,
           R.drawable.rio_de_janeiro_copacabana,
           R.drawable.sydney_opera,
           R.drawable.hawaii,
           R.drawable.alaska_denali
       )
   }
}
```
Positive
: In Kotlin arrays are defined using arrayOf() and static types are defined within a companion object. [More info](https://kotlinlang.org/docs/tutorials/kotlin-for-py/objects-and-companion-objects.html) 

## Creating a cell layout

Create a new XML layout file in the layout directory of your `res` directory, 
call it `item_place`. Add a `TextView` and an `ImageView` which represents a single item within the `RecyclerView`.
This layout file will be used for each item within the RecyclerView. 
It has a `TextView` which displays the name of the place and below it holds an `ImageView` which displays the image of the place. 
The ImageView has the property `android:scaleType=”centerCrop”` for better visuals.

``` xml
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:paddingStart="4dp"
    android:paddingEnd="4dp">

    <TextView
        android:id="@+id/tvPlace"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:padding="8dp"
        android:text="TextView"
        android:textAlignment="center"
        android:textSize="24sp"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent" />

    <ImageView
        android:id="@+id/ivPlace"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:scaleType="centerCrop"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@+id/tvPlace"
        tools:srcCompat="@tools:sample/avatars" />
</androidx.constraintlayout.widget.ConstraintLayout>
```

## Creating a PlaceAdapter

- Create a class called `PlaceAdapter`. 
- Add an `inner class` ViewHolder
- Within the ViewHolder `bind` the image and name to the ImageView and TextView using kotlin synthetics.  
- Add an `ArrayList` of type `Place` to the class constructor.
- Let the `PlaceAdapter` extend `RecyclerView.ViewHolder` and implement the methods.

## Setting up the MainActivity

The last thing we need to do before we can run our app is to wire the adapter to the RecyclerView in the MainActivity.
- Create and initialize a `ArrayList` of Place object and a PlaceAdapter
- Create a method called `initViews` and call it in the onCreate of the MainActivity
- In initViews set the layout manager (StaggeredGridLayoutManager) and adapter of the RecyclerView. 

Populate the places list and notify the data set has changed using the next code:

```kotlin 
  for (i in Place.PLACE_NAMES.indices) {
        places.add(Place(Place.PLACE_NAMES[i],        
        Place.PLACE_RES_DRAWABLE_IDS[i]))
  }
  placeAdapter.notifyDataSetChanged()
```

The `places` list will be initialized using a for-loop over the `PLACE_NAMES` array. 
After the `ArrayList` has been populated the adapter will be notified(`notifyDataSetChanged()`) that the data set has been changed.

For more information on Kotlin for-loops please reference the following [link](https://kotlinlang.org/docs/reference/control-flow.html#for-loops)

Positive
: Don’t forget to implement **ViewBinding** as you have done in previous assignments! 

Congratulations🎉, you completed your second recyclerview application!

Push the App to Github! 