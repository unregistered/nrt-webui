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
        @set 'pairTo', null
        @set 'state', 'PAIRING'
        
    completePairing: ->
        if @get('pairTo')
            console.log "Completed with", @get('pairTo')
            App.router.serverController.createConnection @get('pairFrom'), @get('pairTo')
        else
            console.log "Fail to complete"

        @set 'state', 'IDLE'
)