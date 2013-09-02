//
//  ViewController.m
//  Dwarf
//
//  Created by Alexander Grebenyuk on 7/14/13.
//  Copyright (c) 2013 Alexander Grebenyuk. All rights reserved.
//

#import "SDFImageFetchingTestViewController.h"
#import "DFSFlickrPhoto.h"
#import "DFSFlickrRecentPhotos.h"
#import "DFImageView.h"


static NSString *_kCellReusableIdentifier = @"reuse_id";


@interface SDFImageFetchingTestViewController () <UICollectionViewDataSource>

@end


@implementation SDFImageFetchingTestViewController {
    // Data
    NSArray *_photos;
    
    // Views
    UIActivityIndicatorView *_activityIndicatorView;
    UICollectionView *_collectionView;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _photos = [NSArray new];
    }
    return self;
}


- (void)loadView {
    [super loadView];
    
    _activityIndicatorView = ({
        UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        view.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2.0,
                                  CGRectGetHeight(self.view.bounds) / 2.0);
        view;
    });
    
    _collectionView = ({
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.itemSize = CGSizeMake(75.f, 75.f);
        layout.sectionInset = UIEdgeInsetsMake(4.f, 4.f, 4.f, 4.f);
        layout.minimumInteritemSpacing = 4.f;
        layout.minimumLineSpacing = 4.f;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        collectionView.backgroundColor = [UIColor blackColor];
        
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:_kCellReusableIdentifier];
        collectionView.dataSource = self;
        collectionView;
    });
    
    
    [self.view addSubview:_collectionView];
    [self.view addSubview:_activityIndicatorView];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadFlickrPhotos];
}

#pragma mark - Loading Data

- (void)loadFlickrPhotos {
    [_activityIndicatorView startAnimating];
    
    DFSFlickrRecentPhotos *recentPhotos = [DFSFlickrRecentPhotos new];
    [recentPhotos loadPhotosWithPageCount:1 completion:^{
        _photos = recentPhotos.photos;
        [_activityIndicatorView stopAnimating];
        [_collectionView reloadData];
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _photos.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_kCellReusableIdentifier forIndexPath:indexPath];
    
    DFImageView *imageView = (DFImageView *)[cell viewWithTag:1];
    if (imageView == nil) {
        cell.backgroundColor = [UIColor darkGrayColor];
        imageView = [[DFImageView alloc] initWithFrame:cell.bounds];
        imageView.tag = 1;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [cell addSubview:imageView];
    }
    
    [imageView setImage:nil];
    DFSFlickrPhoto *photo = _photos[indexPath.row];
    [imageView setImageWithURL:photo.photoURL];
    
    return cell;
}

@end
