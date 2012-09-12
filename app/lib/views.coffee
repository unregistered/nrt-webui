Ember.RaphaelView = Ember.View.extend(
    tagName: 'li'
    paperBinding: "parentView.paper"
    
    beforeRender: ->
        console.log "BEfore render"
)

require "nrt-webui/views/application"
require "nrt-webui/views/servers"