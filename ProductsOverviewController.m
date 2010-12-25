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

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}


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
/*	NSManagedObject *product = [fetchedResultsController objectAtIndexPath:indexPath];
	
	SingleProductViewController *singleProductViewController = [[SingleProductViewController alloc] initWithNibName:@"SingleProductViewController" bundle:nil];
	singleProductViewController.product = product;
	[self.navigationController pushViewController:singleProductViewController animated:YES];
	
	[singleProductViewController release];*/
	
/*
 NSManagedObject *product = [fetchedResultsController objectAtIndexPath:indexPath];
	UIWebView *webView = [[UIWebView alloc] init];
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.marcmachttheater.de/"]]];
	[tableView addSubview:webView];*/
	
	NSManagedObject *product = [fetchedResultsController objectAtIndexPath:indexPath];
	if ([[product valueForKey:@"found_url"] length] > 0) {
		[self showInBrowser:product];
	}
//	[self showOnMap:product];
	
}


- (void)showOnMap:(NSManagedObject *)product {
	MapViewController *mapViewController = [[MapViewController alloc] initWithNibName:@"MapView" bundle:nil];
	mapViewController.product = product;
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
	NSManagedObject *newProduct = [NSEntityDescription insertNewObjectForEntityForName:[productDescription name] inManagedObjectContext:managedObjectContext];
	
	SingleProductViewController *singleProductViewController = [[SingleProductViewController alloc] initWithNibName:@"SingleProductViewController" bundle:nil];
	singleProductViewController.product = newProduct;
	singleProductViewController.currentLocation = self.currentLocation;
	[self.navigationController pushViewController:singleProductViewController animated:YES];
	
	[singleProductViewController release];
}


- (void)viewDidLoad {
	[super viewDidLoad];

//	self.navigationItem.leftBarButtonItem = self.editButtonItem;
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showAddProductForm)];
	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.16f green:0.36f blue:0.46f alpha:0.8f];
	self.navigationItem.rightBarButtonItem = addButton;

	[addButton release];

	[self startStandardUpdates];
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	NSError *error;
	if (![self.fetchedResultsController performFetch:&error]) {
		NSLog(@"Fehler beim Laden");
		return;
	}
	
	[self.tableView setBackgroundColor:[UIColor colorWithRed:0.99 green:0.99 blue:0.99 alpha:1]];
	
	[self.tableView reloadData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	tableView.allowsSelectionDuringEditing = YES;
	return 1;
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
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];

	cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ | %@", nil), [formatter stringFromNumber:[product valueForKey:@"price"]], [product valueForKey:@"found_where"]];
	cell.detailTextLabel.backgroundColor = [UIColor clearColor];
	
	[cell setBadgeString:[NSString stringWithFormat:@"%d", daysUntil]];
	if (daysUntil > 0) {
		[cell setBadgeColor:[UIColor colorWithRed:0.16f green:0.36f blue:0.46f alpha:0.8f]]; // green
		[cell setBadgeColorHighlighted:[UIColor colorWithRed:0.16f green:0.36f blue:0.46f alpha:0.8f]];
	} else {
		[cell setBadgeColor:[UIColor colorWithRed:0.5f green:0.23f blue:0.26f alpha:0.8f]]; // red
		[cell setBadgeColorHighlighted:[UIColor colorWithRed:0.5f green:0.23f blue:0.26f alpha:0.8f]];
	}
	
	if ([[product valueForKey:@"found_url"] length] > 0) {
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
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
	
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
    // Set a movement threshold for new events.
    locationManager.distanceFilter = kCLDistanceFilterNone;
	
    [locationManager startUpdatingLocation];
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
		// cancel all local notifications
		[[UIApplication sharedApplication] cancelAllLocalNotifications];
		
		if (![fetchedResultsController performFetch:&error]) {
			NSLog(@"Fehler beim Laden");
			return;
		}
		
		// create new local notifications for remaining items
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"product" inManagedObjectContext:managedObjectContext];
		[fetchRequest setEntity:entity];
		NSArray *items = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
		for (NSManagedObject *item in items) {
			NSDate *storedDate = [item valueForKey:@"found_date"];
			NSDate *inTheFuture = [storedDate dateByAddingTimeInterval:2592000];
//			NSDate *inTheFuture = [storedDate dateByAddingTimeInterval:60];
			UILocalNotification *notification = [[UILocalNotification alloc] init];
			[notification setFireDate:inTheFuture];
			[notification setAlertBody:[NSString stringWithFormat:@"It's time to review %@", [item valueForKey:@"name"]]];
			[notification setAlertAction:@"Review"];
			[notification setSoundName:UILocalNotificationDefaultSoundName];
			[[UIApplication sharedApplication] scheduleLocalNotification:notification];
			[notification release];
		}  		
		
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
		[tableView reloadData];
	}
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
	[fetchedResultsController release];
	[managedObjectContext release];
    [super dealloc];
}


@end
