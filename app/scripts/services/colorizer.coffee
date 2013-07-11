"use strict"

angular.module('nrtWebuiApp').factory('ColorizerService', ->
    self = {};

    self.str2color = (str) ->
        hashfunc = (str) ->
            hash = 0;
            i = 0;
            while i < str.length
                hash = str.charCodeAt(i) + ((hash << 5) - hash)
                i++
            return hash

        rgbfunc = (i) ->
            r = ((i>>24)&0xFF).toString(16)
            r = '0' + r if r.length == 1
            g = ((i>>16)&0xFF).toString(16)
            g = '0' + g if g.length == 1
            b = ((i>>8)&0xFF).toString(16)
            b = '0' + b if b.length == 1
            return '#'+r+g+b;

        return rgbfunc(hashfunc(str))

    return self
)
