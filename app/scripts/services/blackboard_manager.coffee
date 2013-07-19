"use strict"

angular.module('nrtWebuiApp').factory('BlackboardManagerService', ($rootScope, ServerService) ->
    self = {};

    ###
    Blackboards are stored in an object, keyed by uid
    ###
    self.content = {}

    self.getBlackboardFromUID = (bbuid) ->
        return self.content[bbuid]

    $rootScope.$on('ServerService.new_blackboard_federation_summary', (event, federation_summary)->
        console.log "Got blackboard_federation_summary", federation_summary
        self.content = {}
        _.each federation_summary.message.bbnicks, (it) ->
            self.content[it.uid] = it

        $rootScope.$broadcast('BlackboardManagerService.content_changed', self.content)
    )

    return self
)
