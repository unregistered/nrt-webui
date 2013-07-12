"use strict"

angular.module("nrtWebuiApp").controller "ModulesCtrl", ($scope, ServerService, $timeout) ->
    $scope.$watch("ServerService.last_update_time", ->
        # Parse modules out
        _.each ServerService.federation_summary.message.namespaces[0].modules, (item) ->
            item.x = 0
            item.y = 0
            $scope.modules[item.moduid] = item
    )

    ###
    Modules are stored in an object, keyed by moduid
    ###
    $scope.modules = {}
