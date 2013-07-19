"use strict"

angular.module('nrtWebuiApp').factory('LoaderManagerService', ($rootScope, $q, ServerService, BlackboardManagerService) ->
    self = {}

    # All known module loaders summaries, indexed by their bbuid with the following fields
    #   bbnick: The nickname of the loader
    #   prototypes: A hierarchy or module prototypes
    self.loaders = {}

    # Returns prototype for bbuid and classname. Classnames are unique
    self.getPrototype = (bbuid, classname) ->
        return null unless self.loaders[bbuid]
        _.find self.loaders[bbuid].prototypes, (it) ->
            name = _.last it.logicalPath.split('/')
            return name == classname

    # Watch to see when the list of known blackboards changes
    $rootScope.$on('FederationSummaryParser.federation_ready', (event, federation) ->

        console.log 'SUMMARY: ', blackboardFederationSummary
        new_bbuids = _.keys blackboardFederationSummary

        console.log 'FILTERING: ', new_bbuids, self.loaders

        # Filter out any loaders that have disappeared
        self.loaders = _.pick self.loaders, new_bbuids

        console.log 'Filtered: ', self.loaders

        # If a new loader pops up that we haven't seen before, request a loader summary
        # from it, and add blackboard reference to each element
        for bbuid in new_bbuids

            blackboard = BlackboardManagerService.getBlackboardFromUID(bbuid)

            bbnick = blackboard.nick

            # If we already know about the loader, don't request a new loaderSummary
            continue if _.has self.loaders, bbuid

            # Request the loaderSummary from the loader with the given nickname
            loaderSummaryMessagePromise = ServerService.requestLoaderSummary bbnick

            loaderSummaryMessagePromise.then((loaderSummaryMessage) ->

                bbuid  = loaderSummaryMessage.message.bbUID
                bbnick = loaderSummaryMessage.message.bbNick

                if _.has loaderSummaryMessage.message, 'modules'
                    self.loaders[bbuid] =
                        bbnick: bbnick
                        prototypes: _.map loaderSummaryMessage.message.modules, (it) ->
                            it.blackboard = blackboardFederationSummary[bbuid]
                            it.name = it.logicalPath.split('/').pop()
                            return it
                else
                    console.error 'Got loader summary from ', bbnick, ' with no modules'
            , (reason) ->
                console.error('Failed to get loader summary from ', bbuid, ' because ', reason)

            )

    )

    return self
)
