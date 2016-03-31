//
//  ContactTableViewCell.m
//  API
//
//  Created by QS on 16/3/10.
//  Copyright © 2016年 SayGeronimo. All rights reserved.
//

#import "MemberModelCell.h"

@implementation MemberModelCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.avatarImageView];
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.separatorInset = UIEdgeInsetsMake(0, 56, 0, 0);
    
    self.avatarImageView.left = 10;
    self.avatarImageView.centerY = self.height/2;
    
    self.titleLabel.height = self.height;
    self.titleLabel.left = 56;
}


- (void)setModel:(NSObject<MemberModelInterface> *)model {
    _model = model;

    [self.avatarImageView setBackgroundImage:[UIImage imageWithUIColor:[UIColor colorWithUID:_model.uid]] forState:UIControlStateNormal];
    
    [self.avatarImageView setImageForState:UIControlStateNormal withURL:[NSURL URLWithString:_model.imageUrl] placeholderImage:_model.image];

    self.titleLabel.text = _model.name;
}



#pragma mark - ———— getter ———— -

- (UIButton *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [UIButton buttonWithType:UIButtonTypeCustom];
        _avatarImageView.width = _avatarImageView.height = 36;
        _avatarImageView.layer.cornerRadius = 36.0/2;
        _avatarImageView.layer.masksToBounds = YES;
        _avatarImageView.backgroundColor = [UIColor redColor];
    }
    return _avatarImageView;
}


- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                       UIViewAutoresizingFlexibleRightMargin;
        _titleLabel.textColor = [UIColor colorWithHexString:@"353535"];
        _titleLabel.font = [UIFont systemFontOfSize:16];
    }
    return _titleLabel;
}

@end