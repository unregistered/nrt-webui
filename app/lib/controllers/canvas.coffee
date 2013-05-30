require "nrt-webui/core"

App.CanvasController = Ember.ArrayController.extend(
    zpd: null
    svg: null

    panToCenter: ->
        @get('zpd').panTo(0, 0)

    zoomIn: ->
        pos = {
            x: 0
            y: 0
        }
        @get('zpd').zoomWithDeltaAndPosOnSvgDoc(0.5, pos, @get('svg'))

    zoomOut: ->
        pos = {
            x: 0
            y: 0
        }
        @get('zpd').zoomWithDeltaAndPosOnSvgDoc(-0.5, pos, @get('svg'))
)
