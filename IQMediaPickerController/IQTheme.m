//
//  IQTheme.m
//  IQMediaPickerController
//
//  Created by Jorge Miguel on 04/05/2019.
//

#import "IQTheme.h"

static IQTheme *_sharedSingleton;

@interface IQTheme()
{
#pragma mark - navbar

    UIStatusBarStyle statusBarStyle;

    UIColor *_navBarBackgroundColor;
    UIColor *_navBarTitleColor;

#pragma mark - views

    UIColor *_viewBackgroundColor;

#pragma mark - tableview

    UIColor *_tableViewSectionHeaderBackgroundColor;
    UIColor *_tableViewSectionHeaderTextColor;

#pragma mark - cells

    UIColor *_cellTextColor;
    UIColor *_cellSecundaryTextColor;
    UIColor *_cellSelectedTextColor;
    UIColor *_cellSelectedSecundaryTextColor;
    UIColor *_cellSeparatorColor;
    UIColor *_cellBackgroundColor;
    UIColor *_cellHighlightBackgroundColor;
}

@end

@implementation IQTheme

@synthesize cellTextColor = _cellTextColor;
@synthesize statusBarStyle = _statusBarStyle;
@synthesize navBarTitleColor = _navBarTitleColor;
@synthesize cellSeparatorColor = _cellSeparatorColor;
@synthesize viewBackgroundColor = _viewBackgroundColor;
@synthesize cellBackgroundColor = _cellBackgroundColor;
@synthesize cellSelectedTextColor = _cellSelectedTextColor;
@synthesize navBarBackgroundColor = _navBarBackgroundColor;
@synthesize cellSecundaryTextColor = _cellSecundaryTextColor;
@synthesize cellHighlightBackgroundColor = _cellHighlightBackgroundColor;
@synthesize cellSelectedSecundaryTextColor = _cellSelectedSecundaryTextColor;
@synthesize tableViewSectionHeaderTextColor = _tableViewSectionHeaderTextColor;
@synthesize tableViewSectionHeaderBackgroundColor = _tableViewSectionHeaderBackgroundColor;

+ (instancetype) getInstance
{
    return _sharedSingleton;
}

+ (void) initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        _sharedSingleton = IQTheme.new;
    }
}

- (instancetype) init
{
    self = super.init;
    if(self) {
        _navBarTitleColor = UIColor.blackColor;
        _statusBarStyle = UIStatusBarStyleDefault;
        _navBarBackgroundColor = UIColor.whiteColor;

        _viewBackgroundColor = UIColor.whiteColor;

        _tableViewSectionHeaderBackgroundColor = UIColor.whiteColor;
        _tableViewSectionHeaderTextColor = UIColor.blackColor;

        _cellTextColor = UIColor.blackColor;
        _cellSecundaryTextColor = UIColor.grayColor;
        _cellSelectedTextColor = UIColor.purpleColor;
        _cellSelectedSecundaryTextColor = UIColor.purpleColor;
        _cellSeparatorColor = [UIColor colorWithWhite:0.8 alpha:0.5];
        _cellBackgroundColor = UIColor.clearColor;
        _cellHighlightBackgroundColor = UIColor.grayColor;
    }
    return self;
}

@end
