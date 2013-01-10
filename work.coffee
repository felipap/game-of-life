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
# fps counter
###

## Change gridsquare manipulation

rainbow = (numOfSteps, step) ->
	# from http://stackoverflow.com/a/7419630/396050
    h = step / numOfSteps;
    i = ~~(h * 6);
    f = h * 6 - i;
    q = 1 - f;
    switch i % 6
        when 0 then r = 1; g = f; b = 0;
        when 1 then r = q; g = 1; b = 0;
        when 2 then r = 0; g = 1; b = f;
        when 3 then r = 0; g = q; b = 1;
        when 4 then r = f; g = 0; b = 1;
        when 5 then r = 1; g = 0; b = q;

    c = "#" + ("00" + (~ ~(r * 255)).toString(16)).slice(-2) + ("00" + (~ ~(g * 255)).toString(16)).slice(-2) + ("00" + (~ ~(b * 255)).toString(16)).slice(-2);
    return c

getRandColor = ->
	'#' + (Math.random()*0xFFFFFF<<0).toString(16)

######

class GridSquare
	
	constructor: (@size, @c) ->
	
	render: (context) ->
		# context.fillStyle = getRandColor()
		context.fillStyle = rainbow(@c.x+@c.y, 10)
		context.fillRect @size*@c.x, @size*@c.y, @size, @size

	clear: (context) ->
		context.clearRect @size*@c.x, @size*@c.y, @size, @size


