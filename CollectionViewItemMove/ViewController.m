//
//  ViewController.m
//  CollectionViewItemMove
//
//  Created by 磊 高 on 16/6/29.
//  Copyright © 2016年 磊 高. All rights reserved.
//

#import "ViewController.h"
#import "CollectionViewCell.h"
@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *colorArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"主题";
    self.view.backgroundColor = [UIColor whiteColor];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(self.view.bounds.size.width/2 - 10, 100);
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10 ;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([CollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([CollectionViewCell class])];
    [self.view addSubview:_collectionView];
    
    _colorArray = [NSMutableArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10", nil];
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CollectionViewCell class]) forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:random()%255/255.0 green:random()%255/255.0 blue:random()%255/255.0 alpha:1];
    cell.titleLabel.text = self.colorArray[indexPath.row];
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
    [cell addGestureRecognizer:longPress];
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.colorArray.count;
}

- (void)onLongPress:(id)sender
{
    UILongPressGestureRecognizer* longPress = (UILongPressGestureRecognizer*)sender;
    UIGestureRecognizerState state = longPress.state;
    
    CGPoint location = [longPress locationInView:_collectionView];
    NSIndexPath* indexPath = [_collectionView indexPathForItemAtPoint:location];
    static UIView* snapshot = nil;             ///< A snapshot of the row user is moving.
    static NSIndexPath* sourceIndexPath = nil; ///< Initial index path, where gesture begins.
    static NSIndexPath* originIndexPath = nil;
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            if (indexPath) {
                sourceIndexPath = indexPath;
                UICollectionViewCell* cell = [_collectionView cellForItemAtIndexPath:indexPath];
                // Take a snapshot of the selected row using helper method.
                snapshot = [self takeSnapshotForView:cell];
                // Add the snapshot as subview, centered at cell's center...
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [_collectionView addSubview:snapshot];
                [UIView animateWithDuration:0.25
                                 animations:^{
                                     // Offset for gesture location.
                                     center.y = location.y;
                                     snapshot.center = center;
                                     snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                                     snapshot.alpha = 0.98;
                                     cell.alpha = 0.0f;
                                 }
                                 completion:^(BOOL finished) {
                                     cell.hidden = YES;
                                 }];
            }
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            CGPoint center = snapshot.center;
            center.x = location.x;
            center.y = location.y;
            snapshot.center = center;
            // Is destination valid and is it different from source?
            if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
                // ... move the rows.
                [_collectionView moveItemAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                [self.colorArray exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:indexPath.row];
                // ... and update source so it is in sync with UI changes.
                if (originIndexPath == nil) {
                    originIndexPath = [sourceIndexPath copy];
                }
                sourceIndexPath = indexPath;
            }
            break;
        }
            
        default: {
            // Clean up.
            UICollectionViewCell* cell = [_collectionView cellForItemAtIndexPath:sourceIndexPath];
            [UIView animateWithDuration:0.25
                             animations:^{
                                 snapshot.center = cell.center;
                                 snapshot.transform = CGAffineTransformIdentity;
                                 snapshot.alpha = 0.0;
                                 cell.alpha = 1.0f;
                             }
                             completion:^(BOOL finished) {
                                 cell.hidden = NO;
                                 [snapshot removeFromSuperview];
                                 snapshot = nil;
                             }];
            sourceIndexPath = nil;
            originIndexPath = nil;
            break;
        }
    }
}

- (UIView*)takeSnapshotForView:(UIView*)inputView
{
    UIView* snapshot = [inputView snapshotViewAfterScreenUpdates:YES];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    return snapshot;
}
@end
