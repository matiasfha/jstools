define ['views/baseView'], (BaseView)->

  capitalize = (x) -> x.charAt(0).toUpperCase()+x.substring(1)

  class ApplicationView extends BaseView

    @requiresArguments: false

    initialize: ->
      super()

      @el = $("#mainContainer")[0]
      @rowViews = []

    clearRowViews: ->
      @rowViews = []

    initWithoutTransition : ->

    render : ->
      $(@el).empty()
      for view in @rowViews
        console.log "rendering: #{view.constructor.getName()}"
        $(view.el).appendTo @el
        view.render()

    addRowView: (view) ->
      @rowViews.push view
      view.applicationView = this

    getTransitionTo: (view) ->
      if view
        viewName = view.constructor.route
        transitionName = "transitionFrom#{capitalize viewName}"
        if this[transitionName]
          return transitionName
      return null

    unload: ->

    viewAppear: ->
      toast "#{@constructor.name}::ViewAppear"
