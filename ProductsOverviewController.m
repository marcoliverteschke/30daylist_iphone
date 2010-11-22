//
//  ProductsOverviewController.m
//  30daylist_iphone
//
//  Created by Marc-Oliver Teschke on 22.11.10.
//  Copyright 2010 n/a. All rights reserved.
//

#import "ProductsOverviewController.h"


@implementation ProductsOverviewController

@synthesize managedObjectContext;


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
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
