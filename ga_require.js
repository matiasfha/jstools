/**
 * Google Analytics helper to be used as require.js module
 */

(function() {

  define(['require'], function(require) {
    return window.GATracking = function(ANALYTICS_ID,DOMAIN_NAME) {
      var GATrackingEngine, domainName, loadInterval, page, ready, trackingLabel, urchinId, _dev_log;
      urchinId = ANALYTICS_ID;
      
      page = null;
      trackingLabel = false;
      domainName = DOMAIN_NAME;
      _dev_log = false;
      loadInterval = 100;
      ready = false;
      if (!urchinId || !isNaN(urchinId)) {
        alert('Invalid Google Analytics ID given, please ensure its a valid ID like the following example: UA-XXXXXXX-X');
        return;
      }
      GATrackingEngine = {
        _load: function() {
          var checker, gaHost, s;
          gaHost = 'https:' === document.location.protocol ? 'https://ssl.' : 'http://www.';
          s = document.createElement('script');
          s.src = gaHost + 'google-analytics.com/analytics.js';
          document.getElementsByTagName('head')[0].appendChild(s);
          checker = this._wrap(this, this._check);
          return setTimeout(checker, loadInterval);
        },
        _check: function() {
          var checker, gaTracker, pageTracker;
          if (window['_gat']) {
            gaTracker = _gat._createTracker(urchinId);
            gaTracker._setDomainName(domainName);
            gaTracker._initData();
            ready = true;
            return pageTracker = gaTracker;
          } else {
            checker = this._wrap(this, this._check);
            return setTimeout(checker, loadInterval);
          }
        },
        trackPageview: function(page) {
          var tpv;
          if (ready) {
            if (page === null) {
              gaTracker._trackPageview();
            } else {
              gaTracker._trackPageview(page);
            }
            return this.log('manual trackPageview: ' + page);
          } else {
            tpv = this._wrap(this, this.trackPageview);
            return setTimeout((function() {
              return tpv(page);
            }), loadInterval);
          }
        },
        trackEvent: function(category, action, label) {
          var te;
          if (ready) {
            gaTracker._trackEvent(category, action, (trackingLabel !== false ? trackingLabel : label));
            return this.log('trackEvent: ' + category + ', ' + action + ', ' + label);
          } else {
            te = this._wrap(this, this.trackEvent);
            return setTimeout((function() {
              return te(category, action, label);
            }), loadInterval);
          }
        },
        log: function(msg) {
          if (window.console && window.console.log && _dev_log) {
            return console.log(msg);
          }
        },
        _wrap: function(obj, method) {
          return function() {
            return method.apply(obj, arguments);
          };
        }
      };
      GATrackingEngine._load();
      return GATrackingEngine;
    };
  });

}).call(this);

