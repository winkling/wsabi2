//
//  WSCaptureController.h
//  wsabi2
//
//  Created by Matt Aronoff on 1/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSCDItem.h"
#import "WSCDDeviceDefinition.h"
#import "WSModalityMap.h"
#import "WSCaptureButton.h"
#import "WSAnnotationController.h"
#import "NBCLDeviceLinkManager.h"
#import "constants.h"
#import "UIView+FlipTransition.h"

@protocol WSCaptureDelegate <NSObject>

//-(void) didRequestModalityChangeForItem:(WSCDItem*)item;
//-(void) didRequestDeviceChangeForItem:(WSCDItem*)item;

@end

@interface WSCaptureController : UIViewController <UITextViewDelegate>
{
    NBCLDeviceLink *currentLink;
    NSMutableArray *currentAnnotationArray;
    BOOL frontVisible;
}

-(IBAction)annotateButtonPressed:(id)sender;
-(IBAction)doneButtonPressed:(id)sender;
-(IBAction)modalityButtonPressed:(id)sender;
-(IBAction)deviceButtonPressed:(id)sender;
-(IBAction)captureButtonPressed:(id)sender;

//Notification handlers
-(void) handleDownloadPosted:(NSNotification*)notification;

@property (nonatomic, strong) WSCDItem *item;

@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, strong) IBOutlet UIView *frontContainer;
@property (nonatomic, strong) IBOutlet UIView *backContainer;
@property (nonatomic, strong) IBOutlet UINavigationItem *backNavBarTitleItem;

@property (nonatomic, strong) IBOutlet UITableView *annotationTableView;
@property (nonatomic, strong) IBOutlet UITableView *annotationNotesTableView;
@property (nonatomic, strong) IBOutlet UIButton *annotateButton;

@property (nonatomic, strong) IBOutlet UIButton *modalityButton;
@property (nonatomic, strong) IBOutlet UIButton *deviceButton;
@property (nonatomic, strong) IBOutlet UIImageView *itemDataView;
@property (nonatomic, strong) IBOutlet WSCaptureButton *captureButton;

@property (nonatomic, unsafe_unretained) id<WSCaptureDelegate> delegate;

@end
