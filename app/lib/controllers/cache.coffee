require "nrt-webui/core"

App.CacheController = Ember.Controller.extend(
    content: null
    init: ->
        @set 'content', Ember.Object.create()
        @set 'content.module_position', Ember.Object.create()
)
