"use strict"

###
Parses and processes modules and ports
###
angular.module('nrtWebuiApp').factory('ModuleParserService', ($rootScope, ServerService) ->
    self = {};

    ###
    Modules are stored in an object, keyed by moduid
    ###
    self.modules = {}
    self.ports = []

    $rootScope.$on('ServerService.new_blackboard_federation_summary', (event, federation_summary) ->
        _.each federation_summary.message.namespaces[0].modules, (it) ->
            it.x = 0
            it.y = 0
            self.modules[it.moduid] = it

            # Add details to ports
            _.each it.posters, (poster) ->
                poster.module = it
                poster.orientation = 'poster'
                self.ports.push poster

            _.each it.subscribers, (subscriber) ->
                subscriber.module = it
                subscriber.orientation = 'subscriber'
                self.ports.push subscriber

            _.each it.checkers, (checker) ->
                checker.module = it
                checker.orientation = 'checker'
                self.ports.push checker
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
