"use strict"

angular.module('nrtWebuiApp').factory('BlackboardParserService', ($rootScope, ServerService) ->
    self = {};

    ###
    Blackboards are stored in an object, keyed by uid
    ###
    self.content = {}

    $rootScope.$watch('ServerService.last_update_time', ->
        _.each ServerService.federation_summary.message.bbnicks, (it) ->
            self.content[it.uid] = it

    )

    return self
)
