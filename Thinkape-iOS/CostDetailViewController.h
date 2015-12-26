//
//  CostDetailViewController.h
//  Thinkape-iOS
//
//  Created by tixa on 15/5/6.
//  Copyright (c) 2015年 TIXA. All rights reserved.
//

#import "ParentsViewController.h"

@interface CostDetailViewController : ParentsViewController

@property (nonatomic,strong) NSArray *costLayoutArray;
@property (nonatomic,strong) NSArray *costDataArr;
@property (nonatomic,assign) int index;

@end

