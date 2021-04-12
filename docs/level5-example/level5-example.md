author: HvA
summary: Mad Level 5 Example
id: level5-example
categories: Apps
tags: apps
status: Published
feedback link: https://github.com/pmeijer-hva/mad-codelabs/issues
analytics account: UA-180951198-1

# MAD Level 5 - Example

## Overview

### Requirements

We need to refactor the reminders app to use the Android Architecture Components. 
This will make for a better quality codebase. The following new subjects will be covered in 
this learning task:
- Android Architecture Components (ViewModel, LiveData)

### Solution

Below you will find the necessary steps to build this app. If you encounter problems you can always 
check the [github](https://github.com/Marcellis/MadLevel5Example)  where you can find the whole solution.

The starting point is the result of the level 4 demo.

### Video recording

For this example, a video recording is available. In the recording, an expert performs the steps below. 
The recording can be found here: 
[Mad level 5 Example video recording](https://www.youtube.com/watch?v=UKa2e2e0hLo&feature=youtu.be)

## Creating the ReminderViewModel

In this step we will be going through the steps of modifying the `MainActivity` to use a `ViewModel`

### Modifying the DAO and Repository to return LiveData

In the `DAO` and `repository` remove the `suspend` keyword and change the type to `LiveData<List<Reminder>>`

``` kotlin
@Dao
interface ReminderDao {

    @Query("SELECT * FROM reminderTable")
    fun getAllReminders(): LiveData<List<Reminder>>

    @Insert
    suspend fun insertReminder(reminder: Reminder)

    @Delete
    suspend fun deleteReminder(reminder: Reminder)

    @Update
    suspend fun updateReminder(reminder: Reminder)

}
```
``` kotlin
cclass ReminderRepository(context: Context) {

    private var reminderDao: ReminderDao

    init {
        val reminderRoomDatabase = ReminderRoomDatabase.getDatabase(context)
        reminderDao = reminderRoomDatabase!!.reminderDao()
    }

    fun getAllReminders() : LiveData<List<Reminder>> {
        return reminderDao?.getAllReminders()
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

When a Room method returns a `LiveData` object then Room generates all the necessary 
code to update the `LiveData` object when a database is updated. The generated code runs the query `asynchronously` 
on a background thread when needed. This is the reason why we should remove the `suspend` keyword because we won’t be 
needing `Coroutines` for this method anymore since it’s already running on a background thread. 

### Creating ReminderViewModel

- Create a class `ReminderViewModel` which extends `AndroidViewModel`.
- Add a reminders object of type `LiveData` which has the list of reminders from the repository.
- Make the class be able to insert and delete reminder using a method.

``` kotlin
class ReminderViewModel(application: Application) : AndroidViewModel(application) {

   private val ioScope = CoroutineScope(Dispatchers.IO)
   private val reminderRepository = ReminderRepository(application.applicationContext)

   val reminders: LiveData<List<Reminder>> = reminderRepository.getAllReminders()

   fun insertReminder(reminder: Reminder) {
       ioScope.launch {
           reminderRepository.insertReminder(reminder)
       }
   }

   fun deleteReminder(reminder: Reminder) {
       ioScope.launch {
           reminderRepository.deleteReminder(reminder)
       }
   }

}
```

A `ViewModel` has been made for the `MainActivity`. The logic that does not concern the user interface 
has been moved to this class. This way we have separated the concerns of ui logic and business logic from each other.

We also don’t need the `Dispatcher.Main` scope anymore because in the `ViewModel` we don’t have any user interface logic.

### Connect the ReminderViewModel with the MainActivity

- Use the by `viewModels()` helper method to create and initialize a class variable of `ReminderViewModel`.
- `observeAddReminderResult` should observe the reminders `LiveData object` from the `viewModel`. 
  Whenever the `LiveData object` changes the `recyclerview` should be updated.
- Deleting and inserting a reminder should use the `insertReminder` and `deleteReminder` method from the `viewModel`
- Remove the code from the `ReminderFragment` that was moved to the viewModel (repository, coroutines, getRemindersFromDatabase).

```kotlin
class RemindersFragment : Fragment() {
   private var _binding: FragmentRemindersBinding? = null
   private val binding get() = _binding!!

   //private lateinit var reminderRepository: ReminderRepository

   private val reminders = arrayListOf<Reminder>()
   private val reminderAdapter = ReminderAdapter(reminders)

   private val viewModel: ReminderViewModel by viewModels()

   override fun onCreateView(
           inflater: LayoutInflater, container: ViewGroup?,
           savedInstanceState: Bundle?
   ): View? {
      _binding = FragmentRemindersBinding.inflate(inflater, container, false)
      return binding.root
   }

   override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
      super.onViewCreated(view, savedInstanceState)
      initViews()
      observeAddReminderResult()
      //reminderRepository = ReminderRepository(requireContext())
      //getRemindersFromDatabase()
   }
   /*private fun getRemindersFromDatabase() {
       CoroutineScope(Dispatchers.Main).launch {
           val localReminders = withContext(Dispatchers.IO) {
               reminderRepository.getAllReminders()
           }
           this@RemindersFragment.reminders.clear()
           this@RemindersFragment.reminders.addAll(localReminders)
           reminderAdapter.notifyDataSetChanged()
       }
   }*/
   private fun initViews() {
      // Initialize the recycler view with a linear layout manager, adapter
      binding.rvReminders.layoutManager =
              LinearLayoutManager(context, RecyclerView.VERTICAL, false)
      binding.rvReminders.adapter = reminderAdapter
      createItemTouchHelper().attachToRecyclerView(binding.rvReminders)
   }

   override fun onDestroyView() {
      super.onDestroyView()
      _binding = null
   }
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
            //  reminders.removeAt(position)
            // reminderAdapter.notifyDataSetChanged()
            val reminderToDelete = reminders[position]
            /*CoroutineScope(Dispatchers.Main).launch {
                withContext(Dispatchers.IO) {
                    reminderRepository.deleteReminder(reminderToDelete)
                }
                getRemindersFromDatabase()
            }*/
            viewModel.deleteReminder(reminderToDelete)
         }
      }
      return ItemTouchHelper(callback)
   }
   private fun observeAddReminderResult() {
      viewModel.reminders.observe(viewLifecycleOwner, Observer { reminders ->
         this@RemindersFragment.reminders.clear()
         this@RemindersFragment.reminders.addAll(reminders)
         reminderAdapter.notifyDataSetChanged()
      })
   }
   /*private fun observeAddReminderResult() {
       setFragmentResultListener(REQ_REMINDER_KEY) { _, bundle ->
           bundle.getString(BUNDLE_REMINDER_KEY)?.let {
               val reminder = Reminder(it)
            //   reminders.add(reminder)
             //  reminderAdapter.notifyDataSetChanged()
               CoroutineScope(Dispatchers.Main).launch {
                   withContext(Dispatchers.IO) {
                       reminderRepository.insertReminder(reminder)
                   }
                   getRemindersFromDatabase()
               }
           } ?: Log.e("ReminderFragment", "Request triggered, but empty reminder text!")
       }
   }*/
}
```

In short four things were changed. Let’s summarize them:
- A `ReminderViewModel` object has been added to the class
- A method called `observeViewModel()` has been made which contains the `observer` to the `LiveData` reminders object from the `ViewModel`
- `onSwiped(..)` has been changed to use the ViewModel `deleteReminder` method
- Adding a reminder has been changed to use the ViewModel `insertReminder` method.

1. ViewModels are initialized using the `viewModels()` helper method from the `activity-ktx artifact`. 
Using this will let the Architecture Components initialize the ViewModel for us, which also makes it able to be lifecycle aware.

2. `LiveData` is observed using the `observe` method. Whenever the `LiveData` data changes then this `Observer` will get invoked. 
   Whenever the reminders list changes from the LiveData we want to update the `recyclerview`.

3. `Inserting` and `deleting` a reminder has been changed to use the newly made methods from the ViewModel. 
   Because the viewmodel now takes care of all repository operations the `ReminderRepository` class variable can be removed. 
   All repository interactions have now been moved to the viewmodel layer.

4. You can also see we’re not listening for a `fragmentResult` anymore. Later on in the `AddReminderFragment` we can directly 
   insert the reminder into the viewmodel. The `observeAddReminderResult` will observe a new value and when navigating back 
   from the `AddReminderFragment` we will have the new reminder in our list!
   
## Update the AddReminderFragment

Within this part we will be updating the AddreminderFragment to accommodate our newly added architecture components

First we have to make an instance of the `ReminderViewModel` here, this is the same instance as we’re using in the `RemindersFragment`. 
The by `viewModels()` method takes care of this.

Then in `onAddReminder()` we won’t set a `fragmentResult` anymore. As mentioned in the previous step we can directly insert 
the reminder into the viewmodel! The `RemindersFragment`, which is still on the backstack but just not visible, 
will be updated straight away. When we navigate back we always have the latest data in place! 
It doesn’t matter where it’s modified, as long as it goes through the viewmodel.

```kotlin
//const val REQ_REMINDER_KEY = "req_reminder"
//const val BUNDLE_REMINDER_KEY = "bundle_reminder"

class AddReminderFragment : Fragment() {

    private var _binding: FragmentAddReminderBinding? = null
    private val binding get() = _binding!!

    private val viewModel: ReminderViewModel by viewModels()

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentAddReminderBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        binding.btnAddReminder.setOnClickListener {
            onAddReminder()
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }

    private fun onAddReminder() {
        val reminderText = binding.etReminderName.text.toString()

        if (reminderText.isNotBlank()) {
            //set the data as fragmentResult, we are listening for REQ_REMINDER_KEY in RemindersFragment!
           // setFragmentResult(REQ_REMINDER_KEY, bundleOf(Pair(BUNDLE_REMINDER_KEY, reminderText)))
            viewModel.insertReminder(Reminder(reminderText))
            //"pop" the backstack, this means we destroy
            //this fragment and go back to the RemindersFragment
            findNavController().popBackStack()

        } else {
            Toast.makeText(
                activity,
                R.string.not_valid_reminder, Toast.LENGTH_SHORT
            ).show()
        }
    }
}

Positive
: All done Run the app and push to your GitLab Repository