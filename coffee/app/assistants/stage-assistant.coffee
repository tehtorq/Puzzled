class StageAssistant
  setup: ->
    @controller.pushScene
      name: "menu"
      disableSceneScroller: true