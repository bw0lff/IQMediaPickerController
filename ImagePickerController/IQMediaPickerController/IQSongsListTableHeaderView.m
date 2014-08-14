//
//  IQTableViewHeaderView.m
//  IQAudioPickerController
//
//  Created by Iftekhar on 12/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "IQSongsListTableHeaderView.h"

@implementation IQSongsListTableHeaderView

-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.contentView.frame = CGRectMake(0, 0, 320, 80);
        
        self.imageViewAlbum = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 60, 60)];
        self.imageViewAlbum.contentMode = UIViewContentModeScaleAspectFit;
        self.imageViewAlbum.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [self.contentView addSubview:self.imageViewAlbum];
        
        self.labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(75, 10, 320, 20)];
        self.labelTitle.backgroundColor = [UIColor clearColor];
        self.labelTitle.font = [UIFont boldSystemFontOfSize:15];
        self.labelTitle.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self.contentView addSubview:self.labelTitle];
        
        self.labelSubTitle = [[UILabel alloc] initWithFrame:CGRectMake(75, 30, 320, 20)];
        self.labelSubTitle.backgroundColor = [UIColor clearColor];
        self.labelSubTitle.font = [UIFont systemFontOfSize:13];
        self.labelSubTitle.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self.contentView addSubview:self.labelSubTitle];
        
        self.labelSubSubTitle = [[UILabel alloc] initWithFrame:CGRectMake(75, 50, 320, 20)];
        self.labelSubSubTitle.backgroundColor = [UIColor clearColor];
        self.labelSubSubTitle.font = [UIFont systemFontOfSize:13];
        self.labelSubSubTitle.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self.contentView addSubview:self.labelSubSubTitle];
        
    }

    return self;
}

@end
