//
//  UICollectionViewWaterfallLayout.m
//  Test
//
//  Created by 王杰 on 2017/12/20.
//  Copyright © 2017年 王杰. All rights reserved.
//

#import "WJWaterfallLayout.h"

NSString * const WJWaterfallElementKindSectionHeader = @"WJWaterfallElementKindSectionHeader";
NSString * const WJWaterfallElementKindSectionFooter = @"WJWaterfallElementKindSectionFooter";;

@interface WJWaterfallLayout()

@property (nonatomic, strong) NSMutableArray *attrsArray;//保存所有的UICollectionViewLayoutAttributes

@property (nonatomic, strong) NSMutableArray *rankHeights;//缓存每一列的当前高度

@property (nonatomic) CGFloat contentHeight;//内容高度

@property (nonatomic) CGFloat sectionOriginY;//每个section的起点坐标

@end

@implementation WJWaterfallLayout

- (NSMutableArray *)attrsArray {
    if (!_attrsArray) {
        _attrsArray = [NSMutableArray array];
    }
    return _attrsArray;
}

- (NSMutableArray *)rankHeights {
    if (!_rankHeights) {
        _rankHeights = [NSMutableArray array];
    }
    return _rankHeights;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    self.contentHeight = 0;
    
    [self.rankHeights removeAllObjects];
    for (int i = 0; i < [self.delegate maxRankCountWithLayout:self]; i++) {//每一列高度默认为0
        [self.rankHeights addObject:@(0)];
    }
    
    [self.attrsArray removeAllObjects];
    for (int section = 0; section < self.collectionView.numberOfSections; section++) {
        //head
        NSIndexPath *supplementaryPath = [NSIndexPath indexPathForItem:0 inSection:section];
        UICollectionViewLayoutAttributes *headerAttributes = [self layoutAttributesForSupplementaryViewOfKind:WJWaterfallElementKindSectionHeader atIndexPath:supplementaryPath];
        if (headerAttributes) [self.attrsArray addObject:headerAttributes];
        
        //cell
        NSInteger count = [self.collectionView numberOfItemsInSection:section];
        for (int i = 0; i < count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:section];
            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
            if (attributes) [self.attrsArray addObject:attributes];
        }
        
        //footer
        UICollectionViewLayoutAttributes *footerAttributes = [self layoutAttributesForSupplementaryViewOfKind:WJWaterfallElementKindSectionFooter atIndexPath:supplementaryPath];
        if (footerAttributes) [self.attrsArray addObject:footerAttributes];
    }
}

//返回collection高度
- (CGSize)collectionViewContentSize {
    return CGSizeMake(self.collectionView.frame.size.width, self.contentHeight);
}

- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.attrsArray;
}

//cell生成
- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    CGFloat collectionViewWidth = self.collectionView.frame.size.width;
    CGFloat rankMargin = [self rankMarginAtSection:indexPath.section];//列边距
    CGFloat rowMargin = [self rowMarginAtSection:indexPath.section];//行边距
    NSInteger rankCount = [self rankCountAtSection:indexPath.section];//当前section列数
    UIEdgeInsets edgeInsets = [self sectionEdgeInsetsAtSection:indexPath.section];//当前section偏移量
    
    CGFloat w = ceilf((collectionViewWidth - edgeInsets.left - edgeInsets.right - (rankCount - 1) * rankMargin) / rankCount);
    CGFloat h = ceilf([self.delegate layout:self heightForItemAtIndexPath:indexPath itemWidth:w]);
    //一个section开始位置由当前最大高度开始 将self.rankHeights数组里面的所有值赋值为最大高度那个 也就是self.contentHeight
    if (indexPath.row == 0) {
        for (int i = 0 ; i < self.rankHeights.count; i++) {
            self.rankHeights[i] = @(self.contentHeight + edgeInsets.top);
        }
        self.sectionOriginY = [self.rankHeights.firstObject doubleValue];//记录每个section起点坐标
    }
    
    //取最小那一行的高度赋值
    NSInteger rank = 0;
    CGFloat minRankHeight = [self.rankHeights[rank] doubleValue];
    for (int i = 0 ; i < self.rankHeights.count; i++) {
        CGFloat rankHeight = [self.rankHeights[i] doubleValue];
        if (minRankHeight > rankHeight) {
            minRankHeight = rankHeight;
            rank = i;
        }
    }
    
    CGFloat x = edgeInsets.left + rank * (w + rankMargin);
    CGFloat y = minRankHeight;
    if (y != self.sectionOriginY) {
        y += rowMargin;
    }
    
    attributes.frame = CGRectMake(x, y, w, h);
    CGFloat currentHeight = CGRectGetMaxY(attributes.frame);
    
    //section中最后一个 添加下偏移量
    if (indexPath.row == [self.collectionView numberOfItemsInSection:indexPath.section] - 1) {
        currentHeight += edgeInsets.bottom;
    }
    
    //如果最大列数不是1并且当前section的列数为1的时候 需要为self.rankHeights的所有值赋值 保持一致
    if (rankCount == 1) {
        for (int i = 0 ; i < self.rankHeights.count; i++) {
            self.rankHeights[i] = @(currentHeight);
        }
    } else {
        self.rankHeights[rank] = @(currentHeight); //为高度为最小那一行赋值新高度
    }
    
    //标记最高那一行
    if (self.contentHeight < currentHeight) {
        self.contentHeight = currentHeight;
    }
    return attributes;
}

- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    if (elementKind == WJWaterfallElementKindSectionHeader) {
        if ([self.delegate respondsToSelector:@selector(layout:referenceHeightForHeaderInSection:)]) {
            height = [self.delegate layout:self referenceHeightForHeaderInSection:indexPath.section];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(layout:referenceHeightForFooterInSection:)]) {
            height = [self.delegate layout:self referenceHeightForFooterInSection:indexPath.section];
        }
    }
    if (height == 0) return nil;
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];
    
    CGFloat maxRankHeight = [self.rankHeights.firstObject doubleValue];
    for (int i = 0 ; i < self.rankHeights.count; i++) {
        CGFloat rankHeight = [self.rankHeights[i] doubleValue];
        if (maxRankHeight < rankHeight) {
            maxRankHeight = rankHeight;
        }
    }
    attributes.frame = CGRectMake(0, maxRankHeight, self.collectionView.frame.size.width, height);
    CGFloat currentHeight = maxRankHeight + height;
    for (int i = 0 ; i < self.rankHeights.count; i++) {
        self.rankHeights[i] = @(currentHeight);
    }
    
    if (self.contentHeight < currentHeight) {
        self.contentHeight = currentHeight;
    }
    return attributes;
}

- (NSInteger)rankCountAtSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(layout:rankCountForSectionAtIndex:)]) {
        return [self.delegate layout:self rankCountForSectionAtIndex:section];
    } else {
        return 1;
    }
}

- (UIEdgeInsets)sectionEdgeInsetsAtSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(layout:insetForSectionAtIndex:)]) {
        return [self.delegate layout:self insetForSectionAtIndex:section];
    } else {
        return UIEdgeInsetsZero;
    }
}

- (CGFloat)rankMarginAtSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(layout:rankMarginForSectionAtIndex:)]) {
        return [self.delegate layout:self rankMarginForSectionAtIndex:section];
    } else {
        return 10;
    }
}

- (CGFloat)rowMarginAtSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(layout:rowMarginForSectionAtIndex:)]) {
        return [self.delegate layout:self rowMarginForSectionAtIndex:section];
    } else {
        return 10;
    }
}

@end
