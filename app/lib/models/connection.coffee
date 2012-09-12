require "nrt-webui/core"

App.Connection = Ember.Object.extend(
    source_port: null
    destination_port: null
    
    init: ->
        source_params = @get('from')[0]
        destination_params = @get('from')[1]
                            
        source_mod = App.router.modulesController.findProperty('moduid', source_params.moduid)
        destination_mod = App.router.modulesController.findProperty('moduid', destination_params.moduid)
                
        @set 'source_port', source_mod.get('posters').findProperty('portname', source_params.portname)        
        @set 'destination_port', destination_mod.get('subscribers').findProperty('portname', destination_params.portname)                
)
