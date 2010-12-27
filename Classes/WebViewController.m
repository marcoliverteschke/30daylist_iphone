    //
//  WebViewController.m
//  30daylist_iphone
//
//  Created by Marc-Oliver Teschke on 24.12.10.
//  Copyright 2010 n/a. All rights reserved.
//

#import "WebViewController.h"


@implementation WebViewController

@synthesize webView;
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

	toolbar.tintColor = [UIColor colorWithRed:0.16f green:0.36f blue:0.46f alpha:0.8f];
	[webView addSubview:toolbar];
	[[toolbar.items objectAtIndex:0] setEnabled:NO];
	[[toolbar.items objectAtIndex:1] setEnabled:NO];
	
	NSString *regEx = @"^http://.*";
	NSMutableString *go_to_url;
	NSRange r = [[product valueForKey:@"found_url"] rangeOfString:regEx options:NSRegularExpressionSearch];
	if (r.location == NSNotFound) {
		go_to_url = [NSString stringWithFormat:@"http://%@", [product valueForKey:@"found_url"]];
	} else {
		go_to_url = [product valueForKey:@"found_url"];
	}
	
	[webView setScalesPageToFit:YES];
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:go_to_url]]];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if ([webView canGoBack]) {
		[[toolbar.items objectAtIndex:0] setEnabled:YES];
	} else {
		[[toolbar.items objectAtIndex:0] setEnabled:NO];
	}

	if ([webView canGoForward]) {
		[[toolbar.items objectAtIndex:1] setEnabled:YES];
	} else {
		[[toolbar.items objectAtIndex:1] setEnabled:NO];
	}

	return YES;
}


/*- (IBAction)reload {
	[webView reload];
}


- (IBAction)go_back {
	[webView goBack];
}


- (IBAction)go_forward {
	[webView goForward];
}*/


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
	[webView release];
    [super dealloc];
}


@end
