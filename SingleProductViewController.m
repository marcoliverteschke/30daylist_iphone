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

	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveProduct)];
	self.navigationItem.rightBarButtonItem = doneButton;
	[doneButton release];
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.tableView reloadData];
}


-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
	NSInteger nextTag = textField.tag + 1;
	if (nextTag <= kProductFoundWhereRow) {
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
/*	if ([[[[self.tableView.visibleCells objectAtIndex:0] valueForKey:@"textField"] text] length])
	{
		if (self.tipprunde == nil)
		{
			NSManagedObject *newTipprunde = [NSEntityDescription insertNewObjectForEntityForName:@"Tipprunde" inManagedObjectContext:managedObjectContext];
			[newTipprunde setValue:[[[[[self.tableView.visibleCells objectAtIndex:0] valueForKey:@"textField"] text] lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"kurzname"];
			[newTipprunde setValue:[[[[self.tableView.visibleCells objectAtIndex:1] valueForKey:@"textField"] text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"tippername"];
			[newTipprunde setValue:[[[[self.tableView.visibleCells objectAtIndex:2] valueForKey:@"textField"] text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"passwort"];
		} else {
			[self.tipprunde setValue:[[[[[self.tableView.visibleCells objectAtIndex:0] valueForKey:@"textField"] text] lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"kurzname"];
			[self.tipprunde setValue:[[[[self.tableView.visibleCells objectAtIndex:1] valueForKey:@"textField"] text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"tippername"];
			[self.tipprunde setValue:[[[[self.tableView.visibleCells objectAtIndex:2] valueForKey:@"textField"] text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"passwort"];
		}
		NSError *error;
		if (![managedObjectContext save:&error])
		{
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			NSLog(@"Fehler bein Speichern einer Tipprunde: ");
		}
	}*/
	[self.navigationController popViewControllerAnimated:TRUE];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	
	if (indexPath.section == kDirectInputsSection) {
		static NSString *TextCellIdentifier = @"TextCell";

		cell = [tableView dequeueReusableCellWithIdentifier:TextCellIdentifier];
		UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(120, 10, 175, 30)];
		textField.adjustsFontSizeToFitWidth = YES;
		textField.textColor = [UIColor blackColor];
		textField.backgroundColor = [UIColor whiteColor];
		
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TextCellIdentifier] autorelease];
		}
		
		if (indexPath.row == kProductNameRow) {
			textField.keyboardType = UIKeyboardTypeAlphabet;
			[textField setPlaceholder:NSLocalizedString(@"iPhone", nil)];
			[textField setReturnKeyType:UIReturnKeyNext];
			[textField setText:[product valueForKey:@"name"]];
			[textField setTag:kProductNameRow];
			cell.textLabel.text = NSLocalizedString(@"Was?", nil);
		} else if (indexPath.row == kProductPriceRow) {
			textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
			[textField setPlaceholder:NSLocalizedString(@"499.00", nil)];
			[textField setReturnKeyType:UIReturnKeyNext];
			[textField setTag:kProductPriceRow];
			if ([product valueForKey:@"price"] == nil) {
				[textField setText:@""];
			} else {
				[textField setText:[NSString stringWithFormat:@"%@", [product valueForKey:@"price"]]];
			}
			cell.textLabel.text = NSLocalizedString(@"Wie teuer?", nil);
		} else if (indexPath.row == kProductFoundWhereRow) {
			textField.keyboardType = UIKeyboardTypeAlphabet;
			[textField setPlaceholder:NSLocalizedString(@"Gefunden bei", nil)];
			[textField setReturnKeyType:UIReturnKeyDone];
			[textField setText:[product valueForKey:@"found_where"]];
			[textField setTag:kProductFoundWhereRow];
			cell.textLabel.text = NSLocalizedString(@"Wo?", nil);
		}

		[textField setDelegate:self];
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
