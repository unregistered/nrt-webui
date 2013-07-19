"use strict"

angular.module("nrtWebuiApp").controller "LoadersCtrl", ($scope, LoaderManagerService) ->

    $scope.loaders = []
    $scope.selected_bbnick = ""

    $scope.LoaderManagerService = LoaderManagerService
    $scope.$watch('LoaderManagerService.loaders', ->
        return if _.isEmpty LoaderManagerService.loaders
        $scope.loaders = []
        loaders = LoaderManagerService.loaders
        console.log 'Got loaders: ', loaders
        for bbuid in _.keys loaders
            $scope.loaders.push
              bbuid: bbuid
              bbnick: loaders[bbuid]['bbnick']

         if $scope.selected_bbnick == ""
             $scope.selected_bbnick = $scope.loaders[0].bbnick
    , true)
