# board.coffee for https://github.com/f03lipe/game-of-life


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

fillGridSquare = (context, size, coord) ->
	context.fillStyle = rainbow(coord.x+coord.y, 10)
	context.fillRect size*coord.x, size*coord.y, size, size

clearGridSquare = (context, size, coord) ->
	context.clearRect size*coord.x, size*coord.y, size, size

class window.Board

	boardState 	: []
	DEAD 		: null
	ALIVE 		: 1

	constructor: (@canvas, gridSize=10, pop=null) ->
		@context 	= @canvas.getContext "2d"
		pop ?= @WIDTH*@HEIGHT*.5
		@resetBoard(pop, gridSize)

	initializeBoard: ->
		console.log "Initializing boardState #{@WIDTH} by #{@HEIGHT}"
		boardState = []
		for i in [0...@WIDTH]
			boardState[i] = Array(@HEIGHT)
			for i2 in [0...@HEIGHT]
				boardState[i][i2] = @DEAD
		@boardState = boardState
		@context.clearRect 0, 0, @canvas.width, @canvas.height

	resetBoard: (@initialPop=@initialPop, @gridSize=@gridSize)->
		@WIDTH 		= ~~(@canvas.width/@gridSize)+1    
		@HEIGHT 	= ~~(@canvas.height/@gridSize)+1

		@initializeBoard()
		@context.clearRect 0, 0, @canvas.width, @canvas.height
		@toogleSquare(@_getRandBoardPos()) for i in [1..@initialPop]

	clearBoard: ->
		@initializeBoard()
		@context.clearRect 0, 0, @canvas.width, @canvas.height

	###### Canvas manipulation functions

	addSquare: (coord) ->
		@boardState[coord.x][coord.y] = @ALIVE
		fillGridSquare(@context, @gridSize, coord)

	toogleSquare: (coord) =>
		if @boardState[coord.x][coord.y]
			clearGridSquare(@context, @gridSize, coord)
			@boardState[coord.x][coord.y] = @DEAD
		else
			fillGridSquare(@context, @gridSize, coord)
			@boardState[coord.x][coord.y] = @ALIVE

	###### Main Engine

	render: (newState) ->
		# Toogles the squares in which newState differs from @boardState.
		for x in [0...newState.length] when not _.isEqual newState[x], @boardState[x] # Prevent loop in non-changed strips.
			for y in [0...newState[x].length] when newState[x][y] != @boardState[x][y]
				if not newState[x][y]
					clearGridSquare(@context, @gridSize, {x:x, y:y})
				else
					fillGridSquare(@context, @gridSize, {x:x, y:y})

	tic: ->
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
			$(@).trigger 'toc', {empty: @_isEmptyBoard(@boardState)}

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

	_isEmptyBoard: (boardState=@boardState) ->
		for x in [0...@WIDTH]
			for y in [0...@HEIGHT]
				if boardState[x][y] != @DEAD
					return false
		return true



