/**
 * Uservoice Widget helpe to be used as require.js module
 */
(function(){

	define([],function(){

		return window.UV_widget = function(forum_id,app_id,primary_color,link_color,tab_color){
			
		    
		    var forum_id 		= forum_id,
		    ready			= false,
		    loadInterval 	= 100;

		    UserVoiceHelperEngine = {
		    	_load:function(){
		    		var gaHost,s,checker;
		    		uvHost = 'https:' === document.location.protocol ? 'https://' : 'http://';
		    		s = document.createElement('script');
		    		s.src = uvHost + 'widget.uservoice.com/'+app_id+'.js';
		    		document.getElementsByTagName('head')[0].appendChild(s);
		    		checker = this._wrap(this,this._check);
		    		return setTimeout(checker,loadInterval);
		    	},
		    	_unload:function(){
		    		$('#uvTab').remove()
		    		
		    	},
		    	_check: function(){
		    		var checker;
		    		if(window['UserVoice']){
		    			ready = true;
		    			this._createWidget();
		    		}else{
		    			checker = this._wrap(this,this._check);
		    			return setTimeout(checker, loadInterval);
		    		}
		    	},
		    	_wrap: function(obj,method){
		    		return function(){
		    			return method.apply(obj,arguments);
		    		}
		    	},
		    	_createWidget: function(){
		    		UserVoice = window.UserVoice || [];
					UserVoice.push(['showTab', 'classic_widget', {
						mode: 'full',
						primary_color: primary_color,
						link_color: link_color,
						default_mode: 'feedback',
						tab_label: 'Comentarios y soporte',
						tab_color: tab_color,
						tab_position: 'middle-right',
						tab_inverted: false
					}]);
		    	}

		    };
		    UserVoiceHelperEngine._load();
			return UserVoiceHelperEngine;
		};
	});

}).call(this);
