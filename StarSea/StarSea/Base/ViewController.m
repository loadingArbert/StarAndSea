//
//  ViewController.m
//  StarSea
//
//  Created by WayneLiu on 15/4/15.
//  Copyright (c) 2015年 WayneLiu. All rights reserved.
//

#import "ViewController.h"
#import "FriendsViewController.h"
#import "Tools.h"
//#import "NotesCollectionViewCell.h"
#import "NotesTableViewCell.h"

#import "DetailViewController.h"
//#import "JTCalendarContentView.h"

static NSString *NoteCollectionCellIdentifier = @"noteCollectionCell";
static NSString *NoteDeatilCellIdentifier = @"noteDetailcell";
@interface ViewController ()

@property(nonatomic ,strong)NSMutableArray *dataArray;

@property (nonatomic,assign)NSInteger cellCount;
@end

@implementation ViewController


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    [self setupMode];
    [self setupDateNow];
   // [self setupCollectionView];
    self.TableView.delegate = self;
    self.TableView.dataSource = self;
    
    
    NSArray *array = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
    _dataArray = [NSMutableArray arrayWithArray:array];
    //_cellCount = 20;

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
    [self.calendar reloadData]; // Must be call in viewDidAppear
}


#pragma mark - 初始,加载
//初始化日历控件
-(void)setupMode
{
     self.calendar = [JTCalendar new];
    if(self.calendar.calendarAppearance.isWeekMode)
    {
        self.calendarContentViewHeight.constant = 50;
    }
    self.calendar.calendarAppearance.calendar.firstWeekday = 2; // Sunday == 1, Saturday == 7
    self.calendar.calendarAppearance.dayCircleRatio = 9. / 10.;
    self.calendar.calendarAppearance.ratioContentMenu = 1.;
    
    [self.calendar setMenuMonthsView:self.calendarMenuView];
    [self.calendar setContentView:self.calendarContentView];
    [self.calendar setDataSource:self];

}

//获得当前时间和星期几
-(void)setupDateNow
{
    self.currentMonthDayWeekday.text = [Tools getCurrentDate];
}


//初始化collectionView
//-(void)setupCollectionView
//{
//    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NoteCollectionCellIdentifier];
//    [self.collectionView registerNib:[UINib nibWithNibName:@"NotesCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:NoteDeatilCellIdentifier];
//    ;
//    self.collectionView.backgroundColor = [UIColor lightGrayColor];
//    self.collectionView.allowsMultipleSelection = YES;
//}


#pragma mark - Buttons callback

- (IBAction)didGoTodayTouch
{
    [self.calendar setCurrentDate:[NSDate date]];
    
    
    FriendsViewController *friendsVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"friendsVC"];
    
    [self.navigationController pushViewController:friendsVC animated:YES];
}

- (IBAction)didChangeModeTouch
{
    self.calendar.calendarAppearance.isWeekMode = !self.calendar.calendarAppearance.isWeekMode;
    
    [self transitionExample];
}

#pragma mark - JTCalendarDataSource

- (BOOL)calendarHaveEvent:(JTCalendar *)calendar date:(NSDate *)date
{
    return (rand() % 4) == 0;
}

- (void)calendarDidDateSelected:(JTCalendar *)calendar date:(NSDate *)date
{
    [Tools getClickedDate:date];
}

#pragma mark - Transition examples

- (void)transitionExample
{
    CGFloat newHeight = 200;
    if(self.calendar.calendarAppearance.isWeekMode){
        newHeight = 50;
    }
    
    [UIView animateWithDuration:.5
                     animations:^{
                         self.calendarContentViewHeight.constant = newHeight;
                         [self.view layoutIfNeeded];
                     }];
    
    [UIView animateWithDuration:.25
                     animations:^{
                         self.calendarContentView.layer.opacity = 0;
                     }
                     completion:^(BOOL finished) {
                         [self.calendar reloadAppearance];
                         
                         [UIView animateWithDuration:.25
                                          animations:^{
                                              self.calendarContentView.layer.opacity = 1;
                                          }];
                     }];
}




#pragma mark -tableView 的代理和数据源
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //左滑删除功能的添加
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        //获取选中删除行索引值
        //NSInteger row = indexPath.row;
        [tableView beginUpdates];
        
        
        NSInteger row = [indexPath section];
        LQCLog(@"row==== =%ld",(long)row);
        //        通过获取的索引值删除数组中的值
        [_dataArray removeObjectAtIndex:row];
        
        //        删除单元格的某一行时，在用动画效果实现删除过程
       // [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView deleteSections:[NSIndexSet indexSetWithIndex:row] withRowAnimation:UITableViewRowAnimationFade];
        
        [tableView endUpdates];
        
    }
}

