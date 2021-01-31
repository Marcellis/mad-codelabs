author: HvA
summary: MAD Level 4 - Task 2
id: level4-task2
tags: apps
categories: Apps
status: Published
feedback link: https://github.com/pmeijer-hva/mad-codelabs/issues
analytics account: UA-180951198-1

# MAD Level 4 - Task 2

## Overview

### What we are building

<img src="assets/level4task2.gif" width="265" height="450"/>

### Requirements

We need to build an app in which you can play rock, paper, scissors with the computer. 
The app has the following requirements:

- Let the user select out three images to make their move (rock , paper, scissors).
- When a user has made their move it’s visualized which move they made and which move the computer made.
- The result (win, lose, draw) is displayed.
    - Every game played is stored in a Room database. A game consists of:
    - Date at which the game was played.
    - Which move the computer made.
    - Which move the player made.
    - The result of the game (win, lose, draw).
- The game history should be displayed.
- The user should be able to clear the game history.

The images used can be downloaded from this [link](https://docs.google.com/uc?export=download&id=1tQ1l5_LyIVqytaVXUc874FIMMjeEKxxR).

The end result should look something like this (**note** statistics are optional, see the extra section):

### Tips

Storing object references in Room is not possible. So if you want to use enums, or a `Date` object in the `Game` entity class 
you will be needing `TypeConverters`, the following link has some good documentation and even an example using a 
`Date` object on how to use [TypeConverters](https://developer.android.com/training/data-storage/room/referencing-data) 

### Solution

Now, you are on your own. There is no solution provided. Good Luck!
Push the app to your GitLab Repository.

### Optional

As seen in the example images there are statistics displayed of how many wins, draws and losses the user has. 
Whenever a user plays, the statistics should be updated. 
When the game history is cleared then the statistics should also be cleared. 
With the `@Query` annotation you can make all sorts of queries on the database. 
This is the preferred method of getting the statistics (**tip**: using a select count query).



