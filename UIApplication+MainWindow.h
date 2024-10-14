//
//  UIApplication+MainWindow.h
//  AFNetworking
//
//  Created by macairlzq on 2024/10/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (MainWindow)
-(UIWindow*)mainWindow;
@end
static bool ISDevice_Full_IPAD(){
    return (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad && UIApplication.sharedApplication.mainWindow.bounds.size.width == UIScreen.mainScreen.bounds.size.width);
}
static UIEdgeInsets mainScreenSafeAreaInsets(){
    return [UIApplication sharedApplication].mainWindow.safeAreaInsets;
}
NS_ASSUME_NONNULL_END
