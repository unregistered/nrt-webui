"use strict"

angular.module('nrtWebuiApp').factory('ConnectionParserService', ($rootScope, ServerService) ->
    self = {};

    ###
    Modules are stored in an object, keyed by moduid
    ###
    self.connections = []

    $rootScope.$on('ServerService.new_blackboard_federation_summary', (event, federation_summary) ->
        _.each federation_summary.message.namespaces[0].connections, (it) ->
            self.connections.push it
    )

    self.isConnected = (port1, port2) ->
        return false

    return self
)
