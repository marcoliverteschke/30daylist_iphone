//
//  ProductsOverviewController.m
//  30daylist_iphone
//
//  Created by Marc-Oliver Teschke on 22.11.10.
//  Copyright 2010 n/a. All rights reserved.
//

#import "ProductsOverviewController.h"
#import "SingleProductViewController.h"


@implementation ProductsOverviewController

@synthesize managedObjectContext;


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
	NSManagedObject *product = [fetchedResultsController objectAtIndexPath:indexPath];
	
	SingleProductViewController *singleProductViewController = [[SingleProductViewController alloc] initWithNibName:@"SingleProductViewController" bundle:nil];
	singleProductViewController.product = product;
	[self.navigationController pushViewController:singleProductViewController animated:YES];
	
	[singleProductViewController release];
}


- (IBAction)showAddProductForm {
	NSEntityDescription *productDescription = [[fetchedResultsController fetchRequest] entity];
	NSManagedObject *newProduct = [NSEntityDescription insertNewObjectForEntityForName:[productDescription name] inManagedObjectContext:managedObjectContext];
	
	SingleProductViewController *singleProductViewController = [[SingleProductViewController alloc] initWithNibName:@"SingleProductViewController" bundle:nil];
	singleProductViewController.product = newProduct;
	[self.navigationController pushViewController:singleProductViewController animated:YES];
	
	[singleProductViewController release];
}


/*- (IBAction)addProduct {
	NSEntityDescription *productDescription = [[fetchedResultsController fetchRequest] entity];
	NSManagedObject *newProduct = [NSEntityDescription insertNewObjectForEntityForName:[productDescription name] inManagedObjectContext:managedObjectContext];
	[newProduct setValue:@"iPad" forKey:@"name"];
	[newProduct setValue:[NSNumber numberWithFloat:699.00] forKey:@"price"];
	[newProduct setValue:@"Apple" forKey:@"found_where"];
	[newProduct setValue:@"http://www.apple.de/ipad/" forKey:@"found_url"];
	[newProduct setValue:@"123;123" forKey:@"found_latlong"];
	[newProduct setValue:[NSDate date] forKey:@"found_date"];
	
	NSError *error;
	if (![managedObjectContext save:&error]) {
		NSLog(@"Fehler beim Speichern des Produkts");
	}
	if (![fetchedResultsController performFetch:&error]) {
		NSLog(@"Fehler beim Laden");
		return;
	}
	
	[self.tableView reloadData];
}*/


- (void)viewDidLoad {
	[super viewDidLoad];

	self.navigationItem.leftBarButtonItem = self.editButtonItem;
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showAddProductForm)];
	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.16f green:0.36f blue:0.46f alpha:0.8f];
	self.navigationItem.rightBarButtonItem = addButton;

	[addButton release];
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	NSError *error;
	if (![self.fetchedResultsController performFetch:&error]) {
		NSLog(@"Fehler beim Laden");
		return;
	}
	
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
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
	}
	
	NSManagedObject *product = [fetchedResultsController objectAtIndexPath:indexPath];
	
	cell.textLabel.text = [product valueForKey:@"name"];
//	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	NSTimeInterval timeInterval = [[product valueForKey:@"found_date"] timeIntervalSinceNow];
	NSInteger daysUntil = 30 + ceil(timeInterval / 86400);
	
	cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ | %@ | %d", nil), [product valueForKey:@"price"], [product valueForKey:@"found_where"], daysUntil];
	
//	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
//	cell.accessoryType = UITableViewCellAccessoryCheckmark;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	[dateFormatter release];
	return cell;
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
		if (![fetchedResultsController performFetch:&error]) {
			NSLog(@"Fehler beim Laden");
			return;
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
