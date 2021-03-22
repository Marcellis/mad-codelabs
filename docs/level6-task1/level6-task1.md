author: HvA
summary: Mad Level 6 - Task 1
id: level6-task1
categories: Apps
tags: apps
status: Published
feedback link: https://github.com/pmeijer-hva/mad-codelabs/issues
analytics account: UA-180951198-1

# MAD Level 6 - Task 1

## Overview

### Requirements

In the second learning task of this level an app is going to be made where a recyclerview of coloured images is
displayed from the web. When an image is clicked then the name of the color is displayed in a snackbar message. The
following new subjects will be covered in this learning task:

- Adding a click listener for each item in a recyclerview.
- Using [Glide](https://bumptech.github.io/glide/int/about.html) to display images from the web.

<img src="assets/level6task1.gif" width="265" height="450"/><br>

### Solution

Below you will find the necessary steps to build this app. If you encounter problems you can always check
the [github](https://github.com/Marcellis/MadLevel6task1) where you can find the whole solution.

## Setting up the project

### Setup the ColorFragment

Make a new project via the Basic Activity template. As with the example, we will use only fragment within this project
so you can remove the `SecondFragment` with the associated navigation and layout xml. Rename the `FirstFragment` to
`ColorFragment`, also rename the corresponding xml properly.

### Add libraries

- Add the necessary dependencies for Architecture Components. You can reuse most of the dependencies from the example.
  Apply plugin kotlin-kapt.
- Add the necessary dependencies for [Glide](https://bumptech.github.io/glide/int/about.html).
- Add Internet Permission to the android manifest and `android:usesCleartextTraffic="true"`

`app:build.gradle`

```kotlin
apply plugin: 'kotlin-kapt'
```

`app:build.gradle`

```kotlin
// Glide
implementation 'com.github.bumptech.glide:glide:4.11.0'
kapt 'com.github.bumptech.glide:compiler:4.11.0'
```

`AndroidManifest.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
          xmlns:tools="http://schemas.android.com/tools"
          package="nl.hva.level6task1">

    <uses-permission android:name="android.permission.INTERNET"/>

    <application
            android:usesCleartextTraffic="true"
            android:allowBackup="true"
            android:icon="@mipmap/ic_launcher"
            android:label="@string/app_name"
            android:roundIcon="@mipmap/ic_launcher_round"
            android:supportsRtl="true"
            android:theme="@style/AppTheme"
            tools:ignore="GoogleAppIndexingWarning">
        <activity
                android:name=".MainActivity"
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

In this learning task we won’t be needing Retrofit because we will only be dealing with image urls from the web. An
ImageView can’t load an image directly from an url. For loading images into an ImageView *Glide* will be used. This is
an image loading library.

Positive
: Do not forget to add view binding

## Create the ColorItem data class

- Create a data class named `ColorItem`
- Add the variable *hex* (String) and *name* (String)
- Add a method which returns an image url of the hex color from [singlecolor](http://www.singlecolorimage.com/)

`ColorItem.kt`

```kotlin
data class ColorItem(
        var hex: String,
        var name: String
) {
    fun getImageUrl() = "http://singlecolorimage.com/get/$hex/1080x1080"
}
```

We are using `http://www.singlecolorimage.com/` to generate image urls of the specified hex color. The method
`getImageUrl()` returns an image url of the hex color in `1080x1080` format.

## Create the recyclerview

- Add a recyclerview in `fragment_color.xml` and name it `rvColors`.
- Create `item_color.xml` layout for the recyclerview items. The item has an ImageView of width match parent and height
  200dp. Name the imageView `ivColor`.
- Create the `ColorAdapter`. In the `bind` method of the ViewHolder use `Glide` to load the image url into the
  ImageView.

`ColorAdapter.kt`

```kotlin
class ColorAdapter(private val colors: List<ColorItem>) :
        RecyclerView.Adapter<ColorAdapter.ViewHolder>() {

    private lateinit var context: Context

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        context = parent.context

        return ViewHolder(
                LayoutInflater.from(context).inflate(R.layout.item_color, parent, false)
        )
    }

    override fun getItemCount(): Int = colors.size

    override fun onBindViewHolder(holder: ViewHolder, position: Int) = holder.bind(colors[position])

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        fun bind(colorItem: ColorItem) {
            Glide.with(context).load(colorItem.getImageUrl()).into(itemView.ivColor)
        }
    }

}

```

A regular adapter has been made as learning in level 2. With Glide the image is loaded into the ImageView named ivColor.
Using `Glide.with(context)` the methods of Glide can be accessed. Using the `load(colorItem.getImageUrl())` Glide is
being told to load this image. Using `into(itemView.ivColor)` Glide will load the image into the imageView specified
there. There are many possibilities with Glide. For example you could override the dimensions of the loaded image before
loading it into the ImageView. For more information on Glide refer to
this [link](https://github.com/codepath/android_guides/wiki/Displaying-Images-with-the-Glide-Library#advanced-usage)

## Add Click Listeners to the items

- Add a constructor variable called *onClick* of type `(ColorItem)` -> `Unit`
- In the *init* method of the *ViewHolder* set an onclick listener to the itemView which invoked the onClick variable

`ColorAdapter.kt`

```kotlin

class ColorAdapter(private val colors: List<ColorItem>, private val onClick: (ColorItem) -> Unit) :
        RecyclerView.Adapter<ColorAdapter.ViewHolder>() {

    private lateinit var context: Context

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        context = parent.context

        return ViewHolder(
                LayoutInflater.from(context).inflate(R.layout.item_color, parent, false)
        )
    }

    override fun getItemCount(): Int = colors.size

    override fun onBindViewHolder(holder: ViewHolder, position: Int) = holder.bind(colors[position])

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        init {
            itemView.setOnClickListener { onClick(colors[adapterPosition]) }
        }

        private val binding = ItemColorBinding.bind(itemView)

        fun bind(colorItem: ColorItem) {
            Glide.with(context).load(colorItem.getImageUrl()).into(binding.ivColor)
        }
    }

}
```

In Kotlin it’s possible to pass methods as variables to other methods. The `Unit` type corresponds to the `void` type in
Java. This means we have added a parameter in the constructor which is a method that has a ColorItem parameter.
Essentially we have to pass the following method when constructing the ColorAdapter:

```kotlin
fun onClick(colorItem: ColorItem) {

}
```

When a ViewHolder is initialized we have defined an OnClickListener to the itemView. This means that the OnClickListener
is bound to the entire item. If you have multiple buttons in an Item then you should be setting the OnClickListener to
these buttons of the item. When the item has been clicked then the `onClick(colorItem: ColorItem)` is invoked with the
`ColorItem` of the `colors` list using the `adapterPosition`.

Passing methods to other methods are called `Higher-Order functions` for more information refer to
this [link](https://kotlinlang.org/docs/reference/lambdas.html#higher-order-functions-and-lambdas)

## ColorFragment

- In the `ColorFragment` initialize the recyclerview as learned from level 2.
- In the `ColorFragment` create a method `onColorClick(colorItem: ColorItem)` which displays a `Snackbar` message with
  the color name.
- When initializing the `ColorAdapter` we pass our colors and an `onColorClick` high-order-function via the :: notation

`ColorFragment.kt`

```kotlin
class ColorFragment : Fragment() {
    private val colors = arrayListOf<ColorItem>()
    private lateinit var colorAdapter: ColorAdapter
    private val viewModel: ColorViewModel by viewModels()
    private var _binding: FragmentColorBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
            inflater: LayoutInflater,
            container: ViewGroup?,
            savedInstanceState: Bundle?
    ): View {
        _binding = FragmentColorBinding.inflate(inflater, container, false)

        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        colorAdapter = ColorAdapter(colors, ::onColorClick)
        binding.rvColors.layoutManager = LinearLayoutManager(activity, RecyclerView.VERTICAL, false)
        binding.rvColors.adapter = colorAdapter

    }

    private fun onColorClick(colorItem: ColorItem) {
        Snackbar.make(binding.rvColors, "This color is: ${colorItem.name}", Snackbar.LENGTH_LONG)
                .show()
    }
}

```

## Populating the recyclerview

In this step the data will be added to the recyclerview using the architecture learned in level 5.

### Repository

- Create a ColorRepository which has a method getColorItems() which returns an arraylist of the following colors:
    - 000000 (black)
    - FF0000 (red)
    - 0000FF (blue)
    - FFFF00 (yellow)
    - 008000 (green)

`ColorRepository.kt`

```kotlin
class ColorRepository {
    fun getColorItems(): List<ColorItem> {
        return arrayListOf(
                ColorItem("000000", "Black"),
                ColorItem("FF0000", "Red"),
                ColorItem("0000FF", "Blue"),
                ColorItem("FFFF00", "Yellow"),
                ColorItem("008000", "Green")
        )
    }
}
```

The `ColorRepository` will be used for generating a list of predefined `ColorItems` using the method `getColorItems()`

### ViewModel

- Create a `ColorViewModel`
- Add a `colorItems` variable of type `MutableLiveData<List<ColorItem>>` and populate it using the `getColorItems()`
  method from the `ColorRepository`

`ColorViewModel.kt`

```kotlin
class ColorViewModel : ViewModel() {
    private val colorRepository = ColorRepository()

    //use encapsulation to expose as LiveData
    val colorItems: LiveData<List<ColorItem>>
        get() = _colorItems

    private val _colorItems = MutableLiveData<List<ColorItem>>().apply {
        value = colorRepository.getColorItems()
    }
}
```

In the ViewModel the `ColorRepository` is initialized and the value of the `colorItems` variable is set using the list
returned from `getColorItems()`.

### Observe in ColorFragment

- Get a reference to the view model
- Observe the `colorItems` and in the Observer callback add the items to the colors list and notify the adapter about
  the data changes.

`ColorFragment.kt`

```kotlin
 private fun observeColors() {
    viewModel.colorItems.observe(viewLifecycleOwner, {
        colors.clear()
        colors.addAll(it)
        colorAdapter.notifyDataSetChanged()
    })
}
```

Call `observeColors()` in the `onViewCreated()` and initialize the view model as property.

When the `colorItems` are there then the colors list is populated.

*Note*: in order to get colors full width of the device, you should add to the ivColor imageView item:

`item_color.xml`

```xml
android:scaleType="centerCrop"
```

Positive
: Run the app. You should be able to click on the colors and get the color name displayed as a Snackbar message. Push
the app to your GitLab repository.


