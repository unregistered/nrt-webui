require "nrt-webui/core"

App.SelectionController = Ember.ArrayController.extend(
    type: "blank"
    content: Ember.A()

    selected: null
    proxy: null

    hasSelection: (->
        @get('selected') != null
    ).property('selected')

    makeClear: ->
        @set 'proxy.selected', null if @get('proxy')
        @set 'proxy', null
        @set 'selected', null

    makeActive: (obj, prox) ->
        proxobj = Ember.get(prox)

        @set 'proxy', proxobj
        @set 'selected', obj
        @set 'proxy.selected', obj

    selectModule: (module) ->
        @makeActive module, 'App.router.modulesController'

    selectCanvas: (canvas) ->
        @makeClear()
        @set 'selected', canvas


    #
    # Replaces the current selected object with a new one
    #
    replaceSelection: (type, obj) ->
        if @get('type') != type
            @set 'type', type

        @get('content').clear()
        @get('content').pushObject obj

    #
    # Attempts to append object to current selection
    # if type does not match, it will clear itself
    #
    appendSelection: (type, obj) ->
        if @get('type') != type
            return @replaceSelection(type, obj)

        @get('content').pushObject obj
)
