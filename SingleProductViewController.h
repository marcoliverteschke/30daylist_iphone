//
//  SingleProductViewController.h
//  30daylist_iphone
//
//  Created by Marc-Oliver Teschke on 28.11.10.
//  Copyright 2010 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface SingleProductViewController : UITableViewController<UITextFieldDelegate> {
	CLLocation *currentLocation;
	NSManagedObjectContext *managedObjectContext;
	NSManagedObject *product;
	NSEntityDescription *entityDescription;
	UITextField *productNameField;
	UITextField *productPriceField;
	UITextField *productFoundWhereField;
	UITextField *productURLField;
}

@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObject *product;
@property (nonatomic, retain) NSEntityDescription *entityDescription;
@property (nonatomic, readonly) IBOutlet UITextField *productNameField;
@property (nonatomic, readonly) IBOutlet UITextField *productPriceField;
@property (nonatomic, readonly) IBOutlet UITextField *productFoundWhereField;
@property (nonatomic, readonly) IBOutlet UITextField *productURLField;

@end
