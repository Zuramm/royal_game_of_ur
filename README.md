# Royal Game of Ur

A 3D implementation of the [Royal Game of Ur](https://en.wikipedia.org/wiki/Royal_Game_of_Ur), one of the oldest known board games. Built with Godot and GDScript.

## Play and download

**[The Royal Game of Ur on itch.io](https://zuramm.itch.io/the-royal-game-of-ur)**

## How to play

You play as **white** against a computer opponent (**black**).

### Goal
Move all of your pieces through your path, around the shared middle lane, and off the board at the far end. The first side to bear off every piece wins.

### Turns
Each turn the game rolls for the active player (by default, four binary dice, so the result is **0–4**). The roll is shown on screen. A **0** means you cannot move; the turn passes to the other side.

### Choosing a move
When you have one or more legal moves, **click the highlighted path** you want (from your off-board stock onto the track, along the board, or off the end). If several moves are possible, each valid option is shown; pick one. If there are no legal moves, your turn ends automatically.

### Paths
At the start of the game you can choose the path on which the pieces travel. These are the available paths and they will be mirrored (long side) for your opponent.

| Name | Path |
| --- | --- |
| Bell's path | <img src="pictures/Preview%20Bell%27s%20Path.png" alt="Bell's path" width="300"> |
| Master's path | <img src="pictures/Preview%20Masters%20Path.png" alt="Master's path" width="300"> |
| Skiriuk's path | <img src="pictures/Preview%20Skiriuks%20Path.png" alt="Skiriuk's path" width="300"> |
| Murray's path | <img src="pictures/Preview%20Murrays%20Path.png" alt="Murray's path" width="300"> |

## Requirements for local development

- [Godot 4.6](https://godotengine.org/download) (matches `project.godot`; use the same major/minor version to avoid import or API issues).
- Clone the repository and open the project folder in the Godot editor.

## Exporting from source

Export presets are configured in `export_presets.cfg` (including **Web** and **Android**). In Godot: **Project → Export**, select a preset, set an output path, and export.

Pushing a semantic version tag (`x.y.z`) runs `.github/workflows/main.yml`, which exports web and Android builds and attaches them to a GitHub release.
