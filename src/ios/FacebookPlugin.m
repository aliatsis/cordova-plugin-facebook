#import "FacebookPlugin.h"
#import <Cordova/CDV.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@implementation FacebookPlugin : CDVPlugin

NSDictionary *appEventNameConstByString = nil;
NSDictionary *appEventParameterNameConstByString = nil;

- (void)pluginInitialize
{
    NSLog(@"[FacebookPlugin] plugin initialized");

    #ifdef DEBUG
        //empty
    #else
        [self setAppEventConstByString];
    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOpenURLNotification:) name:CDVPluginHandleOpenURLNotification object:nil];
    #endif
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

    [[FBSDKApplicationDelegate sharedInstance] application:application
        openURL:[notification object]
        sourceApplication:nil
        annotation:nil
    ];
}

- (void)onAppDidBecomeActive:(NSNotification*)notification
{
    [FBSDKAppEvents activateApp];
}

- (void)logPurchase:(CDVInvokedUrlCommand*)command
{
    NSNumber* purchaseAmount = [command.arguments objectAtIndex:0];
    NSString* currency = [command.arguments objectAtIndex:1];
    NSDictionary* parameters = [command.arguments objectAtIndex:2];
    FBSDKAccessToken* accessToken = [command.arguments objectAtIndex:3];

    if (currency == (id)[NSNull null] || [currency length] == 0) {
        currency = @"USD";
    }

    if (accessToken == (id)[NSNull null]) {
        accessToken = nil;
    }
    
    [FBSDKAppEvents logPurchase:[purchaseAmount doubleValue]
              currency:currency
              parameters:[self getParametersWithConstKeys:parameters]
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

    if (accessToken == (id)[NSNull null]) {
        accessToken = nil;
    }
    
    [FBSDKAppEvents logEvent:appEventNameConstByString[eventName]
              valueToSum:valueToSum
              parameters:[self getParametersWithConstKeys:parameters]
              accessToken:accessToken ];
}

- (NSDictionary*)getParametersWithConstKeys:(NSDictionary*)parameters
{
    if (parameters == (id)[NSNull null]) {
        return nil;
    }
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    for(id key in parameters) {
        NSString* constValue = [appEventParameterNameConstByString objectForKey:key];
        NSString* newKey = constValue == nil ? key : constValue;
        id value = [parameters objectForKey:key];
        
        if ([value isEqual:@(YES)]) {
            value = FBSDKAppEventParameterValueYes;
        } else if ([value isEqual:@(NO)]) {
            value = FBSDKAppEventParameterValueYes;
        }
        
        [result setObject:value forKey:newKey];
    }
    
    return result;
}

- (void)setAppEventConstByString
{
    appEventNameConstByString =
    @{
      @"FBSDKAppEventNameAchievedLevel": FBSDKAppEventNameAchievedLevel,
      @"FBSDKAppEventNameAddedPaymentInfo": FBSDKAppEventNameAddedPaymentInfo,
      @"FBSDKAppEventNameAddedToCart": FBSDKAppEventNameAddedToCart,
      @"FBSDKAppEventNameAddedToWishlist": FBSDKAppEventNameAddedToWishlist,
      @"FBSDKAppEventNameCompletedRegistration": FBSDKAppEventNameCompletedRegistration,
      @"FBSDKAppEventNameCompletedTutorial": FBSDKAppEventNameCompletedTutorial,
      @"FBSDKAppEventNameInitiatedCheckout": FBSDKAppEventNameInitiatedCheckout,
      @"FBSDKAppEventNameRated": FBSDKAppEventNameRated,
      @"FBSDKAppEventNameSearched": FBSDKAppEventNameSearched,
      @"FBSDKAppEventNameSpentCredits": FBSDKAppEventNameSpentCredits,
      @"FBSDKAppEventNameUnlockedAchievement": FBSDKAppEventNameUnlockedAchievement,
      @"FBSDKAppEventNameViewedContent": FBSDKAppEventNameViewedContent
    };
    
    appEventParameterNameConstByString =
    @{
      @"FBSDKAppEventParameterNameContentID": FBSDKAppEventParameterNameContentID,
      @"FBSDKAppEventParameterNameContentType": FBSDKAppEventParameterNameContentType,
      @"FBSDKAppEventParameterNameCurrency": FBSDKAppEventParameterNameCurrency,
      @"FBSDKAppEventParameterNameDescription": FBSDKAppEventParameterNameDescription,
      @"FBSDKAppEventParameterNameLevel": FBSDKAppEventParameterNameLevel,
      @"FBSDKAppEventParameterNameMaxRatingValue": FBSDKAppEventParameterNameMaxRatingValue,
      @"FBSDKAppEventParameterNameNumItems": FBSDKAppEventParameterNameNumItems,
      @"FBSDKAppEventParameterNamePaymentInfoAvailable": FBSDKAppEventParameterNamePaymentInfoAvailable,
      @"FBSDKAppEventParameterNameRegistrationMethod": FBSDKAppEventParameterNameRegistrationMethod,
      @"FBSDKAppEventParameterNameSearchString": FBSDKAppEventParameterNameSearchString,
      @"FBSDKAppEventParameterNameSuccess": FBSDKAppEventParameterNameSuccess
    };
}

@end