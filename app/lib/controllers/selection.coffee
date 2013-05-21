require "nrt-webui/core"

App.SelectionController = Ember.ArrayController.extend(
    content: Ember.A()

    setSelection: (obj) ->
        if obj instanceof Array
            @get('content').clear()
            obj.forEach (item) =>
                @get('content').pushObject item
        else
            @get('content').clear()
            @get('content').pushObject obj

    clearSelection: ->
        @set 'content', Ember.A()
)
