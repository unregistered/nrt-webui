"use strict"

angular.module("nrtWebuiApp").controller "PreferencesCtrl", ($scope, ConfigService, AlertRegistryService) ->
    $scope.string_config = ""

    $scope.ConfigService = ConfigService
    $scope.$watch("ConfigService.settings", ->
        $scope.string_config = JSON.stringify ConfigService.settings
    , true)

    $scope.saveChanges = ->
        try
            json = JSON.parse $scope.string_config
            _.extend ConfigService.settings, json
            AlertRegistryService.registerSuccess "Settings updated"
        catch e
            AlertRegistryService.registerError "Could not set settings", e

