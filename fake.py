import sys

from twisted.python import log
from twisted.internet import reactor
from twisted.web.server import Site
from twisted.web.static import File

from autobahn.websocket import listenWS, connectWS
from autobahn.wamp import WampServerFactory, WampClientFactory,\
                          WampServerProtocol, WampClientProtocol,\
                          exportRpc
 

import uuid
from nc import NotificationCenter
notificationCenter = NotificationCenter()

bbfs = {
    u'message': {
        u'bbnicks': [
            {
                u'nick': u'ilab21',
                u'uid': u'ilab21[8323329]:3174:0x7e3f40'
            },
            {
                u'nick': u'ilab21.1',
                u'uid': u'ilab21[8323329]:3599:0x7e3f40'
            }
        ],
        u'namespaces': [
            {
                'prototypes': [
                    {
                        'classname': 'nrt::TwitterChecker',
                        'name': 'Twitter Checker',
                        'description': 'Polls for tweets and emits a message on tweet.'
                    },
                    {
                        'classname': 'nrt::EmailSender',
                        'name': 'Email Sender',
                        'description': 'Sends an email when an input is triggered.'
                    }
                ],
                'connections': [
                    [
                        {
                            'bbuid': 'ilab21[8323329]:3174:0x7e3f40',
                            'moduid': 'ilab21[8323329]:3174:0x1882bf8',
                            'portname': 'TweetReceived'
                        },
                        {
                            'bbuid': 'ilab21[8323329]:3174:0x7e3f40',
                            'moduid': 'ilab21[8323329]:3180:0x188f4a8',
                            'portname': 'SendEmail'
                        }
                    ]
                ],
                u'modules': [
                    {
                        'coordinates': [300, 100],
                        u'bbuid': u'ilab21[8323329]:3174:0x7e3f40',
                        u'checkers': [],
                        u'classname': u'nrt::EmailSender',
                        u'instance': u'Emailer',
                        u'moduid': u'ilab21[8323329]:3180:0x188f4a8',
                        u'parameters': [
                            {
                                'name': 'Email Address'
                            }
                        ],
                        u'parent': u'',
                        u'posters': [
                            {
                                u'description': u'Email Sent',
                                u'msgtype': u'nrt::EmailSent',
                                u'portname': u'EmailSent',
                                u'rettype': u'void',
                                u'topi': u''
                            }
                        ],
                        u'subscribers': [
                            {
                                u'description': u'Send Email Event',
                                u'msgtype': u'nrt::SendEmail',
                                u'portname': u'SendEmail',
                                u'rettype': u'void',
                                u'topi': u''
                            },
                            {
                                u'description': u'Send Email Alert',
                                u'msgtype': u'nrt::SendEmail',
                                u'portname': u'SendEmailAlert',
                                u'rettype': u'void',
                                u'topi': u''
                            },
                            {
                                u'description': u'Send Email Warning',
                                u'msgtype': u'nrt::SendEmail',
                                u'portname': u'SendEmailWarning',
                                u'rettype': u'void',
                                u'topi': u''
                            },
                            {
                                u'description': u'Send Email Crisis',
                                u'msgtype': u'nrt::SendEmail',
                                u'portname': u'SendEmailCrisis',
                                u'rettype': u'void',
                                u'topi': u''
                            }
                            
                        ]
                    },
                    {
                        'coordinates': [100, 100],
                        u'bbuid': u'ilab21[8323329]:3174:0x7e3f40',
                        u'checkers': [],
                        u'classname': u'nrt::TwitterChecker',
                        u'instance': u'TwitterChecker',
                        u'moduid': u'ilab21[8323329]:3174:0x1882bf8',
                        u'parameters': [
                            {
                                'name': 'Twitter Account'
                            }
                        ],
                        u'parent': u'',
                        u'posters': [
                            {
                                u'description': u'Tweet Received',
                                u'msgtype': u'nrt::TweetReceived',
                                u'portname': u'TweetReceived',
                                u'rettype': u'void',
                                u'topi': u''
                            }
                        ],
                        u'subscribers': []
                    }
                ],
                u'name': u'/'
            }
        ]
    }
}

