//
//  EditInfoViewController.h
//  MyHealth
//
//  Created by Steven Nguyen on 2/21/17.
//  Copyright © 2017 Steven Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditInfoViewControllerDelegate

-(void)editingInfoWasFinished;

@end

@interface EditInfoViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) id<EditInfoViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITextField *txtFoodname;

@property (weak, nonatomic) IBOutlet UITextField *txtPriority;

@property (nonatomic) int recordIDToEdit;

- (IBAction)saveInfo:(id)sender;

@end
