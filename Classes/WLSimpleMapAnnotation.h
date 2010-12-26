//
//  WLSimpleMapAnnotation.h
//
//  Created by William LaFrance on 2/23/10.
//  Public Domain
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface WLSimpleMapAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D _coordinate;
    NSString * _title;
    NSString * _subtitle;
}

+ (id) initWithCoordinate:(CLLocationCoordinate2D)coordinate;
+ (id) initWithCoordinate:(CLLocationCoordinate2D)coordinate andTitle:(NSString *) title;
+ (id) initWithCoordinate:(CLLocationCoordinate2D)coordinate andTitle:(NSString *) title andSubtitle:(NSString *)subtitle;

- (NSString *)title;
- (NSString *)subtitle;

@end