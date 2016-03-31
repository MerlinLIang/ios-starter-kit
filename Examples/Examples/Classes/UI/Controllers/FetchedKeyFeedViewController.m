//
// Created by 杨玉刚 on 3/24/16.
// Copyright (c) 2016 奇迹空间. All rights reserved.
//

#import "FetchedKeyFeedViewController.h"

#import <StarterKit/SKTableViewControllerBuilder.h>
#import <libextobjc/EXTScope.h>
#import "SKFeedTableViewCell.h"
#import "Feed.h"
#import "SKFeedPictureTableViewCell.h"
#import "SKManagedHTTPSessionManager+Example.h"

@implementation FetchedKeyFeedViewController

- (id)init {
  if (self = [super init]) {
    [self createWithBuilder:^(SKTableViewControllerBuilder *builder) {
      builder.cellMetadata = @[[SKFeedTableViewCell class], [SKFeedPictureTableViewCell class]];
      builder.entityName = @"Feed";
      builder.modelOfClass = [Feed class];
      NSMutableArray *sortDescriptors = [NSMutableArray new];
      NSDictionary *sortDescriptor = @{
        @"key":@"identifier",
        @"ascending":@"NO",
      };
      [sortDescriptors addObject:sortDescriptor];
      builder.sortDescriptors = [sortDescriptors copy];
      @weakify(self);
      builder.paginateBlock = ^(NSDictionary *parameters) {
        @strongify(self)
        return [self.httpSessionManager fetchFeedsWithId:parameters];
      };
    }];
  }
  return self;
}

- (NSString *)cellReuseIdentifier:(Feed *)item indexPath:(NSIndexPath *)indexPath {
  if (item.images && item.images.count > 0) {
    return [SKFeedPictureTableViewCell cellIdentifier];
  }
  return [SKFeedTableViewCell cellIdentifier];
}

- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
}

@end