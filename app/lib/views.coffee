Ember.RaphaelView = Ember.View.extend(
    paperBinding: "parentView.paper"
    
    beforeRender: ->
        console.log "BEfore render"
)

require "nrt-webui/views/application"
require "nrt-webui/views/servers"