//
//  MessageImageBubbleView.m
//  API
//
//  Created by QS on 16/3/16.
//  Copyright © 2016年 SayGeronimo. All rights reserved.
//

#import "MessageImageBubbleView.h"
#import "Y2WImageMessage.h"
@interface MessageImageBubbleView ()
@property (nonatomic, retain) MessageModel *model;
@end
@implementation MessageImageBubbleView

+ (instancetype)create {
    MessageImageBubbleView *view = [super buttonWithType:UIButtonTypeCustom];
    view.clipsToBounds = YES;
    view.layer.cornerRadius = 15;
    view.layer.borderWidth = 1;
    view.layer.borderColor = [UIColor colorWithHexString:@"DDDDDD"].CGColor;
    return view;
}



- (void)refreshData:(MessageModel *)data {
    _model = data;
    Y2WBaseMessage *temp_message = _model.message;
    Y2WImageMessage *message = (Y2WImageMessage *)temp_message;
    [self setImageForState:UIControlStateNormal withURL:[NSURL URLWithString:message.thumImageUrl] placeholderImage:[UIImage imageNamed:@"输入框-图片"]];
}

@end
