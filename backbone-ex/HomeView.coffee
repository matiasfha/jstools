define [
	'Synchronizer'
	'views/BaseView'
	'views/ApplicationView'
	'views/TopSearchView'
	'collections/CarpoolTripCollection'
	'collections/UserCollection'
	'collections/ArticlesCollection'
	'collections/StatisticCollection'
	'bootstrap-tooltip'
], (Synchronizer, BaseView, ApplicationView, TopSearchView, CarpoolTripCollection, UserCollection,ArticlesCollection,StatisticCollection,Tooltip) ->

	elementInDocument = (elem) ->
		while elem = elem.parentNode
			if elem == document
				return true
		return false

	class Thumbnail extends BaseView

		templateName: "thumbnailTemplate"
		className: "thumb"
		events:
			'click .system-user-thumb' : 'thumbClicked'

		render: ->
			@renderTemplateToElement
				avatar: @model.getAvatarUrl(60)
				name: @model.get('first_name')
				full_name : @model.getFullName()
				url:@model.getProfileUrl()

		thumbClicked:(e) ->
			Application.showSpinner("",@)
			route = $(e.currentTarget).attr('data-url')
			Application.router.navigate route, trigger: true
			false



	class SystemUsersView extends BaseView
		templateName: "systemUsersTemplate"

		events:
			'click .js-user-search-btn': 'userSearchBtnClicked'
			'keypress .js-user-query-input' : 'userQueryInputKeyPressed'


		initialize: (options) ->
			super(options)

			@collection = new UserCollection()
			@collection.bind('reset', @render, this)
			@collection.bind('change', @render, this)
			@collection.searchSampleUsers {success: => @trigger "load"}
			@q = ""

		render: ->
			super()
			$(@el).empty()

			if @collection.models.length > 0
				@renderTemplateToElement
					num_total_users: @collection.meta.total_count, q: @q

				for user in @collection.models
					thumb = new Thumbnail model: user
					$(".nugget", @el).append thumb.el
					thumb.render()
			else
				@renderTemplateToElement
					num_total_users: "-"
					q: @q

			@delegateEvents()
			return this

		userSearchBtnClicked: ()->
			@q = $(".js-user-query-input", @el).val()
			@collection.search(@q)

		userQueryInputKeyPressed: (event)->
			if event.keyCode == 13 #enter
				$('.js-user-search-btn').click()

	class UpcomingTripsView extends BaseView
		templateName: 'upcomingTripsTemplate'
		events:
			'click div.upcomingItem:not(.image)':'itemSelected'

		initialize: (options) ->
			super(options)
			@updatePeriod = 10000

			@carpools = new CarpoolTripCollection()


			@collection = new Backbone.Collection()
			@collection.bind('reset', @render, this)
			trips = []
			@carpools.searchUpcoming
				success: =>
					trips = @carpools.models
					sorted = _.sortBy @carpools.models, (trip) -> trip.getNextOcurrence()
					@collection.reset(sorted,{silent:true})
					@trigger 'load'


		fetch: ->
			trips = []
			synchronizer = new Synchronizer(spinner: false)
			synchronizer.when ["carpool"], =>
				sorted = _.sortBy trips, (trip) => trip.getNextOcurrence()
				@collection.reset(sorted)

			@carpools.searchUpcoming
				success: =>
					for trip in @carpools.models
						trips.push trip
					synchronizer.ready "carpool"


		setUpdate: (enabled)->
			update = =>
				if not elementInDocument(@el)
					clearInterval @updateTo
					return
				@render()

				if @collection.models.length > 2
					tripRolledOver = @collection.models[0].getNextOcurrence() >= @collection.models[1].getNextOcurrence()

				if @collection.models.length > 0
					tripPassed = @collection.models[0].getNextOcurrence() <= (new Date())

				if tripRolledOver or tripPassed
					@fetch()

			clearInterval @updateTo
			if enabled
				@updateTo = setInterval (update), @updatePeriod

		render: ->
			$(@el).empty()
			@renderTemplateToElement()
			for item in @collection.models
				data =
					origin: item.getOrigin().get('address1')
					destination: item.getDestination().get('address1')
					departure: item.getDepartureCountdown()
					avatar: item.getCreatorAvatarUrl()
					id: item.get('id')
					creator_name: item.getCreatorName()
					creator_url : item.getProfileUrl()
					transport: item.get('transport').get('id')


				view = new UpcomingItemView data: data
				$('.upcoming-nugget',@el).append view.el
				view.render()
			return this


		itemSelected: (e) ->
			target = $(e.currentTarget)
			id = target.attr('id').split('-')[1]
			e.stopPropagation()
			route = "upcoming_trips/#{id}/"
			Application.router.navigate route, trigger: true
			toast "Se mostrará detalle del viaje"

	class UpcomingItemView extends BaseView

		templateName: "upComingItemTemplate"
		events:
			'click .image':'goToProfile'

		initialize:(options) ->
			@trip = options.data
			@template = JST["#{@templateName}"]

		render: ->
			cdText = ""
			if @trip.departure.totalSecs > 0
				if @trip.departure.hours > 0
					cdText = @trip.departure.hours + " hrs "
				cdText += @trip.departure.minutes + " min"
			else
				cdText = "Ya salió"
			@trip.cdText = cdText

			if @trip.transport
				if @trip.transport == '2'
				  	transport_icon_class = 'upcoming-icon-ryder'
				else
				 	 transport_icon_class = 'upcoming-icon-driver'
			else
				transport_icon_class = 'upcoming-icon-passenger'

			data =
				trip: @trip
				transport_icon_class: transport_icon_class
			@renderTemplateToElement data

		goToProfile: (e) ->
			route = $(e.currentTarget).attr('data-route')
			Application.router.navigate route, trigger:true
			e.stopPropagation()
			false



	#Clase para mostrar el nugget de noticias
	class NewsPreviewView extends BaseView
		templateName: "newsPreviewTemplate"

		initialize: (options) ->
			super(options)
			@collection = new ArticlesCollection()
			@collection.fetch({success:=> @trigger('load')})

		render: ->
			$(@el).empty()
			@renderTemplateToElement {articles:@collection.getData()}



	class HomeContentView extends BaseView

		className: ""
		templateName: "homeContentTemplate"

		initialize: (options)->
			super(options)

			@synchronizer = new Synchronizer(spinner: true)
			@synchronizer.when ['upcoming','news','users'], => #'statistics',
				@render()


			# @statisticsCollection = new StatisticCollection()
			# @statisticsCollection.fetch
			#   success: =>
			#     @synchronizer.ready("statistics")

			@upcomingTripsView = new UpcomingTripsView()
			@upcomingTripsView.bind "load", () => @synchronizer.ready("upcoming")

			@systemUsersView = new SystemUsersView()
			@systemUsersView.bind "load", () => @synchronizer.ready("users")

			@newsView = new NewsPreviewView()
			@newsView.bind 'load', () => @synchronizer.ready("news")

		render : ->
			super()

			# statistics =
			#   shared_trips_kms: 0
			#   shared_trips_count: 0
			#   co2_savings: 0
			#   money_savings: 0

			# for statistic in @statisticsCollection.models
			#   name = statistic.get('name')
			#   if name of statistics
			#     statistics[statistic.get('name')] = statistic.get('value')

			# co2_savings = statistics['co2_savings']
			# gas_savings = statistics['money_savings']
			# total_trips_count = statistics['shared_trips_count']


			@renderTemplateToElement()

			$(".js-upcoming-nugget", @el).append @upcomingTripsView.el
			@upcomingTripsView.render()
			@upcomingTripsView.setUpdate(true)


			$(".js-nugget-users", @el).append @systemUsersView.el
			@systemUsersView.render()

			$('.js-nugget-news',@el).append @newsView.el
			@newsView.render()

			return this

	class HomeView extends ApplicationView
		@route: "home"

		initialize: ->
			super()
			@contentView = new HomeContentView()
			@find('.mainContainer').removeAttr('style')
			@topSearchView = TopSearchView.getInstance()

		initWithoutTransition: ->
			@topSearchView.addSearchOverlay()
			@topSearchView.render()
			@appendContentView()
			Application.hideSpinner()


		appendContentView : ->
			@find('.mainContainer').empty().append @contentView.el
			# @contentView.render()
			Application.hideSpinner()

		genericTransition:() ->
			@find('.mainContainer')
			.removeAttr('class')
			.removeAttr('style')
			.addClass('mainContainer')
			.empty()
			@topSearchView.bind 'showed', () =>
				@topSearchView.clearGoogleOverlays()
				@topSearchView.regenerateMap()
				@topSearchView.addSearchOverlay()
				@topSearchView.render()
			@topSearchView.show()

			@appendContentView()

		transitionFromTerms: ->
			@find('.mainContainer')
			.removeAttr('class')
			.removeAttr('style')
			.addClass('mainContainer')
			.empty()
			$('.map-container').show()
			@topSearchView.regenerateMap()
			@topSearchView.addSearchOverlay()
			@topSearchView.render()
			@topSearchView.show()
			$('#boton-mapa').show()
			@appendContentView()



		transitionFromCreateTrip: (prevView) ->
			@genericTransition()

		transitionFromMensajes:() =>
			@genericTransition()

		transitionFromUserTrips:(prevView) =>
			@genericTransition()

		transitionFromUpcoming:(prevView) ->
			@genericTransition()

		transitionFromSearchResults: (prevView) ->
			@genericTransition()

		transitionFromNotificaciones:(prevView) ->
		 	@genericTransition()

		transitionFromUserTripDetail:(prevView) ->
			$('.map-container').removeClass('notVisible')
			$('.map-container').css('height',300)
			$('#boton-mapa').removeClass('boton-mapa-back')
			$('#boton-mapa').css('margin-top','0px')
			@appendContentView()

		transitionFromUserProfile:(prevView) =>
			@genericTransition()

		transitionFromWelcome: (prevView) ->
			@find('.mainContainer')
			.removeAttr('class')
			.removeAttr('style')
			.addClass('mainContainer')
			.empty()
			@find('.map-container').removeAttr('style').removeClass('login')
			@find('.fondoFooter').removeClass('login')
			@find('footer').removeClass('login')
			@find('body').removeClass('login')
			prevView.topContainer.empty()
			@topSearchView = TopSearchView.getInstance()
			@topSearchView.addSearchOverlay()
			@topSearchView.bind 'showed', () =>
				@topSearchView.regenerateMap()
				@topSearchView.addSearchOverlay()
				@topSearchView.render()
			@topSearchView.show()

			@appendContentView()

		transitionFromError: (prevView) ->
			@find('.mainContainer')
			.removeAttr('class')
			.removeAttr('style')
			.addClass('mainContainer')
			.empty()
			@find('.map-container').removeAttr('style').removeClass('login')
			prevView.topContainer.empty()
			@topSearchView = TopSearchView.getInstance()
			@topSearchView.addSearchOverlay()
			@topSearchView.bind 'showed', () =>
				@topSearchView.regenerateMap()
				@topSearchView.addSearchOverlay()
				@topSearchView.render()
			@topSearchView.show()

			@appendContentView()

		transitionFromTerms:(prevView) ->
			$('.map-container').find('.terms-overlay').remove()
			@genericTransition()

