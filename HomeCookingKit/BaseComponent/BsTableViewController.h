
#import <UIKit/UIKit.h>
#import "NavigationTheme.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^NavigationIntialSetup)(NavigationTheme *);

@interface BsTableViewController : UITableViewController

@property (nullable, copy, nonatomic) NavigationIntialSetup navigationSetup;

@end

NS_ASSUME_NONNULL_END
