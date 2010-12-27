//
//  MapViewController.h
//  30daylist_iphone
//
//  Created by Marc-Oliver Teschke on 24.12.10.
//  Copyright 2010 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapViewController : UIViewController {
	IBOutlet MKMapView *mapView;
	IBOutlet UIToolbar *toolbar;
	NSManagedObject *product;	
}

@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, retain) NSManagedObject *product;

@end
