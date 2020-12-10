author: HvA
summary: Mad Level 5 - Task 1
id: level5-task1
categories: Apps
tags: apps
status: Published
feedback link: https://github.com/pmeijer-hva/mad-codelabs/issues
analytics account: UA-180951198-1

# MAD Level 5 - Task 1

### Requirements

We will be building an app which acts as a notepad in which you write down notes. The following new subjects will be covered in this learning task:
- Architecture Components (ViewModel, LiveData)
- Room type converters
- Room pre-populate database

<img src="assets/level5task1.gif" width="265" height="450"/><br>

### Solution

Below you will find the necessary steps to build this app. If you encounter problems you can always
[check](https://github.com/Marcellis/MadLevel5Task1) where you can find the whole solution.

### Prerequisites

Before we start please do the following by yourself:
- Add the dependencies for `material widgets`, `room`, `viewmodel` and `livedata`.
- Build the layout for `NotepadFragment` and the `AddNoteFragment`
- Create a database, model and ui package.

## Create the database

In this step we will be implementing the Room database. We won’t be going into the details of Room because this has been covered in the previous level.
- Create an entity class `Note` which has the following variables:
    - title (String)
    - lastUpdated (Date)
    - text (String)
    - id (Long, PrimaryKey)
- Create a `NoteDao` interface which has methods for getting, updating and inserting a note. 
  The `getNotepad()` method should return a Note wrapped inside a LiveData object.
- Create a `NotepadRoomDatabase` class in which an instance of the database can be created.
- Create a `NoteRepository` class which has the implementation of the `NoteDao` and can update and get the note.

`NoteDao.kt`
```kotlin
@Dao
interface NoteDao {

   @Insert
   suspend fun insertNote(note: Note)

   @Query("SELECT * FROM NoteTable LIMIT 1")
   fun getNotepad(): LiveData<Note?>

   @Update
   suspend fun updateNote(note: Note)

}
```

`NotepadRoomDatabase.kt`
```kotlin
@Database(entities = [Note::class], version = 1, exportSchema = false)
abstract class NotepadRoomDatabase : RoomDatabase() {

   abstract fun noteDao(): NoteDao

   companion object {
       private const val DATABASE_NAME = "NOTEPAD_DATABASE"

       @Volatile
       private var INSTANCE: NotepadRoomDatabase? = null

       fun getDatabase(context: Context): NotepadRoomDatabase? {
           if (INSTANCE == null) {
               synchronized(NotepadRoomDatabase::class.java) {
                   if (INSTANCE == null) {
                       INSTANCE = Room.databaseBuilder(
                           context.applicationContext,
                           NotepadRoomDatabase::class.java, DATABASE_NAME
                       )
                           .fallbackToDestructiveMigration()
                           .build()
                   }
               }
           }
           return INSTANCE
       }
   }

}
```

`NoteRepository.kt`
```kotlin
class NoteRepository(context: Context) {

   private val noteDao: NoteDao

   init {
       val database = NotepadRoomDatabase.getDatabase(context)
       noteDao = database!!.noteDao()
   }

   fun getNotepad(): LiveData<Note?> {
       return noteDao.getNotepad()
   }

   suspend fun updateNotepad(note: Note) {
       noteDao.updateNote(note)
   }

}
```

A regular Room database is made with a dao and repository. The big difference is that we have changed the return type 
for the `getNotepad()` method to not return a `Note` but a Note wrapped inside a `LiveData object`.

When `Room` sees the return type to be `LiveData` it will automatically operate in a background thread. 
So we don’t have to use a `Coroutine` for this method.

`LiveData` is an observable data holder class. Whenever the data this class is holding is changed the `observers` will be notified.

The Query uses `LIMIT 1` so we will always only get one `Note` from the database. 
The `Note` wrapped inside the` LiveData object` is also made `nullable`.

## Extra Database Configuration

In learning task 2 of the previous level `TypeConverters` were briefly mentioned.
- Add a `typeconverter` for a `Date object`.

`TypeConverter.kt`
```kotlin
class Converters {
   @TypeConverter
   fun fromTimestamp(value: Long?): Date? {
       return value?.let { Date(it) }
   }

   @TypeConverter
   fun dateToTimestamp(date: Date?): Long? {
       return date?.time?.toLong()
   }
}
```

`NotepadRoomDatabase.kt`
```kotlin
@Database(entities = [Note::class], version = 1, exportSchema = false)
@TypeConverters(Converters::class)
abstract class NotepadRoomDatabase : RoomDatabase() {

...
```

Room cannot store object references in the database. For this reason `TypeConverters` exist. 
They convert an object type into a type that can be stored in the database (String, Int, Long etc.). 
Two methods are defined as for a type converter. One for forward conversion and one for backward conversion. 
We have defined one method for creating a `timestamp` from a Date object and one for creating a `Date object` from the timestamp. 
The timestamp is stored in the database and when the object is retrieved from the database the type converter will 
convert it back to a Date object. Using the `@TypeConverters` annotation the converters are added to the database.

In the app we want an empty `Note` to already be showing. For this reason we need to pre-populate the database with one `Note` when the database is created.
- Add a `callback` to the database builder and override the `onCreate`
- When the database is first created insert an empty `Note`.

`NotepadRoomDatabase.kt`
```kotlin
fun getDatabase(context: Context): NotepadRoomDatabase? {
   if (INSTANCE == null) {
       synchronized(NotepadRoomDatabase::class.java) {
           if (INSTANCE == null) {
               INSTANCE = Room.databaseBuilder(
                   context.applicationContext,
                   NotepadRoomDatabase::class.java, DATABASE_NAME
               )
                   .fallbackToDestructiveMigration()
                   .addCallback(object : RoomDatabase.Callback() {
                       override fun onCreate(db: SupportSQLiteDatabase) {
                           super.onCreate(db)
                           INSTANCE?.let { database ->
                               CoroutineScope(Dispatchers.IO).launch {
                                   database.noteDao().insertNote(Note("Title", Date(), ""))
                               }
                           }
                       }
                   })
                   .build()
           }
       }
   }
   return INSTANCE
}
```

A callback has been added to the database builder. This gets invoked when the database is built. 
Inside the callback the onCreate has been overridden because this only gets called when the database is created.

Using `let` we check if the `INSTANCE` is not null. If it’s not null then the Note is added using a `Coroutine` and the `noteDao`.

## NotepadFragment

In this step we will be building the functionalities of the `NotepadFragment`.

### Create the ViewModel

- Create a class `NoteViewmodel` which extends the `AndroidViewModel`.
- Add a `LiveData<Note?>` class variable and initialize is using `getNotepad()` from the repository.

`NoteViewModel.kt`
```kotlin
class NoteViewModel(application: Application) : AndroidViewModel(application) {
  
   private val noteRepository =  NoteRepository(application.applicationContext)

   val note = noteRepository.getNotepad()

}
```

The ViewModel for the `Note` entity/data class takes care of fetching the notepad from the repository and exposing 
it as a `LiveData object` which the `Fragment` can observe.

### Connect the activity to the ViewModel

Add the `NoteViewmodel` as a class variable to the `MainActivity` and initialize it.

`NotepadFragment.kt`
```kotlin
class NotepadFragment : Fragment() {

   private val viewModel: NoteViewModel by viewModels()

   override fun onCreateView(..) { .. }

   override fun onViewCreated(view: View, savedInstanceState:     Bundle?) {
       super.onViewCreated(view, savedInstanceState)

       observeAddNoteResult()
   }

   private fun observeAddNoteResult() {
      viewModel.note.observe(viewLifecycleOwner, Observer{ note ->
           note?.let {
               tvNoteTitle.text = it.title
               tvLastUpdated.text = getString(R.string.last_updated, it.lastUpdated.toString())
               tvNoteText.text = it.text
           }
       })
   }

}
```

A method `observeAddNoteResult()` made which will take care of initializing the viewmodels and setting up the observers.

The `Note` LiveData object is observed and whenever it changes the textviews title, last updated and text will be updated.

Positive
: Run the app and check that the note pre-populated in the database is shown.

## AddNoteFragment

In this step we will be implementing the features for the `AddNoteFragment`.

### Create the ViewModel

- Expand our `NoteViewModel` so that it can update the notepad using the repository.
- Create a Note object wrapped in `MutableLiveData`.
- Create an error String object wrapped in `MutableLiveData`.
- Create a success boolean wrapped in `MutableLiveData`.
- Create a method which validates a note.

`NoteViewModel.kt`
```kotlin
class NoteViewModel(application: Application) : AndroidViewModel(application) {

   private val noteRepository = NoteRepository(application.applicationContext)
   private val mainScope = CoroutineScope(Dispatchers.Main)

   val note = noteRepository.getNotepad()
   val error = MutableLiveData<String>()
   val success = MutableLiveData<Boolean>()

   fun updateNote(title: String, text: String) {

       //if there is an existing note, take that id to update it instead of adding a new one
       val newNote = Note(
           id = note.value?.id,
           title = title,
           lastUpdated = Date(),
           text = text
       )

       if(isNoteValid(newNote)) {
           mainScope.launch {
               withContext(Dispatchers.IO) {
                   noteRepository.updateNotepad(newNote)
               }
               success.value = true
           }
       }
   }

   private fun isNoteValid(note: Note): Boolean {
       return when {
           note.title.isBlank() -> {
               error.value = "Title must not be empty"
               false
           }
           else -> true
       }
   }
}
```

A ViewModel has been made which extends the AndroidViewModel class from the Architecture components.

In this class we use the type MutableLiveData which is a subtype of LiveData. Just as with val and var, LiveData is immutable and MutableLiveData is mutable. We have defined an error LiveData which the activity can observe and display an error message when an error occurred. The same is applied to the success boolean.

The method isNoteValid() validates if the note is valid according to our business rules (note must not be null and the title must not be empty). If either of those business rules is violated then the value of the error object is changed to the error and the UI will be triggered by that error.

The updateNote() method uses the isNoteValid() method to check if the note is valid. If the return type was true then it uses the noteRepository to update the note with newNote. Since our note MutableLiveData object is coupled to the repository it will update once the note has been updated in the database.

This class demonstrates how the business logic is moved to the ViewModel and the Fragment is notified by two pieces of livedata regarding the state of the data.

Positive
: opposed the previous step here we need to use the Main scope because a value from LiveData can’t be set in a background thread.

### Connect the ViewModel to the NotepadFragment

Connecting to the same viewModel:
- Again initialize a `viewModel` property, this one points to the same viewModel as the `NotepadFragment`
    - `Observe` the **Note** object from the `viewModel`. onChange it should populate the title and note input fields.
    - `Observe` the **error** object from the `ViewModel`. onChange it should display the error message in a Toast widget.
    - `Observe` the **success** object from the `viewModel`. onChange it should “pop the backstack” and bring us back to the `NotepadFragment`
- Create logic to handle the adding/editing of a Note:
    - When pressed **Save**, call the `updateNote(..)` method in the `viewModel` with the user input gathered from the view
    
`AddNoteFragment.kt`
```kotlin
class AddNoteFragment : Fragment() {

   private val viewModel: NoteViewModel by viewModels()

   override fun onCreateView(..) { .. }

   override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
       super.onViewCreated(view, savedInstanceState)

        btnSave.setOnClickListener {
           saveNote()
       }

       observeNote()
   }

   private fun observeNote() {
//fill the text fields with the current text and title from the viewmodel
viewModel.note.observe(viewLifecycleOwner, Observer { 
note  ->
           note?.let { 
   tilNoteTitle.editText?.setText(it.title)
   tilNoteText.editText?.setText(it.text)
           }

       })

viewModel.error.observe(viewLifecycleOwner, Observer { message ->
           Toast.makeText(activity, message, Toast.LENGTH_SHORT).show()
       })

viewModel.success.observe(viewLifecycleOwner, Observer {     success ->
           //"pop" the backstack, this means we destroy this    fragment and go back to the RemindersFragment
           findNavController().popBackStack()
       })
   }

   private fun saveNote() {
     viewModel.updateNote(tilNoteTitle.editText?.text.toString(), tilNoteText.editText?.text.toString())
   }
  
}
```

This Fragment is more complicated than the `NotepadFragment` because we have to deal with more business logic. Luckily, 
we moved most of this logic to the ViewModel.

When the save button is clicked we need to trigger the `viewModel` to update the note through the repository in the database.

When the validation logic is moved the the `ViewModel` the question arises of how the fragment will know when a task has 
been completed or if errors occurred. One way to solve this is by adding `MutableLiveData` objects to the `ViewModel` 
which hold the state (error, success). These objects are observed in the `NotepadFragment` and whenever an error 
value is changed the `observer` gets notified about it. If the error message is not null then we want to display it using a `Toast` message. 
The same applies for the success state. Whenever the Note has been updated successfully then we want to finish the activity. 
This could also be done for a loading state (displaying a loading circle when the Note is updated).

We also access the `viewModel` for the current Note so we can pre-fill the text fields with the title and text from that Note!

Positive
: All done Run the app, check if all the functionalities are working and push to your Github Repository








