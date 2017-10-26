//
//  MBProgressHUD+MJ.m
//
//  Created by mj on 13-4-18.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MBProgressHUD+MJ.h"

@implementation MBProgressHUD (MJ)

+ (MBProgressHUD *)showMessage:(NSString *)message{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kWindow animated:YES];
    hud.label.text = message;
    hud.removeFromSuperViewOnHide = YES;
    return hud;
}

+ (void)hideHUD{
    [self hideHUDForView:kWindow animated:YES];
}

+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view{
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]]];
    hud.label.text = text;
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // .2秒之后再消失
    [hud hideAnimated:YES afterDelay:1.5];
}

+ (void)showSuccess:(NSString *)success{
    [self show:success icon:@"success.png" view:kWindow];
}

+ (void)showError:(NSString *)error{
    [self show:error icon:@"error.png" view:kWindow];
}

+(void)showToast:(NSString *)msg{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kWindow animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabel.font = [UIFont boldSystemFontOfSize:15.0];
    hud.detailsLabel.text = msg;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:1.5];
}

@end
