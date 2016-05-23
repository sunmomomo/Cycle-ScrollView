//
//  MOCustomPageContol.m
//  泡房
//
//  Created by 馍馍帝😈 on 15/5/6.
//  Copyright (c) 2015年 馍馍帝. All rights reserved.
//

#import "MOCustomPageContol.h"

@implementation MOCustomPageContol
 - (void)setCurrentPage:(NSInteger)page
{
    [super setCurrentPage:page];
    for (NSUInteger subviewIndex = 0; subviewIndex < [self.subviews count]; subviewIndex++) {
        UIImageView* subview = [self.subviews objectAtIndex:subviewIndex];
        CGSize size;
        size.height = 11;
        size.width = 11;
        CGPoint point = subview.frame.origin;
        point.x = point.x/3;
        [subview setFrame:CGRectMake(point.x, point.y, size.width/2,size.height/2)];
        subview.layer.cornerRadius = 2.75;
        if (subviewIndex == page) {
            [subview setBackgroundColor:self.currentPageIndicatorTintColor];
        } else {
            [subview setBackgroundColor:self.pageIndicatorTintColor];
        }
    }
}
@end
