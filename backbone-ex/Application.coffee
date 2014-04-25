define [
	'views/FooterView'
	'views/LoadingSpinner'
	'rpcs'
	'BaseRouter'
	'models/CurrentUser'
	'collections/PushCollection'
	'PusherConfig'
	'views/NavigationBarView'
	'views/HomeView'
	'views/TermsView'
	'views/PublishTripView'
	'views/SearchResultsView'
	'views/HelpView'
	'views/UpcomingView'
	'views/MyTripsView'
	'views/NotificationsView'
	'views/DetailTripView'
	'views/ProfileView'
	'views/MessagesView'
	'views/ErrorView'
], (FooterView,LoadingSpinner, rpc, BaseRouter, CurrentUser,PushCollection,PusherConfig, NavigationBarView, views...) ->

	get = (name) ->
		name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]")
		regexS = "[\\?&]" + name + "=([^&#]*)"
		regex = new RegExp(regexS)
		results = regex.exec(window.location.search)
		unless results?
			""
		else
			decodeURIComponent results[1].replace(/\+/g, " ")


	class Base

		applicationViews: {}

		register : (view) ->
			@applicationViews[view.route] = view

		constructor: ->
			@currentView = false
			@spinner = LoadingSpinner.getInstance(el: $('<div class="loading-container"></div>')[0])


		showSpinner: (msg="Cargando...",caller=null) ->
			@spinner.show()

		hideSpinner: (msg="Cargando...",caller=null)->
			@spinner.hide()
		init: ->
			Backbone.history.start pushState: Modernizr.history, silent: true, root:'/home'
			@user = CurrentUser.getInstance()

			if window.location.hash == "" && !Modernizr.history
				url = window.location.protocol + "//"
				url += window.location.host + "/#" + window.location.pathname.slice(1)
				console.log("Redirect to #{url}")
				window.location.href = url

			#Si el usuario se logea
			@user.bind 'change:id', () =>
				if @user.isAuthenticated()
					@notifications = new PushCollection([],{type:'notifications'})
					@messages      = new PushCollection([],{type:'messages'})
					@pusher = PusherConfig.getInstance().getPusher()
					@notifications.fetch({success: => @notifications.trigger('reset')})
					@messages.fetch({success: => @messages.trigger('reset')})
					window.UV_widget(Settings.USERVOICE_FORUM_ID, Settings.USERVOICE_APP_ID,"##{Settings.USERVOICE_PRIMARY_COLOR}", "##{Settings.USERVOICE_LINK_COLOR}", "##{Settings.USERVOICE_TAB_COLOR}");
					if $(@navigationBarView.el).is(':hidden')
						$(@navigationBarView.el).show()

			$('body').click () ->
				$('#passengeredit-box').remove()
				$('#profile-box',@el).slideUp()

			# top navigation bar
			@navigationBarView = new NavigationBarView()
			$navigationBar = $(".header")
			$navigationBar.empty()
			$navigationBar.append(@navigationBarView.el)

			footerView = new FooterView()
			$("footer").append(footerView.el)
			footerView.render()
			@loginAndContinue()
			Application.hideSpinner()

		cleanLocation: ->
			url = window.location.protocol + "//"
			url += window.location.host + "/home"
			if Modernizr.history
				window.history.replaceState "Object", "Title", url

		loginAndContinue: ->
			request = window.location.pathname.substring(1)
			request or= window.location.hash.substring(1)
			request = request.substring(5,request.length)
			rpc.getUser
				success: (response) =>
					@user.set(response)
					requesting_recover = request.substring(0,7) == "recover"
					requesting_notifications = request.substring(0,13) == "notifications"
					request = decodeURIComponent(request.replace("home/",""))
					if requesting_recover
						request = 'profile/edit/'
					if requesting_notifications
						request = "notifications"

					@cleanLocation()
					if @user.isAuthenticated()
						request = '/home' if request == ''
						console.log(request)
						Application.router.navigate request, trigger:true
					else
						request = request.replace('/','')
						if request.length > 0
							route = "/?next=#{request}"
						else
							route = '/'
						@hideSpinner()
						window.location.href = route
				error:(error) =>
					request = decodeURIComponent(request.replace("home/",""))
					request = request.replace('/','')
					if request.length > 0
						route = "/?next=#{request}"
					else
						route = '/'
					@hideSpinner()
					window.location.href = route


		getRouter: -> new BaseRouter()

		navigateTo: (viewName, options={}) ->
			@booting = false
			@currentViewName = viewName
			if Application.user.isAuthenticated()
				if not Application.user.hasAcceptedTerms() and viewName != "terms"
					Application.router.navigate "terms", trigger: true
					return
			else if  viewName != "terms"
				route = "/"+Backbone.history.getFragment().replace("/","")
				Application.router.navigate route, trigger: true
				return

			viewClass = @applicationViews[viewName]
			if not viewClass
				toast "view does not exist: #{viewName}"
				return

			if window.currentView
				window.currentView.unload()

			if viewClass.requiresArguments and $.isEmptyObject options
				toast "Missing arguments for #{viewClass.getName()}"
				@navigateTo("home")
				return
			view = new viewClass(options)
			transition = view.getTransitionTo window.currentView
			if transition
				view[transition](@currentView)
			else
				view.initWithoutTransition()
				view.render()
			@currentView = view

			window.currentView = view
			view.viewAppear()

	app = new Base()
	for view in views
		app.register view
	app.router = app.getRouter()
	return app
