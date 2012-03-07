class level

  constructor: (size, width, height) ->
    @tiles = new Array(size * size)
    @width = width
    @height = height
    
    @selected_size = null
    @image_path = null
    @freeplay = null
    
    i = 0

    while i < @tiles.length
      @tiles[i] = i
      i++
      
    @selected_tile = 0
    
  getHeight: ->
    @height

  getWidth: ->
    @width

  is_sorted: ->
    i = 0

    while i < @tiles.length
      return false  unless @tiles[i] is i
      i++
    
    true

  row_count: ->
    Math.sqrt @tiles.length

  column_count: ->
    Math.sqrt @tiles.length

  select_tile: (tile) ->
    @swap_tiles tile, @selected_tile
    @selected_tile = tile

  swap_tiles: (x, y) ->
    temp1 = @tiles[x]
    temp2 = @tiles[y]
    @tiles[x] = temp2
    @tiles[y] = temp1

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
