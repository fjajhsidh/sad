//
//  BianJiViewController.m
//  Thinkape-iOS
//
//  Created by admin on 15/12/23.
//  Copyright © 2015年 TIXA. All rights reserved.
//

#import "BianJiViewController.h"
#import "BillsDetailViewController.h"
#import "LayoutModel.h"
#import "CostLayoutModel.h"

#import "CostDetailViewController.h"
#import "HistoryModel.h"

#import "DocumentsFlowchartCell.h"
#import "SDPhotoBrowser.h"
#import "LinkViewController.h"
#import <QuickLook/QLPreviewController.h>
#import <QuickLook/QLPreviewItem.h>
#import "CTToastTipView.h"
#import "SendMsgViewController.h"
#import "ImageModel.h"
#import "UIImage+SKPImage.h"
#import "CTAssetsPickerController.h"
#import "HomeViewController.h"
#import "BianjiTableViewCell.h"

#import "KindsModel.h"
#import "KindsLayoutModel.h"
#import "KindsPickerView.h"
#import "KindsItemModel.h"
@interface BianJiViewController ()<UITableViewDataSource,UITableViewDelegate,SDPhotoBrowserDelegate,QLPreviewControllerDataSource,UIAlertViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,CTAssetsPickerControllerDelegate,UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong,nonatomic) NSMutableArray *mainLayoutArray; // 主表 布局视图
@property (weak, nonatomic) IBOutlet UIView *smallview;
@property (strong,nonatomic) NSMutableArray *costLayoutArray;

@property (strong,nonatomic) NSMutableArray *pathFlow; // 审批流程
@property (nonatomic,strong) NSMutableArray *mainData;
@property (nonatomic,strong) NSMutableArray *costData;
@property (nonatomic,strong) NSMutableArray *uploadArr;
@property (strong, nonatomic) KindsModel *selectModel;
@property (strong, nonatomic) KindsPickerView *kindsPickerView;

@property (nonatomic,strong) UITextField *beizhuText;
@property(nonatomic,strong)UIActionSheet *actionshoot;


@property (nonatomic , strong) NSMutableArray *imageArray;
@end

@implementation BianJiViewController
{
    NSString *delteImageID;
    UIView *bgView;
    CGFloat textFiledHeight;
    UIButton *sureBtn;
    UIButton *backBatn;
    UIView *infoView;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"详情";
    
    self.tableview.delegate=self;
    self.tableview.dataSource=self;
    
    _mainLayoutArray = [[NSMutableArray alloc] init];
    _costLayoutArray = [[NSMutableArray alloc] init];
    _mainData = [[NSMutableArray alloc] init];
    _costData = [[NSMutableArray alloc] init];
    _pathFlow = [[NSMutableArray alloc] init];
    [self requestDataSource];
}

- (IBAction)Cancel:(id)sender {
}
- (IBAction)Save:(id)sender {
}

