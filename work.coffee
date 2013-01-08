# Jesus, that's a lot of work.
# Let's get going...

###

Rules:
	1. Any live cell with fewer than two live neighbours dies, as if caused by under-population.
	2. Any live cell with two or three live neighbours lives on to the next generation.
	3. Any live cell with more than three live neighbours dies, as if by overcrowding.
	4. Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.

# Add
# STOP WHEN MOUSE DOWN
# fps counter
###

`
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
`
getRandColor = ->
	'#' + (Math.random()*0xFFFFFF<<0).toString(16)


class CanvasObject

	# Nothing here.


class GridSquare extends CanvasObject
	
	constructor: (@size, @c) ->
	
	render: (context) ->
		context.fillStyle = getRandColor() # (@c.x-@c.y, 1000) # "black" # Black.
		context.fillRect @size*@c.x, @size*@c.y, @size, @size

	clear: (context) ->
		context.clearRect @size*@c.x, @size*@c.y, @size, @size		


class Board

	size 	: 10 # ... gap???
	board 	: []

	DEAD 	: null
	ALIVE 	: 1

	constructor: (@canvas, pop=null) ->

		@context 	= @canvas.getContext "2d"
		@WIDTH 		= ~~(@canvas.width/@size)+1
		@HEIGHT 	= ~~(@canvas.height/@size)+1

		window.canvas = @canvas

		@_drawGrid()
		@genInitialState()

		pop ?= @WIDTH*@HEIGHT*.1

		@addSquare(@_getRandBoardPos()) for i in [1..pop]
		# @_printBoard(@board)

		@render(@board)

	genInitialState: ->
		console.log "Initializing board #{@WIDTH} by #{@HEIGHT}"
		board = []
		for i in [0...@WIDTH]
			board[i] = Array(@HEIGHT)
			for i2 in [0...@HEIGHT]
				board[i][i2] = @DEAD
		@board = board
		@render()

	addSquare: (coord) ->
		@board[coord.x][coord.y] = @ALIVE

	toogleSquare: (c) =>
		if @board[c.x][c.y]
			new GridSquare(@size, c).clear(@context)
			@board[c.x][c.y] = @DEAD
		else
			new GridSquare(@size, c).render(@context)
			@board[c.x][c.y] = @ALIVE


		# @renderToggle(@board)

	render: (board=@board) ->
		@clear()
		for x in [0...board.length]
			for y in [0...board[x].length] when board[x][y]
				new GridSquare(@size, {x:x,y:y}).render(@context)
		return

	renderToggle: (board) ->
		# @clear()
		for x in [0...board.length]
			# console.log(x, board[x])
			for y in [0...board[x].length] when board[x][y] != @board[x][y]
				if not board[x][y]
					new GridSquare(@size, {x:x, y:y}).clear(@context)
				else
					new GridSquare(@size, {x:x, y:y}).render(@context)
		# console.log "toc"

	tick: ->
		# Create a copy @board to board.
		board = Array(@WIDTH)
		for x in [0...@WIDTH]
			board[x] = @board[x].slice(0)

		if @mouse is on
			return

		# Make changes according to the rules
		for x in [0...@WIDTH]
			for y in [0...@HEIGHT]
				status = @board[x][y]
				neighbours = @_countNeighbours(x, y)

				switch status
					when @DEAD
						switch neighbours
							# Any dead cell with exactly three live neighbours
							# becomes a live cell, as if by reproduction.
							when 3
								board[x][y] = @ALIVE

					when @ALIVE
						switch neighbours
							# Any live cell with two or three live neighbours
							# lives on to the next generation.
							when 2,3,4;
							else
								# - Any live cell with fewer than two live
								# neighbours dies, as if caused by under-population.
								# - Any live cell with more than three live
								# neighbours dies, as if by overcrowding.
								board[x][y] = @DEAD

		# Render new board.
		@renderToggle(board)
		@board = board

	clear: ->
		
		@context.clearRect 0, 0, @canvas.width, @canvas.height

	resetListeners: ->
		pass

	_countNeighbours: (x, y) ->
		# Most basic implementation.
		count = 0
		for s in [-1..1] when @board[x+s]
			# console.log('out', @board[x+s])
			for s2 in [-1..1] when @board[x+s][y+s2] and not (s == s2 == 0)
				# console.log('in', @board[x+s][y+s2])
				count += 1
		count

	_drawGrid: ->
		canvas2 = document.querySelector "canvas#grid"
		context2 = canvas2.getContext "2d" 

		makeLine = (x, y, x2, y2) -> 
			context2.beginPath()
			context2.moveTo x, y
			context2.lineTo x2, y2
			context2.stroke()

		SIZE = @size

		context2.lineWidth = .1

		for icol in [0...canvas2.width/SIZE]
			makeLine(SIZE*icol, 0, SIZE*icol, canvas2.height)
		for iline in [0...canvas2.height/SIZE]
			makeLine(0, SIZE*iline, canvas2.width, SIZE*iline)

	_printBoard: (board=@board) ->
		for y in [0...@HEIGHT]
			line = []
			for x in [0...@WIDTH]
				line.push(if board[x][y] then 1 else 0)
			console.log line.join(', ')

	_getRandBoardPos: () ->
		return {
			x: Math.floor Math.random()*@WIDTH
			y: Math.floor Math.random()*@HEIGHT
		}


class EventDispatcher
	# Only part of the code using jQuery, to handle the events on the canvas.

	constructor: (board) ->
		@board = board
		@canvas = board.canvas

		console.log "Attaching listeners to #{board}"
		$(canvas).on 'click', 		@canvasClicked
		$(canvas).on 'mouseover', 	@inCanvas
		$(canvas).on 'mouseout', 	@outCanvas
		$(canvas).on 'mousemove mousedown', @mousemove

	_getMousePos = (canvas, event) ->
		rect = canvas.getBoundingClientRect()
		x: event.clientX - rect.left
		y: event.clientY - rect.top

	outCanvas: (event) =>
		@board.mouseon = off

	inCanvas: (event) =>
		@board.mouseon = on

	canvasClicked: (event) =>
		mousePos = _getMousePos @canvas, event
		boardPos =
			x: ~~(mousePos.x/@board.size)
			y: ~~(mousePos.y/@board.size)
		console.log "Canvas click fired at (#{mousePos.x},#{mousePos.y}) => (#{boardPos.x},#{boardPos.y})"
		@board.toogleSquare boardPos


window.drawDot = (canvas, x, y) ->

	console.log canvas
	window.context = canvas.getContext "2d"
	
	context.strokeStyle = "black"
	context.beginPath()
	context.arc x, y, 2, 0, 2*Math.PI, true
	context.fill()

class Painter

	constructor: ->

	buildCanvas: ->
		@canvas =
			grid:	document.createElement "canvas"
			board:	document.createElement "canvas"

		for id, elm of @canvas
			elm.id = id
			elm.width 	= window.innerWidth
			elm.height 	= window.innerHeight
			$(elm).appendTo $(".wrapper")

	loop: ->
		board = new Board @canvas.board
		console.log board
		new EventDispatcher board
		window.setInterval =>
			board.tick()
		, 100



window.AnimateOnFrameRate = do ->
	# thanks Paul Irish
	window.requestAnimationFrame 			or
	window.webkitRequestAnimationFrame		or
	window.mozRequestAnimationFrame			or
	window.oRequestAnimationFrame			or
	window.msRequestAnimationFrame			or
	(callback) ->
		window.setTimeout callback, 1000/60


window.onload = ->

	painter = new Painter
	painter.buildCanvas()
	painter.loop()

	return