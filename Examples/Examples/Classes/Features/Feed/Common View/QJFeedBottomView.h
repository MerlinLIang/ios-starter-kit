//
// Created by 杨玉刚 on 7/18/16.
// Copyright (c) 2016 奇迹空间. All rights reserved.
//

#import "QJView.h"

@class QJPost;

@interface QJFeedBottomView : QJView

@property(nonatomic, strong) QJPost *post;
@property(nonatomic) BOOL shouldHideLocation;

@end