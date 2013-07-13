"use strict"

angular.module('nrtWebuiApp').factory('AlertRegistryService', ->
    self = {};

    ### Alert Levels ###
    self.ALERTLEVEL_ERROR = 'error'
    self.ALERTLEVEL_WARN = 'warn'
    self.ALERTLEVEL_SUCCESS = 'success'

    self.alerts = [
        {
            level: self.ALERTLEVEL_ERROR
            title: 'Disconnected'
            desc: 'NRT Webui has been disconnected from the server'
        },
        {
            level: self.ALERTLEVEL_WARN
            title: 'Uh oh'
            desc: "Something looks fishy"
        }
    ]

    self.registerAlert = (alertlevel, title, desc) ->
        self.alerts.push {
            level: alertlevel
            title: title
            desc: desc
        }

    self.dismissAlert = (alert) ->
        idx = self.alerts.indexOf(alert)
        self.alerts.splice(idx, 1) # Remove one item

    return self
)
