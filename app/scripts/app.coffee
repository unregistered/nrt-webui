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
.factory('safeApply', [($rootScope) ->
    # safeApply($scope, (optional) fn)
    # See https://coderwall.com/p/ngisma
    ($scope, fn) ->
        phase = $scope.$root.$$phase;
        if(phase == '$apply' || phase == '$digest')
            if (fn)
                $scope.$eval(fn)
        else
            if (fn)
                $scope.$apply(fn)
            else
                $scope.$apply()
])
