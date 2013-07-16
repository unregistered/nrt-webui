"use strict"

angular.module("nrtWebuiApp").controller "ServersCtrl", ($scope, $routeParams, ServerService, $location) ->
    $scope.$on('$routeChangeSuccess', (next, current) ->
        ServerService.host = $routeParams.host_and_port.split(':')[0]
        ServerService.port = $routeParams.host_and_port.split(':')[1]

        ServerService.name = 'QuickConnect'

        ServerService.connect()

        $scope.active.name = ServerService.name
        console.log "Change server", ServerService.name
    )

    $scope.active = {
        name: 'Uninitialized'
        host: 'Uninitialized'
        port: '0'
    }
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
