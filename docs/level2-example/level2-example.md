author: HvA
summary: Mad Level 2 Example
id: level2-example
categories: Apps
tags: apps
status: Published
feedback link: https://github.com/pmeijer-hva/mad-codelabs/issues
analytics account: UA-180951198-1

# MAD Level 2 - Example

## Overview

### Requirements

In this example, we build an app that can be used to write down your reminders. 

### Solution
//TODO GIF FOTO

Below you will find the necessary steps to build this app. If you encounter problems you
can always check [Github](https://github.com/Marcellis/MadLevel2Example) where you can find the whole solution.

**Resources:**
* For this example, a video recording is available.
In the recording, an expert performs the steps below. The recording can be found here:
[Mad level 2 Example video recording](https://www.youtube.com/watch?v=bXmzfYzbnjA&feature=youtu.be)

### Setup a new project

Make sure ones you get started with this example the following steps were taken in advance: 

1. Select the ‘Empty Activity’
2. Name the ‘MadLevel2Example’
3. Choose language ‘Kotlin’
4. Choose API 23
5. Press finish getting started.

## Create the user interface
Duration: 0:20:00

### Activity_main.xml

Create the main activity layout file containing the code listed below 

``` xml
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:context=".MainActivity">

    <androidx.recyclerview.widget.RecyclerView
        android:id="@+id/rvReminders"
        android:layout_width="0dp"
        android:layout_height="0dp"
        app:layout_constraintBottom_toTopOf="@+id/llAddReminderGroup"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent" />

    <LinearLayout
        android:id="@+id/llAddReminderGroup"
        android:layout_width="0dp"
        android:layout_height="50dp"
        android:orientation="horizontal"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent">

        <EditText
            android:id="@+id/etReminder"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:ems="10"
            android:inputType="textPersonName"
            android:hint="@string/et_reminder" />

        <Button
            android:id="@+id/btnAddReminder"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:text="@string/btn_add_reminder" />

    </LinearLayout>
</androidx.constraintlayout.widget.ConstraintLayout>
```

The most important part in this layout, and the main topic in this exercise is the `RecyclerView` widget. 
A `RecyclerView` allows us to show a list of items in our Android apps. 

The `LinearLayout` component is used in this example to easily align our text input field 
next to our button.

//TODO VOEG AFBEELDING

The `RecyclerView` widget is `constrained` to fill the screen above the input field. The `RecyclerView`has been 
given the id: `rvReminders`. 

Our `Button` with id: `btnAddReminder` and our text input field with id: `etReminder` 
are contained inside a `LinearLayout`. This `LinearLayout` notably has the attribute `android:orientation="horizontal"` 
in order to have the input field and the button be next to each other.

### item_reminder.xml

After building  the User Interface using a `RecyclerView` (rvReminders as ID) and an `EditText` (etReminder as ID for the text input field), we 
need to create a layout file representing each item in our list. Define and create an `item_reminder.xml` layout file with one text field. 
The xml code can be found below.

``` xml
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="wrap_content">

    <TextView
        android:id="@+id/tvReminder"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent" />
</androidx.constraintlayout.widget.ConstraintLayout>
```

Positive
: This xml layout represents the list items of the recyclerview

## Create the data class
Duration: 0:10:00

### Reminder data class

Create a data class called `Reminder` which has a String representing the reminder.

``` kotlin
data class Reminder(
   var reminderText: String
)
```

A model has to be made representing the reminder String. In Kotlin, classes can be prefixed with `data`. 
This means that the main purpose is to hold data. The compiler will automatically create getters, setters, a toString and many more, 
so we don’t need to define them. For more information refer to this [link](https://kotlinlang.org/docs/reference/data-classes.html). 

In Kotlin we also don’t need to define a separate constructor if we define the variables in the class constructor. 
Kotlin automatically creates a constructor that initializes these variables for us.


## Create the adapter
Duration: 0:20:00

### Create a ReminderAdapter class

1. Create a `ReminderAdapter` class that will be used by the RecyclerView. 
2. Let the ReminderAdapter extend the `RecyclerView.Adapter<Reminderadapter.ViewHolder>`, add a list of Reminder objects in the class constructor and implement the methods. 
3. Create a `ViewHolder` with a bind method which binds the Reminder String to a TextView


Wire up the checkAnswer method to the Button widget by setting an OnClickListener to it.

``` kotlin
class ReminderAdapter(private val reminders: List<Reminder>) : RecyclerView.Adapter<ReminderAdapter.ViewHolder>(){

inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {

   val binding = ItemReminderBinding.bind(itemView)

   fun databind(reminder: Reminder) {
       binding.tvReminder.text = reminder.reminderText
       }
   }
}
```
For the recyclerview to know how and which items to display, an adapter needs to be created. Create a Kotlin class named `ReminderAdapter`. 

The RecyclerView recycles a set of ViewHolders. The views in the list are represented by ViewHolder objects. An inner class, called `ViewHolder`,
which extends `RecyclerView.ViewHolder` is the view holder for this Recyclerview. In the ViewHolder a reference to the TextView is made, 
and a bind method is created which is used to populate the widgets with data from the Reminder object. 
In our case, it sets the text from the TextView to the text from the Reminder String.

Positive
: Now, change the ReminderAdapter you have just written.

``` kotlin
/**
* Creates and returns a ViewHolder object, inflating a standard layout called simple_list_item_1.
*/
override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
   return ViewHolder(
       LayoutInflater.from(parent.context).inflate(R.layout.item_reminder, parent, false)
   )
}

/**
* Returns the size of the list
*/
override fun getItemCount(): Int {
   return reminders.size
}

/**
* Called by RecyclerView to display the data at the specified position.
*/
override fun onBindViewHolder(holder: ViewHolder, position: Int) {
   holder.databind(reminders[position])
}
```

In the class constructor, a variable called `reminders` is added. This is a List of Reminder objects which represent the reminders that should be displayed in the RecyclerView.

The `ReminderAdapter` extends `RecyclerView.Adapter<ReminderAdapter.ViewHolder>`. Here the ViewHolder that was created has been given as the ViewHolder type. 
Android Studio will prompt us to implement methods. The following methods are implemented:

- `onCreateViewHolder`: Called when RecyclerView needs a new RecyclerView.ViewHolder. Here a new ReminderAdapter.ViewHolder object is created using a LayoutInflater which inflates the layout resource file item_reminder.
- `getItemCount`: Returns the total number of items in the data set held by the adapter.
- `onBindViewHolder`: Called by RecyclerView to bind the data with the specified position. The bind method made in the previous step is used.


## Setting up the MainActivity
Duration: 0:30:00

In the MainActivity all the parts we created will come together. 
- Create and initialize an `ArrayList` of type Reminder.
- Create and initialize a `ReminderAdapter`.
- Within the `onCreate` function, initialize the binding.
 
``` kotlin
   private val reminders = arrayListOf<Reminder>()
   private val reminderAdapter = ReminderAdapter(reminders)
   // Don't forget to create a binding object as you did in previous assignments.
   private lateinit var binding: ActivityMainBinding
```

Using the Kotlin method `arrayListOf<Reminder>` an ArrayList of type Reminder is initialized. 
This list is given as a parameter when initializing the ReminderAdapter.

``` kotlin 
override fun onCreate(savedInstanceState: Bundle?) {
   super.onCreate(savedInstanceState)
   binding = ActivityMainBinding.inflate(layoutInflater)
   setContentView(binding.root)

   initViews()
}
```

A method called `initViews` is made which is going to be responsible for initializing the views on startup. 
This method is called in the onCreate.

### Setting up the RecyclerView

To initialize the RecyclerView:

- Create the initViews method called in onCreate before.
- Create an onClickListener associated with the button.
- Set the layout manager of the RecyclerView to a LinearLayoutManager.
- Set the Adapter of the RecyclerView to the ReminderAdapter.
- Set the ItemDecoration to a DividerItemDecoration.

``` kotlin 
private fun initViews() {
   // Create an onClickListener associated with the button
   binding.btnAddReminder.setOnClickListener {
      val reminder = binding.etReminder.text.toString()
      addReminder(reminder)
   }

   // Initialize the recycler view with a linear layout manager, adapter
   binding.rvReminders.layoutManager = LinearLayoutManager(this@MainActivity, RecyclerView.VERTICAL, false)
   binding.rvReminders.adapter = reminderAdapter
   binding.rvReminders.addItemDecoration(DividerItemDecoration(this@MainActivity, DividerItemDecoration.VERTICAL))

}
```

Within the initViews method a `layoutManager` is added to the Recyclerview of type `LinearLayoutManager` 
which defines that our RecyclerView will be Linear (e.g. if you want a grid layout a `GridLayoutManager` is used). 
The `reminderAdapter` is also added. An `itemDecoration` is also added, 
the `dividerItemDecoration` adds a line under each item in the RecyclerView to separate them, giving a better user experience.

### Implementing Add reminder

Having done this, the recyclerview is all set. But it’s still empty because we don’t have any reminders yet. Create the functionality of adding reminders.
- Create a method called `addReminder(reminder: String)`
- In addReminder check if the String is not empty. Display a `SnackBar message` if it is.
- In addReminder add a new `Reminder object` to the reminders ArrayList.
- In addReminder notify the adapter that the dataset has changed. 
- Last be not least clear the inputfield.

Below the code to add to the addReminder method.

``` kotlin 
// addReminder method
private fun addReminder(reminder: String) {
   if (reminder.isNotBlank()) {
       reminders.add(Reminder(reminder))
       reminderAdapter.notifyDataSetChanged()
       binding.etReminder.text?.clear()
   } else {
       Snackbar.make(etReminder, "You must fill in the input field!", Snackbar.LENGTH_SHORT).show()
   }
}
```

Using the Kotlin method `isNotBlank` it is verified that the String is not null or empty. 
A SnackBar message is displayed if it’s empty to notify the user that you can’t add empty reminders.

If the reminder is valid a Reminder object is created using the String and it is added to the reminders ArrayList. 
Because the list has been updated the adapter needs to be notified that the dataset has changed so it can refresh itself. 
This is done using `reminderAdapter.notifyDataSetChanged()`. Using `etReminder.text?.clear()` the input field has been cleared.

Note the use of the `?` mark. This means that the variable `etReminder.text` is optional. With `?` it can be the null object or have a value; 
if it is null nothing happens and the next statement is executed. With `!`, if the value is the null object, the program crashes.

In the `initViews` method where the `onClickListener` for the `FloatingActionButton` has been moved to, 
the `addReminder` method is invoked using the text from the inputField which is retrieved using `etReminder.text.toString()`. 

Positive
: 
    - Note in order to support Snackbar make sure that “implementation 'com.google.android.material:material:1.1.0'” is added as dependency in build.gradle (Module: app).
    - Test if the app works and reminders are added to the user interface.

## Swipe to delete
Duration: 0:20:00

The last step of this app is to add the functionality of `removing` a reminder from the list by swiping it to the left.
- Create a method called `createItemTouchHelper` and create an `ItemTouchHelper object`.
- Implement the `ItemTouchHelper.SimpleCallBack` methods and let `onMove` return true and `onSwiped` should remove the item from the list and update the adapter.

``` kotlin 
/**
* Create a touch helper to recognize when a user swipes an item from a recycler view.
* An ItemTouchHelper enables touch behavior (like swipe and move) on each ViewHolder,
* and uses callbacks to signal when a user is performing these actions.
*/
private fun createItemTouchHelper(): ItemTouchHelper {

   // Callback which is used to create the ItemTouch helper. Only enables left swipe.
   // Use ItemTouchHelper.SimpleCallback(0, ItemTouchHelper.LEFT or ItemTouchHelper.RIGHT) to also enable right swipe.
   val callback = object : ItemTouchHelper.SimpleCallback(0, ItemTouchHelper.LEFT) {

       // Enables or Disables the ability to move items up and down.
       override fun onMove(
           recyclerView: RecyclerView,
           viewHolder: RecyclerView.ViewHolder,
           target: RecyclerView.ViewHolder
       ): Boolean {
           return false
       }

       // Callback triggered when a user swiped an item.
       override fun onSwiped(viewHolder: RecyclerView.ViewHolder, direction: Int) {
           val position = viewHolder.adapterPosition
           reminders.removeAt(position)
           reminderAdapter.notifyDataSetChanged()
       }
   }
   return ItemTouchHelper(callback)
}
```
Positive
: An ItemTouchHelper is used to enable the swiping of items from a RecyclerView. A method called createItemTouchHelper is created which returns an ItemTouchHelper.

An `ItemTouchHelper` is created using an `ItemTouchHelper.SimpleCallBack` interface. 
The implementation is stored in a variable called `callback`. 

The SimpleCallback parameters given define that we only want this callback to be done when a user swipes to the left (0, ItemTouchHelper.LEFT). 
The callback implements two methods:
- `onMove`: Called when `ItemTouchHelper` wants to move the dragged item from its old position to the new position. 
- `onSwiped`: Called when a `ViewHolder` is swiped by the user. 

For the onMove method simply return false because we don’t implement this functionality. For the onSwiped method, 
the position of the viewholder in the adapter needs to be found using `viewHolder.adapterPosition`, 
after which the object needs to be removed from the reminders list, and lastly, 
the `reminderAdapter` needs to be notified that the data set has changed.

Positive
: The last step is to attach the ItemTouchHelper to the recyclerView, do this in the initViews method.

``` kotlin
   createItemTouchHelper().attachToRecyclerView(rvReminders)
```

`ItemTouchHelper` has a method called `attachToRecyclerView` which is used to attach the ItemTouchHelper to the `rvReminders` RecyclerView.

Congratulations🎉, you completed your first recyclerview application!

Now push the app to GitHub.