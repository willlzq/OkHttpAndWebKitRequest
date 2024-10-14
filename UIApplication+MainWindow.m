//
//  UIApplication+MainWindow.m
//  AFNetworking
//
//  Created by macairlzq on 2024/10/14.
//

#import "UIApplication+MainWindow.h"

@implementation UIApplication (MainWindow)
-(UIWindow*)mainWindow{
    UIWindow*keyWin;
    if (@available(iOS 13.0, *)) {
        for(UIScene * scene in self.connectedScenes.allObjects){
            if(scene.activationState==UISceneActivationStateForegroundActive && [scene isKindOfClass:UIWindowScene.class]){
                keyWin =((UIWindowScene*)scene).windows.firstObject;
                break;
            }
        }
    }
    return keyWin?keyWin:self.windows.firstObject;
}
@end
