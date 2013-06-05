###
Syncrhonizer class writen as require.js module
###

define ->
  class Synchronizer

    """
    The Synchronizer class allows to sync up a number of async calls.

    synchronizer = new Synchronizer()
    synchronizer.when ['ImReady','MeToo'], =>
      doSomething()

    anAsyncProcess callback: => synchronizer.ready "ImReady"
    anotherAsyncProcess callback: => synchronizer.ready "MeToo"

    """

    constructor: (options = {spinner: true}) ->
      @spinner = options.spinner
      @eventsReady = {}
      @callbacks = []

    ready: (name) ->
      @eventsReady[name] = true
      @triggerReadyCallbacks()

    when: (events, callback) ->
      if @spinner
        Application.showSpinner()

      @callbacks.push
        events: events
        callback: callback
      @triggerReadyCallbacks()

    triggerReadyCallbacks: ->
      for data in @callbacks
        for event in data.events
          if @eventsReady[event]
            data.events = _.without data.events, event
        if data.events.length == 0
          @callbacks = _.without @callbacks, data
          data.callback? (null)
          if @spinner
            Application.hideSpinner()


