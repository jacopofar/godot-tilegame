This project implements a 2D game based on Godot 3.2 and Tiled, with a step by step explanation of the development.

## Parts
* [part 0](tutorial/part00.md) - Create and integrate a Tiled map in a project, with a character that can move around. Animate the main character.
* [part 1](tutorial/part01.md) - Define terrains in Tiled; Instantiate Nodes based on points in the Tiled map object layer.

## TODO
- [x] Instantiate nodes based on map objects with an import script
- [x] Have the chest interact to an action button, by opening
- [ ] Show a message when the chest is open
- [ ] Pass properties from the Tiled map to the Godot instances, e.g. the name of the Treasure chest content and its unique ID
- [ ] Export for the browser
- [ ] Add [Mouse movement](https://www.davidepesce.com/2019/10/14/godot-tutorial-5-1-dragging-player-with-mouse/) as alternative to keyboard, and try on mobile
- [ ] Send the player position to a server
