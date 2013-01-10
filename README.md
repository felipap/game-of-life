game-of-life
============

A CoffeeScript implementation for HTML5's canvas of John Conway's Game of Life.

Compile with `coffeescript --output js --compile coffee/\*.coffee/`.

Currently using jQuery, Bootstrap and Backbone.js.

Game of Life rules: (extracted from [Wikipedia][1])
-------------------
1. Any live cell with fewer than two live neighbours dies, as if caused by under-population.
2. Any live cell with two or three live neighbours lives on to the next generation.
3. Any live cell with more than three live neighbours dies, as if by overcrowding.
4. Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.

**live**: http://f03lipe.github.com/game-of-life

[1]: http://en.wikipedia.org/wiki/Conway's_Game_of_Life
