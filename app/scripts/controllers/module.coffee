"use strict"

angular.module("nrtWebuiApp").controller "ModuleCtrl", ($scope, ServerService) ->
    $scope.deleteModule = (module) ->
        ServerService.deleteModule module
