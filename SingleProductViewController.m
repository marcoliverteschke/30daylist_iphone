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
static const NSInteger kProductURLRow = 3;

@implementation SingleProductViewController

@synthesize currentLocation;
@synthesize managedObjectContext;
@synthesize product;
@synthesize productNameField;
@synthesize productPriceField;
@synthesize productFoundWhereField;
@synthesize productURLField;
@synthesize entityDescription;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}


- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = NSLocalizedString(@"New item", nil);
	
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveProduct)];
	self.navigationItem.rightBarButtonItem = doneButton;
	[doneButton release];
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/table_bg.png"];
	UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
	UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
	[self.tableView setBackgroundView:imageView];
	
	[self.tableView setScrollEnabled:NO];
	
	[self.tableView reloadData];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 50.0f;
}


-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
	NSInteger nextTag = textField.tag + 1;
	if (nextTag <= kProductURLRow) {
		UIResponder* nextResponder = [[self.tableView.visibleCells objectAtIndex:nextTag] viewWithTag:nextTag];
		if (nextResponder) {
			[nextResponder becomeFirstResponder];
		}
	} else {
		[textField resignFirstResponder];
		[self saveProduct];
	}
	return NO;
}


- (IBAction)saveProduct
{
	NSNumberFormatter *priceFormatter = [NSNumberFormatter alloc];
	[priceFormatter init];
//	[priceFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"EN-US"]];
	NSNumber *price = [priceFormatter numberFromString:[productPriceField text]];
	NSDate *now = [[NSDate alloc] init];
	
	if ([[productNameField text] length] == 0) {
		UIAlertView *validationError = [[UIAlertView alloc] initWithTitle: @"Oh my!" message: @"Please enter the name of this fine product!" delegate: self cancelButtonTitle: @"Alright then…" otherButtonTitles: nil];
		[validationError show];
		[validationError release];
		return;
	}	
	if (price == nil) {
		UIAlertView *validationError = [[UIAlertView alloc] initWithTitle: @"Oh my!" message: @"You did not enter a price. That is quite cheap!" delegate: self cancelButtonTitle: @"Alright then…" otherButtonTitles: nil];
		[validationError show];
		[validationError release];
		return;
	}
	if ([[productFoundWhereField text] length] == 0) {
		UIAlertView *validationError = [[UIAlertView alloc] initWithTitle: @"Oh my!" message: @"Please tell me where I can purchase such quality items!" delegate: self cancelButtonTitle: @"Alright then…" otherButtonTitles: nil];
		[validationError show];
		[validationError release];
		return;
	}	
	
	self.product = [NSEntityDescription insertNewObjectForEntityForName:[entityDescription name] inManagedObjectContext:managedObjectContext];
	
	[product setValue:[productNameField text] forKey:@"name"];
	[product setValue:price forKey:@"price"];
	[product setValue:[productFoundWhereField text] forKey:@"found_where"];
	[product setValue:[productURLField text] forKey:@"found_url"];
	
	if (currentLocation != nil) {
		[product setValue:[NSNumber numberWithFloat:currentLocation.coordinate.latitude] forKey:@"found_latitude"];
		[product setValue:[NSNumber numberWithFloat:currentLocation.coordinate.longitude] forKey:@"found_longitude"];
	} else {
		[product setValue:0 forKey:@"found_latitude"];
		[product setValue:0 forKey:@"found_longitude"];
	}
	
	[product setValue:now forKey:@"found_date"];
	
	NSError *error;
	if (![managedObjectContext save:&error]) {
		NSLog([error localizedDescription]);
		NSLog([error localizedFailureReason]);
		NSLog([error localizedRecoveryOptions]);
		NSLog([error localizedRecoverySuggestion]);
		NSLog(@"Fehler beim Speichern des Produkts");
	}/* else {
		NSLog(@"We cool? Then schedule a notification");
	}*/

/*	UILocalNotification *notification = [[UILocalNotification alloc] init];
	NSDate *justAMinute = [[[NSDate alloc] init] dateByAddingTimeInterval:2592000]; // 30 days
	NSDate *justAMinute = [[[NSDate alloc] init] dateByAddingTimeInterval:120]; // 30 days
	[notification setFireDate:justAMinute];
	[notification setAlertBody:[NSString stringWithFormat:@"It's time to review %@", [productNameField text]]];
	[notification setAlertAction:@"Review"];
	[notification setSoundName:UILocalNotificationDefaultSoundName];
	[[UIApplication sharedApplication] scheduleLocalNotification:notification];
	[notification release];*/
	
	[self.navigationController popViewControllerAnimated:TRUE];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	
	if (indexPath.section == kDirectInputsSection) {
		static NSString *TextCellIdentifier = @"TextCell";

		cell = [tableView dequeueReusableCellWithIdentifier:TextCellIdentifier];
		
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TextCellIdentifier] autorelease];
		}
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		if (indexPath.row == kProductNameRow) {
			productNameField = [[UITextField alloc] initWithFrame:CGRectMake(130, 10, 175, 30)];
			productNameField.textColor = [UIColor blackColor];
			productNameField.backgroundColor = [UIColor clearColor];
			productNameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;

			productNameField.keyboardType = UIKeyboardTypeAlphabet;
			productNameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
			productNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
			[productNameField setPlaceholder:NSLocalizedString(@"Awesome Product", nil)];
			[productNameField setReturnKeyType:UIReturnKeyNext];
			[productNameField setText:[product valueForKey:@"name"]];
			[productNameField setTag:kProductNameRow];
			cell.textLabel.text = NSLocalizedString(@"What?", nil);

			[productNameField setDelegate:self];
			[productNameField setEnabled: YES];
			[productNameField becomeFirstResponder];
			[cell addSubview:productNameField];
			[productNameField release];
		} else if (indexPath.row == kProductPriceRow) {
			productPriceField = [[UITextField alloc] initWithFrame:CGRectMake(130, 10, 175, 30)];
			productPriceField.textColor = [UIColor blackColor];
			productPriceField.backgroundColor = [UIColor clearColor];
			productPriceField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;

			productPriceField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
			productPriceField.clearButtonMode = UITextFieldViewModeWhileEditing;
			
			NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
			[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
			[productPriceField setPlaceholder:[NSString stringWithFormat:NSLocalizedString(@"%@", nil), [formatter stringFromNumber:[[NSNumber alloc] initWithFloat:0.99]]]];
			[productPriceField setReturnKeyType:UIReturnKeyNext];
			[productPriceField setTag:kProductPriceRow];
			if ([product valueForKey:@"price"] == nil) {
				[productPriceField setText:@""];
			} else {
				[productPriceField setText:[NSString stringWithFormat:@"%@", [product valueForKey:@"price"]]];
			}
			cell.textLabel.text = NSLocalizedString(@"How much?", nil);

			[productPriceField setDelegate:self];
			[productPriceField setEnabled: YES];
			[cell addSubview:productPriceField];
			[productPriceField release];
		} else if (indexPath.row == kProductFoundWhereRow) {
			productFoundWhereField = [[UITextField alloc] initWithFrame:CGRectMake(130, 10, 175, 30)];
			productFoundWhereField.textColor = [UIColor blackColor];
			productFoundWhereField.backgroundColor = [UIColor clearColor];
			productFoundWhereField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
			
			productFoundWhereField.keyboardType = UIKeyboardTypeAlphabet;
			productFoundWhereField.clearButtonMode = UITextFieldViewModeWhileEditing;
			[productFoundWhereField setPlaceholder:NSLocalizedString(@"Found at", nil)];
			[productFoundWhereField setReturnKeyType:UIReturnKeyNext];
			[productFoundWhereField setText:[product valueForKey:@"found_where"]];
			[productFoundWhereField setTag:kProductFoundWhereRow];
			cell.textLabel.text = NSLocalizedString(@"Where?", nil);
			
			[productFoundWhereField setDelegate:self];
			[productFoundWhereField setEnabled: YES];
			[cell addSubview:productFoundWhereField];
			[productFoundWhereField release];
		} else if (indexPath.row == kProductURLRow) {
			productURLField = [[UITextField alloc] initWithFrame:CGRectMake(130, 10, 175, 30)];
			productURLField.textColor = [UIColor blackColor];
			productURLField.backgroundColor = [UIColor clearColor];
			productURLField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
			
			[productURLField setKeyboardType:UIKeyboardTypeURL];
			productURLField.autocapitalizationType = UITextAutocapitalizationTypeNone;
			productURLField.clearButtonMode = UITextFieldViewModeWhileEditing;
			[productURLField setPlaceholder:NSLocalizedString(@"www.product.com", nil)];
			[productURLField setReturnKeyType:UIReturnKeyDone];
			[productURLField setText:[product valueForKey:@"found_url"]];
			[productURLField setTag:kProductURLRow];
			cell.textLabel.text = NSLocalizedString(@"URL", nil);
			
			[productURLField setDelegate:self];
			[productURLField setEnabled: YES];
			[cell addSubview:productURLField];
			[productURLField release];
		}
	}

	NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/cell_bg.png"];
	UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
	UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
	[cell setBackgroundView:imageView];

	return cell;
	
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger rowCount = 0;
	if(section == kDirectInputsSection)
		rowCount = 4;
	return rowCount;
}


- (void)dealloc {
	[product release];
    [super dealloc];
}


@end
