//
//  UIViewController+MyViewControllerAdditions.m
//  Pods
//
//  Created by Vincil Bishop on 9/24/14.
//
//

#import "UIViewController+MyViewControllerAdditions.h"
#import "ObjcAssociatedObjectHelpers.h"
#import "MyiOSViewCategories.h"

@implementation UIViewController (MyViewControllerAdditions)

SYNTHESIZE_ASC_OBJ(MY_validators, setMY_validators);
SYNTHESIZE_ASC_PRIMITIVE(isValid, setIsValid, BOOL);
SYNTHESIZE_ASC_OBJ(MY_keyboardControls, setMY_keyboardControls);
SYNTHESIZE_ASC_PRIMITIVE(MY_validChangeBlock, setMY_validChangeBlock, MYValidationChangedBlock);
SYNTHESIZE_ASC_PRIMITIVE(MY_invalidChangeBlock, setMY_invalidChangeBlock, MYValidationChangedBlock);
SYNTHESIZE_ASC_PRIMITIVE(MY_waitingForRemoteChangeBlock, setMY_waitingForRemoteChangeBlock, MYValidationChangedBlock);

#pragma mark - Setup Methods -

- (void) MY_viewControllerSetup {
    
    self.MY_keyboardControls = [[APLKeyboardControls alloc] initWithInputFields:self.textViewsAndFields];
    self.MY_keyboardControls.hasPreviousNext = YES;
    self.MY_validators = [NSMutableArray new];
    
    if ([self.view isKindOfClass:[TPKeyboardAvoidingScrollView class]]) {
        
        //TPKeyboardAvoidingScrollView *scrollView = (TPKeyboardAvoidingScrollView*)self.view;
        
        //scrollView.contentSize = self.view.frame.size;
    }
}

#pragma mark - Validation Helpers -

- (void) addValidator:(ALPValidator*)validator forControl:(UIControl*)control
{
    __block UIViewController *blockSelf = self;
    
    __block ALPValidator *blockValidator = validator;
    
    validator.validatorStateChangedHandler = ^(ALPValidatorState newState) {
        switch (newState) {
                
            case ALPValidatorValidationStateValid:
                
                if (blockSelf.MY_validChangeBlock) {
                    // do happy things
                    blockSelf.MY_validChangeBlock(self,YES,blockValidator);
                }
                
                break;
                
            case ALPValidatorValidationStateInvalid:
                
                if (blockSelf.MY_invalidChangeBlock) {
                    // do unhappy things
                    blockSelf.MY_invalidChangeBlock(self,NO,blockValidator);
                }
                
                break;
                
            case ALPValidatorValidationStateWaitingForRemote:
                
                if (blockSelf.MY_waitingForRemoteChangeBlock) {
                    // do loading indicator things
                    blockSelf.MY_waitingForRemoteChangeBlock(self,NO,blockValidator);
                }
                
                break;
        }
    };
    
    if([control respondsToSelector:@selector(attachValidator:)])
    {
        [control alp_attachValidator:validator];
    }
    
    if ([control respondsToSelector:@selector(text)]) {
        NSString *string = [control performSelector:@selector(text) withObject:nil];
        [validator validate:string];
    }
    
    NSMutableArray *validators = [self.MY_validators mutableCopy];
    [validators addObject:validator];
    
    self.MY_validators = validators;
}


- (NSArray*) invalidValidators
{
    NSMutableArray *invalidValidators = [NSMutableArray new];
    
    [self.MY_validators enumerateObjectsUsingBlock:^(ALPValidator *validator, NSUInteger idx, BOOL *stop) {
        
        if (!validator.isValid) {
            [invalidValidators addObject:validator];
        }
    }];
    
    return (NSArray*)invalidValidators;
}


- (BOOL) formIsValid
{
    return self.invalidValidators.count > 0;
}


- (void) validateWithCompletion:(MYFormValidationBlock)completionBlock
{
    NSArray *invalidValidators = self.invalidValidators;
    
    if (completionBlock) {
        completionBlock(self,invalidValidators.count == 0,invalidValidators);
    }
}

- (void) validateAndNotifyWithCompletion:(MYFormValidationBlock)completionBlock
{
    [self validateWithCompletion:^(id sender, BOOL success, NSArray *invalidValidators) {
        
        ALPValidator *validator = invalidValidators[0];
        
        NSString *errorMessage = _.array(validator.errorMessages).reduce(@"",^(NSString *x, NSString *y) {
            if (x.length > 0) {
                return [NSString stringWithFormat:@"%@\n%@",x,y];
            } else {
                return y;
            }
            
        });
        
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Error" description:errorMessage type:TWMessageBarMessageTypeError duration:2.0];
        
        if (completionBlock) {
            completionBlock(self,invalidValidators.count == 0,invalidValidators);
        }

        
    }];
}



#pragma mark - Overrides -

- (NSArray*) textViewsAndFields
{
    NSMutableArray *textViewsAndFields = [[NSMutableArray alloc] init];
    
    @synchronized (self) {
        
        
        for (UIView *view in self.view.allSubviews) {
            
            if ([view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]]) {
                
                [textViewsAndFields addObject:view];
            }
        }
    }
    
    return textViewsAndFields;
    
}

- (NSArray*) textFields
{
    NSMutableArray *textFields = [[NSMutableArray alloc] init];
    
    @synchronized (self) {
        
        textFields = [[NSMutableArray alloc] init];
        
        for (UIView *view in self.view.allSubviews) {
            
            if ([view isKindOfClass:[UITextField class]]) {
                
                [textFields addObject:view];
            }
        }
    }
    
    return textFields;
}

- (NSArray*) textViews
{
    NSMutableArray *textViews = [[NSMutableArray alloc] init];
    
    @synchronized (self) {
        
        textViews = [[NSMutableArray alloc] init];
        
        for (UIView *view in self.view.allSubviews) {
            
            if ([view isKindOfClass:[UITextView class]]) {
                
                [textViews addObject:view];
            }
        }
    }
    
    
    return textViews;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSInteger textFieldIndex = [self.textViewsAndFields indexOfObject:textField];
    
    if (textFieldIndex < self.textViewsAndFields.count - 1) {
        [(UITextField *)self.textViewsAndFields[textFieldIndex + 1] becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

@end
