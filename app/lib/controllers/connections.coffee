require "nrt-webui/core"

App.ConnectionsController = Ember.ArrayController.extend(
    contentBinding: []
    selected: null
    hovered: null # What the user is hovering over

    pairFrom: null
    pairToBinding: 'hovered'
    state: 'IDLE'
    ###
               ----> complete
              /
    start --<
              \
               ----> fail
    ###
    startPairing: (port) ->
        console.log "Start with port", port
        @set 'pairFrom', port
        @set 'state', 'PAIRING'

    completePairing: ->
        if @get('pairTo') && @get('pairTo') != @get('pairFrom')
            console.log "Completed with", @get('pairTo')
            App.router.serverController.createConnection @get('pairFrom'), @get('pairTo')
        else
            console.log "Fail to complete"

        @set 'pairFrom', null
        @set 'state', 'IDLE'

    # Returns all ports that we could connect to.
    # Ports are returned if they have the same msgtype and different orientations.
    # Does not take existing connections into account.
    candidatePorts: (->
        source = @get('pairFrom')
        return [] unless App.router.portsController.get("content") && source

        App.router.portsController.get("content").filter (port) =>
            same_message_type = port.get('msgtype') == source.get('msgtype')
            different_directions = port.get('orientation') != source.get('orientation')
            same_message_type && different_directions

    ).property('pairFrom', "App.router.portsController.content.@each")

    # Returns dummy connections for the GUI to display.
    # Filters out existing connections
    candidateConnections: (->
        # Potential connections
        source = @get('pairFrom')
        return [] unless source

        @get('candidatePorts').filter (port) =>
            # Remove existing connections as options
            !@get('content').some (connection) =>
                # Since the user can drag starting from the destination or the source, we have to match both possibilities
                p1 = (connection.get('source_port') == @get('pairFrom')) && (connection.get('destination_port') == port)
                p2 = (connection.get('source_port') == port) && (connection.get('destination_port') == @get('pairFrom'))
                p1 or p2

        .map (port) =>
            App.Connection.create(
                source_port: source
                destination_port: port
            )

    ).property('candidatePorts')
)
