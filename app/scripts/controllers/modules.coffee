"use strict"

angular.module("nrtWebuiApp").controller "ModulesCtrl", ($scope, ServerService) ->
    $scope.$watch("ServerService.last_update_time", ->
        # Parse modules out
        _.each ServerService.federation_summary.message.namespaces[0].modules, (item) ->
            $scope.modules[item.moduid] = item

    )

    ###
    Modules are stored in an object, keyed by moduid
    ###
    $scope.modules = {}
