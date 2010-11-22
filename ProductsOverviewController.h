//
//  ProductsOverviewController.h
//  30daylist_iphone
//
//  Created by Marc-Oliver Teschke on 22.11.10.
//  Copyright 2010 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProductsOverviewController : UITableViewController<NSFetchedResultsControllerDelegate> {

	NSManagedObjectContext *managedObjectContext;
	NSFetchedResultsController *fetchedResultsController;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;

@end
