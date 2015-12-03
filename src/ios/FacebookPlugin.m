#import "FacebookPlugin.h"
#import <Cordova/CDV.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@implementation FacebookPlugin : CDVPlugin

- (void)pluginInitialize
{
    NSLog(@"[FacebookPlugin] plugin initialized");

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil]; 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOpenURLNotification:) name:CDVPluginHandleOpenURLNotification object:nil]; 
}

- (void)finishLaunching:(NSNotification *)notification
{
    #ifdef DEBUG
        [FBSDKSettings enableLoggingBehavior:FBSDKLoggingBehaviorAppEvents];
    #endif

    UIApplication *application = [UIApplication sharedApplication];
    NSDictionary *launchOptions = [notification userInfo];

    [[FBSDKApplicationDelegate sharedInstance] application:application
        didFinishLaunchingWithOptions:launchOptions];
}

- (void)handleOpenURLNotification:(NSNotification*)notification
{
    UIApplication *application = [UIApplication sharedApplication];

    // [[FBSDKApplicationDelegate sharedInstance] application:application
    //     openURL:url
    //     sourceApplication:sourceApplication
    //     annotation:annotation
    //   ];
}

- (void)onAppDidBecomeActive:(NSNotification*)notification
{
    [FBSDKAppEvents activateApp];
}

- (void)logPurchase:(CDVInvokedUrlCommand*)command
{
    double purchaseAmount = [command.arguments objectAtIndex:0];
    NSString* currency = [command.arguments objectAtIndex:1];
    NSDictionary* parameters = [command.arguments objectAtIndex:2];
    FBSDKAccessToken* accessToken = [command.arguments objectAtIndex:3];

    if (currency == (id)[NSNull null] || [currency length] == 0) {
        currency = @"USD";
    }

    if (parameters == (id)[NSNull null]) {
        parameters = nil;
    }

    if (accessToken == (id)[NSNull null]) {
        accessToken = nil;
    }
    
    [FBSDKAppEvents logPurchase:purchaseAmount
              currency:currency
              parameters:parameters
              accessToken:accessToken ];
}

- (void)logEvent:(CDVInvokedUrlCommand*)command
{
    NSString* eventName = [command.arguments objectAtIndex:0];
    NSNumber* valueToSum = [command.arguments objectAtIndex:1];
    NSDictionary* parameters = [command.arguments objectAtIndex:2];
    FBSDKAccessToken* accessToken = [command.arguments objectAtIndex:3];

    if (valueToSum == (id)[NSNull null]) {
        valueToSum = nil;
    }

    if (parameters == (id)[NSNull null]) {
        parameters = nil;
    }

    if (accessToken == (id)[NSNull null]) {
        accessToken = nil;
    }
    
    [FBSDKAppEvents logEvent:eventName
              valueToSum:valueToSum
              parameters:parameters
              accessToken:accessToken ];
}

@end