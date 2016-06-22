//
//  MOVerticalCycleView.m
//  泡房
//
//  Created by 馍馍帝😈 on 15/5/4.
//  Copyright (c) 2015年 馍馍帝. All rights reserved.
//

#import "MOVerticalCycleView.h"

@implementation MOVerticalCycleView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        //初始化滚动视图
        self.scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        //设置滚动视图滚动范围
        self.scrollView.contentSize = CGSizeMake(0, self.frame.size.height*3);
        //设置滚动视图代理
        self.scrollView.delegate = self;
        //设置滚动视图的边界
        self.scrollView.bounces = NO;
        //设置滚动视图的滚动条显示
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.pagingEnabled = YES;
        //设置滚动视图初始偏移量
        self.scrollView.contentOffset = CGPointMake(0, self.frame.size.height);
        //给滚动视图添加点击事件
        [self.scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)]];
        //将滚动视图添加到父视图
        [self addSubview:self.scrollView];
        //设置初始的页数
        self.currentPage = 0;
        self.placeHolderImg = [[UIImageView alloc]initWithFrame:self.bounds];
        [self addSubview:self.placeHolderImg];
        if (self.shouldAutoScroll) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(autoScroll) userInfo:nil repeats:YES];
        }
    }
    return self;
}

-(void)autoScroll
{
    self.scrollView.contentOffset = CGPointMake(0, self.bounds.size.height*2);
}

-(void)setDatasource:(id<MOVerticalCycleViewDatasource>)datasource
{
    _datasource = datasource;
    [self reload];
}

-(void)reload
{
    self.totalPage = [self.datasource numberOfPageWithView:self];
    if (self.totalPage <= 1) {
        self.scrollView.scrollEnabled = NO;
    }
    else
    {
        self.scrollView.scrollEnabled = YES;
    }
    if (self.totalPage == 0) {
        return;
    }
    [self loadData];
}

- (void)loadData
{
    NSArray *subViews = [self.scrollView subviews];
    if([subViews count] > 0){
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    if (self.totalPage >=2) {
        self.arrow1 = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width/2-IPhoneAll(18, 18), self.frame.size.height-IPhoneAll(9, 9), IPhoneAll(18, 18), IPhoneAll(9, 9))];
        self.arrow1.image = [UIImage imageNamed:@"arrow"];
        [self addSubview:self.arrow1];
        self.arrow2 = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width/2-IPhoneAll(18, 18), 0, IPhoneAll(18, 18), IPhoneAll(9, 9))];
        self.arrow2 .image = [UIImage imageNamed:@"arrow"];
        self.arrow2 .transform = CGAffineTransformMakeRotation(M_PI/180*180);
        [self addSubview:self.arrow2 ];
    }
    [self showImagesWithCurpage:self.currentPage];
    for (int i = 0; i < 3; i++) {
        UIView *tempView = [self.curViews objectAtIndex:i];
        tempView.frame = CGRectOffset(tempView.frame, 0, tempView.frame.size.height * i);
        [self.scrollView addSubview:tempView];
    }
    [self.scrollView setContentOffset:CGPointMake(0, self.scrollView.frame.size.height)];
    self.arrow1.hidden = NO;
    self.arrow2.hidden = NO;
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
        [self.curViews addObject:[self.datasource pageAtCView:self AtIndex:pre]];
        [self.curViews addObject:[self.datasource pageAtCView:self AtIndex:page]];
        [self.curViews addObject:[self.datasource pageAtCView:self AtIndex:next]];
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
            v.frame = CGRectOffset(v.frame, 0,v.frame.size.height * i);
            [self.scrollView addSubview:v];
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float y = scrollView.contentOffset.y;
    if(floor(y) >= (floor(2*self.frame.size.height))) {
        self.currentPage = [self validPageValue:self.currentPage+1];
        [self loadData];
    }
    if(y <= 0) {
        self.currentPage = [self validPageValue:self.currentPage-1];
        [self loadData];
    }
}


-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    self.arrow1.hidden = YES;
    self.arrow2.hidden = YES;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.scrollView setContentOffset:CGPointMake(0, self.scrollView.frame.size.height) animated:YES];
    self.arrow1.hidden = NO;
    self.arrow2.hidden = NO;
}

-(void)tap:(UITapGestureRecognizer*)tap
{
    if ([self.delegate respondsToSelector:@selector(didSelectImage:AtIndex:)]) {
        [self.delegate didSelectImage:self AtIndex:self.currentPage];
    }
}

@end
