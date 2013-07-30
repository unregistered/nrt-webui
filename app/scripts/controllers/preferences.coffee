"use strict"

angular.module("nrtWebuiApp").controller "PreferencesCtrl", ($scope, ConfigService) ->
    $scope.getConfig = ->
        ConfigService.settings

