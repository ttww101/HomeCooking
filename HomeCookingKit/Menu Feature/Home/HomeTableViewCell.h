#import <UIKit/UIKit.h>

@interface HomeTableViewCell : UITableViewCell

-(void)setData:(NSDictionary *)info AtIndex:(NSInteger)index;

@property (nonatomic, retain) UIImageView *iconView;

@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *cateLabel;
@end
