require "nrt-webui/core"

App.SelectionController = Ember.ArrayController.extend(
    content: Ember.A()

    setSelection: (obj) ->
        @clearSelection()

        if obj instanceof Array
            obj.forEach (item) =>
                item.set 'selected', true
                @get('content').pushObject item
        else
            obj.set 'selected', true
            @get('content').pushObject obj

    clearSelection: ->
        @get('content').forEach (item) ->
            item.set('selected', false)

        @get('content').clear()
)
