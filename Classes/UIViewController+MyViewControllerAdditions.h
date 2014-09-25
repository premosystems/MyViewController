//
//  UIViewController+MyViewControllerAdditions.h
//  Pods
//
//  Created by Vincil Bishop on 9/24/14.
//
//

#import <UIKit/UIKit.h>

#import "ALPValidator.h"
#import "MyiOSLogicBlocks.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "APLKeyboardControls.h"

@interface UIViewController (MyViewControllerAdditions)

@property (strong, nonatomic) NSMutableArray *validators;
@property (nonatomic) BOOL isValid;
@property (nonatomic,strong) NSMutableString *errorString;
@property (nonatomic,strong) NSMutableArray *errorMessages;
@property (nonatomic,strong) APLKeyboardControls *keyboardControls;

@end
