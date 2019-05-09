//
//  IQTheme.h
//  IQMediaPickerController
//
//  Created by Jorge Miguel on 04/05/2019.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IQTheme : NSObject

#pragma mark - navbar

@property(assign)  UIStatusBarStyle statusBarStyle;
@property(nonnull) UIColor *navBarBackgroundColor;
@property(nonnull) UIColor *navBarTitleColor;

#pragma mark - views

@property(nonnull) UIColor *viewBackgroundColor;

#pragma mark - tableview

@property(nonnull) UIColor *tableViewSectionHeaderBackgroundColor;
@property(nonnull) UIColor *tableViewSectionHeaderTextColor;

#pragma mark - cells

@property(nonnull) UIColor *cellTextColor;
@property(nonnull) UIColor *cellSecundaryTextColor;
@property(nonnull) UIColor *cellSelectedTextColor;
@property(nonnull) UIColor *cellSelectedSecundaryTextColor;
@property(nonnull) UIColor *cellSeparatorColor;
@property(nonnull) UIColor *cellBackgroundColor;
@property(nonnull) UIColor *cellHighlightBackgroundColor;

+ (nonnull instancetype) getInstance;

@end

NS_ASSUME_NONNULL_END
