"use strict"

angular.module("nrtWebuiApp").controller "PrototypesCtrl", ($scope, ServerService, LoaderManagerService) ->

    $scope.lastSearch = null
    $scope.emptyTree = {name: "Modules", expanded: true, children: []}
    $scope.lastTree = $scope.emptyTree

    # Treeify a flat list of modules, inserting them into a hierarchy based on their categories
    $scope._treeify = (modules) ->
        tree = {name: "Modules", expanded: true, children: []}
        for module in modules

            currCategory = tree

            categories = module.logicalPath.split '/'
            for category in categories[1..categories.length-2]

                result = currCategory['children'].filter (x) -> x['name'] == category
                if result.length == 0
                    currCategory['children'].push
                        name: category
                        expanded: true
                        children: []
                    currCategory = currCategory['children'][currCategory['children'].length-1]
                else
                    result = currCategory['children'].filter (x) -> x['name'] == category
                    currCategory = result[0]

            currCategory['children'].push module

        return tree

    $scope.currentLoaderUID = ''
    $scope.search = ''

    # Get the filtered prototype tree
    #   Make sure to memoize the result based on the search so that we don't keep returning brand new objects (angular hates that)
    $scope.getFilterPrototypes = ->

        return $scope.emptyTree unless LoaderManagerService.loaders
        return $scope.emptyTree unless LoaderManagerService.loaders[$scope.currentLoaderUID]

        if $scope.search == $scope.lastSearch && $scope.lastTree
            return $scope.lastTree

        filteredPrototypes = _.filter LoaderManagerService.loaders[$scope.currentLoaderUID]['prototypes'], (it) ->
            return ~it.name.toLowerCase().indexOf($scope.search.toLowerCase())

        $scope.lastTree = $scope._treeify filteredPrototypes

        $scope.lastSearch = $scope.search

        return $scope.lastTree


    # When the list of known loaders has changed, treeify the currently selected loader
    $scope.$on("LoaderManagerService.loaders_updated", ->
        loaders = LoaderManagerService.loaders

        #console.log 'Loaders changed', loaders
        return unless loaders

        if $scope.currentLoaderUID == '' or not _(loaders).has($scope.currentLoaderUID)
            return if _(loaders).isEmpty()
            $scope.currentLoaderUID = _(loaders).keys()[0]

        $scope.prototypes = $scope._treeify loaders[$scope.currentLoaderUID]['prototypes']
    )
