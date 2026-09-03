#import "FluttertoastPlugin.h"
#import "UIView+Toast.h"

static NSString *const CHANNEL_NAME = @"PonnamKarthik/fluttertoast";

@interface FluttertoastPlugin ()
@property(nonatomic, strong) FlutterMethodChannel *channel;
@end

@implementation FluttertoastPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:CHANNEL_NAME
                                                                binaryMessenger:[registrar messenger]];
    FluttertoastPlugin *instance = [[FluttertoastPlugin alloc] init];
    instance.channel = channel;
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if (![NSThread isMainThread]) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf handleMethodCall:call result:result];
        });
        return;
    }

    if ([call.method isEqualToString:@"cancel"]) {
        [[self activeWindow] hideAllToasts];
        result(@YES);
        return;
    }

    if (![call.method isEqualToString:@"showToast"]) {
        result(FlutterMethodNotImplemented);
        return;
    }

    if (![call.arguments isKindOfClass:[NSDictionary class]]) {
        result([FlutterError errorWithCode:@"invalid_arguments"
                                   message:@"Toast arguments must be a dictionary."
                                   details:nil]);
        return;
    }

    NSDictionary *arguments = (NSDictionary *)call.arguments;
    NSString *message = arguments[@"msg"];
    if (![message isKindOfClass:[NSString class]]) {
        result([FlutterError errorWithCode:@"invalid_arguments"
                                   message:@"The toast message must be a String."
                                   details:nil]);
        return;
    }

    NSNumber *fontSizeNumber = arguments[@"fontSize"];
    CGFloat fontSize = [fontSizeNumber isKindOfClass:[NSNumber class]]
        ? MAX(1.0, fontSizeNumber.doubleValue)
        : 16.0;

    NSInteger seconds = [arguments[@"time"] respondsToSelector:@selector(integerValue)]
        ? [arguments[@"time"] integerValue]
        : 1;
    seconds = MIN(10, MAX(1, seconds));

    UIWindow *window = [self activeWindow];
    if (window == nil) {
        result(@NO);
        return;
    }

    CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
    style.messageFont = [UIFont systemFontOfSize:fontSize];
    style.backgroundColor = [self colorWithARGBNumber:arguments[@"iosBgcolor"]
                                               fallback:[UIColor blackColor]];
    style.messageColor = [self colorWithARGBNumber:arguments[@"iosTextcolor"]
                                            fallback:[UIColor whiteColor]];

    NSString *gravity = arguments[@"gravity"];
    id position = CSToastPositionBottom;
    if ([gravity isEqualToString:@"top"]) {
        position = CSToastPositionTop;
    } else if ([gravity isEqualToString:@"center"]) {
        position = CSToastPositionCenter;
    }

    [window makeToast:message
             duration:(NSTimeInterval)seconds
             position:position
                style:style];
    result(@YES);
}

- (UIColor *)colorWithARGBNumber:(id)value fallback:(UIColor *)fallback {
    if (![value respondsToSelector:@selector(unsignedIntegerValue)]) {
        return fallback;
    }

    NSUInteger color = [value unsignedIntegerValue];
    CGFloat alpha = ((color >> 24) & 0xFF) / 255.0;
    CGFloat red = ((color >> 16) & 0xFF) / 255.0;
    CGFloat green = ((color >> 8) & 0xFF) / 255.0;
    CGFloat blue = (color & 0xFF) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (UIWindow *)activeWindow {
    UIApplication *application = UIApplication.sharedApplication;
    for (UIScene *scene in application.connectedScenes) {
        if (scene.activationState != UISceneActivationStateForegroundActive &&
            scene.activationState != UISceneActivationStateForegroundInactive) {
            continue;
        }
        if (![scene isKindOfClass:[UIWindowScene class]]) {
            continue;
        }
        for (UIWindow *window in ((UIWindowScene *)scene).windows) {
            if (window.isKeyWindow) {
                return window;
            }
        }
    }

    return nil;
}

@end
