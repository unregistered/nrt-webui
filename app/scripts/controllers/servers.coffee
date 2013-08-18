"use strict"

angular.module("nrtWebuiApp").controller "ServersCtrl", ($scope, ServerService, $location, ConfigService) ->
    $scope.active = ServerService
    $scope.servers = ConfigService.settings.servers

    $scope.viewServer = (server) ->
        $location.url("/server/#{server.host}:#{server.port}")

    $scope.quickConnect = (hostname, port) ->
        $scope.viewServer(
            host: hostname
            port: port
        )

    $scope.addServer = (name, hostname, port) ->
        $scope.servers.push (
            name: name
            hostname: hostname
            port: port
        )
