//
//  ScanController.h
//  MyHealth
//
//  Created by Steven Nguyen on 2/22/17.
//  Copyright © 2017 Steven Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScanControllerDelegate

-(void)editingInfoWasFinished;

@end

@interface ScanController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) id<ScanControllerDelegate> delegate;

@end
