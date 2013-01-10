# painter.coffee for https://github.com/f03lipe/game-of-life

# Jesus, that's a lot of work.
# Let's get going...
# Using underscore.js and jQuery

# John Conway's Game of Life
# Rules from Wikipedia (http://en.wikipedia.org/wiki/Conway's_Game_of_Life)
# 1. Any live cell with fewer than two live neighbours dies, as if caused by under-population.
# 2. Any live cell with two or three live neighbours lives on to the next generation.
# 3. Any live cell with more than three live neighbours dies, as if by overcrowding.
# 4. Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.

#! ToDos
# --?


class Painter

	###### Canvas manipulation functions

	drawDot = (context, x, y, color="black") ->
		context.strokeStyle = color
		context.beginPath()
		context.arc x, y, 2, 0, 2*Math.PI, true
		context.fill()

	makeLine = (context, x, y, x2, y2, lineWidth=0.1, color="black") -> 
		context.strokeStyle = color
		context.lineWidth = lineWidth
		context.beginPath()
		context.moveTo x, y
		context.lineTo x2, y2
		context.stroke()
	
	drawGrid = (canvas, gridSize) ->
		context = canvas.getContext "2d"
		# Erase any previous grids
		context.clearRect 0, 0, canvas.width, canvas.height
		for icol in [0...canvas.width/gridSize]
			makeLine(context, gridSize*icol, 0, gridSize*icol, canvas.height, .1, 'grey')
		for iline in [0...canvas.height/gridSize]
			makeLine(context, 0, gridSize*iline, canvas.width, gridSize*iline, .1, 'grey')

	incStateCounter: ->
		window.stateCount += 1
		document.querySelector(".count").innerHTML = window.stateCount

	resetStateCounter: ->
		window.stateCount = 1
		document.querySelector(".count").innerHTML = window.stateCount

	###### Fps stuff

	window.fps = 0
	lastUpdate = (new Date)*1 - 1
	fpsFilter = 50

	addFpsCounter = ->
		fpsOut = document.getElementById 'fps'
		setInterval =>
			fpsOut.innerHTML = window.fps.toFixed(1)
		, 500

	resetFpsCounter = ->
		window.fps = 0

	######

	# Defaults
	gridSize: 10
	initialPop: 1000
	fps: 20

	constructor: ->
		@canvas =
			grid:	document.createElement "canvas"
			board:	document.createElement "canvas"

		for id, elm of @canvas
			elm.id = id
			elm.width 	= $(window).width() # window.innerWidth
			elm.height 	= $(window).height() # window.innerHeight
			$(elm).appendTo $(".wrapper")
		drawGrid(@canvas.grid, @gridSize)
	
		@board = new Board(@canvas.board, @gridSize, @initialPop)
		@dispatcher = new EventDispatcher(@board, @)

	changeBoardSpecs: (obj) ->
		@fps = obj.fps ? @fps
		@initialPop = obj.initialPop ? @initialPop
		@gridSize = obj.gridSize ? @gridSize

		drawGrid @canvas.grid, @gridSize
		window.stateCount = 0
		@resetStateCounter()
		resetFpsCounter()

		@board.resetBoard(@initialPop, @gridSize)

	_loop: ->

		# Synchronise window.fps
		thisFrameFPS = 1000 / ((now=new Date) - lastUpdate)
		window.fps += (thisFrameFPS - window.fps) / 1;
		lastUpdate = now * 1 - 1
	
		window.setTimeout =>
			@_loop()
		, 1000/@fps
		
		return if window.canvasStop or
			window.mouseDown and window.mouseOverCanvas
		
		@board.tic()

	loop: ->
		addFpsCounter()
		console.log "Start looping board" # , @board, "with painter", @ 
		@_loop()




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
	# Start a painter and loop.
	window.painter = new Painter(20, 100)
	window.painter.loop()

	return