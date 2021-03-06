#import "FacebookLoginPlugin.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareDialog.h>
#import <FBSDKShareKit/FBSDKSharePhoto.h>
#import <FBSDKShareKit/FBSDKSharePhotoContent.h>



@implementation FacebookLoginPlugin {
  FBSDKLoginManager *loginManager;

}

@synthesize docFile = _docFile;
static NSString *const kInstagramCommentKey = @"InstagramCaption";
static NSString *const kInstagramUTI = @"com.instagram.exclusivegram";
static CGFloat const kInstagramImageSize = 612.0;


+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel = [FlutterMethodChannel
      methodChannelWithName:@"com.roughike/flutter_facebook_login"
            binaryMessenger:[registrar messenger]];
  FacebookLoginPlugin *instance = [[FacebookLoginPlugin alloc] init];
  [registrar addApplicationDelegate:instance];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)init {
  loginManager = [[FBSDKLoginManager alloc] init];
  return self;
}

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
  [[FBSDKApplicationDelegate sharedInstance] application:application
                           didFinishLaunchingWithOptions:launchOptions];
  return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:
                (NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
  BOOL handled = [[FBSDKApplicationDelegate sharedInstance]
            application:application
                openURL:url
      sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
             annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
  return handled;
}

- (BOOL)application:(UIApplication *)application
              openURL:(NSURL *)url
    sourceApplication:(NSString *)sourceApplication
           annotation:(id)annotation {
  BOOL handled =
      [[FBSDKApplicationDelegate sharedInstance] application:application
                                                     openURL:url
                                           sourceApplication:sourceApplication
                                                  annotation:annotation];
  return handled;
}

- (void)handleMethodCall:(FlutterMethodCall *)call
                  result:(FlutterResult)result {
  if ([@"loginWithReadPermissions" isEqualToString:call.method]) {
    FBSDKLoginBehavior behavior =
        [self loginBehaviorFromString:call.arguments[@"behavior"]];
    NSArray *permissions = call.arguments[@"permissions"];

    [self loginWithReadPermissions:behavior
                       permissions:permissions
                            result:result];
  } else if ([@"loginWithPublishPermissions" isEqualToString:call.method]) {
    FBSDKLoginBehavior behavior =
        [self loginBehaviorFromString:call.arguments[@"behavior"]];
    NSArray *permissions = call.arguments[@"permissions"];

    [self loginWithPublishPermissions:behavior
                          permissions:permissions
                               result:result];
  } else if ([@"logOut" isEqualToString:call.method]) {
    [self logOut:result];
  } else if ([@"getCurrentAccessToken" isEqualToString:call.method]) {
    [self getCurrentAccessToken:result];
  }else if ([@"shareImageFacebook" isEqualToString:call.method]) {
      [self shareFile:call.arguments
       withController:[UIApplication sharedApplication].keyWindow.rootViewController];
  }else if ([@"shareImageInstagram" isEqualToString:call.method]) {
      NSString *share = call.arguments[@"share"];

      [self shareImageWithInstagram:share
       withController:[UIApplication sharedApplication].keyWindow.rootViewController];
  }else if ([@"logEvent" isEqualToString:call.method]) {
      NSString *name = call.arguments[@"name"];
      NSString *params = call.arguments[@"params"];
      [self logEvent:name params:params];
  }else if ([@"logSignup" isEqualToString:call.method]) {
      NSNumber *value = call.arguments;
      [FBSDKAppEvents logEvent:FBSDKAppEventNameCompletedRegistration valueToSum:[value doubleValue]];
  }else {
    result(FlutterMethodNotImplemented);
  }
}


- (void)logEvent :(NSString*)name
                    params :(NSString*)params{
    
    NSDictionary *parameters =
    [[NSDictionary alloc] initWithObjectsAndKeys:
     params, FBSDKAppEventParameterNameContent,
     nil];
    [FBSDKAppEvents logEvent:@"damnnnnn"];
    [FBSDKAppEvents logEvent: name
                  parameters: parameters];
}


- (void)shareFile:(id)sharedItems withController:(UIViewController *)controller {
    NSMutableString *filePath = [NSMutableString stringWithString:sharedItems];
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *imagePath = [docsPath stringByAppendingPathComponent:filePath];
    NSURL *imageUrl = [NSURL fileURLWithPath:imagePath];
    NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
    UIImage *shareImage = [UIImage imageWithData:imageData];
    FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
    photo.image = shareImage;
    photo.userGenerated = YES;
    FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
    content.photos = @[photo];
    [FBSDKShareDialog showFromViewController:controller
                                 withContent:content
                                    delegate:nil];
}

- (void) shareImageWithInstagram: (id)sharedItems withController:(UIViewController *)controller
{
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]){
        CGRect rect = CGRectMake(0 ,0 , 612, 612);
        NSURL *igImageHookFile = [[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"file://%@", sharedItems]];
        NSLog(@"URL Path %@", igImageHookFile);
        self.docFile.annotation = [NSDictionary dictionaryWithObject: @"#Cuenca"
                                                              forKey:@"InstagramCaption"];
        self.docFile.UTI = @"com.instagram.exclusivegram";
        self.docFile = [self setupControllerWithURL:igImageHookFile usingDelegate:self];
//        self.docFile=[UIDocumentInteractionController interactionControllerWithURL:igImageHookFile];
        [self.docFile presentOpenInMenuFromRect: controller.view.frame    inView: controller.view animated: YES ];
    }else
    {
        NSLog(@"No Instagram Found");
    }
}



- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate {
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.UTI = @"com.instagram.exclusivegram";
    interactionController.delegate = interactionDelegate;
    return interactionController;
}


- (FBSDKLoginBehavior)loginBehaviorFromString:(NSString *)loginBehaviorStr {
  if ([@[ @"nativeWithFallback", @"nativeOnly" ]
          containsObject:loginBehaviorStr]) {
    return FBSDKLoginBehaviorNative;
  } else if ([@"webOnly" isEqualToString:loginBehaviorStr]) {
    return FBSDKLoginBehaviorBrowser;
  } else if ([@"webViewOnly" isEqualToString:loginBehaviorStr]) {
    return FBSDKLoginBehaviorWeb;
  } else {
    NSString *message = [NSString
        stringWithFormat:@"Unknown login behavior: %@", loginBehaviorStr];
    @throw [NSException exceptionWithName:@"InvalidLoginBehaviorException"
                                   reason:message
                                 userInfo:nil];
  }
}

- (void)loginWithReadPermissions:(FBSDKLoginBehavior)behavior
                     permissions:(NSArray *)permissions
                          result:(FlutterResult)result {
  [loginManager setLoginBehavior:behavior];
  [loginManager
      logInWithReadPermissions:permissions
            fromViewController:nil
                       handler:^(FBSDKLoginManagerLoginResult *loginResult,
                                 NSError *error) {
                         [self handleLoginResult:loginResult
                                          result:result
                                           error:error];
                       }];
}

- (void)loginWithPublishPermissions:(FBSDKLoginBehavior)behavior
                        permissions:(NSArray *)permissions
                             result:(FlutterResult)result {
  [loginManager setLoginBehavior:behavior];
  [loginManager
      logInWithPublishPermissions:permissions
               fromViewController:nil
                          handler:^(FBSDKLoginManagerLoginResult *loginResult,
                                    NSError *error) {
                            [self handleLoginResult:loginResult
                                             result:result
                                              error:error];
                          }];
}

- (void)logOut:(FlutterResult)result {
  [loginManager logOut];
  result(nil);
}

- (void)getCurrentAccessToken:(FlutterResult)result {
  FBSDKAccessToken *currentToken = [FBSDKAccessToken currentAccessToken];
  NSDictionary *mappedToken = [self accessTokenToMap:currentToken];

  result(mappedToken);
}

- (void)handleLoginResult:(FBSDKLoginManagerLoginResult *)loginResult
                   result:(FlutterResult)result
                    error:(NSError *)error {
  if (error == nil) {
    if (!loginResult.isCancelled) {
      NSDictionary *mappedToken = [self accessTokenToMap:loginResult.token];

      result(@{
        @"status" : @"loggedIn",
        @"accessToken" : mappedToken,
      });
    } else {
      result(@{
        @"status" : @"cancelledByUser",
      });
    }
  } else {
    result(@{
      @"status" : @"error",
      @"errorMessage" : [error description],
    });
  }
}

- (id)accessTokenToMap:(FBSDKAccessToken *)accessToken {
  if (accessToken == nil) {
    return [NSNull null];
  }

  NSString *userId = [accessToken userID];
  NSArray *permissions = [accessToken.permissions allObjects];
  NSArray *declinedPermissions = [accessToken.declinedPermissions allObjects];
  NSNumber *expires = [NSNumber
      numberWithLong:accessToken.expirationDate.timeIntervalSince1970 * 1000.0];

  return @{
    @"token" : accessToken.tokenString,
    @"userId" : userId,
    @"expires" : expires,
    @"permissions" : permissions,
    @"declinedPermissions" : declinedPermissions,
  };
}
@end
