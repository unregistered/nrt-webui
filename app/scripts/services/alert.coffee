"use strict"

angular.module('nrtWebuiApp').factory('AlertRegisterService', ->
    self = {};

    ### Alert Levels ###
    self.ALERTLEVEL_ERROR = 'error'
    self.ALERTLEVEL_WARN = 'warn'
    self.ALERTLEVEL_SUCCESS = 'success'

    self.alerts = []

    self.registerAlert = (alertlevel, title, desc) ->
        alerts.push {
            level: alertlevel
            title: title
            desc: desc
        }

    return self
)
