class Slot
  
  constructor: (level, index) ->
    @index = index
    @level = level
    
    @width = @level.width / @level.column_count()
    @height = @level.height / @level.row_count()
    @x = @width * (@index % @level.column_count())
    @y = @height * Math.floor(@index / @level.column_count())
    Mojo.Log.info("#{@x} #{@y} #{@width} #{@height}")

  draw: (ctx) ->
    ctx.strokeStyle = "#ff0000"
    ctx.beginPath()
    ctx.moveTo @x, @y
    ctx.lineTo @x + @width, @y
    ctx.lineTo @x + @width, @y + @height
    ctx.lineTo @x, @y + @height
    ctx.lineTo @x, @y
    ctx.stroke()
    
    ctx.fillStyle = "#ff0000"
    ctx.fillText("#{@index}", @x, @y + @height / 2)
    
  contains: (x, y) ->
    (x >= @x) and (x <= (@x + @width)) and (y >= @y) and (y <= (@y + @height))
    
  find_tile: ->
    _.first _.select(@level.tiles, (tile) => tile.slot.index is @index)
