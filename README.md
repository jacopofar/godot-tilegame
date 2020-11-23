This project implements a 2D game based on Godot 3.2 and Tiled, with a step by step explanation of the development.

__WARNING: this project is archived because there are better solutions to integrate Tiled map (and tilemaps in Godot are going to change soon with 4.0) and a good part of it now lives in its own [plugin](https://github.com/jacopofar/blocking-dialog-box)__

## References

* [RPG Tutorial by Davide Pesce](https://www.davidepesce.com/godot-tutorials/) - text format, step by step RPG from scratch
* [HeartBeast](https://www.youtube.com/user/uheartbeast/videos) - a long and very detailed YouTube series about action RPGs
* [GDQuest tutorials](https://www.gdquest.com/tutorial/) - many topics at different levels, both text and videos
* [Godot recipes](https://godotrecipes.com/) - Excellent collection of tricks and solutions to common problems
## Parts
* [part 0](tutorial/part00.md)
  * Create and integrate a Tiled map in a project, with a character that can move around.
  * Animate the main character.
* [part 1](tutorial/part01.md)
  * Define terrains in Tiled
  * Instantiate Nodes based on points in the Tiled map object layer.
* [part 2](tutorial/part02.md)
  * Let the player interact with objects
  * Display an essential message.
  * Move shared logic to an AutoLoad (singleton) scene
  * Assign custom properties from the map to the scene
  * Reorganize the folders a bit
* [part 3](tutorial/part03.md)
  * Export the game so far for the web
  * Add mouse and multitouch integration to work on mobile
* [part 4](tutorial/part04.md)
  * Make the text fade and disappear
  * Integrate with GodotTIE and adapt it to mouse and multitouch
  * rename and prune a bit the Dialogue autoloaded object
* [part 5](tutorial/part05.md)
  * Add an inventory and a global game state
  * Create a central item catalogue file

## TODO / roadmap
- [x] Instantiate nodes based on map objects with an import script
- [x] Have the chest interact to an action button, by opening
- [x] Show a message when the chest is open
- [x] Delegate message displaying to a singleton
- [x] Pass properties from the Tiled map to the Godot instances, e.g. the name of the Treasure chest content and its unique ID
- [x] Rearrange the resources in folders
- [x] Export for the browser
- [x] Add [Mouse movement](https://www.davidepesce.com/2019/10/14/godot-tutorial-5-1-dragging-player-with-mouse/) as alternative to keyboard, and try on mobile
- [x] Embellish the message bubble and make it disappear
- [x] Integrate with GodotTIE
- [x] Change name of autoloaded object, make it generic for all the Game-level calls instead of ComicBubble
- [x] Define an inventory as a shared property in autoload
- [x] Read id-name inventory mapping from a JSON, with human-readable string ids and arbitrary equip metadata
- [x] ~~Move catalogue logic in its own AutoLoad~~ in hindsight, is not needed
- [ ] Show a menu when the user presses ESC or clicks on a corner, with list of items and save option
- [ ] Implement game saving under `User://`
- [ ] Add script to process the map and assign each object an identifier,
reorganize project folders in script, tutorial and game.
- [ ] Use the id to allow treasure chests to store their state globally to be saved
- [ ] Have player spawn in saved position
- [ ] Allow dialogues and choices using the message bubble (note: check other dialogue plugins)
- [ ] Allow map switching, maybe push the map to its own scene and load it in Main
- [ ] Make an NPC which moves around
- [ ] Try tiled worlds, check integration with the plugin
- [ ] Send the player position to a server
- [ ] Stress test for the map size
- [ ] Add optional map chunks unload when too distant
- [ ] Add optional map chunks retrieval (or push? maybe it's better) from server
