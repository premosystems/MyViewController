//
//  UIViewController+MyViewControllerAdditions.h
//  Pods
//
//  Created by Vincil Bishop on 9/24/14.
//
//

#import <UIKit/UIKit.h>

#import "ALPValidator.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "APLKeyboardControls.h"
#import "TWMessageBarManager.h"

typedef void (^MYValidationChangedBlock)(id sender, BOOL isValid, ALPValidator *validator);
typedef void (^MYFormValidationBlock)(id sender, BOOL isValid, NSArray *validators);

@interface UIViewController (MyViewControllerAdditions)

@property (strong, nonatomic) NSMutableArray *validators;
@property (nonatomic) BOOL isValid;
@property (nonatomic,strong) APLKeyboardControls *keyboardControls;
@property (nonatomic,copy) MYValidationChangedBlock validChangeBlock;
@property (nonatomic,copy) MYValidationChangedBlock invalidChangeBlock;
@property (nonatomic,copy) MYValidationChangedBlock waitingForRemoteChangeBlock;

- (NSArray*) invalidValidators;
- (BOOL) formIsValid;
- (void) addValidator:(ALPValidator*)validator forControl:(UIControl*)control;
- (void) validateWithCompletion:(MYFormValidationBlock)completionBlock;
- (void) validateAndNotifyWithCompletion:(MYFormValidationBlock)completionBlock;

@end
