//
//  ProductsOverviewController.m
//  30daylist_iphone
//
//  Created by Marc-Oliver Teschke on 22.11.10.
//  Copyright 2010 n/a. All rights reserved.
//

#import "ProductsOverviewController.h"
#import "SingleProductViewController.h"
#import "TDBadgedCell.h"
#import "WebViewController.h"
#import "MapViewController.h"

@implementation ProductsOverviewController

@synthesize managedObjectContext;
@synthesize locationManager;
@synthesize currentLocation;
@synthesize currentProduct;
@synthesize timeToFireNotification;

- (NSFetchedResultsController *)fetchedResultsController {
	if(fetchedResultsController != nil)
		return fetchedResultsController;
	
	NSFetchRequest *fetchRequest = [NSFetchRequest new];
	NSEntityDescription *productDescription = [NSEntityDescription entityForName:@"product" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:productDescription];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"found_date" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Overview"];
	fetchedResultsController.delegate = self;
	[fetchRequest release];
	[sortDescriptor release];
	[sortDescriptors release];
	return fetchedResultsController;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSManagedObject *product = [fetchedResultsController objectAtIndexPath:indexPath];
	self.currentProduct = product;
	UIActionSheet *actionsMenu = [[UIActionSheet alloc]
							 initWithTitle: NSLocalizedString(@"Show me that thing…", @"title of the action sheet appearing when an item is tapped")
							 delegate:self
							 cancelButtonTitle:nil
							 destructiveButtonTitle:nil
							 otherButtonTitles: nil];
	
	if ([[product valueForKey:@"found_url"] length] > 0) {
		[actionsMenu addButtonWithTitle:NSLocalizedString(@"in the browser", @"option to show the item in the browser")];
	}

	if ([[[product valueForKey:@"found_latitude"] stringValue] length] > 0 && [[[product valueForKey:@"found_longitude"] stringValue]length] > 0) {
		[actionsMenu addButtonWithTitle:NSLocalizedString(@"on a map", @"option to show the item on the maps view")];
	}
	
	[actionsMenu addButtonWithTitle:NSLocalizedString(@"Uh, never mind", @"dismiss the action sheet and do nothing")];
	[actionsMenu setCancelButtonIndex:[actionsMenu numberOfButtons] - 1];
    [actionsMenu showInView:self.view];	
	
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIdx
{
	// url => 0 == browser, 1 == cancel
	// latlong => 0 == map, 1 == cancel
	// url + latlong => 0 == browser, 1 == latlong, 2 == cancel
	
	if ([actionSheet buttonTitleAtIndex:buttonIdx] == NSLocalizedString(@"in the browser", nil)) {
		[self showInBrowser:self.currentProduct];
	} else if ([actionSheet buttonTitleAtIndex:buttonIdx] == NSLocalizedString(@"on a map", nil)) {
		[self showOnMap:self.currentProduct];
	} else {
		[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
	}
    [actionSheet release];
}


- (void)showOnMap:(NSManagedObject *)product {
	MapViewController *mapViewController = [[MapViewController alloc] initWithNibName:@"MapView" bundle:nil];
	mapViewController.product = product;
	mapViewController.currentLocation = currentLocation;
	[self.navigationController pushViewController:mapViewController animated:YES];
	[mapViewController release];
}


- (void)showInBrowser:(NSManagedObject *)product {
	WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebView" bundle:nil];
	webViewController.product = product;
	[self.navigationController pushViewController:webViewController animated:YES];
	[webViewController release];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	self.currentLocation = newLocation;
}


- (IBAction)showAddProductForm {
	NSEntityDescription *productDescription = [[fetchedResultsController fetchRequest] entity];
	
	SingleProductViewController *singleProductViewController = [[SingleProductViewController alloc] initWithNibName:@"SingleProductViewController" bundle:nil];
	singleProductViewController.managedObjectContext = managedObjectContext;
	singleProductViewController.entityDescription = productDescription;
	singleProductViewController.currentLocation = self.currentLocation;
	[self.navigationController pushViewController:singleProductViewController animated:YES];
	
	[singleProductViewController release];
}


- (void)viewDidLoad {
	[super viewDidLoad];

	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showAddProductForm)];
	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.16f green:0.36f blue:0.46f alpha:0.8f];
	self.navigationItem.rightBarButtonItem = addButton;
	
	[addButton release];

