class MenuAssistant extends BaseAssistant

  setup: ->
    super
    
    @radioButtonModel =
      value: new Mojo.Model.Cookie("difficulty").get() or "4"
    
    @toggleButtonModel =
      value: new Mojo.Model.Cookie("freeplay").get() or "off"
      disabled: false
    
    @controller.setupWidget("myButton1",
      choices: [
        {label: "Easy", value: "3"}
        {label: "Medium", value: "4"}
        {label: "Hard", value: "5"}
      ]
      @radioButtonModel
    )
    
    @controller.setupWidget "myButton3", {trueValue: "on", falseValue: "off"}, @toggleButtonModel
    @controller.setupWidget "myButton2", {}, label: "Start"
    @controller.setupWidget "myButton4", {}, label: "Change image"

  activate: (event) ->
    super
    
    Mojo.Log.info("HERE")
    
    Mojo.Event.listen @controller.get("myButton4"), Mojo.Event.tap, @select_image
    Mojo.Event.listen @controller.get("myButton2"), Mojo.Event.tap, @start_game
    
    
    # @addListeners(
    #   [@controller.get("myButton4"), Mojo.Event.tap, @select_image]
    #   [@controller.get("myButton2"), Mojo.Event.tap, @start_game]
    # )
    
    Mojo.Log.info("HERE============")

  deactivate: (event) ->
    #super

  cleanup: (event) ->
    #super

  start_game: =>
    difficulty = new Mojo.Model.Cookie("difficulty").get() or "4"
    image_path = new Mojo.Model.Cookie("image").get()
    
    # level = new level(difficulty, @controller.window.innerWidth, @controller.window.innerHeight)
    # level.freeplay = @toggleButtonModel.value
    # level.image_path = image_path
    
    params =
      difficulty: difficulty
      image_path: image_path
      freeplay: "on"
    
    @controller.stageController.pushScene {name: "puzzle", disableSceneScroller: true}, params

  select_image: =>
    params =
      kinds: [ "image" ]
      actionType: "open"
      onSelect: (file) =>
        Mojo.Log.info file.fullPath
        level.image_path = file.fullPath
        imageCookie = new Mojo.Model.Cookie("image")
        imageCookie.put level.image_path

    Mojo.FilePicker.pickFile params, @controller.stageController
