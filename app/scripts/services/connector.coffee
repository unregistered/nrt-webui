"use strict"

###
Responsible for a couple things relating to connections:
* Registers the bounding box of ports to allow connectors to latch
* Assists active connections by providing a list of matching ports
###
angular.module('nrtWebuiApp').factory('ConnectorService', ($rootScope, ServerService, HoverService, ModuleManagerService) ->
    self = {};

    self.portdb = {} # Ports keyed by bbuid, moduid, portname
    self.registerPortBBox = (module, port, bbox) ->
        self.portdb["#{module.bbuid}>>#{module.moduid}>>#{port.portname}"] = bbox

    self.getPortBBox = (bbuid, moduid, portname) ->
        self.portdb["#{bbuid}>>#{moduid}>>#{portname}"]

    #
    # Pairing
    #
    self.pairFrom = null
    self.pairingState = 'IDLE'
    self.isPairing = ->
        self.pairingState == 'PAIRING'

    self.startPairing = (port) ->
        console.log "Begin pairing"
        self.pairFrom = port
        self.pairingState = 'PAIRING'

        $rootScope.$broadcast("ConnectorService.pairing_state_changed")

    self.completePairing = ->
        # Get the hovered object
        pairTo = HoverService.getHovered 'port'

        console.log "Complete pairing"
        self.createConnection pairTo, self.pairFrom

        self.pairFrom = null
        self.pairingState = 'IDLE'

        $rootScope.$broadcast("ConnectorService.pairing_state_changed")

    self.isViableCandidate = (port) ->
        return undefined unless self.pairFrom
        return false unless port

        # No, unless message types match
        return false unless self.pairFrom.msgtype == port.msgtype

        # No, unless orientations differ
        return false unless self.pairFrom.orientation != port.orientation # There's an insensitive joke in here

        # No, if a connection already exists
        # return false

        return true

    self.createConnection = (port1, port2) ->
        console.log "Create connection, TODO"

    self.getPhantomConnections = ->
        return [] unless self.pairingState == 'PAIRING'

        viablePorts = _.filter ModuleManagerService.ports, (port) -> self.isViableCandidate(port)

        connections = _.map viablePorts, (port) ->
                    module = port.module
                    {
                        bbuid1: module.bbuid
                        module1: module.moduid
                        portname1: port.portname
                        bbuid2: self.pairFrom.module.bbuid
                        module2: self.pairFrom.module.moduid
                        portname2: self.pairFrom.portname

                        from_module: self.pairFrom
                        to_module: module
                    }

        return connections

    return self
)
