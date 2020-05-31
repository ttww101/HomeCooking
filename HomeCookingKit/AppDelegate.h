#import <UIKit/UIKit.h>
#import "RESideMenu.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate,RESideMenuDelegate>{
    NSString *idfa;
    NSData *popupRawJSON;
    BOOL isFirstStart;
    NSMutableDictionary *clientIDFAInfo;
    BOOL googleAdSwitch;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) RESideMenu *sideMenuViewController;
@property (strong, nonatomic) NSString *idfa;
@property (strong, nonatomic) NSData *popupRawJSON;
@property (nonatomic) BOOL isFirstStart;
@property (strong, nonatomic) NSMutableDictionary *clientIDFAInfo;
@property (nonatomic) BOOL googleAdSwitch;

@end
