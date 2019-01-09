//
//  YZHAddBookAdditionalCell.m
//  YZHYolo
//
//  Created by Jersey on 2018/9/28.
//  Copyright © 2018年 YZHChain. All rights reserved.
//

#import "YZHAddBookAdditionalCell.h"

@interface YZHAddBookAdditionalCell()

@end

@implementation YZHAddBookAdditionalCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.badgeView = [NIMBadgeView viewWithBadgeTip:@""];
    self.badgeView.hidden = YES;
    [self.contentView addSubview:self.badgeView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (instancetype)tempTableViewCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    
    NSString* identifierID = [NSString stringWithFormat:@"%ld%ldCell",(long)indexPath.section,(long)indexPath.row];
    
    YZHAddBookAdditionalCell* cell = [tableView dequeueReusableCellWithIdentifier:identifierID];
    
    if (!cell) {
        
        UINib* nib = [UINib nibWithNibName:@"YZHAddBookAdditionalCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:identifierID];
        cell = [nib instantiateWithOwner:nil options:nil].lastObject;
    }
    if (indexPath.row == 0) {
        cell.iconImage.image = [UIImage imageNamed:@"addBook_cover_cell_phoneAddressBook"];
        cell.titleLabel.text = @"手机联系人";
    } else {
        cell.iconImage.image = [UIImage imageNamed:@"addBook_cover_cell_addFirendLog"];
        cell.titleLabel.text = @"好友添加记录";
    }
    return cell;
}

- (void)refreshUnreadCount:(NSInteger)unreadCount {
    
    if (unreadCount) {
        self.badgeView.hidden = NO;
        [self.badgeView setBadgeValue:@(unreadCount).stringValue];
    } else {
        self.badgeView.hidden = YES;
        [self.badgeView setBadgeValue:nil];
    }
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.badgeView.right = YZHScreen_Width - 15;
    self.badgeView.centerY = self.height / 2;
    
}

@end
