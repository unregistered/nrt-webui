"use strict"

angular.module('nrtWebuiApp').factory('ConnectionManagerService', ($rootScope, ServerService, ModuleManagerService) ->
    self = {};

    ###
    Modules are stored in an object, keyed by moduid
    ###
    self.connections = []

    $rootScope.$on('ServerService.federation_update', (event, federation) ->
        self.connections = federation.connections
    )

    self.isConnected = (port1, port2) ->
        return false

    return self
)
