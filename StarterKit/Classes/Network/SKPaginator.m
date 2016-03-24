//
// Created by Hammer on 1/18/16.
// Copyright (c) 2016 奇迹空间. All rights reserved.
//

#import <Overcoat/OVCResponse.h>
#import <libextobjc/EXTScope.h>
#import "SKPaginator.h"
#import "SKNetworkConfig.h"
#import "SKManaged.h"

@interface SKPaginator ()
@property(nonatomic, assign) BOOL hasDataLoaded;
@property(nonatomic, assign) NSUInteger pageSize;
@end

@implementation SKPaginator

- (instancetype)init {
    if (self = [super init]) {
      _pageSize = [SKNetworkConfig sharedInstance].perPage;
      self.hasMorePages = YES;
    }
    return self;
}

- (void)setLoading:(BOOL)loading {
  if (self.isLoading == loading) {
    return;
  }
  _loading = loading;
}

- (void)setRefresh:(BOOL)refresh {
  if (self.isRefresh == refresh) {
    return;
  }
  _refresh = refresh;
}

- (AnyPromise *)refresh {
  return nil;
}

- (AnyPromise *)loadMore {
  return nil;
}

@end


/////////////////////////////
/////////////////////////////
@interface SKPagedPaginator ()
@property(nonatomic, assign) NSUInteger firstPage;
@property(nonatomic, assign) NSUInteger nextPage;
@end

@implementation SKPagedPaginator

- (instancetype)init {
  if (self = [super init]) {
    _firstPage = 1;
    self.hasMorePages = YES;
  }
  return self;
}

- (AnyPromise *)refresh {
  if (self.refresh || self.loading) {
    return nil;
  }
  if (self.delegate && [self.delegate respondsToSelector:@selector(networkOnStart:)]) {
    self.refresh = YES;
    self.loading = YES;
    [self.delegate networkOnStart:YES];
  }
  if (self.delegate && [self.delegate respondsToSelector:@selector(paginate:)]) {
    NSDictionary *parameters = @{@"page" : @(self.firstPage),@"page_size" : @(self.pageSize)};
    return [self paginate:parameters isRefresh:YES];
  }

  return nil;
}

- (AnyPromise *)loadMore {
  if (self.refresh || self.loading) {
    return nil;
  }
  if (self.delegate && [self.delegate respondsToSelector:@selector(networkOnStart:)]) {
    self.refresh = NO;
    self.loading = YES;
    [self.delegate networkOnStart:NO];
  }
  if (self.delegate && [self.delegate respondsToSelector:@selector(paginate:)]) {
    NSDictionary *parameters = @{@"page" : @(self.nextPage),@"page_size" : @(self.pageSize)};
    return [self paginate:parameters isRefresh:NO];
  }

  return nil;
}

- (AnyPromise *)paginate:(NSDictionary *)parameters isRefresh:(BOOL)isRefresh {
  if (!self.delegate || ![self.delegate respondsToSelector:@selector(paginate:)]) {
    return nil;
  }
  AnyPromise *promise = [self.delegate paginate:[parameters mutableCopy]];
  if (promise) {
    @weakify(self);
    return promise.then(^(OVCResponse *response) {
      @strongify(self);
      NSArray *result = response.result;
      self.hasDataLoaded = YES;
      if (result && result.count >= self.pageSize) {
        self.nextPage += 1;
        self.hasMorePages = YES;
      } else{
        self.hasMorePages = NO || isRefresh;
      }
      return result;
    }).finally(^{
      self.refresh = NO;
      self.loading = NO;
    });
  }
  return nil;
}
@end
/////////////////////////////
/////////////////////////////

/////////////////////////////
/////////////////////////////
@interface SKKeyPaginator ()
@end

@implementation SKKeyPaginator

- (instancetype)initWithEntityName:(NSString *)entityName {
  if (self = [super init]) {
    _entityName = entityName;
  }
  return self;
}

- (AnyPromise *)refresh {
  if (self.refresh || self.loading) {
    return nil;
  }
  if (self.delegate && [self.delegate respondsToSelector:@selector(networkOnStart:)]) {
    self.refresh = YES;
    self.loading = YES;
    [self.delegate networkOnStart:YES];
  }

  if (self.delegate && [self.delegate respondsToSelector:@selector(paginate:)]) {
    NSDictionary *parameters = @{};
    NSNumber *identifier = [[SKManaged sharedInstance] lastModelIdentifier:self.entityName];
    if (identifier) {
      parameters = [parameters mtl_dictionaryByAddingEntriesFromDictionary:@{@"since-id": [identifier stringValue]}];
    }
    return [self paginate:parameters isRefresh:YES];
  }

  return nil;
}

- (AnyPromise *)loadMore {
  if (self.refresh || self.loading) {
    return nil;
  }
  if (self.delegate && [self.delegate respondsToSelector:@selector(networkOnStart:)]) {
    self.refresh = NO;
    self.loading = YES;
    [self.delegate networkOnStart:NO];
  }

  if (self.delegate && [self.delegate respondsToSelector:@selector(paginate:)]) {
    NSNumber *identifier = [[SKManaged sharedInstance] firstModelIdentifier:self.entityName];
    NSAssert(identifier, @"loadMore should not be called when the cache is empty");
    NSDictionary *parameters = @{@"max-id": [identifier stringValue],@"page_size" : @(self.pageSize)};
    return [self paginate:parameters isRefresh:false];
  }

  return nil;
}

- (AnyPromise *)paginate:(NSDictionary *)parameters isRefresh:(BOOL)isRefresh {
  if (!self.delegate || ![self.delegate respondsToSelector:@selector(paginate:)]) {
    return nil;
  }
  AnyPromise *promise = [self.delegate paginate:[parameters mutableCopy]];
  if (promise) {
    @weakify(self);
    return promise.then(^(OVCResponse *response) {
      NSArray *result = response.result;
      self.hasDataLoaded = YES;
      @strongify(self);
      if (result && result.count >= self.pageSize) {
        self.hasMorePages = YES;
      } else {
        self.hasMorePages = NO || isRefresh;
      }
      self.hasError = NO;
      return result;
    }).catch(^(NSError *error){
      self.hasError = YES;
    }).finally(^{
      self.refresh = NO;
      self.loading = NO;
    });
  }
  return nil;
}
@end
/////////////////////////////