//单元格返回的编辑风格，包括删除 添加 和 默认  和不可编辑三种风格
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //跳转
//    MBProgressHUD *hud = [[MBProgressHUD alloc]init];
//    [Tools showHUD:@"跳转中" andView:tableView andHUD:hud];
    [Tools checkNetWorking];
    DetailViewController *detailVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"DetailNoticeVC"];
    [self.navigationController pushViewController:detailVC animated:YES];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotesTableViewCell *notesCell ;
    if(notesCell == nil)
    {
        NSArray *array = [[NSBundle mainBundle]loadNibNamed:@"NotesTableViewCell" owner:nil options:nil];
        notesCell = [array objectAtIndex:0];
    }
    
    notesCell.informTime.text = @"18:25";
    notesCell.informDetailContent.text = @"嘿,老板,煎饼果子来一套!";
    notesCell.inviteAddress.text = [_dataArray objectAtIndex:indexPath.section];//@"小铁门";
    notesCell.invitePersonPic.image = [UIImage imageNamed:@"MUN"];
    [Tools ChoosenImageViewChangeModelToCircle:notesCell.invitePersonPic];
    
    
    notesCell.backgroundColor = [UIColor whiteColor];
    notesCell.selectionStyle = UITableViewCellSelectionStyleNone;
    

    return notesCell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  120;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataArray.count;
}

//设置section的title

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//
//{
//    CGRect frameRect = CGRectMake(0, 0, 100, 40);
//    UILabel *label = [[UILabel alloc] initWithFrame:frameRect];
//    if(section == 0)
//        label.text=@"myTitle";
//    else if(section == 1)
//        label.text=@"LQC";
//    
//    return label;
//} 




-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}




/*
#pragma mark -CollectionView 的datasource 和 delegate的设置
//section
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _dataArray.count;
}
//item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

//每个section中不同的行之间的行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //重用cell
    NotesCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NoteDeatilCellIdentifier forIndexPath:indexPath];
    //添加手势识别
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handlelongPress:)];
    [cell addGestureRecognizer:longPressGestureRecognizer];
    longPressGestureRecognizer.minimumPressDuration = 1.0;
    longPressGestureRecognizer.delegate = self;
    longPressGestureRecognizer.view.tag = indexPath.section;

    
    //赋值
    
    cell.informTime.text = @"18:25";
    cell.informDetailContent.text = @"嘿,老板,煎饼果子来一套!";
    cell.inviteAddress.text = [_dataArray objectAtIndex:indexPath.section];//@"小铁门";
    cell.invitePersonPic.image = [UIImage imageNamed:@"MUN"];
    [Tools ChoosenImageViewChangeModelToCircle:cell.invitePersonPic];
    
    
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
    
}


//定义每个UICollectionViewCell 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(270, 120);
}
//定义每个Section 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(15, 15, 5, 15);//分别为上、左、下、右
}

//返回头footerView的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    CGSize size={320,30};
    return size;
}


//选择了某个cell
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor greenColor]];
    
////*******************////
//    [_dataArray removeObjectAtIndex:indexPath.row];
//    [collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
//    //[self numberOfSectionsInCollectionView:collectionView];
//    
////*****************////
/*
    DetailViewController *DetailNoticeVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"DetailNoticeVC"];
    
    [self.navigationController pushViewController:DetailNoticeVC animated:YES];
}
//取消选择了某个cell
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor redColor]];
}



#pragma mark -  手势识别(删除便签)
-(void)handlelongPress:(UILongPressGestureRecognizer *)recognizer
{
    if(recognizer.state == UIGestureRecognizerStateBegan)
    {
        NSLog(@"开始触发长按操作%ld",(long)recognizer.view.tag);
        
        UIAlertView *alertView  = [[UIAlertView alloc]initWithTitle:@"删除便签" message:@"确定要删除该便签?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        [alertView show];
        
        [self.collectionView performBatchUpdates:^{
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:recognizer.view.tag inSection:0];
            //NSArray *deleteItem = @[indexPath];
            [_dataArray removeObjectAtIndex:recognizer.view.tag];
            NSLog(@"...%@",indexPath);
            //[self.collectionView reloadItemsAtIndexPaths:_dataArray];
            //[self.collectionView deleteItemsAtIndexPaths:deleteItem];
            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:0]];
            
        } completion:^(BOOL finished)
         {
             [UIView setAnimationsEnabled:YES];
         }];
        
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        NSLog(@"结束触发长按操作");
    }
    [self.collectionView reloadData];
    //[self.collectionView reloadInputViews];
    //[self collectionView:self.collectionView numberOfItemsInSection:_dataArray.count];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        NSLog(@"111122");
    }
}
*/

@end

