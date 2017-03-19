//
//  RecipeController.m
//  MyHealth
//
//  Created by Steven Nguyen on 3/14/17.
//  Copyright © 2017 Steven Nguyen. All rights reserved.
//

#import "DBManager.h"
#import "RecipeController.h"

@interface RecipeController ()

@property (nonatomic, strong) DBManager *dbManager;

@property (nonatomic, strong) NSArray *arrPeopleInfo;

@property (weak, nonatomic) IBOutlet UIImageView *cell;

@property (weak, nonatomic) IBOutlet UIButton *recipeButton;

@property (weak, nonatomic) IBOutlet UITextView *recipeName;

@property (weak, nonatomic) IBOutlet UITextView *ingredients;

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation RecipeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Initialize the dbManager property.
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"pantry.sql"];
    
    self.recipeButton.layer.cornerRadius = 6;
    self.recipeName.layer.cornerRadius = 6;
    self.ingredients.layer.cornerRadius = 6;
    self.cell.layer.cornerRadius = 6;
    self.cell.layer.borderWidth = 0.5;
    self.cell.clipsToBounds = true;
}

- (NSDictionary*)generateJSON {
    //Selects random item from pantry
    NSUInteger highestBound = [self.arrPeopleInfo count];
    NSString* randomItem;
    NSString *base = @"http://www.recipepuppy.com/api/?i=";
    NSUInteger baseLength = 34;
    
    for (int i = 0; i < highestBound; i++) {
        if ((arc4random() % (2)) == 1) continue;
        if ([base length] != baseLength) base = [base stringByAppendingString:@","];
        randomItem = [[self.arrPeopleInfo objectAtIndex:i] objectAtIndex:1];
        NSString* refined = [randomItem stringByReplacingOccurrencesOfString:@" " withString:@","];
        base = [base stringByAppendingString:refined];
    }
    
    if ([randomItem length] == 0) {
        int test = (arc4random() % ([self.arrPeopleInfo count]));
        randomItem = [[self.arrPeopleInfo objectAtIndex:test] objectAtIndex:1];
        NSString* refined = [randomItem stringByReplacingOccurrencesOfString:@" " withString:@","];
        base = [base stringByAppendingString:refined];
    }
    
    NSURL * url=[NSURL URLWithString:base];
    NSData * data=[NSData dataWithContentsOfURL:url];
    NSError * error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    return json;
}

- (IBAction)generateRecipe:(id)sender {
    [self loadData];
    if ([self.arrPeopleInfo count] <= 0) return;
    
    NSDictionary *json = [self generateJSON];
    //If results are empty, randomly search for a new recipe
    int i = 0;
    while ([[json valueForKeyPath:@"results"] count] <= 0) {
        if (i++ > 30) return;
        json = [self generateJSON];
    }
    
    //Grab one of the JSON results randomly
    NSInteger randomJSON = 0 + arc4random() % ([[json valueForKeyPath:@"results"] count] - 0);
    NSString *title = [[json valueForKeyPath:@"results.title"] objectAtIndex:randomJSON];
    NSString *url = [[json valueForKeyPath:@"results.href"] objectAtIndex:randomJSON];
    NSURL *URL = [NSURL URLWithString:url];
    NSString *ingredients = [[json valueForKeyPath:@"results.ingredients"] objectAtIndex:randomJSON];
    NSString *img = [[json valueForKeyPath:@"results.thumbnail"] objectAtIndex:randomJSON];
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: img]];
        if ( data == nil )
            return;
        dispatch_async(dispatch_get_main_queue(), ^{
            _cell.image = [UIImage imageWithData: data];
            _recipeName.text = title;
            _ingredients.text = ingredients;
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:URL];
            [_webView loadRequest:urlRequest];
        });
    });
}

-(void)loadData{
    // Form the query.
    NSString *query = @"select * from pantryInfo;";
    
    // Get the results.
    if (self.arrPeopleInfo != nil) {
        self.arrPeopleInfo = nil;
    }
    self.arrPeopleInfo = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
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
