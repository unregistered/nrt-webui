"use strict"

angular.module("nrtWebuiApp").filter('ext2mime', ->
    (text) ->
        return '' unless text
        ext = text[1..]
        return "image/#{ext}"
)
