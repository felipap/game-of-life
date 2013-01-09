// Generated by CoffeeScript 1.4.0

/*

Rules:
	1. Any live cell with fewer than two live neighbours dies, as if caused by under-population.
	2. Any live cell with two or three live neighbours lives on to the next generation.
	3. Any live cell with more than three live neighbours dies, as if by overcrowding.
	4. Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.

# Add
# STOP WHEN MOUSE DOWN
# fps counter
*/


(function() {
  
function rainbow(numOfSteps, step) {
    // This function generates vibrant, "evenly spaced" colours (i.e. no clustering). This is ideal for creating easily distiguishable vibrant markers in Google Maps and other apps.
    // Adam Cole, 2011-Sept-14
    // HSV to RBG adapted from: http://mjijackson.com/2008/02/rgb-to-hsl-and-rgb-to-hsv-color-model-conversion-algorithms-in-javascript
    var r, g, b;
    var h = step / numOfSteps;
    var i = ~~(h * 6);
    var f = h * 6 - i;
    var q = 1 - f;
    switch(i % 6){
        case 0: r = 1, g = f, b = 0; break;
        case 1: r = q, g = 1, b = 0; break;
        case 2: r = 0, g = 1, b = f; break;
        case 3: r = 0, g = q, b = 1; break;
        case 4: r = f, g = 0, b = 1; break;
        case 5: r = 1, g = 0, b = q; break;
    }
    var c = "#" + ("00" + (~ ~(r * 255)).toString(16)).slice(-2) + ("00" + (~ ~(g * 255)).toString(16)).slice(-2) + ("00" + (~ ~(b * 255)).toString(16)).slice(-2);
    return (c);
}
;

  var Board, CanvasObject, EventDispatcher, GridSquare, Painter, getRandColor,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  getRandColor = function() {
    return '#' + (Math.random() * 0xFFFFFF << 0).toString(16);
  };

  CanvasObject = (function() {

    function CanvasObject() {}

    return CanvasObject;

  })();

  GridSquare = (function(_super) {

    __extends(GridSquare, _super);

    function GridSquare(size, c) {
      this.size = size;
      this.c = c;
    }

    GridSquare.prototype.render = function(context) {
      context.fillStyle = rainbow(this.c.x - this.c.y, 10);
      return context.fillRect(this.size * this.c.x, this.size * this.c.y, this.size, this.size);
    };

    GridSquare.prototype.clear = function(context) {
      return context.clearRect(this.size * this.c.x, this.size * this.c.y, this.size, this.size);
    };

    return GridSquare;

  })(CanvasObject);

  Board = (function() {

    Board.prototype.boardState = [];

    Board.prototype.DEAD = null;

    Board.prototype.ALIVE = 1;

    function Board(canvas, size, pop) {
      var i, _i;
      this.canvas = canvas;
      this.size = size != null ? size : 10;
      if (pop == null) {
        pop = null;
      }
      this.toogleSquare = __bind(this.toogleSquare, this);

      this.context = this.canvas.getContext("2d");
      this.WIDTH = ~~(this.canvas.width / this.size) + 1;
      this.HEIGHT = ~~(this.canvas.height / this.size) + 1;
      this.initializeBoard();
      if (pop == null) {
        pop = 0;
      }
      for (i = _i = 1; 1 <= pop ? _i <= pop : _i >= pop; i = 1 <= pop ? ++_i : --_i) {
        this.toogleSquare(this._getRandBoardPos());
      }
    }

    Board.prototype.initializeBoard = function() {
      var boardState, i, i2, _i, _j, _ref, _ref1;
      console.log("Initializing boardState " + this.WIDTH + " by " + this.HEIGHT);
      boardState = [];
      for (i = _i = 0, _ref = this.WIDTH; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        boardState[i] = Array(this.HEIGHT);
        for (i2 = _j = 0, _ref1 = this.HEIGHT; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; i2 = 0 <= _ref1 ? ++_j : --_j) {
          boardState[i][i2] = this.DEAD;
        }
      }
      return this.boardState = boardState;
    };

    Board.prototype.addSquare = function(coord) {
      this.boardState[coord.x][coord.y] = this.ALIVE;
      return new GridSquare(this.size, coord).render(this.context);
    };

    Board.prototype.toogleSquare = function(coord) {
      if (this.boardState[coord.x][coord.y]) {
        new GridSquare(this.size, coord).clear(this.context);
        return this.boardState[coord.x][coord.y] = this.DEAD;
      } else {
        new GridSquare(this.size, coord).render(this.context);
        return this.boardState[coord.x][coord.y] = this.ALIVE;
      }
    };

    Board.prototype.render = function(boardState) {
      var x, y, _i, _ref, _results;
      _results = [];
      for (x = _i = 0, _ref = boardState.length; 0 <= _ref ? _i < _ref : _i > _ref; x = 0 <= _ref ? ++_i : --_i) {
        if (!_.isEqual(boardState[x], this.boardState[x])) {
          _results.push((function() {
            var _j, _ref1, _results1;
            _results1 = [];
            for (y = _j = 0, _ref1 = boardState[x].length; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; y = 0 <= _ref1 ? ++_j : --_j) {
              if (boardState[x][y] !== this.boardState[x][y]) {
                if (!boardState[x][y]) {
                  _results1.push(new GridSquare(this.size, {
                    x: x,
                    y: y
                  }).clear(this.context));
                } else {
                  _results1.push(new GridSquare(this.size, {
                    x: x,
                    y: y
                  }).render(this.context));
                }
              }
            }
            return _results1;
          }).call(this));
        }
      }
      return _results;
    };

    Board.prototype.tick = function() {
      var boardState, changed, neighbours, status, x, y, _i, _j, _k, _ref, _ref1, _ref2;
      if (window.mouseDown || window.spaceDown) {
        return;
      }
      boardState = Array(this.WIDTH);
      for (x = _i = 0, _ref = this.WIDTH; 0 <= _ref ? _i < _ref : _i > _ref; x = 0 <= _ref ? ++_i : --_i) {
        boardState[x] = this.boardState[x].slice(0);
      }
      changed = false;
      for (x = _j = 0, _ref1 = this.WIDTH; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; x = 0 <= _ref1 ? ++_j : --_j) {
        for (y = _k = 0, _ref2 = this.HEIGHT; 0 <= _ref2 ? _k < _ref2 : _k > _ref2; y = 0 <= _ref2 ? ++_k : --_k) {
          status = this.boardState[x][y];
          neighbours = this._countNeighbours(x, y);
          switch (status) {
            case this.DEAD:
              switch (neighbours) {
                case 3:
                  boardState[x][y] = this.ALIVE;
                  changed = true;
              }
              break;
            case this.ALIVE:
              switch (neighbours) {
                case 2:
                case 3:
                  break;
                default:
                  boardState[x][y] = this.DEAD;
                  changed = true;
              }
          }
        }
      }
      this.render(boardState);
      this.boardState = boardState;
      if (changed) {
        return $(this).trigger('toc', {
          empty: this._isEmpty(this.boardState)
        });
      }
    };

    Board.prototype.clearBoard = function() {
      return this.context.clearRect(0, 0, this.canvas.width, this.canvas.height);
    };

    Board.prototype._countNeighbours = function(x, y) {
      var count, s, s2, _i, _j;
      count = 0;
      for (s = _i = -1; _i <= 1; s = ++_i) {
        if (this.boardState[x + s]) {
          for (s2 = _j = -1; _j <= 1; s2 = ++_j) {
            if (this.boardState[x + s][y + s2] && !((s === s2 && s2 === 0))) {
              count += 1;
            }
          }
        }
      }
      return count;
    };

    Board.prototype._printBoard = function(boardState) {
      var line, x, y, _i, _j, _ref, _ref1, _results;
      if (boardState == null) {
        boardState = this.boardState;
      }
      _results = [];
      for (y = _i = 0, _ref = this.HEIGHT; 0 <= _ref ? _i < _ref : _i > _ref; y = 0 <= _ref ? ++_i : --_i) {
        line = [];
        for (x = _j = 0, _ref1 = this.WIDTH; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; x = 0 <= _ref1 ? ++_j : --_j) {
          line.push(boardState[x][y] ? 1 : 0);
        }
        _results.push(console.log(line.join(', ')));
      }
      return _results;
    };

    Board.prototype._getRandBoardPos = function() {
      return {
        x: Math.floor(Math.random() * this.WIDTH),
        y: Math.floor(Math.random() * this.HEIGHT)
      };
    };

    Board.prototype._isEmpty = function(boardState) {
      var x, y, _i, _j, _ref, _ref1;
      if (boardState == null) {
        boardState = this.boardState;
      }
      for (x = _i = 0, _ref = this.WIDTH; 0 <= _ref ? _i < _ref : _i > _ref; x = 0 <= _ref ? ++_i : --_i) {
        for (y = _j = 0, _ref1 = this.HEIGHT; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; y = 0 <= _ref1 ? ++_j : --_j) {
          if (boardState[x][y] !== this.DEAD) {
            return false;
          }
        }
      }
      return true;
    };

    return Board;

  })();

  EventDispatcher = (function() {

    EventDispatcher.prototype._getMousePos = function(event) {
      var rect;
      rect = this.canvas.getBoundingClientRect();
      return {
        x: event.clientX - rect.left,
        y: event.clientY - rect.top
      };
    };

    EventDispatcher.prototype._getGridPos = function(event) {
      var coord;
      coord = this._getMousePos(event);
      return {
        x: ~~(coord.x / this.board.size),
        y: ~~(coord.y / this.board.size)
      };
    };

    EventDispatcher.lastHoveredSquare = null;

    function EventDispatcher(board) {
      this.board = board;
      this._getGridPos = __bind(this._getGridPos, this);

      this._getMousePos = __bind(this._getMousePos, this);

      this.canvas = board.canvas;
      console.log("Attaching listeners to board:", this.detectMouse());
      this.detectSpacebar();
      this.detectMousePos();
      this.detectCanvasClick;
      this.detectCanvasClick();
      this.detectMouseMove();
      this.bindBoardToc();
    }

    EventDispatcher.prototype.bindBoardToc = function() {
      window.stateCount = 0;
      return $(this.board).bind('toc', function(event, context) {
        if (!context.empty) {
          window.stateCount += 1;
          return document.querySelector(".count").innerHTML = window.stateCount;
        }
      });
    };

    EventDispatcher.prototype.detectMouse = function() {
      var _this = this;
      window.msouseDown = false;
      $(document).mousedown(function(event) {
        return window.mouseDown = true;
      });
      return $(document).mouseup(function(event) {
        return window.mouseDown = false;
      });
    };

    EventDispatcher.prototype.detectSpacebar = function() {
      var _this = this;
      window.spaceDown = false;
      $(document).keydown(function(event) {
        if (event.keyCode === 32) {
          return window.spaceDown = true;
        }
      });
      return $(document).keyup(function(event) {
        if (event.keyCode === 32) {
          return window.spaceDown = false;
        }
      });
    };

    EventDispatcher.prototype.detectMousePos = function() {
      window.mouseOverCanvas = false;
      $(this.canvas).mouseover(function(event) {
        return window.mouseOverCanvas = true;
      });
      return $(this.canvas).mouseout(function(event) {
        return window.mouseOuverCanvas = false;
      });
    };

    EventDispatcher.prototype.detectCanvasClick = function() {
      var _this = this;
      return $(this.canvas).mousedown(function(event) {
        var coord;
        coord = _this._getGridPos(event);
        if (!_.isEqual(coord, _this.lastHoveredSquare)) {
          console.log("Click at canvas fired at", coord);
          return _this.board.toogleSquare(coord);
        }
      });
    };

    EventDispatcher.prototype.detectMouseMove = function() {
      var _this = this;
      return $(this.canvas).mousemove(function(event) {
        var coord;
        if (window.mouseOverCanvas && window.mouseDown) {
          coord = _this._getGridPos(event);
          console.log('lasthovered', _this.lastHoveredSquare);
          if (!_.isEqual(coord, _this.lastHoveredSquare)) {
            _this.lastHoveredSquare = coord;
            _this.board.addSquare(coord);
            console.log("Hovering board at square", coord);
          }
        }
        return _this.lastHoveredSquare = coord;
      });
    };

    return EventDispatcher;

  })();

  Painter = (function() {
    var drawDot, gridSize, makeLine, _drawGrid;

    drawDot = function(context, x, y, color) {
      if (color == null) {
        color = "black";
      }
      context.strokeStyle = color;
      context.beginPath();
      context.arc(x, y, 2, 0, 2 * Math.PI, true);
      return context.fill();
    };

    makeLine = function(context, x, y, x2, y2, color) {
      if (color == null) {
        color = "black";
      }
      context.strokeStyle = color;
      context.beginPath();
      context.moveTo(x, y);
      context.lineTo(x2, y2);
      return context.stroke();
    };

    _drawGrid = function(canvas, size) {
      var context, icol, iline, _i, _j, _ref, _ref1, _results;
      context = canvas.getContext("2d");
      context.lineWidth = .1;
      for (icol = _i = 0, _ref = canvas.width / size; 0 <= _ref ? _i < _ref : _i > _ref; icol = 0 <= _ref ? ++_i : --_i) {
        makeLine(context, size * icol, 0, size * icol, canvas.height);
      }
      _results = [];
      for (iline = _j = 0, _ref1 = canvas.height / size; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; iline = 0 <= _ref1 ? ++_j : --_j) {
        _results.push(makeLine(context, 0, size * iline, canvas.width, size * iline));
      }
      return _results;
    };

    gridSize = 4;

    function Painter() {
      this.buildCanvas();
    }

    Painter.prototype.buildCanvas = function() {
      var elm, id, _ref;
      this.canvas = {
        grid: document.createElement("canvas"),
        board: document.createElement("canvas")
      };
      _ref = this.canvas;
      for (id in _ref) {
        elm = _ref[id];
        elm.id = id;
        elm.width = $(window).width();
        elm.height = $(window).height();
        $(elm).appendTo($(".wrapper"));
      }
      return _drawGrid(this.canvas.grid, gridSize);
    };

    Painter.prototype.loop = function() {
      var board,
        _this = this;
      board = new Board(this.canvas.board, gridSize);
      new EventDispatcher(board);
      console.log("Looping board:", board);
      return window.setInterval(function() {
        return board.tick();
      }, 10);
    };

    return Painter;

  })();

  window.AnimateOnFrameRate = (function() {
    return window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame || function(callback) {
      return window.setTimeout(callback, 1000 / 60);
    };
  })();

  window.onload = function() {
    var painter;
    painter = new Painter();
    painter.buildCanvas();
    painter.loop();
  };

}).call(this);