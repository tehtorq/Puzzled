class PuzzleAssistant extends BaseAssistant

  setup: (params) ->
    @params = params
    
    #super
    
    @dragging_x = null
    @dragging_y = null

  activate: (event) ->
    #super
    
    Mojo.Event.listen @controller.get("canvas"), Mojo.Event.dragging, @handleDrag
    Mojo.Event.listen @controller.get("canvas"), Mojo.Event.dragStart, @handleDragStart
    Mojo.Event.listen @controller.get("canvas"), Mojo.Event.dragEnd, @handleDragEnd
    Mojo.Event.listen @controller.get("canvas"), Mojo.Event.tap, @handleTap
    Mojo.Event.listen @controller.stageController.document, Mojo.Event.stageActivate, @start_game
    Mojo.Event.listen @controller.stageController.document, Mojo.Event.stageDeactivate, @stop_game
    Mojo.Event.listen document, "shaking", @handleShake
    
    # @addListeners(
    #       [@controller.get("canvas"), Mojo.Event.dragging, @handleDrag]
    #       [@controller.get("canvas"), Mojo.Event.dragStart, @handleDragStart]
    #       [@controller.get("canvas"), Mojo.Event.dragEnd, @handleDragEnd]
    #       [@controller.get("canvas"), Mojo.Event.tap, @handleTap]
    #       [@controller.stageController.document, Mojo.Event.stageActivate, @start_game]
    #       [@controller.stageController.document, Mojo.Event.stageDeactivate, @stop_game]
    #       [document, "shaking", @handleShake]
    #     )
    
    #@log JSON.stringify(@params)
    
    @level = new Level(5, @controller.window.innerWidth, @controller.window.innerHeight)
    @level.freeplay = "on"
    @level.image_path = "/media/internal/wallpapers/10.jpg"
    
    #@log JSON.stringify(@level)
    
    @init_level()
    @start_game()

  deactivate: (event) ->
    #super    
    #@cleanup_level()

  cleanup: (event) ->
    super
    #@cleanup_level()
    
  start_game: =>
    @insInterval = @controller.window.setInterval(@clock, 33)

  stop_game: =>
    clearInterval @insInterval

  freeplay: ->
    @level.freeplay is "on"
    
  clock: =>
    #Mojo.Log.info("clock")
    @ctx.clearRect 0, 0, @level.width, @level.height
    @shuffle_level() while @state is "shuffling"
    @drawpuzzle()

  init_level: ->
    @ctx = @controller.get("canvas").getContext("2d")
    @grid = null
    @moves = 0
    @state = "playing"
    @insInterval = null
    #@level = new level(selected_size, @controller.window.innerWidth, @controller.window.innerHeight)
    @picture = new Image()
    @picture.src = @level.image_path
    @level.image = @picture
    @dragging = false

  cleanup_level: ->
    @ctx = null
    @picture = null
    @level = null
    @grid = null
    @moves = 0
    @state = "playing"
    @insInterval = null

  handleTap: (event) =>
    return unless @state is "playing"
    return @handleDragEnd(event) if @dragging is true

    tap_x = event.down.x
    tap_y = event.down.y
    
    tile = @level.slot_for_coords(tap_x, tap_y).find_tile()

    if @level.selected_piece?
      @level.swap_tiles @level.selected_piece, tile
      @level.selected_piece = null
    else
      @level.selected_piece = tile

  handleDragStart: (event) =>
    return unless @state is "playing"
    @dragging = true
    
    @dragging_x = event.down.x
    @dragging_y = event.down.y
    
    @level.selected_piece = @level.slot_for_coords(@dragging_x, @dragging_y).find_tile()
    
    #@level.selected_piece = @level.tile_for_coords(@dragging_x, @dragging_y)
    
  handleDrag: (event) =>
    return unless @state is "playing"

    @dragging_x = event.move.x
    @dragging_y = event.move.y

  handleDragEnd: (event) =>
    #Banner.send("drag ended")
    @dragging = false
    
    tile = @level.slot_for_coords(@dragging_x, @dragging_y).find_tile()
    
    if @level.selected_piece?
      @level.swap_tiles @level.selected_piece, tile
      @level.selected_piece = null
    
    @dragging_x = null
    @dragging_y = null

  handleShake: (event) =>
    @state = "shuffling" if @state is "playing"

  shuffle_level: ->
    @level.shuffle(200)
    @state = "playing"

  draggingTile: ->
    @level.selected_piece? and @dragging_x? and @dragging_y?
    
  drawpuzzle: ->
    _.each @level.slots, (slot) =>
      slot.draw(@ctx)
      
    _.each @level.tiles, (tile) =>
      
      if (@level.selected_piece?) and (@level.selected_piece.slot.index is tile.slot.index) and (@dragging is true)
        move_x = @dragging_x - tile.x
        move_y = @dragging_y - tile.y
      else
        move_x = tile.slot.x - tile.x
        move_y = tile.slot.y - tile.y
      
      if @dragging
        speed = 1000
      else
        speed = 10
        
      move_x = speed if move_x > speed
      move_x = -speed if move_x < -speed
      move_y = speed if move_y > speed
      move_y = -speed if move_y < -speed
      
      tile.x += move_x
      tile.y += move_y
      
      tile.draw(@ctx)
