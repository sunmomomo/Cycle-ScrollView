//
//  MOVerticalCycleView.h
//  泡房
//
//  Created by 馍馍帝😈 on 15/5/4.
//  Copyright (c) 2015年 馍馍帝. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MOVerticalCycleViewDelegate;
@protocol MOVerticalCycleViewDatasource;

@interface MOVerticalCycleView : UIView<UIScrollViewDelegate>
@property(nonatomic,assign)NSInteger totalPage;
@property(nonatomic,strong)UIScrollView *scrollView;
@property(nonatomic,strong)NSMutableArray *curViews;
@property(nonatomic,assign)NSInteger currentPage;
@property(nonatomic,assign)BOOL shouldAutoScroll;
@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,strong)UIImageView *arrow1;
@property(nonatomic,strong)UIImageView *arrow2;
@property(nonatomic,strong)UIImageView *placeHolderImg;
@property(nonatomic,assign)id<MOVerticalCycleViewDelegate> delegate;
@property(nonatomic,assign,setter=setDatasource:)id<MOVerticalCycleViewDatasource> datasource;
-(void)reload;

@end
@protocol MOVerticalCycleViewDelegate <NSObject>

-(void)didSelectImage:(MOVerticalCycleView*)vcView AtIndex:(NSInteger)index;

@end

@protocol MOVerticalCycleViewDatasource <NSObject>

@required
-(NSInteger)numberOfPageWithView:(MOVerticalCycleView*)vcView;
-(UIView *)pageAtCView:(MOVerticalCycleView*)vcView AtIndex:(NSInteger)index;
@end