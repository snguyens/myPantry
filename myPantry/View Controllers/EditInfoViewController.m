//
//  EditInfoViewController.m
//  MyHealth
//
//  Created by Steven Nguyen on 2/21/17.
//  Copyright © 2017 Steven Nguyen. All rights reserved.
//

#import "DBManager.h"
#import "EditInfoViewController.h"

@interface EditInfoViewController ()

@property (nonatomic, strong) DBManager *dbManager;

-(void)loadInfoToEdit;

@end

@implementation EditInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set the navigation bar tint color.
    self.navigationController.navigationBar.tintColor = self.navigationItem.rightBarButtonItem.tintColor;
    
    // Make self the delegate of the textfields.
    self.txtFoodname.delegate = self;
    self.txtPriority.delegate = self;
    
    // Initialize the dbManager object.
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"shopdb.sql"];
    
    // Check if should load specific record for editing.
    if (self.recordIDToEdit != -1) {
        // Load the record with the specific ID from the database.
        [self loadInfoToEdit];
        NSLog(@"YES");
    }
}

- (void)alertMessage:(NSString*)title msg:(NSString*) message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (IBAction)saveInfo:(id)sender {
    NSString *query;
    
    NSString* foodName = self.txtFoodname.text;
    NSString* priority = self.txtPriority.text;
    if ([foodName length] == 0) {
        [self alertMessage:@"Oops!" msg:@"The name of the item cannot be empty!"];
        return;
    }

    if (self.recordIDToEdit == -1) {
        query = [NSString stringWithFormat:@"insert into shopInfo values(null, '%@', '%d')", foodName, [priority intValue]];
    }
    else{
        query = [NSString stringWithFormat:@"update shopInfo set foodname='%@', priority=%d where shopInfoID=%d", foodName, priority.intValue, self.recordIDToEdit];
    }
    [self.dbManager executeQuery:query];
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
        [self.delegate editingInfoWasFinished];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        NSLog(@"Could not execute the query.");
    }
}

-(void)loadInfoToEdit{
    // Create the query.
    NSString *query = [NSString stringWithFormat:@"select * from shopInfo where shopInfoID=%d", self.recordIDToEdit];
    
    // Load the relevant data.
    NSArray *results = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    // Set the loaded data to the textfields.
    self.txtFoodname.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"foodname"]];
    self.txtPriority.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"priority"]];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
