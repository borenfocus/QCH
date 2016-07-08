//
//  RCDiscussGroupSettingViewController.m
//  RongIMToolkit
//
//  Created by Liv on 15/3/30.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDDiscussGroupSettingViewController.h"
#import "RCDUpdateNameViewController.h"
#import "RCDDiscussSettingCell.h"
#import "RCDDiscussSettingSwitchCell.h"
#import "MyChatViewController.h"
#import "AddressBookViewController.h"


@interface RCDDiscussGroupSettingViewController ()<UIActionSheetDelegate>

@property (nonatomic, copy) NSString* discussTitle;
@property (nonatomic, copy) NSString* creatorId;
@property (nonatomic, strong) NSMutableDictionary* members;

@property (nonatomic)BOOL isOwner;
@property (nonatomic,assign) BOOL isClick;
@end

@implementation RCDDiscussGroupSettingViewController

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    //显示顶部视图
    self.headerHidden = NO;
    _members = [[NSMutableDictionary alloc]init];
    
    //添加当前聊天用户
    if (self.conversationType == ConversationType_PRIVATE) {
        /**
        [RCDHTTPTOOL getUserInfoByUserID:self.targetId
                              completion:^(RCUserInfo* user) {
                                          [self addUsers:@[user]];
                                          [_members setObject:user forKey:user.userId];

                              }];**/
    }

    //添加讨论组成员
    if (self.conversationType == ConversationType_DISCUSSION) {

        __weak RCDSettingBaseViewController* weakSelf = self;
       /** [[RCIMClient sharedRCIMClient] getDiscussion:self.targetId success:^(RCDiscussion* discussion) {
            if (discussion) {
                _creatorId = discussion.creatorId;
                if([[RCIMClient sharedRCIMClient].currentUserInfo.userId isEqualToString:discussion.creatorId])
                {
                    [weakSelf disableDeleteMemberEvent:NO];
                    self.isOwner = YES;
                    
                }else{
                    [weakSelf disableDeleteMemberEvent:YES];
                    self.isOwner = NO;
                    if (discussion.inviteStatus == 1) {
                        [self disableInviteMemberEvent:YES];
                    }
                }
                
                NSMutableArray *users = [NSMutableArray new];
                for (NSString *targetId in discussion.memberIdList) {
                    
                        [RCDHTTPTOOL getUserInfoByUserID:targetId
                                                              completion:^(RCUserInfo *user) {
                                                                  if ([discussion.creatorId isEqualToString: user.userId]) {
                                                                      [users insertObject:user atIndex:0];
                                                                  }else{
                                                                  
                                                                       [users addObject:user];
                                                                  }
                                                                  [_members setObject:user forKey:user.userId];
                                                                  [weakSelf addUsers:users];
                                                              }];
                    
                }
                
            }
        } error:^(RCErrorCode status){

        }];**/
    }
    
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40*PMBWIDTH)];
    
    UIImage *image =[UIImage imageNamed:@"group_quit"];
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(20*SCREEN_WSCALE, 5*PMBWIDTH, SCREEN_WIDTH-40*SCREEN_WSCALE, 30*PMBWIDTH)];
    
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setTitle:@"删除并退出" forState:UIControlStateNormal];
    [button setCenter:CGPointMake(view.width/2, view.height/2)];
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    self.tableView.tableFooterView = view;

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _isClick = YES;
}

-(void)buttonAction:(UIButton*)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"删除并且退出讨论组" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil];
    [actionSheet showInView:self.view];
    
}
#pragma mark-UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([actionSheet isEqual:self.clearMsgHistoryActionSheet]) {
        [self clearHistoryMessage];
    }else{
        if (0 == buttonIndex) {
            __weak typeof(&*self)  weakSelf = self;
            [[RCIMClient sharedRCIMClient] quitDiscussion:self.targetId success:^(RCDiscussion *discussion) {
            NSLog(@"退出讨论组成功");
            UIViewController *temp = nil;
            NSArray *viewControllers = weakSelf.navigationController.viewControllers;
            temp = viewControllers[viewControllers.count -1 -2];
            if (temp) {
                //切换主线程
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController popToViewController:temp animated:YES];
                });
                }
            } error:^(RCErrorCode status) {
                    NSLog(@"quit discussion status is %ld",(long)status);
                    
            }];
            
        }
    }
}


- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isOwner) {
        return self.defaultCells.count + 2;
    } else {
        return self.defaultCells.count + 1;
    }
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 44.f;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = nil;
    int offset = 2;
    if (!self.isOwner) {
        offset = 1;
    }
    switch (indexPath.row) {
        case 0:
        {
            RCDDiscussSettingCell *discussCell = [[RCDDiscussSettingCell alloc] initWithFrame:CGRectZero];
            discussCell.lblDiscussName.text = self.conversationTitle;
            discussCell.lblTitle.text = @"讨论组名称";
            cell = discussCell;
            _discussTitle = discussCell.lblDiscussName.text;
        }
            break;
        case 1:
        {
            if (self.isOwner) {
                RCDDiscussSettingSwitchCell *switchCell = [[RCDDiscussSettingSwitchCell alloc] initWithFrame:CGRectZero];
                switchCell.label.text = @"开放成员邀请";
                [[RCIMClient sharedRCIMClient] getDiscussion:self.targetId success:^(RCDiscussion *discussion) {
                    if (discussion.inviteStatus == 0) {
                        switchCell.swich.on = YES;
                    }
                } error:^(RCErrorCode status){
                    
                }];
                [switchCell.swich addTarget:self action:@selector(openMemberInv:) forControlEvents:UIControlEventTouchUpInside];
                cell = switchCell;
            } else {
                cell = self.defaultCells[0];
            }


    } break;
    case 2: {
        cell = self.defaultCells[indexPath.row - offset];
    } break;
    case 3: {
        cell = self.defaultCells[indexPath.row - offset];

    } break;
    case 4: {
        cell = self.defaultCells[indexPath.row - offset];

    } break;
    }

    return cell;
}

#pragma mark - RCConversationSettingTableViewHeader Delegate
//点击最后一个+号事件
- (void)settingTableViewHeader:(RCConversationSettingTableViewHeader*)settingTableViewHeader indexPathOfSelectedItem:(NSIndexPath*)indexPathOfSelectedItem
            allTheSeletedUsers:(NSArray*)users
{
    //点击最后一个+号,调出选择联系人UI
    if (indexPathOfSelectedItem.row == settingTableViewHeader.users.count) {
        
        AddressBookViewController *address=[[AddressBookViewController alloc]init];
        [self.navigationController pushViewController:address animated:YES];
/**
        UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        RCDSelectPersonViewController* selectPersonVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"RCDSelectPersonViewController"];
        [selectPersonVC setSeletedUsers:users];
        //设置回调
        selectPersonVC.clickDoneCompletion = ^(RCDSelectPersonViewController* selectPersonViewController, NSArray* selectedUsers) {
            
            if (selectedUsers && selectedUsers.count) {
                NSMutableArray *newUsers = [[NSMutableArray alloc]init];
                for (int i=0;i<selectedUsers.count; i++) {
                    RCUserInfo *user = (RCUserInfo *)selectedUsers[i];
                    if (![_members.allKeys containsObject:user.userId]) {
                        [_members setObject:user forKey:user.userId];
                        [newUsers addObject:user];
                    }
                }
                //创建者第一个显示
                RCUserInfo *creator = _members[_creatorId];
                if(creator){
                    [_members removeObjectForKey:_creatorId];
                    NSMutableArray *users = [[NSMutableArray alloc]initWithArray: _members.allValues];
                    [users insertObject:creator atIndex:0];
                    [self addUsers:users];
                    [_members setObject:creator forKey:creator.userId];
                }else{
                    NSMutableArray *users = [[NSMutableArray alloc]initWithArray: _members.allValues];
                    [self addUsers:users];
                }
                
                [self createDiscussionOrInvokeMemberWithSelectedUsers:selectedUsers];

            }
            
            [selectPersonViewController.navigationController popViewControllerAnimated:YES];
        };
        [self.navigationController pushViewController:selectPersonVC animated:YES];**/
    }
}

