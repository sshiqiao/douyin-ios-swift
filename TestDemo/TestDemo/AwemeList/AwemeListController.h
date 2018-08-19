//
//  AwemeListController.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AwemeListController : UIViewController
@property (nonatomic, strong) UITableView                       *tableView;
@property (nonatomic, assign) NSInteger                         currentIndex;
-(instancetype)initWithVideoData:(NSMutableArray<NSString *> *)data currentIndex:(NSInteger)currentIndex pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize;
@end
