//
//  ScanController.m
//  BarcodeScanner
//
//  Created by Vijay Subrahmanian on 09/05/15.
//  Copyright (c) 2015 Vijay Subrahmanian. All rights reserved.
//

#import "dbmanager.h"
#import "EditInfoViewController.h"
#import "ScanController.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

@interface ScanController () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) DBManager *dbManager;
@property (weak, nonatomic) IBOutlet UITextView *scannedBarcode;
@property (weak, nonatomic) IBOutlet UIView *cameraPreviewView;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureLayer;
@property (nonatomic) int recordIDToEdit;
@property (nonatomic) NSString* currentName;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *rescanButton;

@end

//NSString *currentName = nil;

@implementation ScanController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupScanningSession];
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"shopdb.sql"];
    
    self.scannedBarcode.layer.cornerRadius = 15;
    self.scannedBarcode.layer.borderWidth = 0.5;
    self.scannedBarcode.clipsToBounds = true;
    
    self.cameraPreviewView.layer.cornerRadius = 15;
    self.cameraPreviewView.layer.borderWidth = 0.5;
    self.cameraPreviewView.clipsToBounds = true;
    
    self.addButton.layer.cornerRadius = 6;
    self.addButton.layer.borderWidth = 0.5;
    self.addButton.clipsToBounds = true;

    self.rescanButton.layer.cornerRadius = 6;
    self.rescanButton.layer.borderWidth = 0.5;
    self.rescanButton.clipsToBounds = true;
    
    self.recordIDToEdit = -1;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Start the camera capture session as soon as the view appears completely.
    [self.captureSession startRunning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)alertMessage:(NSString*)title msg:(NSString*) message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (IBAction)rescanButtonPressed:(id)sender {
    // Start scanning again.
    self.currentName = nil;
    self.scannedBarcode.text = nil;
    [self.captureSession startRunning];
}

- (IBAction)addButtonPressed:(id)sender {
    if (self.currentName != nil) {
        NSString *query = [NSString stringWithFormat:@"insert into shopInfo values(null, '%@', '%d')", self.currentName, 0];
        [self saveInfo:query];
        [self alertMessage:@"Success!" msg:@"This product has been added to your shopping list."];
        [self rescanButtonPressed:self];
    } else {
        
        [self alertMessage:@"Whoops!" msg:@"You have not scanned a product!"];
    }
}

- (void) saveInfo:(NSString*)query{
    [self.dbManager executeQuery:query];
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
        [self.delegate editingInfoWasFinished];
        //[self.navigationController popViewControllerAnimated:YES];
    }
    else{
        NSLog(@"Could not execute the query.");
    }
}

// Local method to setup camera scanning session.
- (void)setupScanningSession {
    // Initalising hte Capture session before doing any video capture/scanning.
    self.captureSession = [[AVCaptureSession alloc] init];
    
    NSError *error;
    // Set camera capture device to default and the media type to video.
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // Set video capture input: If there a problem initialising the camera, it will give am error.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input) {
        NSLog(@"Error Getting Camera Input");
        return;
    }
    // Adding input souce for capture session. i.e., Camera
    [self.captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    // Set output to capture session. Initalising an output object we will use later.
    [self.captureSession addOutput:captureMetadataOutput];
    
    // Create a new queue and set delegate for metadata objects scanned.
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("scanQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    // Delegate should implement captureOutput:didOutputMetadataObjects:fromConnection: to get callbacks on detected metadata.
    [captureMetadataOutput setMetadataObjectTypes:[captureMetadataOutput availableMetadataObjectTypes]];
    
    // Layer that will display what the camera is capturing.
    self.captureLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    [self.captureLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.captureLayer setFrame:self.cameraPreviewView.layer.bounds];
    // Adding the camera AVCaptureVideoPreviewLayer to our view's layer.
    [self.cameraPreviewView.layer addSublayer:self.captureLayer];
}

// AVCaptureMetadataOutputObjectsDelegate method
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    // Do your action on barcode capture here:
    NSString *capturedBarcode = nil;
    
    // Specify the barcodes you want to read here:
    NSArray *supportedBarcodeTypes = @[AVMetadataObjectTypeUPCECode,
                                       AVMetadataObjectTypeCode39Code,
                                       AVMetadataObjectTypeCode39Mod43Code,
                                       AVMetadataObjectTypeEAN13Code,
                                       AVMetadataObjectTypeEAN8Code,
                                       AVMetadataObjectTypeCode93Code,
                                       AVMetadataObjectTypeCode128Code,
                                       AVMetadataObjectTypePDF417Code,
                                       AVMetadataObjectTypeQRCode,
                                       AVMetadataObjectTypeAztecCode];
    
    // In all scanned values..
    for (AVMetadataObject *barcodeMetadata in metadataObjects) {
        // ..check if it is a suported barcode
        for (NSString *supportedBarcode in supportedBarcodeTypes) {
            
            if ([supportedBarcode isEqualToString:barcodeMetadata.type]) {
                // This is a supported barcode
                // Note barcodeMetadata is of type AVMetadataObject
                // AND barcodeObject is of type AVMetadataMachineReadableCodeObject
                AVMetadataMachineReadableCodeObject *barcodeObject = (AVMetadataMachineReadableCodeObject *)[self.captureLayer transformedMetadataObjectForMetadataObject:barcodeMetadata];
                capturedBarcode = [barcodeObject stringValue];
                // Got the barcode. Set the text in the UI and break out of the loop.
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.captureSession stopRunning];
                    NSString *base = @"http://www.searchupc.com/handlers/upcsearch.ashx?request_type=3";
                    NSString *token = @"BC7CE405-BBD7-4E42-A0C5-737B809B4D9B";
                    NSString *upc = capturedBarcode;
                    
                    base = [base stringByAppendingString:@"&access_token="];
                    base = [base stringByAppendingString:token];
                    base = [base stringByAppendingString:@"&upc="];
                    base = [base stringByAppendingString:upc];
                    
                    NSURL * url=[NSURL URLWithString:base];
                    NSData * data=[NSData dataWithContentsOfURL:url];
                    NSError * error;
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                    NSString *output = [[json objectForKey:@"0"] valueForKey:@"productname"];
                    NSString *trimmed = [output
                                                     stringByReplacingOccurrencesOfString:@"\'" withString:@""];
                    self.currentName = trimmed;
                    
                    self.scannedBarcode.text = output;
                    NSLog(@"%@", base);
                });
                return;
            }
        }
    }
}

@end
