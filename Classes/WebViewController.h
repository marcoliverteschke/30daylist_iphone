//
//  WebViewController.h
//  30daylist_iphone
//
//  Created by Marc-Oliver Teschke on 24.12.10.
//  Copyright 2010 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WebViewController : UIViewController {
	IBOutlet UIWebView *webView;
	IBOutlet UIToolbar *toolbar;
	NSManagedObject *product;	
}

- (NSString*)formatURL:(NSString*)original;

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, retain) NSManagedObject *product;

@end
