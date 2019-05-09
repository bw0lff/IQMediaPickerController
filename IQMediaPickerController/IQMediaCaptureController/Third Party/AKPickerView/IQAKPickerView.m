//
//  AKPickerView.m
//  AKPickerViewSample
//
//  Created by Akio Yasui on 3/29/14.
//  Copyright (c) 2014 Akio Yasui. All rights reserved.
//

#import <UIKit/UICollectionViewFlowLayout.h>
#import <UIKit/UICollectionViewCell.h>
#import <UIKit/NSAttributedString.h>
#import <UIKit/NSStringDrawing.h>
#import <Availability.h>

#import "IQAKPickerView.h"

@class IQAKCollectionViewLayout;

@protocol IQAKCollectionViewLayoutDelegate <NSObject>
- (IQAKPickerViewStyle)pickerViewStyleForCollectionViewLayout:(IQAKCollectionViewLayout *)layout;
@end

@interface IQAKCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIFont *highlightedFont;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *highlightedTextColor;
@end

@interface IQAKCollectionViewLayout : UICollectionViewFlowLayout
@property (nonatomic, assign) id <IQAKCollectionViewLayoutDelegate> delegate;
@end

@interface IQAKPickerViewDelegateIntercepter : NSObject <UICollectionViewDelegate>
@property (nonatomic, weak) IQAKPickerView *pickerView;
@property (nonatomic, weak) id <UIScrollViewDelegate> delegate;
@end

@interface IQAKPickerView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, IQAKCollectionViewLayoutDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSUInteger selectedItem;
@property (nonatomic, strong) IQAKPickerViewDelegateIntercepter *intercepter;
- (CGFloat)offsetForItem:(NSUInteger)item;
- (void)didEndScrolling;
- (CGSize)sizeForString:(NSString *)string;
@end

@implementation IQAKPickerView

- (void)initialize
{
	self.font = self.font ?: [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
	self.highlightedFont = self.highlightedFont ?: [UIFont fontWithName:@"HelveticaNeue" size:20];
	self.textColor = self.textColor ?: [UIColor darkGrayColor];
	self.highlightedTextColor = self.highlightedTextColor ?: [UIColor blackColor];
	self.pickerViewStyle = self.pickerViewStyle ?: IQAKPickerViewStyle3D;
	self.maskDisabled = self.maskDisabled;

	[self.collectionView removeFromSuperview];
	self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds
											 collectionViewLayout:[self collectionViewLayout]];
	self.collectionView.showsHorizontalScrollIndicator = NO;
	self.collectionView.backgroundColor = [UIColor clearColor];
	self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
	self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.collectionView.dataSource = self;
	[self.collectionView registerClass:[IQAKCollectionViewCell class]
			forCellWithReuseIdentifier:NSStringFromClass([IQAKCollectionViewCell class])];
	[self addSubview:self.collectionView];

	self.intercepter = [IQAKPickerViewDelegateIntercepter new];
	self.intercepter.pickerView = self;
	self.intercepter.delegate = self.delegate;
	self.collectionView.delegate = self.intercepter;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self initialize];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self initialize];
	}
	return self;
}

- (void)dealloc
{
	self.collectionView.delegate = nil;
}

#pragma mark -

- (void)layoutSubviews
{
	[super layoutSubviews];
	self.collectionView.collectionViewLayout = [self collectionViewLayout];
	if ([self.dataSource numberOfItemsInPickerView:self]) {
		[self scrollToItem:self.selectedItem animated:NO];
	}
	self.collectionView.layer.mask.frame = self.collectionView.bounds;
}

- (CGSize)intrinsicContentSize
{
	return CGSizeMake(UIViewNoIntrinsicMetric, MAX(self.font.lineHeight, self.highlightedFont.lineHeight));
}

- (CGPoint)contentOffset
{
	return self.collectionView.contentOffset;
}

#pragma mark -

- (void)setDelegate:(id<IQAKPickerViewDelegate>)delegate
{
	if (![_delegate isEqual:delegate]) {
		_delegate = delegate;
		self.intercepter.delegate = delegate;
	}
}

