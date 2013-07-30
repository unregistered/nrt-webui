"use strict"

angular.module("nrtWebuiApp").controller "PrototypesCtrl", ($scope, ServerService, LoaderManagerService) ->

    $scope.lastSearch = null
    $scope.emptyTree  = {name: "Modules", expanded: true, children: []}
    $scope.lastTree   = $scope.emptyTree
    $scope.lastBBNick = ''

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

    $scope.search = ''

    # Get the filtered prototype tree
    #   Make sure to memoize the result based on the search so that we don't keep returning brand new objects (angular hates that)
    $scope.getFilterPrototypes = ->

        loader = LoaderManagerService.getSelectedLoader()

        return unless loader

        if $scope.search == $scope.lastSearch && $scope.lastTree && loader.bbnick == $scope.lastBBNick
            return $scope.lastTree

        filteredPrototypes = _.filter loader['prototypes'], (it) ->
            return ~it.name.toLowerCase().indexOf($scope.search.toLowerCase())

        $scope.lastTree = $scope._treeify filteredPrototypes

        $scope.lastSearch = $scope.search

        $scope.lastBBNick = loader.bbnick

        return $scope.lastTree