#pragma mark - private method
- (void)createDiscussionOrInvokeMemberWithSelectedUsers:(NSArray*)selectedUsers
{
    //    __weak RCDSettingViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (ConversationType_DISCUSSION == self.conversationType) {
            //invoke new member to current discussion
            
            NSMutableArray *addIdList = [NSMutableArray new];
            for (RCUserInfo *user in selectedUsers) {
                [addIdList addObject:user.userId];
            }
            
            //加入讨论组
            if(addIdList.count != 0){
                
                [[RCIMClient sharedRCIMClient] addMemberToDiscussion:self.targetId userIdList:addIdList success:^(RCDiscussion *discussion) {
                    NSLog(@"成功");
                } error:^(RCErrorCode status) {
                }];
            }
            
        }else if (ConversationType_PRIVATE == self.conversationType){
            //create new discussion with the new invoked member.
            NSUInteger _count = [_members.allKeys count];
            if (_count > 1) {
                
                NSMutableString *discussionTitle = [NSMutableString string];
                NSMutableArray *userIdList = [NSMutableArray new];
                for (int i=0; i<_count; i++) {
                    RCUserInfo *_userInfo = (RCUserInfo *)_members.allValues[i];
                    [discussionTitle appendString:[NSString stringWithFormat:@"%@%@", _userInfo.name,@","]];

                    [userIdList addObject:_userInfo.userId];
                }
                [discussionTitle deleteCharactersInRange:NSMakeRange(discussionTitle.length - 1, 1)];
                self.conversationTitle = discussionTitle;
                
                __weak typeof(&*self)  weakSelf = self;
                [[RCIMClient sharedRCIMClient] createDiscussion:discussionTitle userIdList:userIdList success:^(RCDiscussion *discussion) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        MyChatViewController *chat =[[MyChatViewController alloc]init];
                        chat.targetId = discussion.discussionId;
                        chat.title = discussion.discussionName;
                        chat.conversationType= ConversationType_DISCUSSION;
                        chat.title= discussionTitle;
                        //[NSString stringWithFormat:@"讨论组(%lu)", (unsigned long)_count];
                        
                        UITabBarController *tabbarVC = weakSelf.navigationController.viewControllers[0];
                        [weakSelf.navigationController popToViewController:tabbarVC animated:NO];
                        [tabbarVC.navigationController  pushViewController:chat animated:YES];
                    });
                } error:^(RCErrorCode status) {
                    //            DebugLog(@"create discussion Failed > %ld!", (long)status);
                }];
            }
            
        }
    });
}

- (void)openMemberInv:(UISwitch*)swch{
    //设置成员邀请权限


    [[RCIMClient sharedRCIMClient] setDiscussionInviteStatus:self.targetId isOpen:swch.on success:^{
//        DebugLog(@"设置成功");
    } error:^(RCErrorCode status) {
        
    }];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    if (self.setDiscussTitleCompletion) {
        self.setDiscussTitleCompletion(_discussTitle);
    }
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath{
    if (indexPath.row == 0) {
        RCDDiscussSettingCell* discussCell = (RCDDiscussSettingCell*)[tableView cellForRowAtIndexPath:indexPath];
        
        discussCell.lblTitle.text = @"讨论组名称";

        RCDUpdateNameViewController *updateNameViewController=[[RCDUpdateNameViewController alloc]init];
        updateNameViewController.targetId = self.targetId;
        updateNameViewController.displayText = discussCell.lblDiscussName.text;
        updateNameViewController.setDisplayTextCompletion = ^(NSString* text) {
            discussCell.lblDiscussName.text = text;
            _discussTitle = text;

        };
        
        [self.navigationController pushViewController:updateNameViewController animated:YES];
//        UINavigationController* navi = [[UINavigationController alloc] initWithRootViewController:updateNameViewController];
//        [self.navigationController presentViewController:navi animated:YES completion:nil];
    }
}

/**
 *  override
 *
 *  @param 添加顶部视图显示的user,必须继承以调用父类添加user
 */
- (void)addUsers:(NSArray*)users
{
    [super addUsers:users];
}

/**
 *  override 左上角删除按钮回调
 *
 *  @param indexPath indexPath description
 */
- (void)deleteTipButtonClicked:(NSIndexPath*)indexPath
{
    RCUserInfo* user = self.users[indexPath.row];
    if ([user.userId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
        return;
    }
    [[RCIMClient sharedRCIMClient] removeMemberFromDiscussion:self.targetId
                                                   userId:user.userId
    success:^(RCDiscussion *discussion) {
        NSLog(@"踢人成功");
        [self.users removeObject:user];
    } error:^(RCErrorCode status) {
        NSLog(@"踢人失败");
    }];
}



- (void)didTipHeaderClicked:(NSString*)userId{
    if(_isClick){
        _isClick = NO;
    }
}


@end