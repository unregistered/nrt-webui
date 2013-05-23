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

    candidatePorts: (->
        source = @get('pairFrom')
        return [] unless App.router.portsController.get("content") && source

        App.router.portsController.get("content").filter (port) =>
            port.get('msgtype') == source.get('msgtype')

    ).property('pairFrom', "App.router.portsController.content.@each")

    candidateConnections: (->
        # Potential connections
        source = @get('pairFrom')
        return [] unless source

        @get('candidatePorts').map (port) =>
            App.Connection.create(
                source_port: source
                destination_port: port
            )

    ).property('candidatePorts')
)
