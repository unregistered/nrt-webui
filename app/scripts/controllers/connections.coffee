"use strict"

angular.module("nrtWebuiApp").controller "ConnectionsCtrl", ($scope, ConnectionParserService, ConnectorService) ->
    ###
    Connections are stored in an array
    ###
    $scope.connections = ConnectionParserService.connections

    ###
    Phantom connections are generated by the ConnectorService
    ###
    $scope.phantom_connections = ConnectorService.getPhantomConnections()
