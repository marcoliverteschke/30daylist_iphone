//
//  SingleProductViewController.h
//  30daylist_iphone
//
//  Created by Marc-Oliver Teschke on 28.11.10.
//  Copyright 2010 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SingleProductViewController : UITableViewController {
	NSManagedObject *product;
}

@property (nonatomic, retain) NSManagedObject *product;

@end
