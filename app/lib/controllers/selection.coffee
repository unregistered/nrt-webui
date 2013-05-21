require "nrt-webui/core"

App.SelectionController = Ember.ArrayController.extend(
    type: null
    content: Ember.A()

    setSelection: (type, obj) ->
        @set 'type', type
        if obj instanceof Array
            @set 'content', obj
        else
            @get('content').clear()
            @get('content').pushObject obj

    clearSelection: ->
        @set 'type', null
        @set 'content', Ember.A()
)
