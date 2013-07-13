"use strict"

angular.module('nrtWebuiApp').factory('ModuleParserService', ($rootScope, ServerService) ->
    self = {};

    ###
    Modules are stored in an object, keyed by moduid
    ###
    self.modules = {}

    $rootScope.$watch('ServerService.last_update_time', ->
        _.each ServerService.federation_summary.message.namespaces[0].modules, (it) ->
            it.x = 0
            it.y = 0
            self.modules[it.moduid] = it

    )

    return self
)
