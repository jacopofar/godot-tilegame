This project implements a 2D game based on Godot 3.2 and Tiled, with a step by step explanation of the development.

__WARNING: I'm not an expert about Godot at all! Right now this is more a development diary than an actual tutorial, and I retroactively change parts after finding a better approach. PR and comments are welcome, refer to the references below for tutorials__

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
  * Reorganize the folders a
* [part 3](tutorial/part03.md)
  * Export the game so far for the web
  * Add mouse and multitouch integration to work on mobile
* [part 4](tutorial/part04.md)
  * Make the text fade and disappear
## TODO
- [x] Instantiate nodes based on map objects with an import script
- [x] Have the chest interact to an action button, by opening
- [x] Show a message when the chest is open
- [x] Delegate message displaying to a singleton
- [x] Pass properties from the Tiled map to the Godot instances, e.g. the name of the Treasure chest content and its unique ID
- [x] Rearrange the resources in folders
- [x] Export for the browser
- [x] Add [Mouse movement](https://www.davidepesce.com/2019/10/14/godot-tutorial-5-1-dragging-player-with-mouse/) as alternative to keyboard, and try on mobile
- [x] Embellish the message bubble and make it disappear
- [ ] Integrate with GodotTIE
- [ ] Define an inventory as a shared object in autoload
- [ ] Allow dialogues and choices using the message bubble
- [ ] Make an NPC which moves around
- [ ] Try tiled worlds, check integration with the plugin
- [ ] Send the player position to a server
- [ ] Stress test for the map size
- [ ] Add optional map chunks unload when too distant
- [ ] Add optional map chunks retrieval (or push? maybe it's better) from server
