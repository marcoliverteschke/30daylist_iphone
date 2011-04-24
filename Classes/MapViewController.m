    //
//  MapViewController.m
//  30daylist_iphone
//
//  Created by Marc-Oliver Teschke on 24.12.10.
//  Copyright 2010 n/a. All rights reserved.
//

#import "MapViewController.h"
#import "MKMapView+ZoomLevel.h"
#import "SSMapAnnotation.h"


@implementation MapViewController

@synthesize currentLocation;
@synthesize mapView;
@synthesize toolbar;
@synthesize product;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	[self setTitle:[self.product valueForKey:@"name"]];

	UIBarButtonItem *externalButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(openInMaps)];// target:self action:@selector(showAddProductForm)];
	self.navigationItem.rightBarButtonItem = externalButton;
	
//	toolbar.tintColor = [UIColor colorWithRed:0.16f green:0.36f blue:0.46f alpha:0.8f];
//	[mapView addSubview:toolbar];
	
//	[[toolbar.items objectAtIndex:1] setAction:@selector(openInMaps:)];
//	[[toolbar.items objectAtIndex:1] addTarget:self action:@selector(openInMaps:)];
}


- (void)openInMaps{
	if (currentLocation != nil) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%@,%@", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude, [product valueForKey:@"found_latitude"], [product valueForKey:@"found_longitude"]]]];
	} else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://maps.google.com/maps?q=%@,%@", [product valueForKey:@"found_latitude"], [product valueForKey:@"found_longitude"]]]];
	}
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	CLLocationCoordinate2D coordinate;
	coordinate.latitude = (CLLocationDegrees)[[product valueForKey:@"found_latitude"] doubleValue];
	coordinate.longitude = (CLLocationDegrees)[[product valueForKey:@"found_longitude"] doubleValue];
	
	[self.mapView setCenterCoordinate:coordinate zoomLevel:14 animated:YES];
	[self.mapView setMapType:MKMapTypeHybrid];
	
	SSMapAnnotation *annotation = [[SSMapAnnotation alloc] initWithCoordinate:coordinate title:[product valueForKey:@"name"] subtitle: NSLocalizedString(@"this is where you found it", @"subtitle for the Maps indicator of the item's location")];
	[self.mapView addAnnotation:annotation];
	[self.mapView selectAnnotation:annotation animated:YES];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