class Board

	boardState 	: []
	DEAD 	: null
	ALIVE 	: 1

	constructor: (@canvas, @gridSize=10, @initPopulation=null) ->
		@context 	= @canvas.getContext "2d"
		@WIDTH 		= ~~(@canvas.width/@gridSize)+1    
		@HEIGHT 	= ~~(@canvas.height/@gridSize)+1

		@initPopulation ?= @WIDTH*@HEIGHT*.5
		@resetBoard()

	initializeBoard: ->
		console.log "Initializing boardState #{@WIDTH} by #{@HEIGHT}"
		boardState = []
		for i in [0...@WIDTH]
			boardState[i] = Array(@HEIGHT)
			for i2 in [0...@HEIGHT]
				boardState[i][i2] = @DEAD
		@boardState = boardState
		@context.clearRect 0, 0, @canvas.width, @canvas.height

	resetBoard: (pop=@initPopulation)->
		@initializeBoard()
		@context.clearRect 0, 0, @canvas.width, @canvas.height
		@toogleSquare(@_getRandBoardPos()) for i in [1..pop]

	clearBoard: ->
		@initializeBoard()
		@context.clearRect 0, 0, @canvas.width, @canvas.height

	###### Canvas manipulation functions

	addSquare: (coord) ->
		@boardState[coord.x][coord.y] = @ALIVE
		new GridSquare(@gridSize, coord).render(@context)

	toogleSquare: (coord) =>
		if @boardState[coord.x][coord.y]
			new GridSquare(@gridSize, coord).clear(@context)
			@boardState[coord.x][coord.y] = @DEAD
		else
			new GridSquare(@gridSize, coord).render(@context)
			@boardState[coord.x][coord.y] = @ALIVE

	###### Main Engine

	render: (newState) ->
		# Toogles the squares in which newState differs from @boardState.
		for x in [0...newState.length] when not _.isEqual newState[x], @boardState[x] # Prevent loop in non-changed strips.
			for y in [0...newState[x].length] when newState[x][y] != @boardState[x][y]
				if not newState[x][y]
					new GridSquare(@gridSize, {x:x, y:y}).clear(@context)
				else
					new GridSquare(@gridSize, {x:x, y:y}).render(@context)

	tick: ->
		# Create a copy @boardState to boardState.
		boardState = Array(@WIDTH)
		for x in [0...@WIDTH]
			boardState[x] = @boardState[x].slice(0)

		# Make changes according to the rules
		changed = false
		for x in [0...@WIDTH]
			for y in [0...@HEIGHT]
				status = @boardState[x][y]
				neighbours = @_countNeighbours(x, y)
				switch status
					when @DEAD
						switch neighbours
							# Any dead cell with exactly three live neighbours
							# becomes a live cell, as if by reproduction.
							when 3
								boardState[x][y] = @ALIVE
								changed = true

					when @ALIVE
						switch neighbours
							# Any live cell with two or three live neighbours
							# lives on to the next generation.
							when 2, 3
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

	##### Internal methods

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

	@lastHoveredSquare = null

	###### Internal methods

	_getMousePos: (event) =>
		rect = @canvas.getBoundingClientRect()
		x: event.clientX - rect.left
		y: event.clientY - rect.top

	_getGridPos: (event) =>
		coord = @_getMousePos event
		x: ~~(coord.x/@board.gridSize)
		y: ~~(coord.y/@board.gridSize)

	###### Constructor, button binders and bindBoardToc()

	constructor: (@painter) ->

	setBoard: (board) ->
		@board = board
		@canvas = board.canvas

		console.log "Attaching listeners to board:", #{board}
		# Bind DOM events
		@detectMouse()
		@detectSpacebar()
		@detectMousePos()
		@detectCanvasClick
		@detectCanvasClick()
		@detectMouseMove()

		# Bind buttons
		@bindBoardToc()
		@bindStopButton()
		@bindClearButton()
		@bindShowPanel()
		@bindHideGrid()
		@bindBuildCanvas()

	bindBoardToc: ->
		# Binds a 'toc' event from the Board, called each time Board.tic() is executed.
		window.stateCount = 0
		$(@board).bind 'toc', (event, context) =>
			if not context.empty
				window.stateCount += 1
				@updateStateCount()

	bindStopButton: ->
		# Somewhy this is called before Bootstrap's api, and when the button is
		# pressed, the .active class won't be set on it and vice versa.
		# This function must return true, otherwise the eventbubble will stop.

		$("button.haltboard").click (event) =>
			if $(event.target).hasClass('active')
				window.canvasStop = false
			else
				window.canvasStop = true
			return true

	bindClearButton: ->
		$("button.clearboard").click (event) =>
			window.stateCount = 0
			@board.clearBoard()
			@updateStateCount()

	bindShowPanel: ->
		$(".show-more").click (event) =>
			if $('.config-panel').is(':hidden')
				$('.config-panel').slideDown()
				$(".show-more").find("h6").html('show less options')
				$(".show-more").find("i").removeClass("icon-circle-arrow-down").addClass("icon-circle-arrow-up")
				$(".grid-size").val(@board.gridSize)
				console.log @board.gridSize
			else
				$('.config-panel').slideUp()
				$(".show-more").find("h6").html('show more options')
				$(".show-more").find("i").removeClass("icon-circle-arrow-up").addClass("icon-circle-arrow-down")

	bindHideGrid: ->
		$("button.hidegrid").click (event) =>
			if $("button.hidegrid").hasClass "active"
				$("canvas#grid").fadeIn()
			else
				$("canvas#grid").fadeOut()		

	bindBuildCanvas: ->
		$("button.buildcanvas").click (event) =>
			particles = $(".initial-particles").val()
			size = $(".grid-size").val()
			fps = $(".refresh-rate").val()
			console.log fps, particles, size
			delete window.painter
			@painter.buildBoard fps, size, particles

			
	#### General functions (multiple callers)

	updateStateCount: =>

		document.querySelector(".count").innerHTML = window.stateCount

	#### DOM Binders

	detectMouse: ->
		window.mouseDown = false
		$(document).mousedown (event) =>
			window.mouseDown = true
		$(document).mouseup (event) =>
			window.mouseDown = false

	detectSpacebar: ->
		window.canvasStop = false
		$(document).keydown (event) =>
			if event.keyCode == 32
				if window.canvasStop
					$("button.haltboard").removeClass('active')
					window.canvasStop = false
				else
					$("button.haltboard").addClass('active')
					window.canvasStop = true

	detectMousePos: ->
		window.mouseOverCanvas = false
		$(@canvas).mouseover (event) ->
			window.mouseOverCanvas = true
		$(@canvas).mouseout (event) ->
			window.mouseOuverCanvas = false

	detectCanvasClick: ->
		$(@canvas).mousedown (event) =>
			console.log "oi1"
			if not window.mouseOverCanvas
				return
			console.log "oi2"
			coord = @_getGridPos event
			if not _.isEqual coord, @lastHoveredSquare
				console.log "Click at canvas fired at", coord
				@board.toogleSquare coord

	detectMouseMove: ->
		$(@canvas).mousemove (event) =>
			if window.mouseOverCanvas and window.mouseDown
				coord = @_getGridPos event
				if not _.isEqual coord, @lastHoveredSquare
					@lastHoveredSquare = coord
					@board.addSquare coord
					console.log "Hovering board at square", coord
				@lastHoveredSquare = coord


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
		for icol in [0...canvas.width/gridSize]
			makeLine(context, gridSize*icol, 0, gridSize*icol, canvas.height, .1, 'grey')
		for iline in [0...canvas.height/gridSize]
			makeLine(context, 0, gridSize*iline, canvas.width, gridSize*iline, .1, 'grey')

	###### 

	# Defaults
	gridSize: 10
	initialPop: 1000
	fps: 100

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
		@buildBoard()

	buildBoard: (@fps=@fps, @gridSize=@gridSize, @initialPop=@initialPop) ->
		console.log "@board", @board
		@board = new Board(@canvas.board, @gridSize, @initialPop)
		@dispatcher = new EventDispatcher(@)
		@dispatcher.setBoard(@board)

	loop: ->
		console.log "Looping board:", board, "sync value", @_boardSync 
		
		window.setInterval =>
			# console.log @, @board, canvasStop, mouseDown, mouseOverCanvas
			if window.canvasStop or window.mouseDown and window.mouseOverCanvas
				return
			@board.tick()
		, 1000/@fps


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
	window.painter = new Painter(20, 100)
	window.painter.loop()
	return