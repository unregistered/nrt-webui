"use strict"

angular.module('nrtWebuiApp').factory('LoaderParserService', ($rootScope, ServerService, BlackboardParserService) ->
    self = {}

    # All known module loaders summaries, indexed by their bbuid with the following fields
    #   bbnick: The nickname of the loader
    #   prototypes: A hierarchy or module prototypes
    self.loaders = {}

    # Returns prototype for bbuid and classname. Classnames are unique
    self.getPrototype = (bbuid, classname) ->
        branch = self.loaders[bbuid]

        return null unless branch

        _traverse = (tree, searchterm) ->
            if !tree.children
                # We've hit a root node
                if searchterm == tree.name
                    return tree
                else
                    return null
            else
                for child in tree.children
                    res = _traverse(child, searchterm)
                    return res if res

        return _traverse(branch.prototypes, classname)


    # Treeify a flat list of modules, inserting them into a hierarchy based on their categories
    self._treeify = (modules, bbnick) ->
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

            currCategory['children'].push
                name: categories[categories.length-1]
                icondata: module.icondata
                icontype: 'image/' + module.iconext[1..]
                logicalPath: module.logicalPath # consumed during module creation
                bbnick: bbnick # consumed during module creation

        return tree

    # Watch to see when the list of known blackboards changes
    $rootScope.$on('BlackboardParserService.content_changed', ->

        # If a new loader pops up that we haven't seen before, request a loader summary
        # from it, and treeify the result into self.loaderSummaries[bbuid]
        for bbuid in _.keys BlackboardParserService.content
            unless _.has self.loaders, bbuid
                loaderSummaryMessage = ServerService.requestLoaderSummary bbuid
                if _.has loaderSummaryMessage.message, 'modules'
                    bbnick = BlackboardParserService.content[bbuid]['nick']
                    self.loaders[bbuid] =
                        bbnick: bbnick
                        prototypes: self._treeify loaderSummaryMessage.message.modules, bbnick
    )

    return self
)
