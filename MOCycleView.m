//
//  MOCycleView.m
//
//  Created by 馍馍帝 on 15/3/23.
//  Copyright (c) 2015年 馍馍帝. All rights reserved.
//

#import "MOCycleView.h"

#define ScrollTimeGap 4.0

@interface MOCycleView ()

@property(nonatomic,assign)NSInteger totalPage;
@property(nonatomic,strong)UIScrollView *scrollView;
@property(nonatomic,strong)NSMutableArray *curViews;
@property(nonatomic,assign)NSInteger currentPage;
@property(nonatomic,strong)MOCustomPageContol *pageControl;

@end

@implementation MOCycleView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        //初始化滚动视图
        self.scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        //设置滚动视图滚动范围
        self.scrollView.contentSize = CGSizeMake(self.bounds.size.width*3, 0);
        //设置滚动视图代理
        self.scrollView.delegate = self;
        //设置滚动视图的边界
        self.scrollView.bounces = NO;
        //设置滚动视图的滚动条显示
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.pagingEnabled = YES;
        //设置滚动视图初始偏移量
        self.scrollView.contentOffset = CGPointMake(self.bounds.size.width, 0);
        //给滚动视图添加点击事件
        [self.scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)]];
        //将滚动视图添加到父视图
        [self addSubview:self.scrollView];
        //初始化pageControl
        self.pageControl = [[MOCustomPageContol alloc] init];
        //设置pageControl的用户交互
        self.pageControl.userInteractionEnabled = NO;
        //将pageControl加载到父视图
        [self addSubview:self.pageControl];
        //设置初始的页数
        self.currentPage = 0;
        self.placeHolderImg = [[UIImageView alloc]initWithFrame:self.bounds];
        [self addSubview:self.placeHolderImg];
    }
    return self;
}

-(void)autoScroll
{
    
    if (self.totalPage>1) {
        
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width*2, 0) animated:YES];
        
    }
    
}

-(void)setDatasource:(id<MOCycleViewDatasource>)datasource
{
    _datasource = datasource;
    [self reload];
}

-(void)reload
{
    self.totalPage = [self.datasource numberOfPageWithView:self];
    if (self.totalPage <= 1) {
        self.scrollView.scrollEnabled = NO;
        self.pageControl.hidden = YES;
    }
    else
    {
        self.pageControl.hidden = NO;
        self.scrollView.scrollEnabled = YES;
    }
    if (self.shouldAutoScroll) {
        if(self.timer)
        {
            [self.timer invalidate];
            self.timer = nil;
        }
        self.timer = [NSTimer scheduledTimerWithTimeInterval:ScrollTimeGap target:self selector:@selector(autoScroll) userInfo:nil repeats:YES];
    }
    
    if ([self.datasource respondsToSelector:@selector(setPageControlWithView:)]) {
        
        self.pageControl.frame = [self.datasource setPageControlWithView:self];
        self.pageControl.currentPageIndicatorTintColor = [self.datasource setPageControlColorWithView:self];
        self.pageControl.pageIndicatorTintColor = [self.datasource setPageControlBackColorWithView:self];
        self.pageControl.layer.cornerRadius = 6;
        self.pageControl.backgroundColor = RGBACOLOR(0, 0, 0, 0.5);
        if ([self.datasource respondsToSelector:@selector(setPageControlBackGroundColorWithView:)]) {
            
            self.pageControl.backgroundColor = [self.datasource setPageControlBackGroundColorWithView:self];
        }
        
    }
    
    if (self.totalPage == 0) {
        return;
    }
    _pageControl.numberOfPages = self.totalPage;
    [self loadData];
}

- (void)loadData
{
    self.pageControl.currentPage = self.currentPage;
    NSArray *subViews = [self.scrollView subviews];
    if([subViews count] > 0) {
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    [self showImagesWithCurpage:self.currentPage];
    for (int i = 0; i < self.curViews.count; i++) {
        UIView *tempView = [self.curViews objectAtIndex:i];
        // 保证 tempView 在 最中间
        CGFloat xx = self.frame.size.width * i + (self.frame.size.width - tempView.frame.size.width)/2.0;
        CGFloat yy = (self.frame.size.height - tempView.frame.size.height)/2.0;
        
        tempView.frame = CGRectMake(xx, yy, tempView.width, tempView.height);
        [self.scrollView addSubview:tempView];
    }
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width, 0)];
}

- (void)showImagesWithCurpage:(NSUInteger)page
{
    if (self.totalPage>=1) {
        NSUInteger pre = [self validPageValue:self.currentPage-1];
        NSUInteger next = [self validPageValue:self.currentPage+1];
        if (!self.curViews) {
            self.curViews = [[NSMutableArray alloc] init];
        }
        [self.curViews removeAllObjects];
        
        if (self.datasource) {
            
            [self.curViews addObjectYF:[self.datasource pageAtCView:self AtIndex:pre]];
            [self.curViews addObjectYF:[self.datasource pageAtCView:self AtIndex:page]];
            [self.curViews addObjectYF:[self.datasource pageAtCView:self AtIndex:next]];
        }
        
    }
}

- (NSUInteger)validPageValue:(NSInteger)value {
    
    if(value == -1) value = self.totalPage - 1;
    if(value == self.totalPage) value = 0;
    return value;
}



- (void)setView:(UIView *)view atIndex:(NSInteger)index
{
    if (index == self.currentPage) {
        [self.curViews replaceObjectAtIndex:1 withObject:view];
        for (int i = 0; i < 3; i++) {
            UIView *v = [self.curViews objectAtIndex:i];
            v.userInteractionEnabled = YES;
            v.frame = CGRectOffset(v.frame, v.frame.size.width * i,0);
            [self.scrollView addSubview:v];
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float x = scrollView.contentOffset.x;
    if(x >= (2*self.frame.size.width)) {
        self.currentPage = [self validPageValue:self.currentPage+1];
        [self loadData];
    }
    if(x <= 0) {
        self.currentPage = [self validPageValue:self.currentPage-1];
        [self loadData];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width, 0) animated:YES];
}

-(void)tap:(UITapGestureRecognizer*)tap
{
    if ([self.delegate respondsToSelector:@selector(didSelectImage:AtIndex:)]) {
        [self.delegate didSelectImage:self AtIndex:self.currentPage];
    }
}

@end
