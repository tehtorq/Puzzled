class PuzzleAssistant

  setup: ->
    @ctx = null
    @picture = null
    @level = null
    @grid = null
    @moves = 0
    @state = "playing"
    @insInterval = null
    @dragging_x = null
    @dragging_y = null
    
    @ctx = @controller.get("canvas").getContext("2d")
    @handleDragBind = @handleDrag.bind(this)
    @handleDragStartBind = @handleDragStart.bind(this)
    @handleDragEndBind = @handleDragEnd.bind(this)
    @handleTapBind = @handleTap.bind(this)
    @clockBind = @clock.bind(this)
    @handleShakeBind = @handleShake.bind(this)
    @startGameBind = @start_game.bind(this)
    @stopGameBind = @stop_game.bind(this)

  start_game: ->
    @insInterval = setInterval(@clockBind, 33)

  stop_game: ->
    clearInterval @insInterval

  activate: (event) ->
    Mojo.Event.listen @controller.get("canvas"), Mojo.Event.dragging, @handleDragBind
    Mojo.Event.listen @controller.get("canvas"), Mojo.Event.dragStart, @handleDragStartBind
    Mojo.Event.listen @controller.get("canvas"), Mojo.Event.dragEnd, @handleDragEndBind
    Mojo.Event.listen @controller.get("canvas"), Mojo.Event.tap, @handleTapBind
    Mojo.Event.listen @controller.stageController.document, Mojo.Event.stageActivate, @startGameBind
    Mojo.Event.listen @controller.stageController.document, Mojo.Event.stageDeactivate, @stopGameBind
    @controller.listen document, "shaking", @handleShakeBind
    @init_level()
    @insInterval = setInterval(@clockBind, 33)

  deactivate: (event) ->
    Mojo.Event.stopListening @controller.get("canvas"), Mojo.Event.dragging, @handleDragBind
    Mojo.Event.stopListening @controller.get("canvas"), Mojo.Event.dragStart, @handleDragStartBind
    Mojo.Event.stopListening @controller.get("canvas"), Mojo.Event.dragEnd, @handleDragEndBind
    Mojo.Event.stopListening @controller.get("canvas"), Mojo.Event.tap, @handleTapBind
    Mojo.Event.stopListening @controller.stageController.document, Mojo.Event.stageActivate, @startGameBind
    Mojo.Event.stopListening @controller.stageController.document, Mojo.Event.stageDeactivate, @stopGameBind
    Mojo.Event.stopListening document, "shaking", @handleShakeBind
    @cleanup_level()

  cleanup: (event) ->
    @cleanup_level()

  freeplay: ->
    level.freeplay is "on"

  init_level: ->
    @picture = null
    @level = null
    @grid = null
    @moves = 0
    @state = "playing"
    @insInterval = null
    width = Mojo.Environment.DeviceInfo.maximumCardWidth
    height = Mojo.Environment.DeviceInfo.maximumCardHeight
    @level = new level(level.selected_size, width, height)
    @picture = new Image()
    @picture.src = level.image_path

  cleanup_level: ->
    @ctx = null
    @picture = null
    @level = null
    @grid = null
    @moves = 0
    @state = "playing"
    @insInterval = null

  handleTap: (event) ->
    if @state is "playing"
      if @level.selected_piece?
        tile = @tile_for_coords(@dragging_x, @dragging_y)
        unless @level.possible_moves(@level.selected_piece).indexOf(tile) is -1
          @level.swap_tiles tile, @level.selected_piece
          date = new Date()
          @grid[tile].time = date.getTime()
      @dragging_x = null
      @dragging_y = null
      @level.selected_piece = null

  handleDragStart: (event) ->
    if @state is "playing"
      @dragging_x = event.down.x
      @dragging_y = event.down.y
      @level.selected_piece = @tile_for_coords(@dragging_x, @dragging_y)
      date = new Date()
      @grid[@level.selected_piece].time = date.getTime()

  handleDragEnd: (event) ->

  handleDrag: (event) ->
    if @state is "playing"
      @dragging_x = event.move.x
      @dragging_y = event.move.y

  handleShake: (event) ->
    @state = "shuffling" if @state is "playing"

  shuffle_level: ->
    tile = 0
    i = 0

    while i < 200
      valid_moves = @level.possible_moves(tile)
      choice = Math.floor(Math.random() * (valid_moves.length + 1))
      choice = choice - 1  if choice is valid_moves.length
      @level.swap_tiles valid_moves[choice], tile
      tile = valid_moves[choice]
      i++
    @state = "playing"

  tile_for_coords: (x, y) ->
    row_length = @level.column_count()
    y_delta = Math.floor(@level.height / row_length)
    x_delta = @level.width / row_length
    row = Math.floor(y / y_delta)
    column = (Math.floor(x / x_delta))
    tile = row * row_length + column % row_length
    tile

  select_piece: (x, y) ->
    tile = @tile_for_coords(x, y)
    @level.select_tile tile  unless @level.possible_moves().indexOf(tile) is -1

  drawTile: (i) ->
    ctx = @ctx
    tile_width = @level.getWidth() / @level.column_count()
    tile_height = @level.getHeight() / @level.row_count()
    ctx.drawImage @picture, @grid[i].image_x, @grid[i].image_y, tile_width, tile_height, @grid[i].x, @grid[i].y, tile_width, tile_height
    ctx.beginPath()
    ctx.moveTo @grid[i].x, @grid[i].y
    ctx.lineTo @grid[i].x + tile_width, @grid[i].y
    ctx.lineTo @grid[i].x + tile_width, @grid[i].y + tile_height
    ctx.lineTo @grid[i].x, @grid[i].y + tile_height
    ctx.lineTo @grid[i].x, @grid[i].y
    ctx.stroke()

  debug: (string) ->
    @controller.showAlertDialog
      onChoose: (inValue) ->

      title: "Debug:"
      message: string
      choices: [
        label: "Ok"
        value: ""
       ]

  debug_board: ->
    string = ""
    row_length = @level.column_count()
    column_length = @level.row_count()
    j = 0

    while j < column_length
      i = 0

      while i < row_length
        string += @level.tiles[j * row_length + i] + ","
        i++
      string += "\n"
      j++
    @controller.showAlertDialog
      onChoose: (inValue) ->

      title: "Debug:"
      message: string
      choices: [
        label: "Ok"
        value: ""
       ]

  drawpuzzle: ->
    unless @grid?
      tile_width = @level.getWidth() / @level.column_count()
      tile_height = @level.getHeight() / @level.row_count()
      @grid = new Array(@level.tiles.length)
      i = 0

      while i < @grid.length
        image_x = (i % @level.column_count()) * tile_width
        image_y = Math.floor(i / @level.row_count()) * tile_height
        @grid[i] = new Gridcell(@level.width / 2, @level.height / 2, image_x, image_y)
        i++
    temp = []
    i = 0

    while i < @level.tiles.length
      temp[i] = i
      i++
    temp.sort (a, b) ->
      if @grid[a].time > @grid[b].time
        return 1
      else return -1  if @grid[b].time > @grid[a].time
      0
    .bind(this)
    y_delta = Math.floor(@level.height / @level.row_count())
    x_delta = @level.width / @level.column_count()
    t = 0

    while t < @level.tiles.length
      i = temp[t]
      tile_for_slot = @level.tiles[i]
      move_x = null
      move_y = null
      if @level.selected_piece is i
        move_x = (@dragging_x - x_delta / 2) - @grid[tile_for_slot].x
        move_y = (@dragging_y - y_delta / 2) - @grid[tile_for_slot].y
      else
        image_column = (i % @level.column_count()) * x_delta
        image_row = Math.floor(i / @level.column_count()) * y_delta
        move_x = image_column - @grid[tile_for_slot].x
        move_y = image_row - @grid[tile_for_slot].y
      speed = 10
      move_x = speed  if move_x > speed
      move_x = -speed  if move_x < -speed
      move_y = speed  if move_y > speed
      move_y = -speed  if move_y < -speed
      @grid[tile_for_slot].x = @grid[tile_for_slot].x + move_x
      @grid[tile_for_slot].y = @grid[tile_for_slot].y + move_y
      @drawTile tile_for_slot
      t++

  clock: ->
    ctx = @ctx
    ctx.clearRect 0, 0, @level.width, @level.height
    @shuffle_level()  while @state is "shuffling"
    @drawpuzzle()
  