- (void)setFisheyeFactor:(CGFloat)fisheyeFactor
{
	_fisheyeFactor = fisheyeFactor;

	CATransform3D transform = CATransform3DIdentity;
	transform.m34 = -MAX(MIN(self.fisheyeFactor, 1.0), 0.0);
	self.collectionView.layer.sublayerTransform = transform;
}

- (void)setMaskDisabled:(BOOL)maskDisabled
{
	_maskDisabled = maskDisabled;

	self.collectionView.layer.mask = maskDisabled ? nil : ({
		CAGradientLayer *maskLayer = [CAGradientLayer layer];
		maskLayer.frame = self.collectionView.bounds;
		maskLayer.colors = @[(id)[[UIColor clearColor] CGColor],
							 (id)[[UIColor blackColor] CGColor],
							 (id)[[UIColor blackColor] CGColor],
							 (id)[[UIColor clearColor] CGColor],];
		maskLayer.locations = @[@0.0, @0.33, @0.66, @1.0];
		maskLayer.startPoint = CGPointMake(0.0, 0.0);
		maskLayer.endPoint = CGPointMake(1.0, 0.0);
		maskLayer;
	});
}

#pragma mark -

- (IQAKCollectionViewLayout *)collectionViewLayout
{
	IQAKCollectionViewLayout *layout = [IQAKCollectionViewLayout new];
	layout.delegate = self;
	return layout;
}

- (CGSize)sizeForString:(NSString *)string
{
	CGSize size;
	CGSize highlightedSize;
#ifdef __IPHONE_7_0
    size = [string sizeWithAttributes:@{NSFontAttributeName: self.font}];
    highlightedSize = [string sizeWithAttributes:@{NSFontAttributeName: self.highlightedFont}];
#else
    size = [string sizeWithFont:self.font];
    highlightedSize = [string sizeWithFont:self.highlightedFont];
#endif
	return CGSizeMake(ceil(MAX(size.width, highlightedSize.width)), ceil(MAX(size.height, highlightedSize.height)));
}

#pragma mark -

- (void)reloadData
{
	[self invalidateIntrinsicContentSize];
	[self.collectionView.collectionViewLayout invalidateLayout];
	[self.collectionView reloadData];
    
    NSUInteger numberOfItems = [self.dataSource numberOfItemsInPickerView:self];
    
	if (numberOfItems) {
		[self selectItem:MIN(self.selectedItem, numberOfItems-1) animated:NO notifySelection:NO];
	}
}

- (CGFloat)offsetForItem:(NSUInteger)item
{
	NSAssert(item < [self.collectionView numberOfItemsInSection:0],
			 @"item out of range; '%lu' passed, but the maximum is '%lu'", item, [self.collectionView numberOfItemsInSection:0]);

	CGFloat offset = 0.0;

	for (NSInteger i = 0; i < item; i++) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
		CGSize cellSize = [self collectionView:self.collectionView layout:self.collectionView.collectionViewLayout sizeForItemAtIndexPath:indexPath];
		offset += cellSize.width;
	}

	NSIndexPath *firstIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
	CGSize firstSize = [self collectionView:self.collectionView layout:self.collectionView.collectionViewLayout sizeForItemAtIndexPath:firstIndexPath];
	NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForItem:item inSection:0];
	CGSize selectedSize = [self collectionView:self.collectionView layout:self.collectionView.collectionViewLayout sizeForItemAtIndexPath:selectedIndexPath];
	offset -= (firstSize.width - selectedSize.width) / 2;

	return offset;
}

- (void)scrollToItem:(NSUInteger)item animated:(BOOL)animated
{
	switch (self.pickerViewStyle) {
		case IQAKPickerViewStyleFlat: {
			[self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0]
										atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
												animated:animated];
			break;
		}
		case IQAKPickerViewStyle3D: {
			[self.collectionView setContentOffset:CGPointMake([self offsetForItem:item], self.collectionView.contentOffset.y)
										 animated:animated];
			break;
		}
		default: break;
	}
}

- (void)selectItem:(NSUInteger)item animated:(BOOL)animated
{
	[self selectItem:item animated:animated notifySelection:YES];
}