class PubSubClient1(WampClientProtocol):
   
    def onSessionOpen(self):
        self.subscribe("org.nrtkit.designer/event/module_position_update", self.module_position_update)
        # self.subscribe("org.nrtkit.designer/event", self.onSimpleEvent)
        notificationCenter.addObserver(self, self.send_fake_update, "bbfs_updated")
        # self.sendSimpleEvent()
        # self.send_fake_update()
   
    def module_position_update(self, topicUri, event):
        try:
            # Find the module
            mods = bbfs['message']['namespaces'][0]['modules']
            try:
                mod = (m for m in mods if m['moduid'] == event['moduid']).next()
            except StopIterationError:
                print "Module with uid " + event['moduid'] + " not found."
                return
        
            mod['coordinates'] = [event['x'], event['y']]
        except Exception as e:
            print type(e), e

    def onSimpleEvent(self, topicUri, event):
        print "Event", topicUri, event
   
    def sendSimpleEvent(self):
        self.publish("org.nrtkit.designer/event/hello", "Hello!")
        reactor.callLater(2, self.sendSimpleEvent)
    
    def send_fake_update(self, arg):         
        self.publish("org.nrtkit.designer/event/blackboard_federation_summary", bbfs)
        # reactor.callLater(3, self.send_fake_update)


class PubSubServer1(WampServerProtocol):
    @exportRpc
    def get_blackboard_federation_summary(self):
        return bbfs
        
    @exportRpc
    def create_module(self, args):
        new_mod = {
            'coordinates': [args['x'], args['y']],
            u'bbuid': u'ilab21[8323329]:3174:0x7e3f40',
            u'checkers': [],
            u'classname': args['classname'],
            u'instance': args['classname'],
            u'moduid': str(uuid.uuid4()),
            u'parameters': [
                {
                    'name': 'Twitter Account'
                }
            ],
            u'parent': u'',
            u'posters': [
                {
                    u'description': u'Tweet Received',
                    u'msgtype': u'nrt::TweetReceived',
                    u'portname': u'TweetReceived',
                    u'rettype': u'void',
                    u'topi': u''
                }
            ],
            u'subscribers': []
        }

        bbfs['message']['namespaces'][0]['modules'].append(new_mod)
        
        notificationCenter.postNotification("bbfs_updated", self)
    
    @exportRpc
    def create_connection(self, args):
        new_conn =      [{
                            'bbuid': 'ilab21[8323329]:3174:0x7e3f40',
                            'moduid': args['from_moduid'],
                            'portname': args['from_portname']
                        },
                        {
                            'bbuid': 'ilab21[8323329]:3174:0x7e3f40',
                            'moduid': args['to_moduid'],
                            'portname': args['to_portname']
                        }]
        
        bbfs['message']['namespaces'][0]['connections'].append(new_conn)
        
        notificationCenter.postNotification("bbfs_updated", self)

    @exportRpc
    def delete_module(self, args):        
        try:
            # Find the module
            mods = bbfs['message']['namespaces'][0]['modules']
            try:
                mod = (m for m in mods if m['moduid'] == args['moduid']).next()
            except StopIterationError:
                print "Module with uid " + event['moduid'] + " not found."
                return
        
            mods.remove(mod)
        except Exception as e:
            print e

        notificationCenter.postNotification("bbfs_updated", self)

    def onSessionOpen(self):
        ## register a URI and all URIs having the string as prefix as PubSub topic
        self.registerForPubSub("org.nrtkit.designer/event", True)
        self.registerMethodForRpc("org.nrtkit.designer/get/blackboard_federation_summary", self, self.__class__.get_blackboard_federation_summary) 
        self.registerMethodForRpc("org.nrtkit.designer/post/module", self, self.__class__.create_module)
        self.registerMethodForRpc("org.nrtkit.designer/post/connection", self, self.__class__.create_connection)
        self.registerMethodForRpc("org.nrtkit.designer/delete/module", self, self.__class__.delete_module)

if __name__ == '__main__':
    
    log.startLogging(sys.stdout)
    debug = len(sys.argv) > 1 and sys.argv[1] == 'debug'
    
    server_factory = WampServerFactory("ws://localhost:9000", debugWamp = True)
    server_factory.protocol = PubSubServer1
    server_factory.setProtocolOptions(allowHixie76 = True)
    listenWS(server_factory)
    
    client_factory = WampClientFactory("ws://localhost:9000", debugWamp = True)
    client_factory.protocol = PubSubClient1
    connectWS(client_factory)
    
    reactor.run()