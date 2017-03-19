//
//  DBManager.h
//  MyHealth
//
//  Created by Steven Nguyen on 2/21/17.
//  Copyright © 2017 Steven Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBManager : NSObject

-(instancetype)initWithDatabaseFilename:(NSString *)dbFilename;

-(NSArray *)loadDataFromDB:(NSString *)query;

-(void)executeQuery:(NSString *)query;

@property (nonatomic, strong) NSMutableArray *arrColumnNames;

@property (nonatomic) int affectedRows;

@property (nonatomic) long long lastInsertedRowID;

@end
