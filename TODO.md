# LJ Engine - Godot | Todo List

## Fix Issues
*none for now*

### Basic Features

- [x] Add FPS Counter, PC Specs, and other useful information.

- [x] Add Characters
  - [x] Animation Offsets
  - [ ] Make character dance on beat, and singing animations based off of V-Slice
  - [ ] Somehow support Rotated Sprites
  - [ ] Add support for Animated Atlases??? Maybe???

- [ ] Possibly rework file structure

- [ ] Rework how `Songs` are loaded and handled for parsing charts and playing songs.

- [ ] Modding Framework using the GDScript language, or even use LUAU?? ***(I'd perfer GDScript for easy engine interp.)***

### Engine Features

- Editors
  - [ ] Characters
  - [ ] Chart Editor
  - [ ] Stage Editor

- [ ] Properly implement Note Types

- [ ] Support Multikey | LOW PRIORITY

- [ ] Support 3D game elements | SUPER LOW PRIORITY

### Others

- [x] Scene that manages switching between other states, UI, Camera, etc. *(FunkinGame.gd)*
  - [ ] Add Transitions that are customizable
  - [ ] Find out how to reflect variables onto another Script before it exists??? (i.e access `Camera` from `FunkinGame.gd` in `MainTesting.gd`)

- [ ] Re-implement `NotePath` for custom note pathing.

- [ ] Rewrite how Sustains are updated, and optimize it. 🙏

- [ ] Add Alphabet Support

- [ ] Add support for translations?

***and probably other stuff I am forgetting about.***