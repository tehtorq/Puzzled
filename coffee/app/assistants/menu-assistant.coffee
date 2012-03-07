class MenuAssistant

  setup: ->
    radioButtonModel =
      value: null
    
    @toggleButtonModel =
      value: "off"
      disabled: false
      
    difficultyCookie = new Mojo.Model.Cookie("difficulty")
    value = difficultyCookie.get()
    @radioButtonModel.value = value if value
    freeplayCookie = new Mojo.Model.Cookie("freeplay")
    value = difficultyCookie.get()
    @toggleButtonModel.value = value if value
    @controller.setupWidget "myButton1",
      choices: [
        label: "Easy"
        value: "3"
      ,
        label: "Medium"
        value: "4"
      ,
        label: "Hard"
        value: "5"
       ]
    , @radioButtonModel
    @controller.setupWidget "myButton3",
      trueValue: "on"
      falseValue: "off"
    , @toggleButtonModel
    @controller.setupWidget "myButton2", {},
      label: "Start"

    @controller.setupWidget "myButton4", {},
      label: "Change image"

    @pickImageBind = @select_image.bind(this)
    @startGameBind = @start_game.bind(this)

  activate: (event) ->
    Mojo.Event.listen @controller.get("myButton4"), Mojo.Event.tap, @pickImageBind
    Mojo.Event.listen @controller.get("myButton2"), Mojo.Event.tap, @startGameBind

  deactivate: (event) ->
    Mojo.Event.stopListening @controller.get("myButton4"), Mojo.Event.tap, @pickImageBind
    Mojo.Event.stopListening @controller.get("myButton2"), Mojo.Event.tap, @startGameBind

  cleanup: (event) ->

  start_game: ->
    level.selected_size = @radioButtonModel.value
    difficultyCookie = new Mojo.Model.Cookie("difficulty")
    difficultyCookie.put level.selected_size
    imageCookie = new Mojo.Model.Cookie("image")
    value = imageCookie.get()
    level.image_path = value  if value
    level.freeplay = @toggleButtonModel.value
    
    @controller.stageController.pushScene
      name: "puzzle"
      disableSceneScroller: true

  select_image: ->
    params =
      kinds: [ "image" ]
      actionType: "open"
      onSelect: (file) =>
        level.image_path = file.fullPath
        imageCookie = new Mojo.Model.Cookie("image")
        imageCookie.put level.image_path

    Mojo.FilePicker.pickFile params, @controller.stageController
