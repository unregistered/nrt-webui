"use strict"

angular.module('nrtWebuiApp').factory('LoaderParserService', ($rootScope, $q, ServerService, BlackboardParserService) ->
    self = {}

    # All known module loaders summaries, indexed by their bbuid with the following fields
    #   bbnick: The nickname of the loader
    #   prototypes: A hierarchy or module prototypes
    self.loaders = {}

    # Returns prototype for bbuid and classname. Classnames are unique
    self.getPrototype = (bbuid, classname) ->
        _.find self.loaders[bbuid].prototypes, (it) ->
            name = _.last it.logicalPath.split('/')
            return name == classname

    # Watch to see when the list of known blackboards changes
    $rootScope.$on('BlackboardParserService.content_changed', ->

        # If a new loader pops up that we haven't seen before, request a loader summary
        # from it, and add blackboard reference to each element
        for bbuid in _.keys BlackboardParserService.content
            unless _.has self.loaders, bbuid
                blackboard = BlackboardParserService.getBlackboardFromUID(bbuid)
                bbnick = blackboard.nick

                loaderSummaryMessagePromise = ServerService.requestLoaderSummary bbnick

                loaderSummaryMessagePromise.then((loaderSummaryMessage) ->
                    console.log 'Got loaderSummaryMessage', loaderSummaryMessage

                    if _.has loaderSummaryMessage.message, 'modules'
                        self.loaders[bbuid] =
                            bbnick: BlackboardParserService.content[bbuid]['nick']
                            prototypes: _.map loaderSummaryMessage.message.modules, (it) ->
                                it.blackboard = BlackboardParserService.content[bbuid]
                                it.name = it.logicalPath.split('/').pop()
                                return it

                        $rootScope.$broadcast("LoaderParserService.loaders_changed", self.loaders)
                    else
                        console.error 'Got loader summary from ', bbnick, ' with no modules'
                , (reason) ->
                    console.error('Failed to get loader summary from ', bbuid, ' because ', reason)
                )
    )

    return self
)