- (void)requestDataSource{
    
    //ac=GetEditData&u=9&programid=130102&billid=28
    [RequestCenter GetRequest:[NSString stringWithFormat:@"ac=EditData&u=%@&programid=%@&billid=%@",self.uid ,self.programeId,self.billid]
                   parameters:nil
                      success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
                          
                          NSDictionary * mainLayout = [[[responseObject objectForKey:@"msg"] objectForKey:@"fieldconf"] objectForKey:@"main"];
                          NSArray * costLayout = [[[responseObject objectForKey:@"msg"] objectForKey:@"fieldconf"] objectForKey:@"details"];
                          [_mainLayoutArray addObjectsFromArray:[LayoutModel objectArrayWithKeyValuesArray:[mainLayout objectForKey:@"fields"]]];
                          [_costLayoutArray addObjectsFromArray:[CostLayoutModel objectArrayWithKeyValuesArray:costLayout]];
                          NSArray *dataArr = [[responseObject objectForKey:@"msg"] objectForKey:@"data"];
                          _mainData = [dataArr safeObjectAtIndex:0];
                          
                          
                          //                          [self addCommintBtn];
                          
                          [_costData addObjectsFromArray:[dataArr objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, _costLayoutArray.count)]]];
                          _uploadArr = [NSMutableArray arrayWithArray:[[responseObject objectForKey:@"msg"] objectForKey:@"upload"]];
                          [self.tableview reloadData];
                          [SVProgressHUD dismiss];
                          
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          
                      }];
    
}
- (void)requestFlowPath{
    [RequestCenter GetRequest:[NSString stringWithFormat:@"ac=GetFlowPath&u=%@&ukey=%@&ProgramID=%@&Billid=%@",self.uid,self.ukey,self.programeId,self.billid]
                   parameters:nil
                      success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
                          
                          //                          _pathFlow = [[responseObject objectForKey:@"msg"] objectForKey:@"data"];
                          _pathFlow =[responseObject objectForKey:@"msg"];
                          _pathFlow = [responseObject objectForKey:@"data"];
                          
                          [SVProgressHUD dismiss];
                          [self.tableview reloadData];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [SVProgressHUD dismiss];
                      }
            showLoadingStatus:YES];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger number = 0;
    //    switch (self.selectedIndex) {
    //        case 0:
    //        {
    if (_mainLayoutArray.count == 0) {
        
        number = 0;
        //                if (self.billType==3) {
        //                    UIBarButtonItem *aller  =[[UIBarButtonItem alloc] initWithTitle:@"更多" style:UIBarButtonItemStylePlain target:self action:@selector(buttontap)];
        //                    self.navigationItem.rightBarButtonItem=aller;
        //                    NSLog(@"进了没");
        //                }
        
        
    }
    else if (_uploadArr.count == 0){
        
        
        
        number = _mainLayoutArray.count + 1;
        //最后一步
        //                UIBarButtonItem *aller  =[[UIBarButtonItem alloc] initWithTitle:@"更多" style:UIBarButtonItemStylePlain target:self action:@selector(buttontap)];
        //                self.navigationItem.rightBarButtonItem=aller;
        
        
        if ([self isUnCommint]) {
            number = _mainLayoutArray.count + 2;
            
            
        }
        
    }
    else
        
        number = _mainLayoutArray.count + 2;
    //                  }
    //            break;
    //        case 1:{
    //            number = self.dataArray.count;
    //
    //        }
    //            break;
    //        case 2:{
    //            number = self.pathFlow.count;
    //        }
    //            break;
    //        default:
    //            break;
    //    }
    return number;
}
-(void)button{
    NSLog(@"ascasc");
}
- (void)addDatePickerView:(NSInteger)tag date:(NSString *)date{
//    if (!self.datePickerView) {
//        self.datePickerView = [[[NSBundle mainBundle] loadNibNamed:@"DatePickerView" owner:self options:nil] lastObject];
//        [self.datePickerView setFrame:CGRectMake(0, self.view.frame.size.height - 218, self.view.frame.size.width, 218)];
//    }
//    __block BianJiViewController *weakSelf = self;
//    self.datePickerView.tag = tag;
//    
//    if (date.length != 0) {
//        self.datePickerView.date = date;
//    }
//    ∫∫
//    self.datePickerView.selectDateCallBack = ^(NSString *date){
    
 
}
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    }
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    BianjiTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell) {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"BianjiTableViewCell" owner:self options:nil] lastObject];
        
    }
    UIView *subView = [cell.contentView viewWithTag:203];
    UIView *subView1 = [cell.contentView viewWithTag:204];
    [subView removeFromSuperview];
    [subView1 removeFromSuperview];
    
    NSDictionary *mainDataDic = [_mainData safeObjectAtIndex:0];
    //    cell.lineViewHeight.constant = 0.5f;
    
    if (indexPath.row < _mainLayoutArray.count) {
        LayoutModel *model = [_mainLayoutArray safeObjectAtIndex:indexPath.row];
        cell.leftlabel.text = [NSString stringWithFormat:@"%@:",model.name];
        //        cell.rightbutton text = [mainDataDic objectForKey:model.fieldname];
        //        [cell.rightbutton setTitle:[mainDataDic objectForKey:model.fieldname] forState:UIControlStateNormal];
        cell.lefttable.text=[mainDataDic objectForKey:model.fieldname];
        
        //        cell.contentLabelHeight.constant = [self fixStr:[mainDataDic objectForKey:model.fieldname]];
        if ([model.fieldname isEqualToString:@"totalmoney"]) {
            //            cell.leftlabel.textColor = [UIColor hex:@"f23f4e"];
            cell.lefttable.textColor=[UIColor hex:@"f23f4e"];
        }
        else
            cell.lefttable.textColor = [UIColor hex:@"333333"];
        
    }
    if (indexPath.row == _mainLayoutArray.count) {
        
        cell.leftlabel.text =nil;
        cell.lefttable.text = nil;
        
        [cell.contentView addSubview:[self costScrollView]];
        
    }
    //注释看看删不删掉
    //            else if (indexPath.row > _mainLayoutArray.count - 3 && indexPath.row < _mainLayoutArray.count + 1){
    //                LayoutModel *model = [_mainLayoutArray safeObjectAtIndex:indexPath.row - 1];
    //                cell.titleLabel.text = [NSString stringWithFormat:@"%@:",model.name];
    //                cell.contentLabel.text = [mainDataDic objectForKey:model.fieldname];
    //                cell.contentLabelHeight.constant = [self fixStr:[mainDataDic objectForKey:model.fieldname]];
    //                if ([model.fieldname isEqualToString:@"totalmoney"]) {
    //                    cell.contentLabel.textColor = [UIColor hex:@"f23f4e"];
    //                }
    //                else
    //                    cell.contentLabel.textColor = [UIColor hex:@"333333"];
    //            }
    else if (indexPath.row == _mainLayoutArray.count + 1){
        cell.leftlabel.text =nil;
        
        cell.lefttable.text =nil;
        if (!bgView) {
            bgView = [[UIView alloc] initWithFrame:CGRectMake(18, 0, SCREEN_WIDTH - 36, (SCREEN_WIDTH - 36) * 0.75)];
            bgView.tag = 204;
        }
        NSInteger count = _imageArray.count + _uploadArr.count;
        CGFloat speace = 15.0f;
        CGFloat imageWidth = (SCREEN_WIDTH - 36 -4*speace) / 3.0f;
        int row = count / 3 + 1;
        //bgView.backgroundColor = [UIColor redColor];
        [bgView setFrame:CGRectMake(18, 0, SCREEN_WIDTH - 36, (speace + imageWidth) * row)];
        [bgView removeFromSuperview];
        [self addItems:bgView];
        [cell.contentView addSubview:bgView];
    }
    
    return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat rowHeight = 0.0f;
    
    //    if (self.selectedIndex == 0) {
    NSDictionary *mainDataDic = [_mainData safeObjectAtIndex:0];
    if (indexPath.row == _mainLayoutArray.count + 1 && _uploadArr.count != 0){
        NSInteger count = _imageArray.count + _uploadArr.count;
        CGFloat speace = 15.0f;
        CGFloat imageWidth = (SCREEN_WIDTH - 36 -4*speace) / 3.0f;
        int row;
        if (count %3 == 0) {
            row = count / 3;
        }
        else{
            row = count / 3 + 1;
        }
        return (speace + imageWidth) * row + 10;
    }
    else if (indexPath.row == _mainLayoutArray.count + 1 && _uploadArr.count == 0 && [self isUnCommint]){
        NSInteger count = _imageArray.count + _uploadArr.count;
        CGFloat speace = 15.0f;
        CGFloat imageWidth = (SCREEN_WIDTH - 36 -4*speace) / 3.0f;
        int row = count / 3 + 1;
        return (speace + imageWidth) * row + 10;
    }
    //看看要不要删掉
    //        else if (indexPath.row > _mainLayoutArray.count - 3 && indexPath.row < _mainLayoutArray.count + 1){
    //           LayoutModel *model = [_mainLayoutArray safeObjectAtIndex:indexPath.row - 1];
    //           rowHeight = [self fixStr:[mainDataDic objectForKey:model.fieldname]] + 20;
    //        }
    else if (indexPath.row < _mainLayoutArray.count){
        LayoutModel *model = [_mainLayoutArray safeObjectAtIndex:indexPath.row];
        rowHeight = [self fixStr:[mainDataDic objectForKey:model.fieldname]] + 20;
    }
    else if(_mainLayoutArray.count == indexPath.row && _costLayoutArray.count != 0 )
        rowHeight = 80;
    
    else
    {
        rowHeight = 0;
        
    }
    
    
    
    
    
    return rowHeight;
    
}
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    //    if (self.selectedIndex == 2) {
//    NSMutableDictionary *dict = [_pathFlow objectAtIndex:indexPath.row];
//    [CTToastTipView showTipText:[dict objectForKey:@"approveuser"]];
//    //    }
//}
// 单条审批
//- (void)singleApprove:(UnApprovalModel *)model type:(NSString *)type{
//    //http://27.115.23.126:3032/ashx/mobile.ashx?ac=Approve&u=1&ukey=abc&ProgramID=130102&Billid=3&BillNo=NO130102_9&disc=fuck&stepid=617&returnrule=&dynamicid=6976&returntodynid=0&resultType=pass
//    NSString *returntodynid = @"0";
//    //看看这条能不能删掉
//    if (![model.returnrule isEqualToString:@"ChoiceReturnStep"]) {
//        returntodynid = @"0";
//    }
//    else
//    {
//
//    }
//    [RequestCenter GetRequest:[NSString stringWithFormat:@"ac=Approve&u=%@&ukey=%@&ProgramID=%@&Billid=%@&BillNo=%@&disc=%@&stepid=%@&returnrule=%@&dynamicid=%@&returntodynid=%@&resultType=%@",self.uid,self.ukey,model.programid,model.billid,model.billno,[_beizhuText.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],model.stepid,model.returnrule,model.dynamicid,returntodynid,type]
//                   parameters:nil
//                      success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
//                          if([[responseObject objectForKey:@"msg"] isKindOfClass:[NSDictionary class]]){
//                              NSString *msg = [[responseObject objectForKey:@"msg"] objectForKey:@"Msg"];
//                              if ([msg isEqualToString:@"ok"] && [type isEqualToString:@"pass"]) {
//                                  [SVProgressHUD showSuccessWithStatus:@"审批成功"];
//                                  [self backVC];
//                              }
//                              else if ([msg isEqualToString:@"ok"] && [type isEqualToString:@"fail"]){
//                                  [SVProgressHUD showSuccessWithStatus:@"退回成功"];
//                                  [self backVC];
//                              }
//                              else
//                              {
//                                  [SVProgressHUD showSuccessWithStatus:msg];
//                              }
//                          }
//                          else
//                          {
//                              [SVProgressHUD showInfoWithStatus:[responseObject objectForKey:@"msg"]];
//                          }
//
//                      }
//                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//
//                      }
//            showLoadingStatus:NO];
//
//}
//- (void)deleateOrder{
//    //http://27.115.23.126:5032/ashx/mobilenew.ashx?ac=DeleteRecord&u=5&programid=130102&billid=382
//    [RequestCenter GetRequest:[NSString stringWithFormat:@"ac=DeleteRecord&u=%@&programid=%@&billid=%@",self.uid,self.programeId,self.bills.billid]
//                   parameters:nil
//                      success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
//
//                          [SVProgressHUD showSuccessWithStatus:@"删除成功"];
//                          if (self.reloadData) {
//                              self.reloadData();
//                          }
//                          [self.navigationController popViewControllerAnimated:YES];
//                      }
//                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                          [SVProgressHUD dismiss];
//                      }];
//}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)isUnCommint{
    NSDictionary *mainDataDic = [_mainData safeObjectAtIndex:0];
    return [[mainDataDic objectForKey:@"flowstatus_show"] isEqualToString:@"未提交"] || [[mainDataDic objectForKey:@"flowstatus_show"] isEqualToString:@"已弃审"] || [[mainDataDic objectForKey:@"flowstatus_show"] isEqualToString:@"已退回"];
}
//- (void)agreeApprove{
//    [self singleApprove:_unModel type:@"pass"];
//}
- (void)resizeFootViewFrame:(NSInteger)type{
    if (type == 0) {
        textFiledHeight = 30;
        // UIView *view = [self.view viewWithTag:1024];
        //        self.tableViewBottomConstraint.constant = 60 + textFiledHeight;
        self.beizhuText.frame = CGRectMake(10, 10, CGRectGetWidth(infoView.frame) - 20, textFiledHeight);
        infoView.frame = CGRectMake(10, SCREEN_HEIGHT - 50 - textFiledHeight, SCREEN_WIDTH - 20, 50 + textFiledHeight);
        CGFloat btnWidth = (CGRectGetWidth(infoView.frame) - 40) / 2.0f;
        [sureBtn setFrame:CGRectMake(10, 45 , btnWidth, 30)];
        [backBatn setFrame:CGRectMake(CGRectGetMaxX(sureBtn.frame) + 20, CGRectGetMinY(sureBtn.frame), btnWidth, 30)];
    }
    else
    {
        textFiledHeight = 0;
        // UIView *view = [self.view viewWithTag:1024];
        //        self.tableViewBottomConstraint.constant = 50 + textFiledHeight;
        self.beizhuText.frame = CGRectMake(10, 0, CGRectGetWidth(infoView.frame) - 20, textFiledHeight);
        infoView.frame = CGRectMake(10, SCREEN_HEIGHT - 50 - textFiledHeight, SCREEN_WIDTH - 20, 50 + textFiledHeight);
        CGFloat btnWidth = (CGRectGetWidth(infoView.frame) - 40) / 2.0f;
        [sureBtn setFrame:CGRectMake(10, 10 , btnWidth, 30)];
        [backBatn setFrame:CGRectMake(CGRectGetMaxX(sureBtn.frame) + 20, CGRectGetMinY(sureBtn.frame), btnWidth, 30)];
    }
    
    //    lastConstant = self.tableViewBottomConstraint.constant;
}

