"use strict"

angular.module('nrtWebuiApp').factory('BlackboardManagerService', ($rootScope, ServerService) ->
    self = {};

    ###
    Blackboards are stored in an object, keyed by uid
    ###
    self.content = {}

    self.getBlackboardFromUID = (bbuid) ->
        return self.content[bbuid]

    $rootScope.$on('FederationSummaryParser.federation_ready', (event, federation)->
        self.content = federation.blackboards
    )

    return self
)
