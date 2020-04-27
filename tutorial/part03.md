Now we have a simple game in which the player can open a chest and see a custom message in an ugly rectangle.

## Export for the web
Exporting the game for the web is pretty easy. Go to *Project -> Export* and click to *Add...* to add an export template. Install the HTML5 one and then click to *Export project* and save it somewhere leaving the default settings.

One of the file, with extension `.wasm`, is the game engine compiled to Webassembly, then you have the `.pck` which contains the game resources and scripts, the `.html` page and some other files. Notice that you cannot just double click on the html file; instead, it has to be served.

Godot can serve it for you, by clicking on the icon close to the play button with a 5 in a shield (the symbol of HTML5) it will open a browser on the current version of the game. However, you cannot access it from other devices (e.g. from a phone) because of security reason it is restricted to localhost.

To serve it, you can export the project and use a web server to serve the resulting static files. A simple option is to use `python3 -m http.server`, if you have Python installed (you should, since I plan to use it later in this project)

You may notice some issue by running the game like this:
* the portion of the world shown in the window is too big (this was true earlier as well, but with the browser it becomes more visible)
* it doesn't work on mobile, since there are no arrow keys to press to move the character around

your mileage may vary, it depends on your screen resolution on both the computer and the phone/tablet/smart-fridge and your personal taste. I decided for my case to change these project settings:

* width and height (under general -> Display -> Window) both at 512 pixels
* rendering -> quality: intended usage set to 2D

## Add mouse movements
...
