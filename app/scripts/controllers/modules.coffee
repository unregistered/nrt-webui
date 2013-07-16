"use strict"

angular.module("nrtWebuiApp").controller "ModulesCtrl", ($scope, ModuleParserService, $timeout) ->
    ###
    Modules are stored in an object, keyed by moduid
    ###
    $scope.modules = ModuleParserService.modules
