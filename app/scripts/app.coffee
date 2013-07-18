"use strict"

angular.module("nrtWebuiApp", []).config ($routeProvider) ->
    $routeProvider.when("/",
        templateUrl: "views/main.html"
        controller: "MainCtrl"
    )
    .when("/server/:host_and_port",
        templateUrl: "views/server.html"
        controller: "ServerCtrl"
    )
    .otherwise redirectTo: "/"
