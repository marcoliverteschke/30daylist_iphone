//
//  ProductsOverviewController.h
//  30daylist_iphone
//
//  Created by Marc-Oliver Teschke on 22.11.10.
//  Copyright 2010 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface ProductsOverviewController : UITableViewController<NSFetchedResultsControllerDelegate,UIActionSheetDelegate,CLLocationManagerDelegate> {
	NSManagedObjectContext *managedObjectContext;
	NSFetchedResultsController *fetchedResultsController;
	CLLocationManager *locationManager;
	CLLocation *currentLocation;
	NSManagedObject *currentProduct;
	NSNumber *timeToFireNotification;
}

- (void)showOnMap:(NSManagedObject *)product;
- (void)showInBrowser:(NSManagedObject *)product;
- (void)startStandardUpdates;
- (void)reloadProductsTable;
- (NSInteger)numberOfItemsStored;
- (void)populateWithDemoData;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, retain) NSManagedObject *currentProduct;
@property (nonatomic, retain) NSNumber *timeToFireNotification;

@end
