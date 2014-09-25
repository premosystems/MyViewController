//
//  UIViewController+MyViewControllerAdditions.m
//  Pods
//
//  Created by Vincil Bishop on 9/24/14.
//
//

#import "UIViewController+MyViewControllerAdditions.h"
#import "JRSwizzle.h"
#import "ObjcAssociatedObjectHelpers.h"
#import "MyiOSViewCategories.h"
#import "MYViewControllerType.h"

@implementation UIViewController (MyViewControllerAdditions)

SYNTHESIZE_ASC_OBJ(validators, setValidators);
SYNTHESIZE_ASC_PRIMITIVE(isValid, setIsValid, BOOL);
SYNTHESIZE_ASC_OBJ(errorString, setErrorString);
SYNTHESIZE_ASC_OBJ(errorMessages, setErrorMessages);
SYNTHESIZE_ASC_OBJ(keyboardControls, setKeyboardControls);

+ (void)load {
    
    NSError *error = nil;
    [UIViewController jr_swizzleMethod:@selector(viewDidLoad) withMethod:@selector(MY_viewDidLoad) error:&error];
    
    if (error) {
        NSLog(@"error:%@",[error localizedDescription]);
    }
    
    //NSAssert(!error,[error localizedDescription]);
}

#pragma mark - Method Swizzling

- (void)MY_viewDidLoad {
    [self MY_viewDidLoad];
    
    if ([self conformsToProtocol:@protocol(MYViewControllerType)]) {
        self.keyboardControls = [[APLKeyboardControls alloc] initWithInputFields:self.textViewsAndFields];
        self.keyboardControls.hasPreviousNext = YES;
        self.validators = [NSMutableArray new];
        
        if ([self.view isKindOfClass:[TPKeyboardAvoidingScrollView class]]) {
            
            //TPKeyboardAvoidingScrollView *scrollView = (TPKeyboardAvoidingScrollView*)self.view;
            
            //scrollView.contentSize = self.view.frame.size;
        }
    }
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