- (void)backVC{
    [self.navigationController popViewControllerAnimated:YES];
    if (self.reloadData) {
        self.reloadData();
    }
    
}

- (CGFloat )fixStr:(NSString *)str{
    CGRect frame = [str boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.view.frame) - 115, 99999) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil];
    return  frame.size.height >=0 ? frame.size.height : 20;
}

- (void)addItems:(UIView *)view{
    
    for (UIView *subView in bgView.subviews) {
        [subView removeFromSuperview];
    }
    
    //    CGFloat width = CGRectGetWidth(view.frame);
    //    CGFloat itemWidth = (width - 4)/3;
    //    int rows = _uploadArr.count / 3 + 1;
    //    [view setFrame:CGRectMake(18, 0, SCREEN_WIDTH - 36, itemWidth * 0.75 * rows)];
    //    for (int i = 0; i < _uploadArr.count; i++) {
    //        int colum = i %3;
    //        int row = i/3;
    //        NSString *url = [_uploadArr safeObjectAtIndex:i];
    //        UIButton *itemView = [UIButton buttonWithType:UIButtonTypeCustom];
    //
    //        [itemView setFrame:CGRectMake(colum*(itemWidth + 2), row * (itemWidth * 0.75 + 2), itemWidth, itemWidth * 0.75)];
    //        itemView.tag = i;
    //        itemView.userInteractionEnabled  = YES;
    //        [itemView addTarget:self action:@selector(showImage:) forControlEvents:UIControlEventTouchUpInside];
    //        [view addSubview:itemView];
    //                }
    if (_uploadArr.count != 0 || _imageArray.count != 0) {
        NSInteger count = _uploadArr.count;
        CGFloat speace = 15.0f;
        CGFloat imageWidth = (SCREEN_WIDTH - 36 - 4*speace) / 3.0f;
        
        for (int i = 0; i < count; i++) {
            int cloum = i %3;
            int row = i / 3;
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(speace + (speace + imageWidth) * cloum, speace + (speace + imageWidth) * row, imageWidth, imageWidth)];
            NSString *url = [_uploadArr safeObjectAtIndex:i];
            if ([self fileType:url] == 1) {
                [btn setImage:[UIImage imageNamed:@"word"] forState:UIControlStateNormal];
            }
            else{
                [btn sd_setBackgroundImageWithURL:[NSURL URLWithString:url] forState:UIControlStateNormal];
            }
            btn.tag = 1024+ i;
            [btn addTarget:self action:@selector(showImage:) forControlEvents:UIControlEventTouchUpInside];
            [bgView addSubview:btn];
            if ([self isUnCommint]) {
                UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [deleteBtn setFrame:CGRectMake(imageWidth - 32, 0, 32, 32)];
                [deleteBtn setImage:[UIImage imageNamed:@"deleteBtn"] forState:UIControlStateNormal];
                deleteBtn.tag = 1024+ i;
                [deleteBtn addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
                [btn addSubview:deleteBtn];
            }
            
        }
        count += _imageArray.count;
        for (int i = _uploadArr.count; i < count; i++) {
            int cloum = i %3;
            int row = i / 3;
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(speace + (speace + imageWidth) * cloum, speace + (speace + imageWidth) * row, imageWidth, imageWidth)];
            [btn setBackgroundImage:[_imageArray safeObjectAtIndex:i - _uploadArr.count] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(showSelectImage:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = 2024+ i;
            [bgView addSubview:btn];
            
            if ([self isUnCommint]) {
                UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [deleteBtn setFrame:CGRectMake(imageWidth - 32, 0, 32, 32)];
                [deleteBtn setImage:[UIImage imageNamed:@"deleteBtn"] forState:UIControlStateNormal];
                deleteBtn.tag = 1024+ i;
                [deleteBtn addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
                [btn addSubview:deleteBtn];
            }
        }
        int btnCloum = count %3;
        int btnRow = count / 3;
        view.backgroundColor = [UIColor clearColor];
        //看看都不能删掉，注意只有一行
        //       NSDictionary *mainDataDic = [_mainData safeObjectAtIndex:0];
        if ([self isUnCommint]) {
            UIButton *addImage = [UIButton buttonWithType:UIButtonTypeCustom];
            [addImage setFrame:CGRectMake(speace + (speace + imageWidth) * btnCloum, speace + (speace + imageWidth) * btnRow, imageWidth, imageWidth)];
            [addImage setImage:[UIImage imageNamed:@"addImage"] forState:UIControlStateNormal];
            [addImage addTarget:self action:@selector(showPickImageVC) forControlEvents:UIControlEventTouchUpInside];
            [bgView addSubview:addImage];
        }
    }
    else{
        CGFloat speace = 15.0f;
        CGFloat imageWidth = (SCREEN_WIDTH - 36 - 4*speace) / 3.0f;
        if ([self isUnCommint]) {
            UIButton *addImage = [UIButton buttonWithType:UIButtonTypeCustom];
            [addImage setFrame:CGRectMake(speace + (speace + imageWidth) * 0, speace + (speace + imageWidth) * 0, imageWidth, imageWidth)];
            [addImage setImage:[UIImage imageNamed:@"addImage"] forState:UIControlStateNormal];
            [addImage addTarget:self action:@selector(showPickImageVC) forControlEvents:UIControlEventTouchUpInside];
            [bgView addSubview:addImage];
        }
        
    }
    
    
}



#pragma mark - CustomMethods

- (void)deleteImage:(UIButton *)btn{
    
    if (btn.tag >=1024 && btn.tag < 2024) {
        NSString *url = [_uploadArr safeObjectAtIndex:btn.tag - 1024];
        
        NSString *imgid = [[url componentsSeparatedByString:@"?"] lastObject];
        
        
        if (delteImageID.length == 0) {
            delteImageID = [NSString stringWithFormat:@"%@",imgid];
        }
        else{
            delteImageID = [NSString stringWithFormat:@"%@,%@",delteImageID,imgid];
        }
        [_uploadArr removeObject:url];
    }
    else{
        [_imageArray removeObjectAtIndex:btn.tag - 2024];
        [self.tableview reloadData];
    }
    [self.tableview reloadData];
}

- (void)showPickImageVC{
    if (!_imageArray) {
        _imageArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    self.actionshoot = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"本地相册", nil];
    self.actionshoot.tag=200;
    [self.actionshoot showInView:self.view];
    
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag==200) {
        if (buttonIndex == 0) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:picker animated:YES completion:nil];
        }
        if (buttonIndex == 1)
        {
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            picker.delegate = self;
            [self presentViewController:picker animated:YES completion:nil];
            
        }
        //    }else{
        //
        if (buttonIndex==0) {
            
            
            [self.navigationController popViewControllerAnimated:YES];
            //              [RequestCenter GetRequest:[NSString stringWithFormat:@"ac=AutoCreate&u=1&sourceprogramid=%@&targetprogramid=%@&billid=%@",self.uid,_unModel.SourceProgramID,_unModel.TargetProgramID,_unModel.billid,]] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
            //          NSArray *msg = [responseObject objectForKey:@"msg"];
            //          for (NSDictionary *dict in msg) {
            //              if ([[dict objectForKey:@"title"] isEqualToString:@"差旅费用报销"]) {
            //
            //              }
            //          }
            //      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //          <#code#>
            //      }];
        }
        //    if (buttonIndex==1) {
        //        NSLog(@"借款");
        //    }
    }
}

