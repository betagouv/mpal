;(function($) {
	var url;

	$.urlLib = {
		// Function to initialise the URL variable on the current URL
		_initUrl: function() {
			url = decodeURIComponent(window.location.href).split("?")[1];
		},

		// Load the current URL
		urlLoad: function() {
			document.location = window.location.href;
		},

		// Get all URL parameters
		// Return an array of URL parameter
		// Return false if there is no parameters
		urlGetParams: function() {
			this._initUrl();

			if (undefined === url && null !== url)
				return false;

			var sURLVariables = url.split('&'),
				sParameterName = [],
				i;

			if (sURLVariables.length == 1 && sURLVariables[0] == "")
				return false;
			else {
				for (i = 0; i < sURLVariables.length; i++) {
					sParameterName.push(sURLVariables[i].split('=')[0]);
				}

				if (sParameterName.length > 0)
					return (sParameterName);
				else
					return false;
			}
		},

		// Get the value of a given parameter
		// Return the value on succeed
		// Return "" if the value is not found but the parameter is found
		// Return undefined on fail
		urlGetParamValue: function(key) {
			if (null !== key && undefined !== key) {
				if (this.urlParamExist(key)) {
					var sURLVariables = url.split('&'),
						sParameterName,
						newURL,
						i;

					for (i = 0; i < sURLVariables.length; i++) {
						sParameterName = sURLVariables[i].split('=');

						if (sParameterName[0] === key) {
							var paramValue = sParameterName[1];
							if (null !== paramValue && undefined !== paramValue)
								return paramValue;
							else
								return "";
						}
					}
				} else
					return undefined;
			} else
				return undefined;
		},

		// Check if an URL parameter exist
		// Return true if the "key" parameter exist
		// Return false if the "key" parameter don't exist
		urlParamExist: function(key) {
			return ($.inArray(key, this.urlGetParams()) >= 0 ? true : false);
		},

		// Delete all parameters from the url
		// If no path parameter is given, it delete all params and restore to the current path
		// If a path parameter is given, it delete all params and restore to the given path
		// Return true if it's a success
		urlDeleteAllParam: function(path) {
			var pathname = window.location.pathname;

			if (undefined === path || null === path || path == "")
				path = pathname;

			window.history.pushState(null, document.title, path);
			return true;
		},

		// Delete a given parameter from the URL
		// Return true if delete succeed
		// Return false if the delete failed
		urlDeleteParam: function(key) {
			if (null !== key && undefined !== key) {
				if (this.urlParamExist(key)) {
					var sURLVariables = url.split('&'),
						sParameterName,
						newURL,
						toRemove = -1,
						i;

					for (i = 0; i < sURLVariables.length; i++) {
						sParameterName = sURLVariables[i].split('=');

						if (sParameterName[0] === key)
							toRemove = i;
					}
					sURLVariables.splice(toRemove, 1);

					sURLVariables = sURLVariables.join("&");
					newURL = window.location.pathname + "?" + sURLVariables;
					window.history.pushState(null, document.title, newURL);
					return true;
				} else
					return false;
			} else
				return false;

		},

		// Delete a bulk of given parameters from the URL
		// Return true on success
		// Return false on fail
		urlBulkDeleteParam: function(keyList) {
			if (null !== keyList && undefined !== keyList) {
				for (var index in keyList) {
					if (!this.urlDeleteParam(keyList[index]))
						return false;
				}
				return true;
			} else
				return false;
		},

		// Update an existing parameter.
		// Return true if update succeed
		// Return false if the update failed
		urlUpdateParam: function(key, val) {
			if ((null !== key && undefined !== key) && (null !== val && undefined !== val)) {
				if (this.urlParamExist(key)) {
					var sURLVariables = url.split('&'),
						sParameterName,
						newURL,
						i;

					for (i = 0; i < sURLVariables.length; i++) {
						sParameterName = sURLVariables[i].split('=');

						if (sParameterName[0] === key)
							sURLVariables[i] = key + "=" + val;
					}
					sURLVariables = sURLVariables.join("&");
					newURL = window.location.pathname + "?" + sURLVariables;
					window.history.pushState(null, document.title, newURL);
					return true;
				} else
					return false;
			} else
				return false;
		},

		// Update an exisiting parameter or create it if it not exist
		// Return true on success
		// Return false on fail
		urlUpdCrtParam: function(key, val) {
			if (this.urlUpdateParam(key, val)) {
				return true;
			}
			else {
				var curUrl = this.urlGetParams(),
					newURL;
				if (!curUrl) {
					newURL = window.location.pathname + "?" + key + "=" + val;
					window.history.pushState(null, document.title, newURL);
					return true;
				}
				else {
					if (undefined === url || null === url)
						newURL = window.location.pathname + "?" + key + "=" + val;
					else
						newURL = window.location.pathname + "?" + url + "&" + key + "=" + val;
					window.history.pushState(null, document.title, newURL);
					return true;
				}
				return false;
			}
			return false;
		},

		// Bulk update of a list of param in form of a JSON object
		// Return true on success
		// Return false on fail
		urlBulkUpdateParam: function(hashMap) {
			if (null !== hashMap && undefined !== hashMap) {
				for (var key in hashMap) {
					if (!this.urlUpdateParam(key, hashMap[key]))
						return false;
				}
				return true;
			} else
				return false;
		},

		// Bulk update / create of a list of params in form of a JSON object
		// Return true on success
		// Return false on fail
		urlBulkUpdCrtParam: function(hashMap) {
			if (null !== hashMap && undefined !== hashMap) {
				for (var key in hashMap) {
					if (!this.urlUpdCrtParam(key, hashMap[key]))
						return false;
				}
				return true;
			} else
				return false;
		}
	}
})(jQuery);