//
//  DatePickerView.m
//  Thinkape-iOS
//
//  Created by tixa on 15/9/7.
//  Copyright (c) 2015年 TIXA. All rights reserved.
//

#import "DatePickerView.h"

@implementation DatePickerView


- (void)awakeFromNib{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 36,width , 218-36)];
    [picker setDatePickerMode:UIDatePickerModeDate];
    [picker setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [self addSubview:picker];
    
    //self.datePicker.datePickerMode = UIDatePickerModeDate;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)doSelect:(id)sender {
    
    NSDate *currentDate = picker.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [formatter stringFromDate:currentDate];
    if (self.selectDateCallBack) {
        self.selectDateCallBack(dateStr);
    }
    
}

- (void)setDate:(NSString *)date{
    if (_date != date) {
        _date = date;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *setDate = [formatter dateFromString:date];
        picker.date = setDate;
    }
}

- (IBAction)closeView:(id)sender {
    
    [self removeFromSuperview];
    
}
@end
