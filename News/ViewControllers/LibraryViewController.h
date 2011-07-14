//
//  LibraryViewController.h
//  News
//
//  Created by Dezso Zoltan on 2011.07.14..
//  Copyright 2011 Friday Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"

@interface LibraryViewController : UIViewController<iCarouselDataSource, iCarouselDelegate> {
    
}

@property (nonatomic, retain) IBOutlet iCarousel *carousel;
@property (nonatomic, retain) IBOutlet UINavigationItem *navItem;

- (IBAction)switchCarouselType;
- (IBAction)toggleWrap;
- (IBAction)insertItem;
- (IBAction)removeItem;

@end
