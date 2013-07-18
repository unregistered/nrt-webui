"use strict"

angular.module('nrtWebuiApp').factory('BlackboardParserService', ($rootScope, ServerService) ->
    self = {};

    ###
    Blackboards are stored in an object, keyed by uid
    ###
    self.content = {}

    self.getBlackboardFromUID = (bbuid) ->
        return self.content[bbuid]

    $rootScope.$on('ServerService.new_blackboard_federation_summary_event', (event, federation_summary)->
        console.log "FEDERATION_SUMMARY", federation_summary
        _.each federation_summary.message.bbnicks, (it) ->
            self.content[it.uid] = it

        $rootScope.$broadcast('BlackboardParserService.content_changed')
    )

    return self
)
