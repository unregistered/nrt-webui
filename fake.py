import sys

from twisted.python import log
from twisted.internet import reactor
from twisted.web.server import Site
from twisted.web.static import File

from autobahn.websocket import listenWS, connectWS
from autobahn.wamp import WampServerFactory, WampClientFactory,\
                          WampServerProtocol, WampClientProtocol,\
                          exportRpc
 

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
                'connections': [
                    [
                        {
                            'bbuid': 'ilab21[8323329]:3174:0x7e3f40',
                            'moduleid': 'ilab21[8323329]:3174:0x1882bf8',
                            'portname': 'TweetReceived'
                        },
                        {
                            'bbuid': 'ilab21[8323329]:3174:0x7e3f40',
                            'moduleid': 'ilab21[8323329]:3180:0x188f4a8',
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


#                                     {u'bbuid': u'ilab21[8323329]:3174:0x7e3f40',
#                                      u'checkers': [],
#                                      u'classname': u'nrt::ModuleLoader',
#                                      u'instance': u'Loader',
#                                      u'moduid': u'ilab21[8323329]:3174:0x18898e0',
#                                      u'parameters': [],
#                                      u'parent': u'',
#                                      u'posters': [{u'description': u'Module Param Changed',
#                                                    u'msgtype': u'nrt::ModuleParamChangedMessage',
#                                                    u'portname': u'ModuleParamChangedOutput',
#                                                    u'rettype': u'void',
#                                                    u'topi': u''},
#                                                   {u'description': u'Module Load Message Output',
#                                                    u'msgtype': u'nrt::LoadModuleRequestMessage',
#                                                    u'portname': u'LoadMessageOutput',
#                                                    u'rettype': u'nrt::LoadModuleResponseMessage',
#                                                    u'topi': u'NRT_LoadModule'},
#                                                   {u'description': u'Module Unload Message Output',
#                                                    u'msgtype': u'nrt::UnloadModuleMessage',
#                                                    u'portname': u'UnloadMessageOutput',
#                                                    u'rettype': u'void',
#                                                    u'topi': u'NRT_UnloadModule'},
#                                                   {u'description': u'Modify Parameter Output',
#                                                    u'msgtype': u'nrt::ModifyParamMessage',
#                                                    u'portname': u'ModifyParamOutput',
#                                                    u'rettype': u'nrt::ModifyParamResponseMessage',
#                                                    u'topi': u'NRT_ModifyParam'},
#                                                   {u'description': u'Modify Topic Output',
#                                                    u'msgtype': u'nrt::ModifyModuleTopicMessage',
#                                                    u'portname': u'ModifyTopicOutput',
#                                                    u'rettype': u'void',
#                                                    u'topi': u'NRT_ModifyTopic'},
#                                                   {u'description': u'Create Namespace Output',
#                                                    u'msgtype': u'nrt::CreateNamespaceMessage',
#                                                    u'portname': u'CreateNamespaceOutput',
#                                                    u'rettype': u'void',
#                                                    u'topi': u'NRT_CreateNamespace'},
#                                                   {u'description': u'Create Connectors Output',
#                                                    u'msgtype': u'nrt::CreateConnectorMessage',
#                                                    u'portname': u'CreateConnectorOutput',
#                                                    u'rettype': u'void',
#                                                    u'topi': u'NRT_CreateConnector'},
#                                                   {u'description': u'Modify Connector Topic Output',
#                                                    u'msgtype': u'nrt::ModifyConnectorTopicMessage',
#                                                    u'portname': u'ModifyConnectorTopicOutput',
#                                                    u'rettype': u'void',
#                                                    u'topi': u'NRT_ModifyConnectorTopic'},
#                                                   {u'description': u'Set GUI Data Output',
#                                                    u'msgtype': u'nrt::GUIdataMessage',
#                                                    u'portname': u'SetGUIdataOutput',
#                                                    u'rettype': u'void',
#                                                    u'topi': u'NRT_SetGUIdata'}],
#                                      u'subscribers': [{u'description': u'Module Load Message Input',
#                                                        u'msgtype': u'nrt::LoadModuleRequestMessage',
#                                                        u'portname': u'LoadMessageInput',
#                                                        u'rettype': u'nrt::LoadModuleResponseMessage',
#                                                        u'topi': u'NRT_LoadModule'},
#                                                       {u'description': u'Module Unload Message Input',
#                                                        u'msgtype': u'nrt::UnloadModuleMessage',
#                                                        u'portname': u'UnloadMessageInput',
#                                                        u'rettype': u'void',
#                                                        u'topi': u'NRT_UnloadModule'},
#                                                       {u'description': u'Modify Parameter Input',
#                                                        u'msgtype': u'nrt::ModifyParamMessage',
#                                                        u'portname': u'ModifyParamInput',
#                                                        u'rettype': u'nrt::ModifyParamResponseMessage',
#                                                        u'topi': u'NRT_ModifyParam'},
#                                                       {u'description': u'Modify Topic Input',
#                                                        u'msgtype': u'nrt::ModifyModuleTopicMessage',
#                                                        u'portname': u'ModifyTopicInput',
#                                                        u'rettype': u'void',
#                                                        u'topi': u'NRT_ModifyTopic'},
#                                                       {u'description': u'Set the running state of the system (start or stopped)',
#                                                        u'msgtype': u'nrt::SetStateMessage',
#                                                        u'portname': u'SetStateInput',
#                                                        u'rettype': u'void',
#                                                        u'topi': u'NRT_SetState'},
#                                                       {u'description': u'Rename Namespace Input',
#                                                        u'msgtype': u'nrt::RenameNamespaceMessage',
#                                                        u'portname': u'RenameNamespaceInput',
#                                                        u'rettype': u'void',
#                                                        u'topi': u''},
#                                                       {u'description': u'Request Module List Input',
#                                                        u'msgtype': u'nrt::BBNickTrigger',
#                                                        u'portname': u'RequestLoaderSummaryInput',
#                                                        u'rettype': u'nrt::LoaderSummaryMessage',
#                                                        u'topi': u'NRT_RequestLoaderSummary'},
#                                                       {u'description': u'Kill this module loader',
#                                                        u'msgtype': u'nrt::TriggerMessage',
#                                                        u'portname': u'KillInput',
#                                                        u'rettype': u'void',
#                                                        u'topi': u'NRT_KillAll|NRT_Kill'},
#                                                       {u'description': u"Put this loader's blackboard into/out of quiet suspended mode",
#                                                        u'msgtype': u'nrt::Message<bool>',
#                                                        u'portname': u'QuietSuspendInput',
#                                                        u'rettype': u'void',
#                                                        u'topi': u'NRT_QuietSuspend|NRT_QuietSuspend'},
#                                                       {u'description': u'Ask all parameters to resend their summaries. The value of this message should be the target loader nickname',
#                                                        u'msgtype': u'nrt::BBNickTrigger',
#                                                        u'portname': u'RefreshParametersInput',
#                                                        u'rettype': u'void',
#                                                        u'topi': u'NRT_RefreshParameters'}]},
#                                     {u'bbuid': u'ilab21[8323329]:3174:0x7e3f40',
#                                      u'checkers': [],
#                                      u'classname': u'DesignerServerModule',
#                                      u'instance': u'NRT_AUTO_1',
#                                      u'moduid': u'ilab21[8323329]:3174:0x1898a60',
#                                      u'parameters': [],
#                                      u'parent': u'ilab21[8323329]:3174:0x18898e0',
#                                      u'posters': [{u'description': u'Module Param Changed',
#                                                    u'msgtype': u'nrt::ModuleParamChangedMessage',
#                                                    u'portname': u'ModuleParamChangedOutput',
#                                                    u'rettype': u'void',
#                                                    u'topi': u''}],
#                                      u'subscribers': [{u'description': u'Blackboard Federation Summary',
#                                                        u'msgtype': u'nrt::blackboard::BlackboardFederationSummary',
#                                                        u'portname': u'BlackboardFederationSummary',
#                                                        u'rettype': u'void',
#                                                        u'topi': u'.*'}]},
#                                     {u'bbuid': u'ilab21[8323329]:3174:0x7e3f40',
#                                      u'checkers': [],
#                                      u'classname': u'nrt::Module',
#                                      u'instance': u'',
#                                      u'moduid': u'ilab21[8323329]:3180:0x188f4a8',
#                                      u'parameters': [],
#                                      u'parent': u'ilab21[8323329]:3174:0x1882bf8',
#                                      u'posters': [{u'description': u'Module Param Changed',
#                                                    u'msgtype': u'nrt::ModuleParamChangedMessage',
#                                                    u'portname': u'ModuleParamChangedOutput',
#                                                    u'rettype': u'void',
#                                                    u'topi': u''},
#                                                   {u'description': u'Load Modules',
#                                                    u'msgtype': u'nrt::LoadModuleRequestMessage',
#                                                    u'portname': u'LoadModuleOutput',
#                                                    u'rettype': u'nrt::LoadModuleResponseMessage',
#                                                    u'topi': u'NRT_LoadModule'},
#                                                   {u'description': u'Load Modules',
#                                                    u'msgtype': u'nrt::UnloadModuleMessage',
#                                                    u'portname': u'UnloadModuleOutput',
#                                                    u'rettype': u'void',
#                                                    u'topi': u'NRT_UnloadModule'},
#                                                   {u'description': u'Change Parameters',
#                                                    u'msgtype': u'nrt::ModifyParamMessage',
#                                                    u'portname': u'ModuleParamChangeOutput',
#                                                    u'rettype': u'nrt::ModifyParamResponseMessage',
#                                                    u'topi': u'NRT_ModifyParam'},
#                                                   {u'description': u'Modify Module Topics',
#                                                    u'msgtype': u'nrt::ModifyModuleTopicMessage',
#                                                    u'portname': u'ModifyModuleTopicOutput',
#                                                    u'rettype': u'void',
#                                                    u'topi': u'NRT_ModifyTopic'},
#                                                   {u'description': u'Modify Connector Topics',
#                                                    u'msgtype': u'nrt::ModifyConnectorTopicMessage',
#                                                    u'portname': u'ModifyConnectorTopicOutput',
#                                                    u'rettype': u'void',
#                                                    u'topi': u'NRT_ModifyConnectorTopic'},
#                                                   {u'description': u'Modify Start/Stop State',
#                                                    u'msgtype': u'nrt::SetStateMessage',
#                                                    u'portname': u'SetStateOutput',
#                                                    u'rettype': u'void',
#                                                    u'topi': u'NRT_SetState'},
#                                                   {u'description': u'Create Connectors',
#                                                    u'msgtype': u'nrt::CreateConnectorMessage',
#                                                    u'portname': u'CreateConnectorOutput',
#                                                    u'rettype': u'void',
#                                                    u'topi': u'NRT_CreateConnector'},
#                                                   {u'description': u'Delete Connectors',
#                                                    u'msgtype': u'nrt::DeleteConnectorMessage',
#                                                    u'portname': u'DeleteConnectorOutput',
#                                                    u'rettype': u'void',
#                                                    u'topi': u'NRT_DeleteConnector'},
#                                                   {u'description': u'Create Namespaces',
#                                                    u'msgtype': u'nrt::CreateNamespaceMessage',
#                                                    u'portname': u'CreateNamespaceOutput',
#                                                    u'rettype': u'void',
#                                                    u'topi': u'NRT_CreateNamespace'},
#                                                   {u'description': u'Set GUI Data',
#                                                    u'msgtype': u'nrt::GUIdataMessage',
#                                                    u'portname': u'GUIdataOutput',
#                                                    u'rettype': u'void',
#                                                    u'topi': u'NRT_SetGUIdata'},
#                                                   {u'description': u'Kill All',
#                                                    u'msgtype': u'nrt::TriggerMessage',
#                                                    u'portname': u'KillAllOutput',
#                                                    u'rettype': u'void',
#                                                    u'topi': u'NRT_KillAll'},
#                                                   {u'description': u"Set all loaders into 'quiet suspend' mode",
#                                                    u'msgtype': u'nrt::Message<bool>',
#                                                    u'portname': u'QuietSuspendOutput',
#                                                    u'rettype': u'void',
#                                                    u'topi': u'NRT_QuietSuspend'}],
#                                      u'subscribers': []},
#                                     {u'bbuid': u'ilab21[8323329]:3599:0x7e3f40',
#                                      u'checkers': [{u'description': u'Blackboard Usage Summary Async Input',
#                                                     u'msgtype': u'nrt::BlackboardUsageMessage',
#                                                     u'portname': u'BlackboardUsageAsyncInput',
#                                                     u'rettype': u'',
#                                                     u'topi': u''}],
#                                      u'classname': u'nrt::BlackboardManager',
#                                      u'instance': u'Blackboard',
#                                      u'moduid': u'ilab21[8323329]:3599:0x24f8bc8',
#                                      u'parameters': [],
#                                      u'parent': u'',
#                                      u'posters': [{u'description': u'Module Param Changed',
#                                                    u'msgtype': u'nrt::ModuleParamChangedMessage',
#                                                    u'portname': u'ModuleParamChangedOutput',
#                                                    u'rettype': u'void',
#                                                    u'topi': u''},
#                                                   {u'description': u'Blackboard Federation Summary',
#                                                    u'msgtype': u'nrt::blackboard::BlackboardFederationSummary',
#                                                    u'portname': u'BlackboardFederationSummaryOutput',
#                                                    u'rettype': u'void',
#                                                    u'topi': u''},
#                                                   {u'description': u'Blackboard Usage Summary Output',
#                                                    u'msgtype': u'nrt::BlackboardUsageMessage',
#                                                    u'portname': u'BlackboardUsageOutput',
#                                                    u'rettype': u'void',
#                                                    u'topi': u'BlackboardUsage'},
#                                                   {u'description': u'GUI Data Changes Output',
#                                                    u'msgtype': u'nrt::GUIdataMessage',
#                                                    u'portname': u'GUIdataOutput',
#                                                    u'rettype': u'void',
#                                                    u'topi': u''}],
#                                      u'subscribers': [{u'description': u'GUI Data Changes Input',
#                                                        u'msgtype': u'nrt::GUIdataMessage',
#                                                        u'portname': u'GUIdataInput',
#                                                        u'rettype': u'void',
#                                                        u'topi': u''},
#                                                       {u'description': u'Create a new Namespace',
#                                                        u'msgtype': u'nrt::CreateNamespaceMessage',
#                                                        u'portname': u'CreateNamespaceInput',
#                                                        u'rettype': u'void',
#                                                        u'topi': u''},
#                                                       {u'description': u'Create a new Connector',
#                                                        u'msgtype': u'nrt::CreateConnectorMessage',
#                                                        u'portname': u'CreateConnectorInput',
#                                                        u'rettype': u'void',
#                                                        u'topi': u''},
#                                                       {u'description': u'Delete a Connector',
#                                                        u'msgtype': u'nrt::DeleteConnectorMessage',
#                                                        u'portname': u'DeleteConnectorInput',
#                                                        u'rettype': u'void',
#                                                        u'topi': u''},
#                                                       {u'description': u"Modify a Connector's topic(filter)",
#                                                        u'msgtype': u'nrt::ModifyConnectorTopicMessage',
#                                                        u'portname': u'ModifyConnectorTopicInput',
#                                                        u'rettype': u'void',
#                                                        u'topi': u''},
#                                                       {u'description': u'Request our current SystemProfiler summary data',
#                                                        u'msgtype': u'nrt::TriggerMessage',
#                                                        u'portname': u'SystemProfilerSummaryRequestInput',
#                                                        u'rettype': u'nrt::SystemProfilerMessage',
#                                                        u'topi': u''}]},
#                                     {u'bbuid': u'ilab21[8323329]:3599:0x7e3f40',
#                                      u'checkers': [],
#                                      u'classname': u'nrt::ModuleLoader',
#                                      u'instance': u'Loader',
#                                      u'moduid': u'ilab21[8323329]:3599:0x24ff8b0',
#                                      u'parameters': [],
#                                      u'parent': u'',
#                                      u'posters': [{u'description': u'Module Param Changed',
#                                                    u'msgtype': u'nrt::ModuleParamChangedMessage',
#                                                    u'portname': u'ModuleParamChangedOutput',
#                                                    u'rettype': u'void',
#                                                    u'topi': u''},
#                                                   {u'description': u'Module Load Message Output',
#                                                    u'msgtype': u'nrt::LoadModuleRequestMessage',
#                                                    u'portname': u'LoadMessageOutput',
#                                                    u'rettype': u'nrt::LoadModuleResponseMessage',
#                                                    u'topi': u'NRT_LoadModule'},
#                                                   {u'description': u'Module Unload Message Output',
#                                                    u'msgtype': u'nrt::UnloadModuleMessage',
#                                                    u'portname': u'UnloadMessageOutput',
#                                                    u'rettype': u'void',
#                                                    u'topi': u'NRT_UnloadModule'},
#                                                   {u'description': u'Modify Parameter Output',
#                                                    u'msgtype': u'nrt::ModifyParamMessage',
#                                                    u'portname': u'ModifyParamOutput',
#                                                    u'rettype': u'nrt::ModifyParamResponseMessage',
#                                                    u'topi': u'NRT_ModifyParam'},
#                                                   {u'description': u'Modify Topic Output',
#                                                    u'msgtype': u'nrt::ModifyModuleTopicMessage',
#                                                    u'portname': u'ModifyTopicOutput',
#                                                    u'rettype': u'void',
#                                                    u'topi': u'NRT_ModifyTopic'},
#                                                   {u'description': u'Create Namespace Output',
#                                                    u'msgtype': u'nrt::CreateNamespaceMessage',
#                                                    u'portname': u'CreateNamespaceOutput',
#                                                    u'rettype': u'void',
#                                                    u'topi': u'NRT_CreateNamespace'},
#                                                   {u'description': u'Create Connectors Output',
#                                                    u'msgtype': u'nrt::CreateConnectorMessage',
#                                                    u'portname': u'CreateConnectorOutput',
#                                                    u'rettype': u'void',
#                                                    u'topi': u'NRT_CreateConnector'},
#                                                   {u'description': u'Modify Connector Topic Output',
#                                                    u'msgtype': u'nrt::ModifyConnectorTopicMessage',
#                                                    u'portname': u'ModifyConnectorTopicOutput',
#                                                    u'rettype': u'void',
#                                                    u'topi': u'NRT_ModifyConnectorTopic'},
#                                                   {u'description': u'Set GUI Data Output',
#                                                    u'msgtype': u'nrt::GUIdataMessage',
#                                                    u'portname': u'SetGUIdataOutput',
#                                                    u'rettype': u'void',
#                                                    u'topi': u'NRT_SetGUIdata'}],
#                                      u'subscribers': [{u'description': u'Module Load Message Input',
#                                                        u'msgtype': u'nrt::LoadModuleRequestMessage',
#                                                        u'portname': u'LoadMessageInput',
#                                                        u'rettype': u'nrt::LoadModuleResponseMessage',
#                                                        u'topi': u'NRT_LoadModule'},
#                                                       {u'description': u'Module Unload Message Input',
#                                                        u'msgtype': u'nrt::UnloadModuleMessage',
#                                                        u'portname': u'UnloadMessageInput',
#                                                        u'rettype': u'void',
#                                                        u'topi': u'NRT_UnloadModule'},
#                                                       {u'description': u'Modify Parameter Input',
#                                                        u'msgtype': u'nrt::ModifyParamMessage',
#                                                        u'portname': u'ModifyParamInput',
#                                                        u'rettype': u'nrt::ModifyParamResponseMessage',
#                                                        u'topi': u'NRT_ModifyParam'},
#                                                       {u'description': u'Modify Topic Input',
#                                                        u'msgtype': u'nrt::ModifyModuleTopicMessage',
#                                                        u'portname': u'ModifyTopicInput',
#                                                        u'rettype': u'void',
#                                                        u'topi': u'NRT_ModifyTopic'},
#                                                       {u'description': u'Set the running state of the system (start or stopped)',
#                                                        u'msgtype': u'nrt::SetStateMessage',
#                                                        u'portname': u'SetStateInput',
#                                                        u'rettype': u'void',
#                                                        u'topi': u'NRT_SetState'},
#                                                       {u'description': u'Rename Namespace Input',
#                                                        u'msgtype': u'nrt::RenameNamespaceMessage',
#                                                        u'portname': u'RenameNamespaceInput',
#                                                        u'rettype': u'void',
#                                                        u'topi': u''},
#                                                       {u'description': u'Request Module List Input',
#                                                        u'msgtype': u'nrt::BBNickTrigger',
#                                                        u'portname': u'RequestLoaderSummaryInput',
#                                                        u'rettype': u'nrt::LoaderSummaryMessage',
#                                                        u'topi': u'NRT_RequestLoaderSummary'},
#                                                       {u'description': u'Kill this module loader',
#                                                        u'msgtype': u'nrt::TriggerMessage',
#                                                        u'portname': u'KillInput',
#                                                        u'rettype': u'void',
#                                                        u'topi': u'NRT_KillAll|NRT_Kill'},
#                                                       {u'description': u"Put this loader's blackboard into/out of quiet suspended mode",
#                                                        u'msgtype': u'nrt::Message<bool>',
#                                                        u'portname': u'QuietSuspendInput',
#                                                        u'rettype': u'void',
#                                                        u'topi': u'NRT_QuietSuspend|NRT_QuietSuspend'},
#                                                       {u'description': u'Ask all parameters to resend their summaries. The value of this message should be the target loader nickname',
#                                                        u'msgtype': u'nrt::BBNickTrigger',
#                                                        u'portname': u'RefreshParametersInput',
#                                                        u'rettype': u'void',
#                                                        u'topi': u'NRT_RefreshParameters'}]},
#                                     {u'bbuid': u'ilab21[8323329]:3599:0x7e3f40',
#                                      u'checkers': [],
#                                      u'classname': u'TransformPosterModule',
#                                      u'instance': u'NRT_AUTO_1',
#                                      u'moduid': u'ilab21[8323329]:3599:0x250d660',
#                                      u'parameters': [],
#                                      u'parent': u'ilab21[8323329]:3599:0x24ff8b0',
#                                      u'posters': [{u'description': u'Module Param Changed',
#                                                    u'msgtype': u'nrt::ModuleParamChangedMessage',
#                                                    u'portname': u'ModuleParamChangedOutput',
#                                                    u'rettype': u'void',
#                                                    u'topi': u''},
#                                                   {u'description': u'The transform port',
#                                                    u'msgtype': u'nrt::TransformMessage',
#                                                    u'portname': u'TransformUpdate',
#                                                    u'rettype': u'void',
#                                                    u'topi': u''}],
#                                      u'subscribers': []}],
#                        u'name': u'/'}]},
# u'msgtype': u'BlackboardFederationSummary'}

class PubSubClient1(WampClientProtocol):
   
    def onSessionOpen(self):
        self.subscribe("org.nrtkit.designer/event", self.onSimpleEvent)
        # self.sendSimpleEvent()
        # self.send_fake_update()
   
    def onSimpleEvent(self, topicUri, event):
        print "Event", topicUri, event
   
    def sendSimpleEvent(self):
        self.publish("org.nrtkit.designer/event/hello", "Hello!")
        reactor.callLater(2, self.sendSimpleEvent)
    
    def send_fake_update(self):         
        self.publish("org.nrtkit.designer/event/blackboard_federation_summary", bbfs)
        reactor.callLater(3, self.send_fake_update)


class PubSubServer1(WampServerProtocol):
    @exportRpc
    def blackboard_federation_summary(self):
        return bbfs

    def onSessionOpen(self):
        ## register a URI and all URIs having the string as prefix as PubSub topic
        self.registerForPubSub("org.nrtkit.designer/event", True)
        self.registerForRpc(self, "org.nrtkit.designer/get/")
 

if __name__ == '__main__':
    
    log.startLogging(sys.stdout)
    debug = len(sys.argv) > 1 and sys.argv[1] == 'debug'
    
    factory = WampServerFactory("ws://localhost:9000", debugWamp = True)
    factory.protocol = PubSubServer1
    factory.setProtocolOptions(allowHixie76 = True)
    listenWS(factory)
    
    factory = WampClientFactory("ws://localhost:9000", debugWamp = True)
    factory.protocol = PubSubClient1
    connectWS(factory)
    
    reactor.run()