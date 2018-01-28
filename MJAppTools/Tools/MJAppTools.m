//
//  MJAppTools.m
//  MJAppTools
//
//  Created by MJ Lee on 2018/1/27.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MJAppTools.h"
#import "MJMachO.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "LSApplicationWorkspace.h"
#import "LSApplicationProxy.h"
#import "FBApplicationInfo.h"

@implementation MJAppTools

+ (BOOL)match:(NSRegularExpression *)exp app:(MJApp *)app
{
    if (!exp) return YES;
    
    if ([exp firstMatchInString:app.displayName options:0 range:NSMakeRange(0, app.displayName.length)]) return YES;
    if ([exp firstMatchInString:app.bundlePath options:0 range:NSMakeRange(0, app.bundlePath.length)]) return YES;
    if ([exp firstMatchInString:app.bundleIdentifier options:0 range:NSMakeRange(0, app.bundleIdentifier.length)]) return YES;
    
    return NO;
}

+ (void)listUserAppsWithType:(MJListAppsType)type regex:(NSString *)regex operation:(void (^)(NSArray *apps))operation
{
    if (!operation) return;
    
    // 正则
    NSRegularExpression *exp = regex ? [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:nil] : nil;
    
    // 数组
    NSMutableArray *apps = [NSMutableArray array];
    NSArray *appInfos = [[LSApplicationWorkspace defaultWorkspace] allApplications];
    
    for (FBApplicationInfo *appInfo in appInfos) {
        if (!appInfo.bundleURL) continue;
        if (![appInfo.applicationType isEqualToString:@"User"]) continue;
        
        MJApp *app = [MJApp appWithInfo:appInfo];
        if (![self match:exp app:app]) continue;
        
        [app setupExecutable];
        if (type == MJListAppsTypeUserDecrypted && app.executable.isEncrypted) continue;
        if (type == MJListAppsTypeUserEncrypted && !app.executable.isEncrypted) continue;
        [apps addObject:app];
    }
    
    operation(apps);
}

@end
