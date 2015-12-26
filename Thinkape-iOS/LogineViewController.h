//
//  LogineViewController.h
//  Thinkape-iOS
//
//  Created by tixa on 15/5/26.
//  Copyright (c) 2015年 TIXA. All rights reserved.
//

#import "ParentsViewController.h"
#import "AccountModel.h"

@interface LogineViewController : ParentsViewController <UIAlertViewDelegate,UITextFieldDelegate>

@property (nonatomic,strong) void (^logSuccess)(AccountModel *model);

@end
