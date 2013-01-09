# Jesus, that's a lot of work.
# Let's get going...
# Using underscore.js and jQuery

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
		# context.fillStyle = getRandColor()
		context.fillStyle = rainbow(@c.x-@c.y, 10)
		context.fillRect @size*@c.x, @size*@c.y, @size, @size

	clear: (context) ->
		context.clearRect @size*@c.x, @size*@c.y, @size, @size


class Board

	boardState 	: []
	DEAD 	: null
	ALIVE 	: 1

	constructor: (@canvas, @size=10, pop=null) ->
		@context 	= @canvas.getContext "2d"
		@WIDTH 		= ~~(@canvas.width/@size)+1    
		@HEIGHT 	= ~~(@canvas.height/@size)+1

		@initializeBoard()

		pop ?= 0 #s @WIDTH*@HEIGHT*.5

		@toogleSquare(@_getRandBoardPos()) for i in [1..pop]
		# @_printBoard(@boardState)
		# @render(@boardState)

	initializeBoard: ->
		console.log "Initializing boardState #{@WIDTH} by #{@HEIGHT}"
		boardState = []
		for i in [0...@WIDTH]
			boardState[i] = Array(@HEIGHT)
			for i2 in [0...@HEIGHT]
				boardState[i][i2] = @DEAD
		@boardState = boardState

	####

	addSquare: (coord) ->
		@boardState[coord.x][coord.y] = @ALIVE
		new GridSquare(@size, coord).render(@context)

	toogleSquare: (coord) =>
		if @boardState[coord.x][coord.y]
			new GridSquare(@size, coord).clear(@context)
			@boardState[coord.x][coord.y] = @DEAD
		else
			new GridSquare(@size, coord).render(@context)
			@boardState[coord.x][coord.y] = @ALIVE

	####

	# render: (boardState=@boardState) ->
	# 	@clearBoard()
	# 	for x in [0...boardState.length]
	# 		for y in [0...boardState[x].length] when boardState[x][y]
	# 			new GridSquare(@size, {x:x,y:y}).render(@context)
	# 	# console.log "toc"

	render: (boardState) ->
		# @clearBoard()
		for x in [0...boardState.length] when not _.isEqual boardState[x], @boardState[x] # Prevent loop in non-changed strips.
			for y in [0...boardState[x].length] when boardState[x][y] != @boardState[x][y]
				if not boardState[x][y]
					new GridSquare(@size, {x:x, y:y}).clear(@context)
				else
					new GridSquare(@size, {x:x, y:y}).render(@context)
		# console.log "toc"

	tick: ->
		if window.mouseDown or window.spaceDown
			return
		
		# Create a copy @boardState to boardState.
		boardState = Array(@WIDTH)
		for x in [0...@WIDTH]
			boardState[x] = @boardState[x].slice(0)


		changed = false

		# Make changes according to the rules
		for x in [0...@WIDTH]
			for y in [0...@HEIGHT]
				status = @boardState[x][y]
				neighbours = @_countNeighbours(x, y)

				switch status
					when @DEAD
						switch neighbours
							# Any dead cell with exactly three live neighbours
							# becomes a live cell, as if by reproduction.
							when 3 #                                 5
								boardState[x][y] = @ALIVE
								changed = true

					when @ALIVE
						switch neighbours
							# Any live cell with two or three live neighbours
							# lives on to the next generation.
							when 2, 3;
							else
								# - Any live cell with fewer than two live
								# neighbours dies, as if caused by under-population.
								# - Any live cell with more than three live
								# neighbours dies, as if by overcrowding.
								boardState[x][y] = @DEAD
								changed = true

		# Render new boardState.
		@render(boardState)
		@boardState = boardState
		if changed
			$(@).trigger 'toc', {empty: @_isEmpty(@boardState)}

	####

	clearBoard: ->
		
		@context.clearRect 0, 0, @canvas.width, @canvas.height

	_countNeighbours: (x, y) ->
		# Most basic implementation.
		count = 0
		for s in [-1..1] when @boardState[x+s]
			for s2 in [-1..1] when @boardState[x+s][y+s2] and not (s == s2 == 0)
				count += 1
		count

	_printBoard: (boardState=@boardState) ->
		for y in [0...@HEIGHT]
			line = []
			for x in [0...@WIDTH]
				line.push(if boardState[x][y] then 1 else 0)
			console.log line.join(', ')

	_getRandBoardPos: () ->
		return {
			x: Math.floor Math.random()*@WIDTH
			y: Math.floor Math.random()*@HEIGHT
		}

	_isEmpty: (boardState=@boardState) ->
		for x in [0...@WIDTH]
			for y in [0...@HEIGHT]
				if boardState[x][y] != @DEAD
					return false
		return true


