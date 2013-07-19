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

        # Filter out any loaders that have disappeared
        self.loaders = _(self.loaders).pick _(federation.blackboards).keys

        # If a new loader pops up that we haven't seen before, request a loader summary
        # from it, and add blackboard reference to each element
        for blackboard in _(federation.blackboards).values()

            continue if _(self.loaders).has blackboard.bbuid

            ServerService.requestLoaderSummary(blackboard.nick).then (loader_summary) ->

                return unless _(loader_summary.message).has 'modules'

                bbuid  = loader_summary.message.bbUID
                bbnick = loader_summary.message.bbNick

                self.loaders[bbuid] =
                    bbnick: bbnick
                    prototypes: _.map loader_summary.message.modules, (it) ->
                        it.blackboard = blackboard
                        it.name = it.logicalPath.split('/').pop()
                        return it

            , (reason) -> console.error "Failed to get loader summary from #{blackboard.bbnick}", reason

    )

    return self
)
