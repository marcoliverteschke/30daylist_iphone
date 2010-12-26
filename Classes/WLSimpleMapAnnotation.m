//
//  WLSimpleMapAnnotation.m
//
//  Created by William LaFrance on 2/23/10.
//  Public Domain
//

#import "WLSimpleMapAnnotation.h"

@implementation WLSimpleMapAnnotation

@synthesize coordinate = _coordinate;

+ (id) initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    self = [super alloc];
    _coordinate = coordinate;
    return self;
}

+ (id) initWithCoordinate:(CLLocationCoordinate2D)coordinate andTitle:(NSString*) title {
    self = [super alloc];
    _coordinate = coordinate;
    _title = [title retain];
    return self;
}

+ (id) initWithCoordinate:(CLLocationCoordinate2D)coordinate andTitle:(NSString*) title andSubtitle:(NSString*) subtitle {
    self = [super alloc];
    _coordinate = coordinate;
    _title = [title retain];
    _subtitle = [subtitle retain];
    return self;
}

- (NSString *)title {
    return _title;
}

- (NSString *)subtitle {
    return _subtitle;
}

-(void) dealloc {
    [_title release];
    [_subtitle release];
    [super dealloc];
}

@end