//	[self setTimeToFireNotification:[[NSNumber alloc] initWithInt:2592000]];
	[self setTimeToFireNotification:[[NSNumber alloc] initWithInt:60]];
	[self startStandardUpdates];
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	NSError *error;
	if (![self.fetchedResultsController performFetch:&error]) {
		NSLog(@"Fehler beim Laden (1)");
		return;
	}
	
	NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/table_bg.png"];
	UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
	UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
	[self.tableView setBackgroundView:imageView];
	
	[self.tableView reloadData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// cancel all local notifications
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
	
	NSError *error;
	if (![self.fetchedResultsController performFetch:&error]) {
		NSLog(@"Fehler beim Laden (2)");
		return 0;
	}
	
	// create new local notifications for remaining items
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"product" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	NSSortDescriptor *sortByDateDesc = [[NSSortDescriptor alloc] initWithKey:@"found_date" ascending:YES];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortByDateDesc, nil]];
	NSArray *items = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
	int i = 1;
	for (NSManagedObject *item in items) {
		NSDate *storedDate = [item valueForKey:@"found_date"];
		NSDate *inTheFuture = [storedDate dateByAddingTimeInterval:[[self timeToFireNotification] intValue]];
		if ([inTheFuture isEqualToDate:[inTheFuture laterDate:[NSDate new]]]) {
			UILocalNotification *notification = [[UILocalNotification alloc] init];
			[notification setFireDate:inTheFuture];
			[notification setAlertBody:[NSString stringWithFormat:NSLocalizedString(@"It's time to review %@", @"notification message when an item is due"), [item valueForKey:@"name"]]];
			[notification setAlertAction:NSLocalizedString(@"Review", @"action of the local notification when an item is due")];
			[notification setSoundName:UILocalNotificationDefaultSoundName];
			[notification setApplicationIconBadgeNumber:i];
			[[UIApplication sharedApplication] scheduleLocalNotification:notification];
			[notification release];
			i++;
		} else if ([inTheFuture isEqualToDate:[inTheFuture earlierDate:[NSDate new]]]) {
			[[UIApplication sharedApplication] setApplicationIconBadgeNumber:i];
			i++;
		}
	}
	
	tableView.allowsSelectionDuringEditing = YES;
	return 1;
}


-(NSInteger)numberOfItemsStored {
	NSError *error;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"product" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	NSArray *items = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
	return [items count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *sections = [fetchedResultsController sections];
	NSUInteger count = 0;
	if ([sections count]) {
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
		count = [sectionInfo numberOfObjects];
	}
	return count;
}


-(void)populateWithDemoData {
	UIAlertView *firstLaunchAlert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Hey there!", @"first launch message title") message: NSLocalizedString(@"I don't think we've met before. I've created some sample data for you to see what 30daylist does.", @"first launch message body") delegate: self cancelButtonTitle: NSLocalizedString(@"Let's rock!", @"first launch message action") otherButtonTitles: nil];
	[firstLaunchAlert show];
	[firstLaunchAlert release];
	
	NSNumberFormatter *priceFormatter = [NSNumberFormatter alloc];
	[priceFormatter init];
	[priceFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"EN-US"]];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"product" inManagedObjectContext:managedObjectContext];

	NSNumber *price = [priceFormatter numberFromString:@"0.99"];
	NSDate *due = [[[NSDate alloc] init] dateByAddingTimeInterval:(86400 * 30 * -1)];
	id product = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:managedObjectContext];
	[product setValue:NSLocalizedString(@"item ready for review", nil) forKey:@"name"];
	[product setValue:price forKey:@"price"];
	[product setValue:@"30daylist" forKey:@"found_where"];
	[product setValue:@"http://www.30daylistapp.com" forKey:@"found_url"];
	[product setValue:[[NSNumber alloc] initWithFloat:52.516269] forKey:@"found_latitude"];
	[product setValue:[[NSNumber alloc] initWithFloat:13.377779] forKey:@"found_longitude"];
	[product setValue:due forKey:@"found_date"];
	NSError *error;
	if (![managedObjectContext save:&error]) {
		NSLog(@"Fehler beim Speichern des Produkts");
	}

	due = [[[NSDate alloc] init] dateByAddingTimeInterval:(86400 * 30 * -1) + (300)];
	product = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:managedObjectContext];
	[product setValue:NSLocalizedString(@"item due in 5 minutes", nil) forKey:@"name"];
	[product setValue:price forKey:@"price"];
	[product setValue:@"30daylist" forKey:@"found_where"];
	[product setValue:@"http://www.30daylistapp.com" forKey:@"found_url"];
	[product setValue:[[NSNumber alloc] initWithFloat:52.516269] forKey:@"found_latitude"];
	[product setValue:[[NSNumber alloc] initWithFloat:13.377779] forKey:@"found_longitude"];
	[product setValue:due forKey:@"found_date"];
	if (![managedObjectContext save:&error]) {
		NSLog(@"Fehler beim Speichern des Produkts");
	}

	due = [[NSDate alloc] init];
	product = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:managedObjectContext];
	[product setValue:NSLocalizedString(@"item due in 30 days", nil) forKey:@"name"];
	[product setValue:price forKey:@"price"];
	[product setValue:@"30daylist" forKey:@"found_where"];
	[product setValue:@"http://www.30daylistapp.com" forKey:@"found_url"];
	[product setValue:[[NSNumber alloc] initWithFloat:52.516269] forKey:@"found_latitude"];
	[product setValue:[[NSNumber alloc] initWithFloat:13.377779] forKey:@"found_longitude"];
	[product setValue:due forKey:@"found_date"];
	if (![managedObjectContext save:&error]) {
		NSLog(@"Fehler beim Speichern des Produkts");
	}
}


