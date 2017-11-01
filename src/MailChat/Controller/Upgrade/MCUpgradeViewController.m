//
//  MCUpgradeViewController.m
//  NPushMail
//
//  Created by admin on 8/4/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCUpgradeViewController.h"
#import "MCDatabaseManager.h"
#import "MCAppDelegate.h"
#import "UIAlertView+Blocks.h"
#import "MCServerAPI+OA.h"
#import "MCOABindingMailConfig.h"
#import "MCOAConfig.h"
#import "MCWorkSpaceManager.h"
#import "MCAccountConfig.h"
#import "MCLoginDetailViewController.h"
#import "MCAppSetting.h"
#import "MCTool.h"


@interface MCUpgradeViewController ()<UIAlertViewDelegate>

@property (nonatomic,weak) IBOutlet UIImageView *backgrouImageView;

@end

@implementation MCUpgradeViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.backgrouImageView.image = [[MCTool shared] getBackgroundImage];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self upgradeDatabase];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)upgradeDatabase
{
    MCDatabaseManager *dbMGr = [MCDatabaseManager new];
    [SVProgressHUD showWithStatus:PMLocalizedStringWithKey(@"PM_Upgrade_hint")];
    if (dbMGr.shouldUpgrade) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL success = [dbMGr upradeDatabase];
             DDLogVerbose(@"Upgrade complete");
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                if (!success) {
                    [self alertUpgradeError];
                }
                else {
                    if (self.completeBlock) {
                        self.completeBlock();
                    }
                }
            });
        });
    }
}

- (void)alertUpgradeError
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:PMLocalizedStringWithKey(@"PM_Upgrade_ErrorTitle") message:PMLocalizedStringWithKey(@"PM_Upgrade_Error_Message") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *retryAction = [UIAlertAction actionWithTitle:PMLocalizedStringWithKey(@"PM_Upgrade_Retry") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self upgradeDatabase];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:PMLocalizedStringWithKey(@"PM_Upgrade_Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (self.completeBlock) {
            self.completeBlock();
        }
    }];
    
    [alert addAction:retryAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}

@end
