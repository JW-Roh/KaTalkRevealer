#include <substrate.h>
#import <Cephei/HBPreferences.h>

BOOL isOther = true;
BOOL enabled;
BOOL enabled_msg;
BOOL enabled_picmov;
BOOL enabled_voice;
BOOL enabled_etc;

%group ShowRemovedMsg
%hook TalkSwiftProxy
+(short)LocoChatLogObject_type: (id)arg1 {
        short orig = %orig;
        if(isOther) {
                if(enabled_msg && orig == 16385) { //채팅 메시지
                        return 1;
                }
                if(enabled_picmov && orig == 16386) { //채팅 사진
                        return 2;
                }
                if(enabled_picmov && orig == 16387) { //채팅 비디오
                        return 3;
                }
                if(enabled_voice && orig == 16389) { //채팅 음성
                        return 5;
                }
                if(enabled_etc
                   && orig != 16385
                   && orig != 16386
                   && orig != 16387
                   && orig != 16389
                   && orig > 16384) { //채팅 그 외의 모든 것들.
                        return %orig - 16384;
                }
        }
        return %orig;
}
%end


%hook ChatMessage
-(int)feedType {
        int orig = %orig;
        if(enabled_msg
           || enabled_picmov
           || enabled_voice
           || enabled_etc) {
                if(isOther && orig == 14) {
                        return 0;
                }
        }
        return %orig;
}
%end

%hook KAOBaseChattingViewController
-(void)deleteMessageFromEveryone: (id)arg1 {
        isOther = false;
        %orig(arg1);
}
%end

%hook ChatDataController
-(void)chatLogsReceivedV2: (id)arg1 withChatRoomID: (id)arg2 {
        isOther = true;
        %orig(arg1, arg2);
}
%end
%end


%ctor {
        @autoreleasepool {
                HBPreferences *preferences;
                preferences = [[HBPreferences alloc] initWithIdentifier:@"kr.xsf1re.katalkrevealer"];
                [preferences registerDefaults:@{
                         @"enabled": @NO,
                         @"enabled_msg": @NO,
                         @"enabled_picmov": @NO,
                         @"enabled_voice": @NO,
                         @"enabled_etc": @NO,
                }];

                [preferences registerBool:&enabled default:NO forKey:@"enabled"];
                [preferences registerBool:&enabled_msg default:NO forKey:@"enabled_msg"];
                [preferences registerBool:&enabled_picmov default:NO forKey:@"enabled_picmov"];
                [preferences registerBool:&enabled_voice default:NO forKey:@"enabled_voice"];
                [preferences registerBool:&enabled_etc default:NO forKey:@"enabled_etc"];

                NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/kr.xsf1re.katalkrevealer.plist"];
                if(prefs) {
                        if([prefs[@"enabled"] boolValue])
                        {
                                enabled_msg = [prefs [@"enabled_msg"] boolValue];
                                enabled_picmov = [prefs [@"enabled_picmov"] boolValue];
                                enabled_voice = [prefs [@"enabled_voice"] boolValue];
                                enabled_etc = [prefs [@"enabled_etc"] boolValue];
                                %init(ShowRemovedMsg);
                        }
                }

        }
}
