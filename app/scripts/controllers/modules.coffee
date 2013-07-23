"use strict"

angular.module("nrtWebuiApp").controller "ModulesCtrl", ($scope, ModuleManagerService, $timeout, ServerService) ->
    ###
    Modules are stored in an object, keyed by moduid
    ###
    $scope.getModules = ->
        return ModuleManagerService.modules