- (void)uploadClick:(UIButton *)btn{
    [self uploadImage:0];
}

- (void)uploadImage:(NSInteger)index{
    NSString *fbyte = @"";  //图片bate64
    
    fbyte = [self bate64ForImage:[_imageArray safeObjectAtIndex:index]];
    NSLog(@"bate64 : %@",fbyte);
    NSString *str = [NSString stringWithFormat:@"%@?ac=UploadMoreFile64&u=%@&EX=%@&FName=%@&programid=%@&billid=%@",Web_Domain,self.uid,@".jpg",@"image",self.programeId,self.billid];
    if (delteImageID.length != 0) {
        str = [NSString stringWithFormat:@"%@&delpicid=%@",str,delteImageID];
    }
    NSLog(@"str : %@",str);
    [SVProgressHUD showWithMaskType:2];
    [[AFHTTPRequestOperationManager manager] POST:str
                                       parameters:_imageArray.count != 0? @{@"FByte":fbyte} : nil
                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                              //看看能不能删掉
                                              //                                              if ([[responseObject objectForKey:@"msg"] isEqualToString:@"ok"]) {
                                              [SVProgressHUD dismiss];
                                              if (index + 1 < _imageArray.count) {
                                                  [self uploadImage:index + 1];
                                              }
                                              if (index + 1 == _imageArray.count - 1) {
                                                  [self.navigationController popViewControllerAnimated:YES];
                                                  if (self.reloadData) {
                                                      self.reloadData();
                                                  }
                                              }
                                              if (_imageArray.count == 0 && delteImageID.length != 0) {
                                                  [self.navigationController popViewControllerAnimated:YES];
                                                  if (self.reloadData) {
                                                      self.reloadData();
                                                  }
                                              }
                                              //                                              }
                                          }
                                          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              
                                          }];
    
    
}