- (void)selectItem:(NSUInteger)item animated:(BOOL)animated notifySelection:(BOOL)notifySelection
{
	[self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0]
									  animated:animated
								scrollPosition:UICollectionViewScrollPositionNone];
	[self scrollToItem:item animated:animated];

	self.selectedItem = item;

	if (notifySelection &&
		[self.delegate respondsToSelector:@selector(pickerView:didSelectItem:)])
		[self.delegate pickerView:self didSelectItem:item];
}

- (void)didEndScrolling
{
	switch (self.pickerViewStyle) {
		case IQAKPickerViewStyleFlat: {
			CGPoint center = [self convertPoint:self.collectionView.center toView:self.collectionView];
			NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:center];
			[self selectItem:indexPath.item animated:YES];
			break;
		}
		case IQAKPickerViewStyle3D: {
			if ([self.dataSource numberOfItemsInPickerView:self]) {
				for (NSUInteger i = 0; i < [self collectionView:self.collectionView numberOfItemsInSection:0]; i++) {
					NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
					IQAKCollectionViewCell *cell = (IQAKCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
					if (cell && [self offsetForItem:i] + cell.bounds.size.width / 2 > self.collectionView.contentOffset.x) {
						[self selectItem:i animated:YES];
						break;
					}
				}
			}
			break;
		}
		default: break;
	}
}

#pragma mark -

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return ([self.dataSource numberOfItemsInPickerView:self] > 0);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return [self.dataSource numberOfItemsInPickerView:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	IQAKCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([IQAKCollectionViewCell class])
																		   forIndexPath:indexPath];

	if ([self.dataSource respondsToSelector:@selector(pickerView:titleForItem:)]) {
		NSString *title = [self.dataSource pickerView:self titleForItem:indexPath.item];
		cell.label.text = title;
		cell.font = self.font;
		cell.highlightedFont = self.highlightedFont;
        cell.textColor = self.textColor;
        cell.highlightedTextColor = self.highlightedTextColor;
        
		cell.label.bounds = (CGRect){CGPointZero, [self sizeForString:title]};
		if ([self.delegate respondsToSelector:@selector(pickerView:marginForItem:)]) {
			CGSize margin = [self.delegate pickerView:self marginForItem:indexPath.item];
			cell.label.frame = CGRectInset(cell.label.frame, -margin.width, -margin.height);
		}
		if ([self.delegate respondsToSelector:@selector(pickerView:configureLabel:forItem:)]) {
			[self.delegate pickerView:self configureLabel:cell.label forItem:indexPath.item];
		}
	}
    
	cell.selected = (indexPath.item == self.selectedItem);

	return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	CGSize size = CGSizeMake(self.interitemSpacing, collectionView.bounds.size.height);
	if ([self.dataSource respondsToSelector:@selector(pickerView:titleForItem:)]) {
		NSString *title = [self.dataSource pickerView:self titleForItem:indexPath.item];
		size.width += [self sizeForString:title].width;
		if ([self.delegate respondsToSelector:@selector(pickerView:marginForItem:)]) {
			CGSize margin = [self.delegate pickerView:self marginForItem:indexPath.item];
			size.width += margin.width * 2;
		}
	}
    
	return size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
	return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
	return 0.0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
	NSInteger number = [self collectionView:collectionView numberOfItemsInSection:section];
	NSIndexPath *firstIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
	CGSize firstSize = [self collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:firstIndexPath];
	NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:number - 1 inSection:section];
	CGSize lastSize = [self collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:lastIndexPath];
	return UIEdgeInsetsMake(0, (collectionView.bounds.size.width - firstSize.width) / 2,
							0, (collectionView.bounds.size.width - lastSize.width) / 2);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	[self selectItem:indexPath.item animated:YES notifySelection:YES];
}

#pragma mark -

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)])
		[self.delegate scrollViewDidEndDecelerating:scrollView];

	if (!scrollView.isTracking) [self didEndScrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)])
		[self.delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];

	if (!decelerate) [self didEndScrolling];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)])
		[self.delegate scrollViewDidScroll:scrollView];

	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue
					 forKey:kCATransactionDisableActions];
	self.collectionView.layer.mask.frame = self.collectionView.bounds;
	[CATransaction commit];
}

#pragma mark -

