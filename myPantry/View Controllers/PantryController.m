//
//  PantryController.m
//  MyHealth
//
//  Created by Steven Nguyen on 2/21/17.
//  Copyright © 2017 Steven Nguyen. All rights reserved.
//

#import "DBManager.h"
#import "PantryController.h"

@interface PantryController ()

@property (nonatomic, strong) DBManager *dbManager;

@property (nonatomic, strong) NSArray *arrPeopleInfo;

@property (nonatomic) int recordIDToEdit;

-(void)loadData;

@end

@implementation PantryController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Make self the delegate and datasource of the table view.
    self.tblPeople.delegate = self;
    self.tblPeople.dataSource = self;
    
    // Initialize the dbManager property.
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"pantry.sql"];
    
    self.recordIDToEdit = -1;
    
    // Load the data.
    [self loadData];
}

- (IBAction)addNewRecord:(id)sender {
    // Before performing the segue, set the -1 value to the recordIDToEdit. That way we'll indicate that we want to add a new record and not to edit an existing one.
    self.recordIDToEdit = -1;
    [self performSegueWithIdentifier:@"idSeguePantryInfo" sender:self];
}

- (IBAction)switchToScanner:(id)sender {
    [self performSegueWithIdentifier:@"cameraScanner" sender:self];
}

-(void)loadData{
    // Form the query.
    NSString *query = @"select * from pantryInfo order by remaining asc;";
    
    // Get the results.
    if (self.arrPeopleInfo != nil) {
        self.arrPeopleInfo = nil;
    }
    self.arrPeopleInfo = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    // Reload the table view.
    [self.tblPeople reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrPeopleInfo.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    // Dequeue the cell.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idCellRecord" forIndexPath:indexPath];
    
    NSInteger indexOfFoodName = [self.dbManager.arrColumnNames indexOfObject:@"itemname"];
    NSInteger indexOfPriority = [self.dbManager.arrColumnNames indexOfObject:@"expiration"];
    NSInteger indexOfRemaining = [self.dbManager.arrColumnNames indexOfObject:@"remaining"];
    
    // Set the loaded data to the appropriate cell labels.
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [[self.arrPeopleInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfFoodName]];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Expiration: %@, Remaining: %@%%", [[self.arrPeopleInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfPriority], [[self.arrPeopleInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfRemaining]];
    
    return cell;
}

-(void)editingInfoWasFinished{
    // Reload the data.
    [self loadData];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    EditInfoViewController *editInfoViewController = [segue destinationViewController];
    editInfoViewController.delegate = self;
    editInfoViewController.recordIDToEdit = self.recordIDToEdit;
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    // Get the record ID of the selected name and set it to the recordIDToEdit property.
    self.recordIDToEdit = [[[self.arrPeopleInfo objectAtIndex:indexPath.row] objectAtIndex:0] intValue];
    
    // Perform the segue.
    [self performSegueWithIdentifier:@"idSeguePantryInfo" sender:self];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the selected record.
        // Find the record ID.
        int recordIDToDelete = [[[self.arrPeopleInfo objectAtIndex:indexPath.row] objectAtIndex:0] intValue];
        
        // Prepare the query.
        NSString *query = [NSString stringWithFormat:@"delete from pantryInfo where pantryID=%d", recordIDToDelete];
        
        // Execute the query.
        [self.dbManager executeQuery:query];
        
        // Reload the table view.
        [self loadData];
    }
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
