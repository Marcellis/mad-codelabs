author: HvA
summary: Mad Level 4 Example
id: level4-example
categories: Apps
tags: apps
status: Published
feedback link: https://github.com/pmeijer-hva/mad-codelabs/issues
analytics account: UA-180951198-1

# MAD Level 4 - Example

## Overview

### Requirements

When a user saves reminders, the reminder will be gone when the app is reopened. We need to store the reminders in a local database. 

### Solution 

In this course you will find the necessary steps to build this app. If you encounter problems you can always check 
[github](https://github.com/Marcellis/MadLevel4Example) where you can find the whole solution (and XML layout files for this course).

The starting point is the result of the level 3 demo.

### Configuration and Build

To save data in a local database we need to use the Room library. Check this 
[link](https://developer.android.com/jetpack/androidx/releases/room#declaring_dependencies) on how to add Room to your project.

On this page it is noted that we should also add the `kapt` plugin into the project. This is done by applying the 
`kotlin-kapt` Gradle plugin into the `app/build.gradle` file. Below the addition can be found. 

```kotlin
apply plugin: 'com.android.application'

apply plugin: 'kotlin-android'

apply plugin: 'kotlin-android-extensions'

apply plugin: 'kotlin-kapt'

...
```

Also the following dependencies should be added to the `app/build.gradle`.

```kotlin
// Room
def room_version = "2.2.5"
kapt "androidx.room:room-compiler:$room_version"
implementation "androidx.room:room-runtime:$room_version"

// Kotlin Extensions and Coroutines support for Room - also needed in this tutorial
  implementation "androidx.room:room-ktx:$room_version"
```

Positive
: More info about kapt can be found [here](https://kotlinlang.org/docs/reference/kapt.html).


## Implementing and configuring the Room database

In this step we will be implementing and configuring the room database with the Reminder object.

### Modify Reminder data class

We need to provide the class with the necessary annotation so that `Room` knows where and how to store the objects:
- Add an `Entity` annotation at the top of the class and define the table name with `“reminderTable”`.
- Add an `id` and mark it as a primary key with the `@PrimaryKey` annotation.
- Add a column name for the `id` and the `reminderText` using the `@ColumnInfo` annotation.

```kotlin 
@Entity(tableName = "reminderTable")
data class Reminder(

   @ColumnInfo(name = "reminder")
   var reminderText: String,

   @PrimaryKey(autoGenerate = true)
   @ColumnInfo(name = "id")
   var id: Long? = null

) 
```

`Room` uses annotations to define configurations for persisting the objects in its database. 

Using the annotation `@Entity` we have defined that this is an entity that needs to be stored in the database. 
Using `tableName` we provide Room with a tableName we want to store this entity in. By default it will use the name of the object (`Reminder`).

As you may know databases need a primary key. We want room to auto generate the id. 
It’s also marked as nullable with the question mark so that it’s optional in the constructor.

Using the `@ColumnInfo` annotation we can define aspects of the column. We only give it a name. 
By default it would have used the name of the variable so in this case we could’ve just used `@ColumnInfo` instead of `@ColumnInfo(name = “reminder”)`

Room creates an `SQLite` database using all objects annotated with `@Entity`. 

### Create the Reminder Data Access Object (DAO)

To get access to the Room database we are using a `DAO`.
- Create an interface `ReminderDao`. Annotate it with `@Dao`.
- Add a method `getAllReminders` and annotate it with `@Query`.
- Add a method `insertReminder` and annotate it with `@Insert`.
- Add a method `deleteReminder` and annotate it with `@Delete`.
- Add a method `updateReminder` and annotate it with `@Update`.

```kotlin
@Dao
interface ReminderDao {

   @Query("SELECT * FROM reminderTable")
   fun getAllReminders(): List<Reminder>

   @Insert
   fun insertReminder(reminder: Reminder)

   @Delete
   fun deleteReminder(reminder: Reminder)

   @Update
   fun updateReminder(reminder: Reminder)

}
```
To access your app's data using the [Room persistence library](https://developer.android.com/training/data-storage/room/index.html), 
you work with data access objects, or `DAOs`. This set of [Dao](https://developer.android.com/reference/androidx/room/Dao.html) 
objects forms the main component of Room, as each DAO includes methods that offer abstract access to your app's database.
By accessing a database using a DAO class instead of query builders or direct queries, you can separate different components of your database architecture.

A `Dao` can either be an `interface` or an `abstract class`.

Room also provides some convenient annotations for `CRUD` (create, read, update, delete) operations which we used. 
You can also create queries using the `@Query` annotation. We used this to retrieve all reminders from the database.

Room will take this interface and implement all the methods for you.

### Creating the Database

In this step we will create the class that will wire everything up and creates/manages the database.

- Create a public abstract class that `extends` `RoomDatabase` and call it `ReminderRoomDatabase`.
- Annotate the class to be a `RoomDatabase()`, declare the entities that belong in the database and set the version number. 
  Listing the entities will create tables in the database.
- Define the `DAOs` that work with the database. Provide an abstract "getter" method for each `@Dao`.
- Make the `ReminderRoomDatabase` a singleton.
- Add the code to get a database using `RoomDatabase.Builder`. 
- Refer to this [link](https://developer.android.com/training/data-storage/room).

```kotlin
@Database(entities = [Reminder::class], version = 1, exportSchema = false)
abstract class ReminderRoomDatabase : RoomDatabase() {

   abstract fun reminderDao(): ReminderDao
  
   companion object {
       private const val DATABASE_NAME = "REMINDER_DATABASE"

       @Volatile
       private var reminderRoomDatabaseInstance: ReminderRoomDatabase? = null

       fun getDatabase(context: Context): ReminderRoomDatabase? {
           if (reminderRoomDatabaseInstance == null) {
               synchronized(ReminderRoomDatabase::class.java) {
                   if (reminderRoomDatabaseInstance == null) {
                       reminderRoomDatabaseInstance = Room.databaseBuilder(
                           context.applicationContext,
                           ReminderRoomDatabase::class.java, DATABASE_NAME
                       )
                           .allowMainThreadQueries()
                           .build()
                   }
               }
           }
           return reminderRoomDatabaseInstance
       }
   }

}
```

The code block seems complicated to let’s break things down.

We start by annotating the class with `@Database` which tells room that this class is a `RoomDatabase`. 
Here we also define the entities that we want to store in this database (we only want to store Reminder entities). 

An abstract method for getting the implementation room makes sure that  the `reminderDao` is added to the class.

Because we want the database to be static we encapsulate the getDatabase function within a `companion object`. 
If you need a function, or a property to be tied to a class rather than to instances of it (similar to `@staticmethod` in Python), 
you can declare it inside a companion object.

The Kotlin language does **not** have the keyword static, hence the introduction of 
[companion object](https://kotlinlang.org/docs/tutorials/kotlin-for-py/objects-and-companion-objects.html#companion-objects). 
Companion objects are also used in Google’s codelabs on [Room](https://codelabs.developers.google.com/codelabs/android-room-with-a-view-kotlin/#6).

Note that in this case the constant `DATABASE_NAME` is also defined inside the companion object rather than at the top level as we did before.

Inside `getDatabase` the `ReminderRoomDatabase` is created using `Room.databaseBuilder`. This is where we define the database name. 

For instantiating the database we use a `Singleton` pattern because creation of a RoomDatabase we only want one instance of the database.

###  Creating the Reminder Repository

The last step of setting up our database is by making a Repository class.
- Create a class called `ReminderRepository`.
- Create and initialize a `ReminderDao` variable.
- Create method implementations of the `reminderDao` methods (`getAllReminders()` returns `reminderDao.getAllReminders()`).

```kotlin
class ReminderRepository(context: Context) {

    private var reminderDao: ReminderDao

    init {
        val reminderRoomDatabase = ReminderRoomDatabase.getDatabase(context)
        reminderDao = reminderRoomDatabase!!.reminderDao()
    }

    fun getAllReminders(): List<Reminder> {
        return reminderDao.getAllReminders()
    }

    fun insertReminder(reminder: Reminder) {
        reminderDao.insertReminder(reminder)
    }

    fun deleteReminder(reminder: Reminder) {
        reminderDao.deleteReminder(reminder)
    }

    fun updateReminder(reminder: Reminder) {
        reminderDao.updateReminder(reminder)
    }
}
```

The last step is to create a repository class which is responsible for using the `DAO` to make operations on the database. 
This prevents us from having to create and initialize the dao objects in the activity classes using the `getDatabase` 
method all the time. We just need to create a repository class now.

The class constructor takes a `Context` object because we need this to access the database. The `reminderDao` is constructed 
using the abstract method we added in the `ReminderRoomDatabase` class.

The methods will use the `reminderDao` methods to make the actual operations. For example `insertReminder` will insert a 
reminder in the database using the `reminderDao.insertReminder()` method.

## Modifying ReminderFragment

Now that the database has been set up and configured properly we can make some changes in the `ReminderFragment` so that 
it uses the database for retrieving and storing the data.

### Get reminders from the database
- Create and initialize a `ReminderRepository` object as an instance variable
- Create a method `getRemindersFromDatabase()` which gets the reminders from the database and updates the list.
- Call this method on startup.

```kotlin
class RemindersFragment : Fragment() {

  private var _binding: FragmentRemindersBinding? = null
  private val binding get() = _binding!!

  private lateinit var reminderRepository: ReminderRepository

  private val reminders = arrayListOf<Reminder>()
  private val reminderAdapter = ReminderAdapter(reminders)

  override fun onCreateView(
    inflater: LayoutInflater, container: ViewGroup?,
    savedInstanceState: Bundle?
  ): View {
    _binding = FragmentRemindersBinding.inflate(inflater, container, false)
    return binding.root
  }

  override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
    super.onViewCreated(view, savedInstanceState)

    initViews()

    observeAddReminderResult()

    reminderRepository = ReminderRepository(requireContext())
    getRemindersFromDatabase()
  }

  override fun onDestroy() {
    super.onDestroy()
    _binding = null
  }

  private fun getRemindersFromDatabase() {
      val reminders = reminderRepository.getAllReminders()
      this@RemindersFragment.reminders.clear()
      this@RemindersFragment.reminders.addAll(reminders)
      reminderAdapter.notifyDataSetChanged()
    }
  }

  ...
}
```

A method called `getRemindersFromDatabase()` is made which will get all the reminders from the database using the repository, 
clear the current reminders list, add the reminders from the database and notifies the adapter that the data set was changed.

When the user starts the app we need to get the reminders from the database and populate the recyclerview with those reminders. 
This is done after initializing the recyclerview.

### Insert reminder into database

- Modify `onActivityResult` to use the repository to insert the reminder into the database.
- After inserting the reminder refresh the dataset by calling `getRemindersFromDatabase()`

```kotlin
private fun observeAddReminderResult() {
   setFragmentResultListener(REQ_REMINDER_KEY) { key, bundle ->
      bundle.getString(BUNDLE_REMINDER_KEY)?.let {
           val reminder = Reminder(it)

           // reminders.add(reminder)
           // reminderAdapter.notifyDataSetChanged()
           reminderRepository.insertReminder(reminder)
           getRemindersFromDatabase() 
       } ?: Log.e("ReminderFragment", "Request triggered, but empty reminder text!")

   }
}
```

In the `observeAddReminderResult()` we no longer need to add the reminder to the list and notify the adapter about the dataset changes because now we use the `reminderRepository.inserReminder()` method. Which inserts the reminder in the database and then call `getRemindersFromDatabase()` to refresh the dataset.

### Delete reminder from database

- Modify the `onSwiped` method from the `ItemTouchHelper` to **remove** the reminder from the database and refresh the list.

```kotlin
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
           // reminders.removeAt(position)
           // reminderAdapter.notifyDataSetChanged()

           val reminderToDelete = reminders[position]
           reminderRepository.deleteReminder(reminderToDelete)
           getRemindersFromDatabase()
       }
   }
   return ItemTouchHelper(callback)
}
```

In `onSwiped()` the reminder is deleted from the database after which the reminders are loaded from the database again to update the user interface.

Positive
: Run the app! Add or remove a reminder, and it will be persisted in the database! Close and re-open the app to check if the reminders are persisted.

## Performing database operations on the background thread

In this step we move the database operations from the main (ui) thread to a background thread.

### Remove allowing main thread queries

- In `ReminderRoomDatabase` remove `.allowMainThreadQueries()` from the builder.

```kotlin
fun getDatabase(context: Context): ReminderRoomDatabase? {
   if (reminderRoomDatabaseInstance == null) {
       synchronized(ReminderRoomDatabase::class.java) {
           if (reminderRoomDatabaseInstance == null) {
               reminderRoomDatabaseInstance = Room.databaseBuilder(
                   context.applicationContext,
                   ReminderRoomDatabase::class.java, DATABASE_NAME
               )
                   .allowMainThreadQueries()
                   .build()
           }
       }
   }
   return reminderRoomDatabaseInstance
}
```
By allowing the queries to be performed on the main thread we will face serious performance issues once the database queries increase in length.

When a query is performed on the main thread then the user interface will stop working until the query is finished. 
In other words the screen will freeze for 3 seconds if the query takes 3 seconds. Enabling this was only meant 
for purposes of going through the basics of Room in the previous steps of this tutorial. **Never allow this in a finished app**.

### Modify Dao and Repository

- Add the `suspend` keyword to the methods.

```kotlin
@Dao
interface ReminderDao {

   @Query("SELECT * FROM reminderTable")
   suspend fun getAllReminders(): List<Reminder>

   @Insert
   suspend fun insertReminder(reminder: Reminder)

   @Delete
   suspend fun deleteReminder(reminder: Reminder)

   @Update
   suspend fun updateReminder(reminder: Reminder)

}
```

By adding the `suspend` keyword to the method we have specified that this method cannot be called without using `Coroutines`.

You should notice that in the activities where we call the methods from the repositories Android Studio will give errors stating: 
“Suspend function `getAllReminders` should be called only from a coroutine or another suspend function”

```kotlin
public class ReminderRepository(context: Context) {

   private var reminderDao: ReminderDao

   init {
       val reminderRoomDatabase = ReminderRoomDatabase.getDatabase(context)
       reminderDao = reminderRoomDatabase!!.reminderDao()
   }

   suspend fun getAllReminders(): List<Reminder> {
       return reminderDao.getAllReminders()
   }

   suspend fun insertReminder(reminder: Reminder) {
       reminderDao.insertReminder(reminder)
   }

   suspend fun deleteReminder(reminder: Reminder) {
       reminderDao.deleteReminder(reminder)
   }

   suspend fun updateReminder(reminder: Reminder) {
       reminderDao.updateReminder(reminder)
   }
}
```
### Moving the method calls into background threads

In RemindersFragment change the following functions:
- `getRemindersFromDatabase()`  to first get all the reminders from the IO thread and then update the list on the ui thread.
- `onSwiped()` to delete a reminder on the IO thread and then update the list on the ui thread.
- `observeAddReminderResult()` to do database operations on the IO thread 

```kotlin
private fun getRemindersFromDatabase() {
   CoroutineScope(Dispatchers.Main).launch {
       val reminders = withContext(Dispatchers.IO) {
           reminderRepository.getAllReminders()
       }
       this@RemindersFragment.reminders.clear()
       this@RemindersFragment.reminders.addAll(reminders)
       reminderAdapter.notifyDataSetChanged()
   }
}
```

Let’s start by explaining what exactly is a **coroutine**. One can think of a coroutine as a light-weight thread. 
Like threads, coroutines can run in parallel, wait for each other and communicate. The biggest difference is that coroutines are very cheap, 
almost free: we can create thousands of them, and pay very little in terms of performance. True threads, on the other hand, 
are expensive to start and keep around. A thousand threads can be a serious challenge for a modern machine.

```kotlin
// Callback triggered when a user swiped an item.
override fun onSwiped(viewHolder: RecyclerView.ViewHolder, direction: Int) {
   val position = viewHolder.adapterPosition
   val reminderToDelete = reminders[position]

   CoroutineScope(Dispatchers.Main).launch {
       withContext(Dispatchers.IO) {
           reminderRepository.deleteReminder(reminderToDelete)
       }
       getRemindersFromDatabase()
   }
}
```

In Kotlin, all coroutines must run in a dispatcher — even when they’re running on the main thread. 
To specify where the coroutines should run, Kotlin provides three 
[Dispatchers](https://kotlin.github.io/kotlinx.coroutines/kotlinx-coroutines-core/kotlinx.coroutines/-coroutine-dispatcher/) 
you can use. The dispatchers being:
- `Dispatchers.Main`: Main thread on Android, interact with the UI and perform light work.
- `Dispatchers.IO`: Optimized for disk and network IO.
- `Dispatchers.Default`: Optimized for CPU intensive work.

Because we are doing database operations we are going to be needing the IO dispatcher. For updating the user interface
we will be using the Main dispatcher.

In `getRemindersFromDatabase()` the background operations are started using the Main dispatcher with the `launch` method 
from `CoroutineScope`. Now the reminders are being queried using the IO dispatcher. Because this is a different dispatcher 
we need to use `withContext`. When the reminders have been received from the database we can resume on the main thread 
to populate the reminders list and notify the adapter about the data set changes.

```kotlin
private fun observeAddReminderResult() {
   setFragmentResultListener(REQ_REMINDER_KEY) { key, bundle ->
       bundle.getString(BUNDLE_REMINDER_KEY)?.let {
           val reminder = Reminder(it)

           CoroutineScope(Dispatchers.Main).launch {
               withContext(Dispatchers.IO) {
                   reminderRepository.insertReminder(reminder)
               }
               getRemindersFromDatabase()
           }
       } ?: Log.e("ReminderFragment", "Request triggered, but empty reminder text!")

   }
}
```

In `onSwiped()` we do the same thing. The coroutine is started using `launch` from a `CoroutineScope` object and passing 
through the dispatcher we want to use. Then in the IO thread the reminder is deleted after which the 
`getRemindersFromDatabase()` is called to update the recyclerview.

The `observeAddReminderResult()` method also had to be modified because here the reminder is saved. All of the logic 
has been moved within a `CoroutineScope` using the Main dispatcher. And the inserting of the reminder has been moved inside a IO dispatcher. 

The reason why we have to start all the Coroutines inside a Main dispatcher is because it’s not possible to modify the user interface within an IO thread.  

Positive
: All done, test your app and push it to github! 