// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#import "BWSModalityChooserController.h"
#import "BWSDDLog.h"

@implementation BWSModalityChooserController
@synthesize item;
@synthesize currentButton;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Capture type";
    [self.view setAccessibilityLabel:@"Device Walkthrough -- Modality View"];

    if (self.item.managedObjectContext && self.item.modality) {
        self.currentButton = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"Keep \"%@\"",self.item.modality]
                                                              style:UIBarButtonItemStyleDone
                                                             target:self action:@selector(currentButtonPressed:)];
        self.navigationItem.rightBarButtonItem = self.currentButton;
    }

    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.view logViewPresented];
    [[self tableView] startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
    [[self tableView] startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeScroll];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.view logViewDismissed];
    [[self tableView] stopLoggingBWSInterfaceEvents];
    
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Button action methods
-(IBAction) currentButtonPressed:(id)sender
{
    //Push a new controller to choose the submodality.
    BWSSubmodalityChooserController *subChooser = [[BWSSubmodalityChooserController alloc] initWithNibName:@"BWSSubmodalityChooserController" bundle:nil];
    subChooser.modality = [BWSModalityMap modalityForString:self.item.modality];

    subChooser.item = self.item; //pass the data object
    
    [self.navigationController pushViewController:subChooser animated:YES];

}

- (void)cancelButtonPressed:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return kModality_COUNT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text = [BWSModalityMap stringForModality:indexPath.row];
    cell.accessibilityLabel = cell.textLabel.text;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [cell startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle ==  UITableViewCellEditingStyleDelete)
        [[tableView cellForRowAtIndexPath:indexPath] stopLoggingBWSInterfaceEvents];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    //Push a new controller to choose the submodality.
    BWSSubmodalityChooserController *subChooser = [[BWSSubmodalityChooserController alloc] initWithNibName:@"BWSSubmodalityChooserController" bundle:nil];
    subChooser.modality = indexPath.row;
    
    DDLogBWSVerbose(@"Walkthrough setting modality to %@",[BWSModalityMap stringForModality:subChooser.modality]);
//    //set the item's modality string to match the chosen object
//    self.item.modality = [WSModalityMap stringForModality:indexPath.row];
    
    subChooser.item = self.item; //pass the data object
    
    [self.navigationController pushViewController:subChooser animated:YES];
}

@end
