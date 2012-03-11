class Level

  constructor: (size, width, height) ->
    @slot_count = size * size
    @width = Math.floor(width / size) * size
    @height = Math.floor(height / size) * size
    
    @slots = _.map _.range(size * size), (i) =>
      new Slot(@, i)
      
    @tiles = _.map @slots, (slot) =>
      new Tile(slot) 
    
    @image_path = null
    @freeplay = null
    @selected_tile = null

  is_sorted: ->
    _.all @tiles, (tile) ->
      tile.inOriginalPosition()

  row_count: ->
    Math.sqrt @slot_count

  column_count: ->
    Math.sqrt @slot_count

  select_tile: (tile) ->
    @swap_tiles tile, @selected_tile
    @selected_tile = tile

  swap_tiles: (first_tile, second_tile) ->
    slot1 = first_tile.slot
    slot2 = second_tile.slot
    
    second_tile.slot = slot1
    first_tile.slot = slot2
  
  possible_moves: (tile) ->
    row_length = @column_count()
    possible_moves = []
    valid_moves = []
  
    if level.freeplay is "on"
      i = 0

      while i < @tiles.length
        possible_moves[i] = i
        i++
    else
      if (tile % row_length) is (row_length - 1)
        possible_moves = [ tile - row_length, tile + row_length, tile - 1 ]
      else if (tile % row_length) is 0
        possible_moves = [ tile - row_length, tile + row_length, tile + 1 ]
      else
        possible_moves = [ tile - row_length, tile + row_length, tile - 1, tile + 1 ]
  
    i = 0

    while i < possible_moves.length
      valid_moves.push possible_moves[i]  if (possible_moves[i] >= 0) and (possible_moves[i] < @tiles.length)
      i++
  
    valid_moves

  shuffle: (iterations) ->
    tile = 0
    i = 0

    while i < iterations
      valid_moves = @possible_moves(tile)
      choice = Math.floor(Math.random() * (valid_moves.length + 1))
      choice = choice - 1  if choice is valid_moves.length
      @level.swap_tiles valid_moves[choice], tile
      tile = valid_moves[choice]
      i++

  slot_for_coords: (x, y) ->
    _.first(_.select @slots, (slot) -> slot.contains(x, y))
          
  tile_for_coords: (x, y) ->
    _.first(_.select @tiles, (tile) -> tile.contains(x, y))
