"use strict"

angular.module("nrtWebuiApp").controller "ConnectionsCtrl", ($scope, ConnectionParserService, $timeout) ->
    ###
    Modules are stored in an object, keyed by moduid
    ###
    $scope.connections = ConnectionParserService.connections
