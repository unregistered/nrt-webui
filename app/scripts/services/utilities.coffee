"use strict"

angular.module('nrtWebuiApp').factory('UtilityService', ->
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

    ###
    Generates a GUID string, according to RFC4122 standards.
    @returns {String} The generated GUID.
    @example af8a8416-6e18-a307-bd9c-f2c947bbb3aa
    @author Slavik Meltser (slavik@meltser.info).
    @link http://slavik.meltser.info/?p=142
    ###
    self.guid = ->
      _p8 = (s) ->
        p = (Math.random().toString(16) + "000000000").substr(2, 8)
        (if s then "-" + p.substr(0, 4) + "-" + p.substr(4, 4) else p)
      _p8() + _p8(true) + _p8(true) + _p8()


    return self
)
