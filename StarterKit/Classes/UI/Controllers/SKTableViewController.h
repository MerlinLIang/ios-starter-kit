//
// Created by Hammer on 1/19/16.
// Copyright (c) 2016 奇迹空间. All rights reserved.
//

#import <TGRDataSource_qijitech/TGRFetchedResultsTableViewController.h>
#import "SKPaginator.h"
#import "SKManagedHTTPSessionManager.h"

@class SKTableViewControllerBuilder;

typedef void (^SKTableViewControllerBuilderBlock)(SKTableViewControllerBuilder *builder);

@interface SKTableViewController : TGRFetchedResultsTableViewController <SKPaginatorDelegate>

@property(nonatomic, strong) SKManagedHTTPSessionManager *httpSessionManager;
@property(nonatomic, strong, readonly) SKPaginator *paginator;

- (void)setupTableView;

- (void)showIndicatorView;
- (void)hideIndicatorView;

- (void)refreshData;
- (void)loadMoreData;

- (void)createWithBuilder:(SKTableViewControllerBuilderBlock )block;
- (void)initWithBuilder:(SKTableViewControllerBuilder *)builder;

// for empty
- (NSString *)emptyTitle;
- (NSString *)emptySubtitle;
- (NSString *)emptyImage;

@end