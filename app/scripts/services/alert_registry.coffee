"use strict"

angular.module('nrtWebuiApp').factory('AlertRegistryService', ($rootScope) ->
    self = {};

    ### Alert Levels ###
    self.ALERTLEVEL_ERROR = 'error'
    self.ALERTLEVEL_WARN = 'warn'
    self.ALERTLEVEL_SUCCESS = 'success'

    self.alerts = []

    self.registerError = (title, desc) ->
        self.registerAlert self.ALERTLEVEL_ERROR, title, desc

    self.registerWarning = (title, desc) ->
        self.registerAlert self.ALERTLEVEL_WARNING, title, desc

    self.registerSuccess = (title, desc) ->
        self.registerAlert self.ALERTLEVEL_SUCCESS, title, desc

    self.registerAlert = (alertlevel, title, desc) ->
        self.alerts.push {
            level: alertlevel
            title: title
            desc: desc
        }
        $rootScope.$apply()

    self.dismissAlert = (alert) ->
        idx = self.alerts.indexOf(alert)
        self.alerts.splice(idx, 1) # Remove one item

    return self
)
