"use strict"

angular.module('nrtWebuiApp').factory('ConnectionParserService', ($rootScope, ServerService) ->
    self = {};

    ###
    Modules are stored in an object, keyed by moduid
    ###
    self.connections = []

    $rootScope.$watch('ServerService.last_update_time', ->
        _.each ServerService.federation_summary.message.namespaces[0].connections, (it) ->
            self.connections.push it
    )

    return self
)
