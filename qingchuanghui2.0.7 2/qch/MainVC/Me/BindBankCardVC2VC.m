//
//  BindBankCardVC2VC.m
//  qch
//
//  Created by W.兵 on 16/7/8.
//  Copyright © 2016年 qch. All rights reserved.
//

#import "BindBankCardVC2VC.h"

@interface BindBankCardVC2VC ()


@end

@implementation BindBankCardVC2VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.nameLabel.text = _name;
    self.bankLabel.text = _bank;
    self.bankNOLabel.text = _bankNO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
