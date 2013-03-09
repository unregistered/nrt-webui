Ember.RaphaelView = Ember.View.extend(
    tagName: 'li'
    paperBinding: "parentView.paper"
)

require "nrt-webui/views/application"
require "nrt-webui/views/tree"
require "nrt-webui/views/trays"
require "nrt-webui/views/servers"
