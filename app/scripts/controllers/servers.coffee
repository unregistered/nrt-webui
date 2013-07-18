"use strict"

angular.module("nrtWebuiApp").controller "ServersCtrl", ($scope, ServerService, $location) ->
    $scope.active = ServerService
    $scope.servers = [
        {
            name: 'localhost'
            host: 'localhost'
            port: '9000'
        },
        {
            name: 'iLab'
            host: 'ilab.usc.edu'
            port: '9000'
        }
    ]

    $scope.viewServer = (server) ->
        $location.url("/server/#{server.host}:#{server.port}")
