"use strict"

angular.module('nrtWebuiApp').factory('ModuleParserService', ($rootScope, ServerService) ->
    self = {};

    ###
    Modules are stored in an object, keyed by moduid
    ###
    self.modules = {}

    $rootScope.$watch('last_update_time', ->
        _.each ServerService.federation_summary.message.namespaces[0].modules, (it) ->
            it.x = 0
            it.y = 0
            self.modules[it.moduid] = it
    )

    $rootScope.$watch('last_guidata_time', ->
        return unless ServerService.guidata
        _.each ServerService.guidata.message, (it) ->
            if it.id[0] == "m"
                # Modules
                moduid = it.id.substring(2)
                module = self.modules[moduid]
                module.x = it.x
                module.y = it.y
    )

    return self
)
