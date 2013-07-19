"use strict"

angular.module('nrtWebuiApp').factory('FederationSummaryParserService', ($rootScope) ->
    self = {}

    # Parse a list of modules from the raw_federation_summary, cleaning up the
    # data and adding fields and links as necessary
    self._parseFederation = (raw_federation_summary) ->

        federation =
            blackboards : {} # keyed by uid
            modules     : {} # keyed by uid
            ports       : []
            connections : []

        # Parse the blackboards
        for blackboard_summary in raw_federation_summary.message.bbnicks
            federation.blackboards[blackboard_summary.uid] = blackboard_summary

        namespace = raw_federation_summary.message.namespaces[0]

        # Parse the modules and ports
        for module_summary in namespace.modules

            # Add a default position
            _(module_summary).extend(
                x          : 0
                y          : 0
                blackboard : federation.blackboards[module_summary.bbuid]
            )

            # Add details to ports
            _(module_summary.posters).each (poster) ->
                poster.module = module_summary
                poster.orientation = 'poster'
                federation.ports.push poster

            _(module_summary.subscribers).each (subscriber) ->
                subscriber.module = module_summary
                subscriber.orientation = 'subscriber'
                federation.ports.push subscriber

            _(module_summary.checkers).each (checker) ->
                checker.module = module_summary
                checker.orientation = 'checker'
                federation.ports.push checker

            federation.modules[module_summary.moduid] = module_summary


        # Parse the connections
        federation.connections = _(namespace.connections).map (connection_summary) ->

            getPort = (module, portname) ->
                p = _(module.posters).findWhere({portname : portname})
                return p if p
                p = _(module.subscribers).findWhere({portname : portname})
                return p if p
                p = _(module.checkers).findWhere({portname : portname})
                return p if p

                return null

            connection_summary = _(connection_summary).extend(
                from_module : federation.modules[connection_summary.module1]
                to_module   : federation.modules[connection_summary.module2]
            )

            connection_summary = _(connection_summary).extend(
                from_port : getPort connection_summary.from_module, connection_summary.portname1
                to_port   : getPort connection_summary.to_module,   connection_summary.portname2
            )

            return connection_summary

        return federation

    # Takes in a raw blackboardFederationSummary message, parses it, and broadcasts the results
    self.updateFederationSummary = (raw_federation_summary) ->
        console.log "raw_federation_summary", raw_federation_summary

        federation = self._parseFederation(raw_federation_summary)
        $rootScope.$broadcast("FederationSummaryParser.federation_ready", federation)

    return self
)
