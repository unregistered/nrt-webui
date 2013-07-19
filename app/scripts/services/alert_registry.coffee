"use strict"

angular.module('nrtWebuiApp').factory('AlertRegistryService', ($rootScope, safeApply) ->
    self = {};

    ### Alert Levels ###
    self.ALERTLEVEL_ERROR = 'error'
    self.ALERTLEVEL_WARN = 'warn'
    self.ALERTLEVEL_SUCCESS = 'success'
    self.ALERTLEVEL_INFO = 'info'

    self.alerts = []

    self.registerInfo = (title, desc, is_pinned, onDismiss) ->
        self.registerAlert self.ALERTLEVEL_INFO, title, desc, is_pinned, onDismiss

    self.registerError = (title, desc, is_pinned, onDismiss) ->
        self.registerAlert self.ALERTLEVEL_ERROR, title, desc, is_pinned, onDismiss

    self.registerWarning = (title, desc, is_pinned, onDismiss) ->
        self.registerAlert self.ALERTLEVEL_WARNING, title, desc, is_pinned, onDismiss

    self.registerSuccess = (title, desc, is_pinned, onDismiss) ->
        self.registerAlert self.ALERTLEVEL_SUCCESS, title, desc, is_pinned, onDismiss

    self.registerAlert = (alertlevel, title, desc, is_pinned, onDismiss) ->
        self.alerts.push {
            level: alertlevel
            title: title
            desc: desc
            is_pinned: is_pinned
            onDismiss: onDismiss
        }
        safeApply($rootScope)

    self.dismissAlert = (alert) ->
        idx = self.alerts.indexOf(alert)
        return unless idx > -1 # We are dismissing an alert that no longer exists

        alert = self.alerts[idx]
        alert.onDismiss() if alert.onDismiss # Call the callback if it exists

        self.alerts.splice(idx, 1) # Remove one item

        safeApply($rootScope)

    return self
)
