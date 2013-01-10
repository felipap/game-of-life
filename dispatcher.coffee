# dispatcher.coffee for https://github.com/f03lipe/game-of-life

class window.EventDispatcher
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

	constructor: (@board, @painter) ->
		@canvas = @board.canvas

		console.log "Attaching listeners to board:", @board
		# Bind DOM events
		@detectMouseDown()
		@detectSpacebar()
		@detectMouseOverCanvas()
		@detectCanvasClick()
		@detectMouseMove()

		# Bind buttons
		@bindBoardToc()
		@bindStopButton()
		@bindClearButton()
		@bindShowConfigPanel()
		@bindHideGrid()
		@bindBuildBoard()

	bindBoardToc: ->
		# Binds a 'toc' event from the Board, called each time Board.tic() is executed.
		window.stateCount = 0
		$(@board).bind 'toc', (event, context) =>
			if not context.empty
				@painter.incStateCounter()

	bindStopButton: ->
		# Somewhy this is called before Bootstrap's api, and when the button is
		# pressed, the .active class won't be set on it and vice versa.
		# This function must return true, otherwise the eventbubble will stop.
		# See https://github.com/twitter/bootstrap/issues/2380
		$('body').on 'click', 'button.haltboard', (event) =>
			if $(event.target).hasClass('active')
				window.canvasStop = false
			else
				window.canvasStop = true
			return true

	bindClearButton: ->
		$("button.clearboard").click (event) =>
			window.stateCount = 0
			@board.clearBoard()
			@painter.resetStateCounter()

	bindShowConfigPanel: ->
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
		# Update form with default values.
		$('[name="refresh-rate"]').val(@painter.fps)
		$('[name="initial-particles"]').val(@painter.initialPop)
		$('[name="grid-size"]').val(@painter.gridSize)

	bindHideGrid: ->
		$("button.hidegrid").click (event) =>
			if $("button.hidegrid").hasClass "active"
				$("canvas#grid").fadeIn()
			else
				$("canvas#grid").fadeOut()		

	bindBuildBoard: ->
		$("button.buildboard").click (event) =>
			@painter.changeBoardSpecs
				fps: 		$('[name="refresh-rate"]').val()
				initialPop:	$('[name="initial-particles"]').val()
				gridSize:	$('[name="grid-size"]').val()

	###### DOM Binders

	detectMouseDown: ->
		window.mouseDown = false
		$(@canvas).mousedown (event) =>
			window.mouseDown = true
		$(@canvas).mouseup (event) =>
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

	detectMouseOverCanvas: ->
		window.mouseOverCanvas = false
		$(@canvas).mouseover (event) ->
			window.mouseOverCanvas = true
		$(@canvas).mouseout (event) ->
			window.mouseOuverCanvas = false

	detectCanvasClick: ->
		$(@canvas).mousedown (event) =>
			coord = @_getGridPos event
			if not _.isEqual coord, @lastHoveredSquare
				console.log "Click on canvas fired at", coord
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