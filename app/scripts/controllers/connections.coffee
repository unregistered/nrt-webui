"use strict"

angular.module("nrtWebuiApp").controller "ConnectionsCtrl", ($scope, ConnectionManagerService, ConnectorService) ->
    ###
    Connections are stored in an array
    ###
    $scope.connections = ConnectionManagerService.connections

    $scope.phantom_connections = []

    # Update phantom_connections whenever we pair
    $scope.$on("ConnectorService.pairing_state_changed", ->
        $scope.phantom_connections = ConnectorService.getPhantomConnections();
    )
