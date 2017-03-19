//
//  EditPantryViewController.h
//  MyHealth
//
//  Created by Steven Nguyen on 2/21/17.
//  Copyright © 2017 Steven Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditPantryViewControllerDelegate

-(void)editingInfoWasFinished;

@end

@interface EditPantryViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) id<EditPantryViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITextField *txtItemName;

@property (weak, nonatomic) IBOutlet UITextField *txtExpiration;

@property (weak, nonatomic) IBOutlet UITextField *txtRemaining;

@property (nonatomic) int recordIDToEdit;

- (IBAction)saveInfo:(id)sender;

@end
