//
//  PantryController.h
//  MyHealth
//
//  Created by Steven Nguyen on 2/21/17.
//  Copyright © 2017 Steven Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditInfoViewController.h"
#import "ScanController.h"

@interface PantryController : UIViewController <UITableViewDelegate, UITableViewDataSource, EditInfoViewControllerDelegate, ScanControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblPeople;

- (IBAction)addNewRecord:(id)sender;

- (IBAction)switchToScanner:(id)sender;

@end
