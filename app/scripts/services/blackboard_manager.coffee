"use strict"

angular.module('nrtWebuiApp').factory('BlackboardManagerService', ($rootScope, ServerService, safeApply) ->
    self = {};

    ###
    Blackboards are stored in an object, keyed by uid
    ###
    self.content = {}

    self.getBlackboardFromUID = (bbuid) ->
        return self.content[bbuid]

    $rootScope.$on('ServerService.federation_update', (event, federation)->
        self.content = federation.blackboards

        #
        #
        # WARNING: safeApply happens here because this service is called last. Why? I don't know. But safeApply needs to happen last.
        #
        #
        safeApply($rootScope)
        #
        #
        #
        #
        #
    )

    return self
)
