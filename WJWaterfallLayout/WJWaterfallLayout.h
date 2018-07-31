//
//  UICollectionViewWaterfallLayout.h
//  Test
//
//  Created by 王杰 on 2017/12/20.
//  Copyright © 2017年 王杰. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WJWaterfallLayout;

extern NSString * const WJWaterfallElementKindSectionHeader;
extern NSString * const WJWaterfallElementKindSectionFooter;

@protocol WJWaterfallLayoutDelegate<NSObject>

@required
//section需要的最大列数
- (NSInteger)maxRankCountWithLayout:(WJWaterfallLayout *)collectionViewLayout;

//cell高度
- (CGFloat)layout:(WJWaterfallLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath itemWidth:(CGFloat)width;

@optional
- (NSInteger)layout:(WJWaterfallLayout *)collectionViewLayout rankCountForSectionAtIndex:(NSInteger)section;//当前section需要的列数
- (CGFloat)layout:(WJWaterfallLayout *)collectionViewLayout rankMarginForSectionAtIndex:(NSInteger)section;//列间距
- (CGFloat)layout:(WJWaterfallLayout *)collectionViewLayout rowMarginForSectionAtIndex:(NSInteger)section;//行间距
- (CGFloat)layout:(WJWaterfallLayout *)collectionViewLayout referenceHeightForHeaderInSection:(NSInteger)section;//header高度
- (CGFloat)layout:(WJWaterfallLayout *)collectionViewLayout referenceHeightForFooterInSection:(NSInteger)section;//footer高度
- (UIEdgeInsets)layout:(WJWaterfallLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;//section偏移量

@end

@interface WJWaterfallLayout : UICollectionViewLayout

@property (nonatomic, weak) id<WJWaterfallLayoutDelegate> delegate;

@end
