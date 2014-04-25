define [
  'backbone'
],(Backbone) ->
  class BaseView extends Backbone.View

    initialize: ->
      #if @templateName is undefined
        #console.warn "Missing template name for view."
      _.extend(@,Backbone.Events);
      if JST["#{@templateName}"]?
        @template = JST["#{@templateName}"]
      else
        $templateScript = $("##{@templateName}")
        if $templateScript.length == 1
          @template = _.template $templateScript.html(),null,{'variable':'data','sourceURL':"#{@templateName}"}

        else if @templateName
          console.warn "Missing template #{@templateName}"

      $(@el).addClass @constructor.getName()

    renderTemplateToElement: (data={})->
      data._view = @
      html = @template data
      $html = $(html)
      $html.appendTo(@el)

      return $html

    replaceWith : (view) ->
      $(@el).replaceWith(view.el)
      @remove()

    appendTo : (element) ->
      $(@el).appendTo(element)

    @getTestingInstance : (callback) ->
      callback new this()

    find : (selector) ->
      return $(selector, @el)

    @getName: ->
      return @name or @toString().match(/function (.+)\(\)/)[1]