- (NSString *)bate64ForImage:(UIImage *)image{
    UIImage *_originImage = image;
    NSData *_data = UIImageJPEGRepresentation(_originImage, 0.5f);
    NSString *_encodedImageStr = [_data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return _encodedImageStr;
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"info:%@",info);
    UIImage *originalImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    UIImage *image = [UIImage imageWithData:[originalImage thumbImage:originalImage]];
    image = [image fixOrientation:image];
    [_imageArray addObject:image];
    [self.tableview reloadData];
}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
    [picker dismissViewControllerAnimated:YES completion:nil];
    id class = [assets lastObject];
    for (ALAsset *set in assets) {
        UIImage *image = [UIImage imageWithCGImage:[set thumbnail]];
        [_imageArray addObject:image];
    }
    [self.tableview reloadData];
    NSLog(@"class :%@",[class class]);
}

- (void)showSelectImage:(UIButton *)btn{
    SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
    
    browser.sourceImagesContainerView = nil;
    
    browser.imageCount = _imageArray.count;
    
    browser.currentImageIndex = btn.tag - 2024 - _uploadArr.count;
    
    browser.delegate = self;
    browser.tag = 11;
    [browser show]; // 展示图片浏览器
}


- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index{
    //    UIButton *imageView = (UIButton *)[bgView viewWithTag:index];
    if (browser.tag == 11) {
        return _imageArray[index];
    }
    else
        return nil;
}


- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index{
    if (browser.tag == 10) {
        NSLog(@"url %@",[_uploadArr objectAtIndex:index]);
        NSString *model = [_uploadArr objectAtIndex:index];
        return [NSURL URLWithString:model];
    }
    else
        return nil;
    
}

- (NSInteger)fileType:(NSString *)fileName{
    NSArray *suffix = [fileName componentsSeparatedByString:@"."];
    NSString *type = [suffix lastObject];
    NSRange range = [type rangeOfString:@"png"];
    NSRange range1 = [type rangeOfString:@"jpg"];
    
    if (range.length >0 || range1.length > 0) {
        return 0;
    }
    else
        return 1;
}

- (void)showImage:(UIButton *)btn{
    NSString *url = [_uploadArr safeObjectAtIndex:btn.tag - 1024];
    if ([self fileType:url] == 1) {
        [[RequestCenter defaultCenter] downloadOfficeFile:url
                                                  success:^(NSString *filename) {
                                                      QLPreviewController *previewVC = [[QLPreviewController alloc] init];
                                                      previewVC.dataSource = self;
                                                      [self presentViewController:previewVC animated:YES completion:^{
                                                          
                                                      }];
                                                  }
                                                  fauiler:^(NSError *error) {
                                                      
                                                  }];
    }
    else {
        SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
        browser.tag = 10;
        browser.sourceImagesContainerView = nil;
        
        browser.imageCount = _uploadArr.count;
        
        browser.currentImageIndex = btn.tag - 1024;
        
        browser.delegate = self;
        
        [browser show]; // 展示图片浏览器
    }
}

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller{
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index{
    return [NSURL fileURLWithPath:[[RequestCenter defaultCenter] filePath]];
}

- (UIScrollView *)costScrollView{
    
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(18, 0, SCREEN_WIDTH - 36, 80)];
    scroll.tag = 203;
    [scroll setContentSize:CGSizeMake(95*_costLayoutArray.count-35, 80)];
    scroll.showsHorizontalScrollIndicator = NO;
    for (int i = 0; i < _costLayoutArray.count; i++) {
        CostLayoutModel *model = [_costLayoutArray safeObjectAtIndex:i];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(i*(60 + 35), 10, 57, 57)];
        [btn addTarget:self action:@selector(costDetail:) forControlEvents:UIControlEventTouchUpInside];
        btn.contentMode = UIViewContentModeScaleAspectFit;
        [btn sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",model.photopath]]
                                 forState:UIControlStateNormal
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                }];
        btn.tag = i;
        
        UILabel *totleMoney = [[UILabel alloc] initWithFrame:CGRectMake(0, 37, 57, 15)];
        totleMoney.textColor = [UIColor whiteColor];
        totleMoney.font = [UIFont systemFontOfSize:15];
        totleMoney.text = model.TotalMoney;
        totleMoney.textAlignment = NSTextAlignmentCenter;
        [btn addSubview:totleMoney];
        
        [scroll addSubview:btn];
    }
    return scroll;
}

-(void)costDetail:(UIButton *)btn{
    
    CostDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CostDetailVC"];
    vc.costLayoutArray = _costLayoutArray;
    vc.costDataArr = _costData;
    vc.index = btn.tag;
    [self.navigationController pushViewController:vc animated:YES];
    
    
}
- (NSString *)appendStr:(NSArray *)arr{
    
    NSMutableString *returnStr = [NSMutableString string];
    for (int i = 0; i < arr.count; i ++) {
        LianxiModel *model = [arr safeObjectAtIndex:i];
        if (i == arr.count - 1) {
            [returnStr appendString:model.iuserid];
        }
        else{
            [returnStr appendFormat:@"%@,",model.iuserid];
        }
    }
    return returnStr;
}






/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
