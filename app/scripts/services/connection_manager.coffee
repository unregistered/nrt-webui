"use strict"

angular.module('nrtWebuiApp').factory('ConnectionManagerService', ($rootScope, ServerService, ModuleManagerService) ->
    self = {};

    ###
    Modules are stored in an object, keyed by moduid
    ###
    self.connections = []

    $rootScope.$on('ServerService.new_blackboard_federation_summary', (event, federation_summary) ->
        self.connections.length = 0 # Clear array
        _.each federation_summary.message.namespaces[0].connections, (it) ->
            self.connections.push _.extend {}, it, {
                from_module: ModuleManagerService.modules[it.module1]
                to_module: ModuleManagerService.modules[it.module2]
            }

    )

    self.isConnected = (port1, port2) ->
        return false

    return self
)
