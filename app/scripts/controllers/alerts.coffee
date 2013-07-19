"use strict"

angular.module("nrtWebuiApp").controller "AlertsCtrl", ($scope, AlertRegistryService) ->
    $scope.getAlerts = ->
        AlertRegistryService.alerts

    $scope.dismiss = (alert) ->
        AlertRegistryService.dismissAlert(alert)