-(void)reloadProductsTable {
	[self.tableView reloadData];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	
	TDBadgedCell *cell = (TDBadgedCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
	}
	
	NSManagedObject *product = [fetchedResultsController objectAtIndexPath:indexPath];
	
	cell.textLabel.text = [product valueForKey:@"name"];
	cell.textLabel.backgroundColor = [UIColor clearColor];
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	NSTimeInterval timeInterval = [[product valueForKey:@"found_date"] timeIntervalSinceNow];
	NSInteger daysUntil = 30 + ceil(timeInterval / 86400);
	
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
//	[formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"EN-US"]];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];

	cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ @ %@", nil), [formatter stringFromNumber:[product valueForKey:@"price"]], [product valueForKey:@"found_where"]];
	cell.detailTextLabel.backgroundColor = [UIColor clearColor];
	
	if (daysUntil > 0) {
		[cell setBadgeColor:[UIColor colorWithRed:0.16f green:0.36f blue:0.46f alpha:0.8f]]; // green
		[cell setBadgeColorHighlighted:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.8f]];
		[cell setBadgeString:[NSString stringWithFormat:@"%d", daysUntil]];
	} else if (daysUntil == 0) {
		[cell setBadgeColor:[UIColor colorWithRed:0.5f green:0.23f blue:0.26f alpha:0.8f]]; // red
		[cell setBadgeColorHighlighted:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.8f]];
		[cell setBadgeString:NSLocalizedString(@"REVIEW", @"due item badge")];
	} else {
		[cell setBadgeColor:[UIColor colorWithRed:0.5f green:0.23f blue:0.26f alpha:0.8f]]; // red
		[cell setBadgeColorHighlighted:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.8f]];
		[cell setBadgeString:[NSString stringWithFormat:@"%d", daysUntil * -1]];
	}
	
	if ([[product valueForKey:@"found_url"] length] > 0 || ([[[product valueForKey:@"found_latitude"] stringValue] length] > 0 && [[[product valueForKey:@"found_longitude"] stringValue]length] > 0)) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/cell_bg.png"];
	UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
	UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
	[cell setBackgroundView:imageView];

	[dateFormatter release];
	return cell;
}


- (void)startStandardUpdates {
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
	
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 75.0f;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSManagedObject *objectToBeDeleted = [fetchedResultsController objectAtIndexPath:indexPath];
		[managedObjectContext deleteObject:objectToBeDeleted];
		
		NSError *error;
		if (![managedObjectContext save:&error]) {
			NSLog(@"Fehler beim Löschen");
			return;
		}

		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
		[tableView reloadData];
	}
}


- (void)dealloc {
/*
	[locationManager release];
	[currentProduct release];
	[currentLocation release];
	[timeToFireNotification release];
 */
	[fetchedResultsController release];
	[managedObjectContext release];
    [super dealloc];
}


@end
