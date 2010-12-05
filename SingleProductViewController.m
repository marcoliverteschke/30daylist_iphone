//
//  SingleProductViewController.m
//  30daylist_iphone
//
//  Created by Marc-Oliver Teschke on 28.11.10.
//  Copyright 2010 n/a. All rights reserved.
//

#import "SingleProductViewController.h"


static const NSInteger kDirectInputsSection = 0;

static const NSInteger kProductNameRow = 0;
static const NSInteger kProductPriceRow = 1;
static const NSInteger kProductFoundWhereRow = 2;

@implementation SingleProductViewController

@synthesize product;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}


- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = NSLocalizedString(@"Neues Produkt", nil);
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.tableView reloadData];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	
	if (indexPath.section == kDirectInputsSection) {
		static NSString *TextCellIdentifier = @"TextCell";

		cell = [tableView dequeueReusableCellWithIdentifier:TextCellIdentifier];
		UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(110, 10, 185, 30)];
		textField.adjustsFontSizeToFitWidth = YES;
		textField.textColor = [UIColor blackColor];
		textField.backgroundColor = [UIColor whiteColor];
		
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TextCellIdentifier] autorelease];
		}
		
		if (indexPath.row == kProductNameRow) {
			textField.placeholder = NSLocalizedString(@"iPhone", nil);
			textField.keyboardType = UIKeyboardTypeAlphabet;
			textField.returnKeyType = UIReturnKeyNext;
			textField.text = [product valueForKey:@"name"];
			cell.textLabel.text = NSLocalizedString(@"Was?", nil);
		} else if (indexPath.row == kProductPriceRow) {
			textField.placeholder = NSLocalizedString(@"499.00", nil);
			textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
			textField.returnKeyType = UIReturnKeyNext;
			if ([product valueForKey:@"price"] == nil) {
				textField.text = @"";
			} else {
				textField.text = [NSString stringWithFormat:@"%@", [product valueForKey:@"price"]];
			}
			cell.textLabel.text = NSLocalizedString(@"Wie teuer?", nil);
		} else if (indexPath.row == kProductFoundWhereRow) {
			textField.placeholder = NSLocalizedString(@"Gefunden bei", nil);
			textField.keyboardType = UIKeyboardTypeAlphabet;
			textField.returnKeyType = UIReturnKeyDone;
			textField.text = [product valueForKey:@"found_where"];
			cell.textLabel.text = NSLocalizedString(@"Wo?", nil);
		}

		[textField setEnabled: YES];
		[cell addSubview:textField];
		[textField release];
	}
	
	return cell;
	
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger rowCount = 0;
	if(section == kDirectInputsSection)
		rowCount = 3;
	return rowCount;
}


- (void)dealloc {
	[product release];
    [super dealloc];
}


@end
