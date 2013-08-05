"use strict"

angular.module("nrtMessageConsoleApp", []).config ($routeProvider) ->
    $routeProvider.otherwise redirectTo: "/"
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