class EventDispatcher
	# Listen for events and set global variables.
	#!? Substitute all globals by an object like "eventState"

	_getMousePos: (event) =>
		rect = @canvas.getBoundingClientRect()
		x: event.clientX - rect.left
		y: event.clientY - rect.top

	_getGridPos: (event) =>
		coord = @_getMousePos event
		x: ~~(coord.x/@board.size)
		y: ~~(coord.y/@board.size)

	######

	@lastHoveredSquare = null

	constructor: (@board) ->
		@canvas = board.canvas

		console.log "Attaching listeners to board:", #{board}
		@detectMouse()
		@detectSpacebar()
		@detectMousePos()
		@detectCanvasClick
		@detectCanvasClick()
		@detectMouseMove()
		@bindBoardToc()


	bindBoardToc: ->
		window.stateCount = 0
		$(@board).bind 'toc', (event, context) ->
			if not context.empty
				window.stateCount += 1
				document.querySelector(".count").innerHTML = window.stateCount

	detectMouse: ->
		window.msouseDown = false
		$(document).mousedown (event) =>
			window.mouseDown = true
		$(document).mouseup (event) =>
			window.mouseDown = false

	detectSpacebar: ->
		window.spaceDown = false
		$(document).keydown (event) =>
			window.spaceDown = true if event.keyCode == 32
		$(document).keyup (event) =>
			window.spaceDown = false if event.keyCode == 32

	detectMousePos: ->
		window.mouseOverCanvas = false
		$(@canvas).mouseover (event) ->
			window.mouseOverCanvas = true
		$(@canvas).mouseout (event) ->
			window.mouseOuverCanvas = false

	detectCanvasClick: ->
		$(@canvas).mousedown (event) =>
			coord = @_getGridPos event
			if not _.isEqual coord, @lastHoveredSquare
				console.log "Click at canvas fired at", coord
				@board.toogleSquare coord

	detectMouseMove: ->
		$(@canvas).mousemove (event) =>
			if window.mouseOverCanvas and window.mouseDown
				coord = @_getGridPos event
				console.log 'lasthovered', @lastHoveredSquare
				if not _.isEqual coord, @lastHoveredSquare
					@lastHoveredSquare = coord
					@board.addSquare coord
					console.log "Hovering board at square", coord
			@lastHoveredSquare = coord


########

class Painter

	drawDot = (context, x, y, color="black") ->
		context.strokeStyle = color
		context.beginPath()
		context.arc x, y, 2, 0, 2*Math.PI, true
		context.fill()

	makeLine = (context, x, y, x2, y2, color="black") -> 
		context.strokeStyle = color
		context.beginPath()
		context.moveTo x, y
		context.lineTo x2, y2
		context.stroke()
	
	_drawGrid = (canvas, size) ->
		context = canvas.getContext "2d"
		context.lineWidth = .1
		for icol in [0...canvas.width/size]
			makeLine(context, size*icol, 0, size*icol, canvas.height)
		for iline in [0...canvas.height/size]
			makeLine(context, 0, size*iline, canvas.width, size*iline)

	#####

	gridSize = 4

	constructor: ->
		@buildCanvas()

	buildCanvas: ->
		@canvas =
			grid:	document.createElement "canvas"
			board:	document.createElement "canvas"

		for id, elm of @canvas
			elm.id = id
			elm.width 	= $(window).width() # window.innerWidth
			elm.height 	= $(window).height() # window.innerHeight
			$(elm).appendTo $(".wrapper")
		_drawGrid(@canvas.grid, gridSize)

	loop: ->
		board = new Board(@canvas.board, gridSize)
		new EventDispatcher(board)
		console.log "Looping board:", board
		
		window.setInterval =>
			board.tick()
		, 10


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
	painter = new Painter()
	painter.buildCanvas()
	painter.loop()
	return