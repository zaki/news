//
//  LibraryViewController.m
//  News
//
//  Created by Dezso Zoltan on 2011.07.14..
//  Copyright 2011 Friday Systems. All rights reserved.
//

#import "LibraryViewController.h"

#define NUMBER_OF_ITEMS 20
#define ITEM_SPACING 210
#define USE_BUTTONS YES

@interface LibraryViewController () <UIActionSheetDelegate>

@property (nonatomic, assign) BOOL wrap;
@property (nonatomic, retain) NSArray *items;

@end

@implementation LibraryViewController

@synthesize carousel;
@synthesize wrap;
@synthesize items;
@synthesize navItem;

- (id)initWithCoder:(NSCoder *)aDecoder
{
  if ((self = [super initWithCoder:aDecoder]))
  {
    //set up data
    self.items = [NSArray arrayWithObjects:
                   @"January, 2010", @"February, 2010", @"March, 2010", @"April, 2010", @"May, 2010",
                   @"June, 2010", @"July, 2010", @"August, 2010", @"September, 2010", @"October, 2010",
                   @"November, 2010", @"December, 2010", @"January, 2011", @"February, 2011", @"March, 2011",
                   @"April, 2011", @"May, 2011", @"June, 2011", @"July, 2011", @"August, 2011",
                   nil];
  }
  return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
  [carousel release];
  [navItem release];
  [items release];
  [super dealloc];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  carousel.type = iCarouselTypeCoverFlow;
  wrap = YES;
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  self.carousel = nil;
  self.navItem = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}

- (IBAction)switchCarouselType
{
  UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Select Carousel Type"
                                                     delegate:self
                                            cancelButtonTitle:nil
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:@"Linear", @"Rotary", @"Inverted Rotary", @"Cylinder", @"Inverted Cylinder", @"CoverFlow", @"Custom", nil];
  [sheet showInView:self.view];
  [sheet release];
}

- (IBAction)toggleWrap
{
  wrap = !wrap;
  navItem.rightBarButtonItem.title = wrap? @"Wrap: ON": @"Wrap: OFF";
  [carousel reloadData];
}

- (IBAction)insertItem
{
  NSInteger index = carousel.currentItemIndex;
}

- (IBAction)removeItem
{
  if (carousel.numberOfItems > 0)
  {
    NSInteger index = carousel.currentItemIndex;
  }
}

#pragma mark -
#pragma mark UIActionSheet methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  //restore view opacities to normal
  for (UIView *view in carousel.visibleViews)
  {
    view.alpha = 1.0;
  }
  self.tabBarController.selectedIndex = 1;
}

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
  return [items count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index
{
  NSString *fileName = [NSString stringWithFormat:@"Covers/issue_%d.jpg", index+1];
  NSLog(@"Loading File for index %d named %@", index, fileName);
  if (USE_BUTTONS)
  {
    //create a numbered button
    UIImage *image = [UIImage imageNamed:fileName];
    UIButton *button = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 240, 320)] autorelease];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.titleLabel.font = [button.titleLabel.font fontWithSize:50];
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = index;
    return button;
  }
  else
  {
    //create a numbered view
    UIView *view = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:fileName]] autorelease];
    return view;
  }
}

- (NSUInteger)numberOfPlaceholdersInCarousel:(iCarousel *)carousel
{
	//note: placeholder views are only displayed if wrapping is disabled
	return 2;
}

- (UIView *)carousel:(iCarousel *)carousel placeholderViewAtIndex:(NSUInteger)index
{
  NSString *fileName = [NSString stringWithFormat:@"Icons/page.jpg", index+1];
	//create a placeholder view
	UIView *view = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:fileName]] autorelease];
	UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 240, 320)] autorelease];
	label.text = (index == 0)? @"[": @"]";
	label.backgroundColor = [UIColor clearColor];
	label.textAlignment = UITextAlignmentCenter;
	label.font = [label.font fontWithSize:50];
	[view addSubview:label];
	return view;
}

- (float)carouselItemWidth:(iCarousel *)carousel
{
  //slightly wider than item view
  return ITEM_SPACING;
}

- (CATransform3D)carousel:(iCarousel *)_carousel transformForItemView:(UIView *)view withOffset:(float)offset
{
  //implement 'flip3D' style carousel
  
  //set opacity based on distance from camera
  view.alpha = 1.0 - fminf(fmaxf(offset, 0.0), 1.0);
  
  //do 3d transform
  CATransform3D transform = CATransform3DIdentity;
  transform.m34 = self.carousel.perspective;
  transform = CATransform3DRotate(transform, M_PI / 8.0, 0, 1.0, 0);
  return CATransform3DTranslate(transform, 0.0, 0.0, offset * carousel.itemWidth);
}

- (BOOL)carouselShouldWrap:(iCarousel *)carousel
{
  //wrap all carousels
  return wrap;
}

- (void)carouselWillBeginDragging:(iCarousel *)carousel
{
	NSLog(@"Carousel will begin dragging");
}

- (void)carouselDidEndDragging:(iCarousel *)carousel willDecelerate:(BOOL)decelerate
{
	NSLog(@"Carousel did end dragging and %@ decelerate", decelerate? @"will": @"won't");
}

- (void)carouselWillBeginDecelerating:(iCarousel *)carousel
{
	NSLog(@"Carousel will begin decelerating");
}

- (void)carouselDidEndDecelerating:(iCarousel *)carousel
{
	NSLog(@"Carousel did end decelerating");
}

- (void)carouselWillBeginScrollingAnimation:(iCarousel *)carousel
{
	NSLog(@"Carousel will begin scrolling");
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel
{
  navItem.title = [items objectAtIndex:[carousel currentItemIndex]];
}

- (void)carousel:(iCarousel *)_carousel didSelectItemAtIndex:(NSInteger)index
{
	if (index == carousel.currentItemIndex)
	{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:[items objectAtIndex:index]
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"View Issue", @"Purchase Issue", nil];
    [sheet showInView:self.view];
    [sheet release];
	}
	else
	{
		NSLog(@"Selected item number %i", index);
	}
}

#pragma mark -
#pragma mark Button tap event

- (void)buttonTapped:(UIButton *)sender
{
  [[[[UIAlertView alloc] initWithTitle:@"Button Tapped"
                               message:[NSString stringWithFormat:@"You tapped button number %i", sender.tag]
                              delegate:nil
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil] autorelease] show];
}
@end
