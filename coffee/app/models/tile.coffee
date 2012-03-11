class Tile
  
  constructor: (slot) ->
    @slot = slot
    @originalSlot = @slot
    
    @width = @slot.width
    @height = @slot.height
    @x = @slot.x
    @y = @slot.y
    
    @image_x = @x
    @image_y = @y
    
  inOriginalPosition: ->
    tile.originalSlot.index is tile.slot.index
    
  image: ->
    @slot.level.image
    
  draw: (ctx) ->
    width = @width
    height = @height
    
    if (@image_y + height) > @image().height
      height = height - ((@image_y + height) - @image().height)
    if (@image_x + width) > @image().width
      width = width - ((@image_x + width) - @image().width)
    
    ctx.drawImage @image(), @image_x, @image_y, width, height, @x, @y, width, height
    
  contains: (x, y) ->
    (x >= @x) and (x <= (@x + @width)) and (y >= @y) and (y <= (@y + @height))