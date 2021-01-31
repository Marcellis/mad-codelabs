author: HvA
summary: Mad Level 6 Example
id: level6-example
categories: Apps
tags: apps
status: Published
feedback link: https://github.com/pmeijer-hva/mad-codelabs/issues
analytics account: UA-180951198-1

# MAD Level 6 - Example

## Overview

### Requirements

We are going to build an app based on [numbersapi](http://numbersapi.com) where a random number is displayed with a fact
about that number. The following new subjects will be covered in this learning task:

- Connect to a REST api using Retrofit

See the GIF below for the end result. The GIF shows the error state first with no internet available. Make sure to test
this in your app as well!

<img src="assets/level6-example.gif" width="265" height="450"/><br>

### Solution

Below you will find the necessary steps to build this app. If you encounter problems you can always check
the [github](https://github.com/Marcellis/MadLevel6Example) where you can find the whole solution.

### Prerequisites

- Choose “Basic Activity” to the project
- Create a new project in Android Studio. Name it Mad Level 6 Example
- Choose API 23.
- Add View binding

## Set up a new project

### Set up the TriviaFragment

We’re dropping the reminders example from this level. Make a new project via the Basic Activity template. We will only
use one fragment(embedded in Activity) within this project so you can remove the `SecondFragment`
with the associated navigation and layout xml. Rename the `FirstFragment` to `TriviaFragment`, also rename the
corresponding xml properly. The last steps in this tutorial will cover the fragment and activity code, so you can leave
it as blank as possible.

### Dependencies

- Add the necessary dependencies for [Retrofit](https://square.github.io/retrofit/)  and
  the [OkHttp](https://square.github.io/okhttp/)
  libraries to `app:build.gradle`.
- Add Internet Permission to the android manifest.

`app:build.gradle`

```kotlin
...
compileOptions {
    sourceCompatibility JavaVersion . VERSION_1_8
            targetCompatibility JavaVersion . VERSION_1_8
}
...

```

`app:build.gradle`

```kotlin
// Retrofit
implementation 'com.squareup.retrofit2:retrofit:2.8.1'
implementation 'com.squareup.retrofit2:converter-gson:2.8.1'
implementation 'com.squareup.okhttp3:okhttp:4.4.0'
implementation 'com.squareup.okhttp3:logging-interceptor:4.4.0'
```

`AndroidManifest.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
          xmlns:tools="http://schemas.android.com/tools" package="com.example.numberskotlin">

    <uses-permission android:name="android.permission.INTERNET"/>

    <application
            android:usesCleartextTraffic="true"
            android:allowBackup="true"
            android:icon="@mipmap/ic_launcher"
            android:label="@string/app_name"
            android:roundIcon="@mipmap/ic_launcher_round"
            android:supportsRtl="true"
            android:theme="@style/AppTheme" tools:ignore="GoogleAppIndexingWarning,UnusedAttribute">
        <activity
                android:name=".ui.MainActivity"
                android:label="@string/app_name"
                android:theme="@style/AppTheme.NoActionBar">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>

                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>

</manifest>
```

In this tutorial, we are building an app that communicates with an external api. To do this we will be using the
Retrofit library. We also use the Gson Converter to parse a json response into an object and the other way around. For
logging purposes, we use the OkHttp Logging Interceptor. With this all in and outgoing communication with the api will
be logged.

## Create the Trivia object

Build a data class which has text, number, found and type variables.

```kotlin
data class Trivia(
        @SerializedName("text") var text: String,
        @SerializedName("number") var number: Int,
        @SerializedName("found") var found: Boolean,
        @SerializedName("type") var type: String
)
```

The REST service we are going to use is called Numbers API and can be found at [numbersapi](http://numbersapi.com). If
you take a look at the API reference you’ll see that they offer various services but we are only interested in the
random trivia option.

The GET request we will be using is `http://numbersapi.com/random/trivia?json` This will return a json object with the
following fields:

- text (the trivia)
- number (the random number)
- found (boolean if the number is found, in our case this is always true)
- type (the type of request, in our case trivia)

`Gson` will serialize the variables using the variable name, in our case this is fine because our variable names have
the same name as the response from the numbers api. But if the api would return, for example, a snake_cased variable and
in Java we use the camelCase notation then you can use `@SerializedName` to indicate that the snake_cased variable can
be serialized into the camelCased variable.

Tip: You can try using `https://www.json2kotlin.com/` to generate a data class using the raw json response
from `http://numbersapi.com/random/trivia?json`

## Create the layout

The layout for this assignment is simple, so that we can focus on learning `Retrofit`. The `fragment_trivia.xml` is
given:
`fragment_trivia.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout
        xmlns:android="http://schemas.android.com/apk/res/android"
        xmlns:tools="http://schemas.android.com/tools"
        xmlns:app="http://schemas.android.com/apk/res-auto"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        app:layout_behavior="@string/appbar_scrolling_view_behavior"
        tools:showIn="@layout/activity_main">

    <TextView
            android:id="@+id/tvTitle"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_marginStart="16dp"
            android:layout_marginTop="16dp"
            android:layout_marginEnd="16dp"
            android:text="@string/instructions"
            android:textSize="16sp"
            app:layout_constraintEnd_toEndOf="parent"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintTop_toTopOf="parent"/>

    <TextView
            android:id="@+id/tvTriviaTitle"
            style="@style/TextAppearance.MaterialComponents.Headline3"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_marginBottom="8dp"
            android:layout_marginStart="16dp"
            android:layout_marginEnd="16dp"
            android:gravity="center"
            android:text="@string/trivia"
            android:textSize="40sp"
            android:textStyle="bold"
            app:layout_constraintBottom_toBottomOf="parent"
            app:layout_constraintBottom_toTopOf="@id/tvTrivia"
            app:layout_constraintEnd_toEndOf="parent"
            app:layout_constraintStart_toStartOf="parent"/>

    <TextView
            android:id="@+id/tvTrivia"
            android:layout_width="0dp"
            android:layout_marginStart="16dp"
            android:layout_marginEnd="16dp"
            android:layout_height="wrap_content"
            android:textSize="20sp"
            android:gravity="center"
            app:layout_constraintEnd_toEndOf="parent"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintBottom_toBottomOf="parent"
            app:layout_constraintTop_toTopOf="parent"/>

</androidx.constraintlayout.widget.ConstraintLayout>
```

`string.xml`

```xml

<string name="instructions">Instructions: click the button to get a random number trivia</string>
<string name="trivia">Trivia</string>
```

## Connect to the Trivia API

In this step we will be creating the class which will connect to the Api and returns a Trivia object.

### The Retrofit Service Class

- Create an interface named `TriviaApiService`
- Add a method called `getRandomNumberTrivia()` which returns `Trivia` object
- Annotate the method with `@GET(“/random/trivia?json”)`

`TriviaApiService.kt`

```kotlin
interface TriviaApiService {

    // The GET method needed to retrieve a random number trivia.
    @GET("/random/trivia?json")
    suspend fun getRandomNumberTrivia(): Trivia
}
```

Retrofit needs a service class with the endpoints of the api. The methods in this interface need to be annotated with
the annotation from Retrofit. The random trivia request is a GET request so the method is annotated with `@GET` and then
we give it the relative link to the endpoint.

The method returns a class of type `Trivia`. A so called `CallAdapter`, which is included by default, will wrap this
object so that kotlin coroutines can work with it. You can also see the familiar `suspend` keyword. Retrofit has
coroutines support since version 2.6.0.

### The Trivia Api class

- Make a class named `TriviaApi`
- Add a companion object and place a *const val* named *baseUrl* and a method `createApi()` which returns
  a `NumbersApiService` object type.

`TriviaApi.kt`

```kotlin
class TriviaApi {
    companion object {
        // The base url off the api.
        private const val baseUrl = "http://numbersapi.com/"

        /**
         * @return [TriviaApiService] The service class off the retrofit client.
         */
        fun createApi(): TriviaApiService {
            // Create an OkHttpClient to be able to make a log of the network traffic
            val okHttpClient = OkHttpClient.Builder()
                    .addInterceptor(HttpLoggingInterceptor().setLevel(HttpLoggingInterceptor.Level.BODY))
                    .build()

            // Create the Retrofit instance
            val triviaApi = Retrofit.Builder()
                    .baseUrl(baseUrl)
                    .client(okHttpClient)
                    .addConverterFactory(GsonConverterFactory.create())
                    .build()

            // Return the Retrofit NumbersApiService
            return triviaApi.create(TriviaApiService::class.java)
        }
    }
}
```

A method named `createApi()` has been made. It’s inside a companion object so it will be statically accessible to all
classes. Using `TriviaApi.createApi()` will return a Retrofit client of `TriviaApiService`.

The `TriviaApiService` is made using a *Retrofit Builder*. This will create a retrofit implementation of the interface
we had made one step earlier. In this Builder the base urls is set, an okHttp client is set for logging and a converter
factory is added to convert the json response into a data class.

### Create the Repository

Create a `TriviaRepository` class which will simply return the Call from the `TriviaApiService`.

`TriviaRepository.kt`

```kotlin
class TriviaRepository {
    private val triviaApiService: TriviaApiService = TriviaApi.createApi()

    private val _trivia: MutableLiveData<Trivia> = MutableLiveData()

    /**
     * Expose non MutableLiveData via getter
     * Encapsulation :)
     */
    val trivia: LiveData<Trivia>
        get() = _trivia

    /**
     * suspend function that calls a suspend function from the numbersApi call
     */
    suspend fun getRandomNumberTrivia() {
        try {
            //timeout the request after 5 seconds
            val result = withTimeout(5_000) {
                triviaApiService.getRandomNumberTrivia()
            }

            _trivia.value = result
        } catch (error: Throwable) {
            throw TriviaRefreshError("Unable to refresh trivia", error)
        }
    }

    class TriviaRefreshError(message: String, cause: Throwable) : Throwable(message, cause)

}
```

Our repository is the hub from the view to the network layer. In here we do the following things:

- We expose a trivia LiveData object following the encapsulation principle. We should only be able to modify a
  `MutableLiveData` object type *within* this class. We expose a regular LiveData via a getter.

- Via the supendable function `getRandomNumberTrivia()` we interact with the `triviaApiService`. If there is an error,
  for example no internet or an unparsable JSON response, we will catch that in here and throw our
  own `TriviaRefreshError`. The viewmodel can later on expose a user friendly error to a corresponding Fragment or
  Activity. In the future you can expand this class with more specific Throwables. For example a `NoInternetError` or
  a `ParseError`.

### Create the ViewModel

- Create a `TriviaViewModel` which has two `MutableLiveData` variables, one for an error and one for the success
  containing the `Trivia` object returned from the api. It follows the same principles for encapsulation as in the
  repository.
- Add a method `getTriviaNumber()` which makes the request in a `coroutines` way.

`TriviaViewModel.kt`

```kotlin
class TriviaViewModel(application: Application) : AndroidViewModel(application) {
    private val triviaRepository = TriviaRepository()

    /**
     * This property points direct to the LiveData in the repository, that value
     * get's updated when user clicks FAB. This happens through the refreshNumber() in this class :)
     */
    val trivia = triviaRepository.trivia

    private val _errorText: MutableLiveData<String> = MutableLiveData()

    /**
     * Expose non MutableLiveData via getter
     * errorText can be observed from Activity for error showing
     * Encapsulation :)
     */
    val errorText: LiveData<String>
        get() = _errorText

    /**
     * The viewModelScope is bound to Dispatchers.Main and will automatically be cancelled when the ViewModel is cleared.
     * Extension method of lifecycle-viewmodel-ktx library
     */
    fun getTriviaNumber() {
        viewModelScope.launch {
            try {
                //the triviaRepository sets it's own livedata property
                //our own trivia property points to this one
                triviaRepository.getRandomNumberTrivia()
            } catch (error: TriviaRepository.TriviaRefreshError) {
                _errorText.value = error.message
                Log.e("Triva error", error.cause.toString())
            }
        }
    }
}
```

The `TriviaViewModel` contains two pieces of LiveData. One to emit the success Trivia result and one to emit a potential
errorText. Later on we will observe these in the `TriviaFragment`.

The `getTriviaNumber()` method will use a `viewModelScope`(see comments in code) to call the `getRandomNumberTrivia()`
method in the repository. If the repository manages to retrieve the data from the network layer successfully
the `trivia`
property will be set automatically with that piece of LiveData:

```kotlin
val trivia = triviaRepository.trivia

```

If an error is thrown(`TriviaRefreshError`)  we will update the errorText LiveData String with a user friendly error.

## MainActivity

`MainActivity.kt`

```kotlin
class MainActivity : AppCompatActivity() {
    private val viewModel: TriviaViewModel by viewModels()
    private lateinit var binding: ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        val view = binding.root
        setContentView(view)
        setSupportActionBar(binding.toolbar)

        binding.fab.setOnClickListener {
            viewModel.getTriviaNumber()
        }
    }

    ..
}
```

The MainActivity contains the `FAB`. Ideally we would kick off the retrieval of a Trivia in the fragment and also
observe that value in that same fragment. Unfortunately we can’t do that because the FAB belongs to the activity. Here
is where ViewModel comes to the rescue. We can share the `TriviaViewModel` between as many activities and fragment as we
like by simply initializing it via the by `viewModels()` helper method.

So inside the `onCreate(..)` we set a clickListener and only call `viewModel.getTriviaNumber()`. In the next step we
will make the fragment which will then observe the triva and errorText LiveData objects!

- `MainActivity` → kicks off retrieval of Trivia
- `TriviaFragment`(next step) → observes the result, either a successful or error result
- `TriviaViewModel` → Shared viewmodel instance between fragment and activity

## TriviaFragment

The `TriviaFragment` is embedded inside the MainActivity and is our only fragment within this application. You can set
up the `nav_graph.xml` the exact same way as our reminder application but without the `AddReminderFragment`.

`TriviaFragment.kt`

```kotlin
class TriviaFragment : Fragment() {

    private val viewModel: TriviaViewModel by activityViewModels()
    private var _binding: FragmentTriviaBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
            inflater: LayoutInflater,
            container: ViewGroup?,
            savedInstanceState: Bundle?
    ): View {
        _binding = FragmentTriviaBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        observeTrivia()
    }

    private fun observeTrivia() {
        viewModel.trivia.observe(viewLifecycleOwner, {
            binding.tvTrivia.text = it?.text
        })

        // Observe the error message.
        viewModel.errorText.observe(viewLifecycleOwner, {
            Toast.makeText(activity, it, Toast.LENGTH_SHORT).show()
        })
    }
}
```

We start with adding a reference to the view model. We do it a bit different than in previous levels, we are using the
by `activityViewModels()` helper here. If we use the regular by `viewModels()` helper it won’t be in sync with the
activity.

Furthermore down below we observe the `trivia` LiveData for a successful result and the errorText LiveData for a
potential
`errorText` result.

That’s it, how clean does this Fragment look?! We’ve spread all the responsibilities over the different layers in our
app.

Positive
: Now run the app, make sure to test the error state by turning off your internet in the emulator(see GIF). If
everything is working push to your GitLab repository