require "nrt-webui/core"

App.Blackboard = Ember.Object.extend(
    modules: (->
        App.router.modulesController.get('content').filterProperty('bbuid', @get('id'))
    ).property('App.router.modulesController.content.@each')

    init: ->
        @set 'bbnick', @get('from.nick')
        @set 'id', @get('from.uid')
)
