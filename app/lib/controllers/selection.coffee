require "nrt-webui/core"

App.SelectionController = Ember.ArrayController.extend(
    selected: null
    proxy: null
    
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
        
)