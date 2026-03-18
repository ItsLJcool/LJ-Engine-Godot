# LJ Engine (Godot v4.6.1)

This is a Friday Night Funkin' Game Engine designed in Godot, and is meant to be easy to modify / understand so that you can understand how the basic principles of the Rhythm game functions.

## Current Features
- [x] [`Note`](./scripts/Note.gd), [`Strum`](./scripts/Strum.gd), & [`StrumLine`](./scripts/StrumLine.gd) use Constructors for performance increase, no Scene is attached to the script.
- [x] [`Conductor`](./scripts/backend/Conductor.gd) using the "QuarterSeconds Conductor" formula (read the script for more info)
- [x] Downscroll uses negative `scroll_speed`
  - [`Note`](./scripts/Note.gd) can override [`Strum`](./scripts/Strum.gd)'s `scroll_speed`
- [x] Optimized [`Note`](./scripts/Note.gd) Rendering
  - Only adds the [`Note`](./scripts/Note.gd) to the Scene if it is in the `render_limit`
- [x] Uses Resources for
[`Chart`](./assets/resources/game/Chart.gd), [`ChartMeta`](./assets/resources/game/ChartMeta.gd),
[`ChartNote`](./assets/resources/game/ChartNote.gd) & [`ChartStrumLine`](./assets/resources/game/ChartStrumLine.gd) to make it friendly to interact with, and add chart parsing for various engines.
  - Currently only CodenameEngine charts can be parsed as of now
- [x] Implements a [`FunkinHelper`](./globals/FunkinHelper.gd) Utility
  - Currently is used for `DirectionType` and Animation Remaps for Note Types
- [x] [`SparrowAtlas`](./assets/resources/SparrowAtlas.gd) implementaion somewhat based off of [FunkinGodot](https://github.com/cherrythecool/funkin_godot)
  - Combined formatting and rotated sprite implementation, the rest I did figure out myself but still credits to cherry 🔥
  - I plan for the [`SparrowAtlas`](./assets/resources/SparrowAtlas.gd) resource to contain the SpriteFrames, AND the Texture as 1 `.tres` asset but currently not implemented yet
- [x] [`NotePositionRemap`](./assets/resources/NotePositionRemap.gd) to allow custom positioning of [`Note`](./scripts/Note.gd)s
- [] [`MultiAudioStreamPlayer`](./assets/resources/MultiAudioStreamPlayer.gd) for containing multiple audio players and easier interaction for pausing, and syncing.

