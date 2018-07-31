//
//  ViewController.m
//  WJWaterfallLayout
//
//  Created by 王杰 on 2018/7/31.
//  Copyright © 2018年 王杰. All rights reserved.
//

#import "ViewController.h"
#import "WJWaterfallLayout.h"

@interface ViewController ()<WJWaterfallLayoutDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.collectionView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark WJWaterfallLayoutDelegate

//section需要的最大列数
- (NSInteger)maxRankCountWithLayout:(WJWaterfallLayout *)collectionViewLayout {
    return 2;
}

//当前section需要的列数
- (NSInteger)layout:(WJWaterfallLayout *)collectionViewLayout rankCountForSectionAtIndex:(NSInteger)section {
    return 2;
}

//cell高度
- (CGFloat)layout:(WJWaterfallLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath itemWidth:(CGFloat)width {
    return 150 + arc4random() % 100;
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 100;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
    cell.backgroundColor = [UIColor yellowColor];
    return cell;
}


#pragma mark setter and getter

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        WJWaterfallLayout *layout = [[WJWaterfallLayout alloc] init];
        layout.delegate = self;
        _collectionView = [[UICollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
        
    }
    return _collectionView;
}

@end
