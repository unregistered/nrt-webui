"use strict"

###
Parses and processes modules and ports
###
angular.module('nrtWebuiApp').factory('ModuleManagerService', ($rootScope, ServerService) ->
    self = {};

    ###
    Modules are stored in an object, keyed by moduid
    ###
    self.modules = {}
    self.ports = []

    $rootScope.$on('FederationSummaryParser.federation_ready', (event, federation_summary) ->
        self.modules = federation_summary.modules
        self.ports = federation_summary.ports
        console.log "Got stuff"
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
