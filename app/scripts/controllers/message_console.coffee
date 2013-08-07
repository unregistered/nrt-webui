"use strict"

angular.module("nrtMessageConsoleApp").controller "MessageConsoleCtrl", ($scope) ->

    $scope.filter_options = {}
    $scope.filter_options.filter_by_module  = true
    $scope.filter_options.filter_by_message = true
    $scope.filter_options.filter_string     = ''

    $scope.messageFilter = (message) ->
        return true if !$scope.filter_options.filter_by_module and !$scope.filter_options.filter_by_message

        if $scope.filter_options.filter_by_module
            return true if (message.module.indexOf $scope.filter_options.filter_string) != -1

        if $scope.filter_options.filter_by_message
            return true if (message.message.indexOf $scope.filter_options.filter_string) != -1

        return false

    $scope.messages = [
        {
            module: "Module1"
            date: new Date((new Date()).getTime() + Math.random()*1000)
            message: "XXX Lorem ipsum dolor sit amet, consectetur adipiscing elit"
        },
        {
            module: "Module2"
            date: new Date((new Date()).getTime() + Math.random()*1000)
            message: "Mauris mattis elementum fringilla. Integer at ligula sapien"
        },
        {
            module: "Module3"
            date: new Date((new Date()).getTime() + Math.random()*1000)
            message: "Donec vel ipsum a enim ornare lobortis"
        },
        {
            module: "Module1"
            date: new Date((new Date()).getTime() + Math.random()*1000)
            message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit"
        },
        {
            module: "Module2"
            date: new Date((new Date()).getTime() + Math.random()*1000)
            message: "Mauris mattis elementum fringilla. Integer at ligula sapien"
        },
        {
            module: "Module3"
            date: new Date((new Date()).getTime() + Math.random()*1000)
            message: "Donec vel ipsum a enim ornare lobortis"
        },
        {
            module: "Module1"
            date: new Date((new Date()).getTime() + Math.random()*1000)
            message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit"
        },
        {
            module: "Module2"
            date: new Date((new Date()).getTime() + Math.random()*1000)
            message: "Mauris mattis elementum fringilla. Integer at ligula sapien"
        },
        {
            module: "Module3"
            date: new Date((new Date()).getTime() + Math.random()*1000)
            message: "Donec vel ipsum a enim ornare lobortis"
        },
        {
            module: "Module1"
            date: new Date((new Date()).getTime() + Math.random()*1000)
            message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit"
        },
        {
            module: "Module2"
            date: new Date((new Date()).getTime() + Math.random()*1000)
            message: "Mauris mattis elementum fringilla. Integer at ligula sapien"
        },
        {
            module: "Module3"
            date: new Date((new Date()).getTime() + Math.random()*1000)
            message: "Donec vel ipsum a enim ornare lobortis"
        },
    ]

