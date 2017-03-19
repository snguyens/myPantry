//
//  EditPantryViewController.m
//  MyHealth
//
//  Created by Steven Nguyen on 2/21/17.
//  Copyright © 2017 Steven Nguyen. All rights reserved.
//

#import "DBManager.h"
#import "EditPantryViewController.h"

@interface EditPantryViewController ()

@property (nonatomic, strong) DBManager *dbManager;

-(void)loadInfoToEdit;

@end

@implementation EditPantryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set the navigation bar tint color.
    self.navigationController.navigationBar.tintColor = self.navigationItem.rightBarButtonItem.tintColor;
    
    // Make self the delegate of the textfields.
    self.txtItemName.delegate = self;
    self.txtExpiration.delegate = self;
    self.txtRemaining.delegate = self;
    
    // Initialize the dbManager object.
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"pantry.sql"];
    
    // Check if should load specific record for editing.
    if (self.recordIDToEdit != -1) {
        // Load the record with the specific ID from the database.
        [self loadInfoToEdit];
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
    NSString* itemName = self.txtItemName.text;
    NSString* expiration = self.txtExpiration.text;
    NSString* remaining = self.txtRemaining.text;
    if ([itemName length] == 0) {
        [self alertMessage:@"Oops!" msg:@"The name of the item cannot be empty!"];
        return;
    }
    if ([expiration length] == 0) {
        expiration = @"N/A";
    }
    if (self.recordIDToEdit == -1) {
        query = [NSString stringWithFormat:@"insert into pantryInfo values(null, '%@', '%@', '%d')", itemName, expiration, [remaining intValue]];
    }
    else{
        query = [NSString stringWithFormat:@"update pantryInfo set itemname='%@', expiration='%@', remaining=%d where pantryID=%d", itemName, expiration, [remaining intValue], self.recordIDToEdit];
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
    NSString *query = [NSString stringWithFormat:@"select * from pantryInfo where pantryID=%d", self.recordIDToEdit];
    
    // Load the relevant data.
    NSArray *results = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    // Set the loaded data to the textfields.
    self.txtItemName.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"itemname"]];
    self.txtExpiration.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"expiration"]];
    self.txtRemaining.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"remaining"]];
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
