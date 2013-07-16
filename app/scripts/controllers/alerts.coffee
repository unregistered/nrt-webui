"use strict"

angular.module("nrtWebuiApp").controller "AlertsCtrl", ($scope, AlertRegistryService) ->
    $scope.alerts = AlertRegistryService.alerts

    $scope.dismiss = (alert) ->
        AlertRegistryService.dismissAlert(alert)
