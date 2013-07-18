"use strict"

###
Responsible for a couple things relating to connections:
* Registers the bounding box of ports to allow connectors to latch
* Assists active connections by providing a list of matching ports
###
angular.module('nrtWebuiApp').factory('ConnectorService', ($rootScope, ServerService, HoverService) ->
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
    self.startPairing = (port) ->
        console.log "Begin pairing"
        self.pairFrom = port
        self.pairingState = 'PAIRING'

    self.completePairing = ->
        # Get the hovered object
        pairTo = HoverService.getHovered 'port'

        console.log "Complete pairing"
        self.createConnection pairTo, self.pairFrom

        self.pairFrom = null
        self.pairingState = 'IDLE'

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
        console.log "Yup"

        return []

    return self
)
