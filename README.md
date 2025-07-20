# LJ Engine - Godot
Welcome to the LJ Engine Godot repository.

This is just a fun side project for me to learn 2D godot and wrap my head around some FNF Concept ideas implemented into Godot.

### You are more than welcome to make Pull Requests and Issues.

## Current State
Here is all that I have gotten to work so far:

1. ImagesToSpriteFrames.gd
- currently no GUI but in the script all it does is convert your Image and XML from Flixel FNF to a `.tres` file with the images embedded inside it, and with the animations. You can look at the `default` folder in `Asssets/Notes` to see how the formating works here.

2. Song.gd
- All it does is just act as a Util class for parsing charts, and playing songs.

- Parses CodenameEngine charting for now.

3. Note.gd
- The sustain is a `Line2D` so you can define points for your funky sustains. It's also used for the `Strum.gd`'s `NotePath` so it can follow it smoothly. (This has yet to be properly implemented, I can't figure out how to make it work 😭)

- The Actual Note Sprite is seperate from the `Line2D` so you can rotate, scale and move the normal note around. I'd reccomend only using it to rotate the note around as it will look weird otherwise.

4. Strum.gd
- This is where your input is handled, and how notes are spawned and destroyed.

- The note's are stored in the `Notes` `Node2D`, instead of stored in an array variable.

- It has the same structure like the `Note.gd`, as the Actual sprite for the Static Note is a child of the `Strum` `Node2D`

- The `NotePath` is just points that the notes will follow along. You can update the points Dynamically, and the notes will follow the new path.

5. StrumLine.gd
- All this really is used for is to wrap your `Strum`s Into a single `Node2D` and some variables you can mess around with. Like the position of the X and Y of the window, the amount ***(currently doesn't work, no multikey supported)***

And that's really for for now.

## Need help on (TODO)
This is in priority order

1. `Strum`'s NotePath breaking for `Note` sustains.

2. UI For `ImagesToSpriteFrames` to select the image ang xml file to automatically convert.

3. Maybe rework file structure???

## Special Thanks
- Aliza - For the `Conductor.gd` Script
- theo - For helping with some of the `NotePath` information