- (IQAKPickerViewStyle)pickerViewStyleForCollectionViewLayout:(IQAKCollectionViewLayout *)layout
{
	return self.pickerViewStyle;
}

@end

@implementation IQAKCollectionViewCell

- (void)initialize
{
	self.layer.doubleSided = NO;
	self.label = [[UILabel alloc] initWithFrame:self.contentView.bounds];
	self.label.backgroundColor = [UIColor clearColor];
	self.label.textAlignment = NSTextAlignmentCenter;
	self.label.numberOfLines = 1;
	self.label.lineBreakMode = NSLineBreakByTruncatingTail;
	self.label.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
	self.label.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin |
								   UIViewAutoresizingFlexibleLeftMargin |
								   UIViewAutoresizingFlexibleBottomMargin |
								   UIViewAutoresizingFlexibleRightMargin);
	[self.contentView addSubview:self.label];
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self initialize];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self initialize];
	}
	return self;
}

- (void)setSelected:(BOOL)selected
{
	[super setSelected:selected];

//	CATransition *transition = [CATransition animation];
//	[transition setType:kCATransitionFade];
//	[transition setDuration:0.15];
//	[self.label.layer addAnimation:transition forKey:nil];
	self.label.font = selected ? self.highlightedFont : self.font;
    self.label.textColor = selected ? self.highlightedTextColor : self.textColor;
}

@end

@interface IQAKCollectionViewLayout ()
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat midX;
@property (nonatomic, assign) CGFloat maxAngle;
@end

@implementation IQAKCollectionViewLayout

- (id)init
{
	self = [super init];
	if (self) {
		self.sectionInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
		self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
		self.minimumLineSpacing = 0.0;
	}
	return self;
}

- (void)prepareLayout
{
	CGRect visibleRect = (CGRect){self.collectionView.contentOffset, self.collectionView.bounds.size};
	self.midX = CGRectGetMidX(visibleRect);
	self.width = CGRectGetWidth(visibleRect) / 2;
	self.maxAngle = M_PI_2;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
	return YES;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewLayoutAttributes *attributes = [[super layoutAttributesForItemAtIndexPath:indexPath] copy];
	switch ([self.delegate pickerViewStyleForCollectionViewLayout:self]) {
		case IQAKPickerViewStyleFlat: {
			return attributes; break;
		}
		case IQAKPickerViewStyle3D: {
			CGFloat distance = CGRectGetMidX(attributes.frame) - self.midX;
			CGFloat currentAngle = self.maxAngle * distance / self.width / M_PI_2;
			CATransform3D transform = CATransform3DIdentity;
			transform = CATransform3DTranslate(transform, -distance, 0, -self.width);
			transform = CATransform3DRotate(transform, currentAngle, 0, 1, 0);
			transform = CATransform3DTranslate(transform, 0, 0, self.width);
			attributes.transform3D = transform;
			attributes.alpha = (ABS(currentAngle) < self.maxAngle);
			return attributes; break;
		}
		default: return nil; break;
	}
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
	switch ([self.delegate pickerViewStyleForCollectionViewLayout:self]) {
		case IQAKPickerViewStyleFlat: {
			return [super layoutAttributesForElementsInRect:rect];
			break;
		}
		case IQAKPickerViewStyle3D: {
			NSMutableArray<UICollectionViewLayoutAttributes*> *attributes = [NSMutableArray array];
			if ([self.collectionView numberOfSections]) {
				for (NSInteger i = 0; i < [self.collectionView numberOfItemsInSection:0]; i++) {
					NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
					[attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
				}
			}
			return attributes;
			break;
		}
		default: return nil; break;
	}
}

@end

@implementation IQAKPickerViewDelegateIntercepter

- (id)forwardingTargetForSelector:(SEL)aSelector
{
	if ([self.pickerView respondsToSelector:aSelector]) return self.pickerView;
	if ([self.delegate respondsToSelector:aSelector]) return self.delegate;
	return [super forwardingTargetForSelector:aSelector];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
	if ([self.pickerView respondsToSelector:aSelector]) return YES;
	if ([self.delegate respondsToSelector:aSelector]) return YES;
	return [super respondsToSelector:aSelector];
}

@end
