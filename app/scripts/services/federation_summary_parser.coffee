"use strict"

###
Parses a raw federation summary to produce an object containing:
    blackboards: {} # keyed by uid
    modules: {} # keyed by uid
    ports: []
    connections: []
###
angular.module('nrtWebuiApp').factory('FederationSummaryParserService', ($rootScope) ->
    self = {}

    # Strip out any prefixes from a parameter_descriptor such that it becomes relative to the module
    self.stripParameterDescriptor = (parameter_descriptor) ->
        return parameter_descriptor.replace 'TheManager:Loader:', ''

    # Clean up a parameter descriptor to get it ready to throw into a module's parameter list
    self.cleanParameter = (parameter, module, value) ->
        parameter.module = module
        parameter.value = undefined
        parameter.descriptor = self.stripParameterDescriptor parameter.descriptor
        return parameter

    module_blacklist = [
        'DesignerServerModule',
        'nrt::Module',
        'nrt::BlackboardManager',
        'nrt::ModuleLoader'
    ]

    # Parse a list of modules from the raw_federation_summary, cleaning up the
    # data and adding fields and links as necessary
    self._parseFederation = (raw_federation_summary) ->

        federation =
            running     : raw_federation_summary.message.running
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

            continue if _(module_blacklist).contains module_summary.classname

            # Add a default position
            _(module_summary).extend(
                x          : 0
                y          : 0
                blackboard : federation.blackboards[module_summary.bbuid]
            )

            # Remove any NRT hidden ports
            module_summary.posters = _(module_summary.posters).reject (it) -> it.portname == 'ModuleParamChangedOutput'

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

            # Add details to parameters
            _(module_summary.parameters).each (parameter) ->
                self.cleanParameter parameter, module_summary, undefined

            federation.modules[module_summary.moduid] = module_summary

        # Filter out any connections to blacklisted modules
        module_uids = _(federation.modules).keys()
        namespace.connections = _(namespace.connections).filter (it) -> _(module_uids).contains(it.module1)
        namespace.connections = _(namespace.connections).filter (it) -> _(module_uids).contains(it.module2)

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

    # Takes in a raw blackboardFederationSummary message, parses it, and returns the results
    self.parseFederationSummary = (raw_federation_summary) ->
        console.log "raw_federation_summary", raw_federation_summary

        federation = self._parseFederation(raw_federation_summary)
        return federation

    return self
)
