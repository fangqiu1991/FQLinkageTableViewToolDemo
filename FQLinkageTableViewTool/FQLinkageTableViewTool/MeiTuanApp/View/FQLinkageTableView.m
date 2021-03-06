//
//  FQLinkageTableView.m
//  FQLinkageTableViewTool
//
//  Created by mac on 2018/7/18.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "FQLinkageTableView.h"
#import "MTShopHeaderView.h"
#import "MTSectionHeader.h"
#import "FQGoodsIndexCell.h"

@interface FQLinkageTableView()<UITableViewDelegate,UITableViewDataSource>
{
    BOOL relate;
    BOOL topCanChange;//是否可以渐变
    CGFloat NavBarHeight;
    CGFloat headerHeight;
    CGFloat ChangedHeight;
    
    CGFloat leftWidth;
    CGFloat rightWidth;
    CGRect BOUNDS;
}
@property (nonatomic, strong) MTShopHeaderView * header;



@end

@implementation FQLinkageTableView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        [self installTableView];
    }
    return self;
}

- (MTShopHeaderView *)header{
    if (!_header) {
        _header = [[MTShopHeaderView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 120)];
        [self addSubview:_header];
    }
    return _header;
}

- (void)initData{
    relate = YES;
    NavBarHeight = 64.f;
    headerHeight = 152.f;
    ChangedHeight = headerHeight - NavBarHeight;
    _goodsList = [FQGoodsListModel new];
    BOUNDS = self.bounds;
    leftWidth = 80;
    rightWidth = BOUNDS.size.width - leftWidth;
    
}

- (void)reloadData{
    [_leftTbView reloadData];
    [_rightTbView reloadData];
    [self resetFrame];
}

- (void)resetFrame{
    if (_rightTbView.contentSize.height-_rightTbView.bounds.size.height>=ChangedHeight) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, self.bounds.size.height+ChangedHeight);
        _rightTbView.frame = CGRectMake(leftWidth, headerHeight, rightWidth, BOUNDS.size.height-headerHeight+ChangedHeight);
        topCanChange = YES;
    }else{
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, self.bounds.size.height);
        _rightTbView.frame = CGRectMake(leftWidth, headerHeight, rightWidth, BOUNDS.size.height-headerHeight);
        topCanChange = NO;
    }
    _leftTbView.frame = CGRectMake(0, headerHeight, leftWidth, BOUNDS.size.height-headerHeight);
    self.header.frame = CGRectMake(0, 0, BOUNDS.size.width, headerHeight);
}

- (void)installTableView{
    //haeder
    self.header.frame = CGRectMake(0, 0, BOUNDS.size.width, headerHeight);
    
    _leftTbView = [[UITableView alloc]initWithFrame:CGRectMake(0, headerHeight, leftWidth, BOUNDS.size.height-headerHeight+ChangedHeight) style:UITableViewStylePlain];
    _leftTbView.delegate = self;
    _leftTbView.dataSource = self;
    _leftTbView.showsVerticalScrollIndicator = NO;
    _leftTbView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _rightTbView = [[UITableView alloc]initWithFrame:CGRectMake(leftWidth, headerHeight, rightWidth, BOUNDS.size.height-headerHeight+ChangedHeight) style:UITableViewStyleGrouped];
    _rightTbView.delegate = self;
    _rightTbView.dataSource = self;
    [self addSubview:_leftTbView];
    [self addSubview:_rightTbView];
}

#pragma mark - tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView==_leftTbView) {
        return 1;
    }
    return self.goodsList.sectionNumber;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView==_leftTbView) {
        return self.goodsList.sectionNumber;
    }
    if (section<self.goodsList.goodsGroups.count) {
        FQGoodsGroupModel * goodsGroup = self.goodsList.goodsGroups[section];
        return [goodsGroup.goodsList count];
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == _rightTbView) {
        return @"商品列表";
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView==_leftTbView) {
        FQGoodsIndexCell * cell = [tableView dequeueReusableCellWithIdentifier:@"FQGoodsIndexCell"];
        if (cell==nil) {
            cell = [[FQGoodsIndexCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FQGoodsIndexCell"];
        }
        if (indexPath.row<self.goodsList.goodsGroups.count) {
            FQGoodsGroupModel * goodsGroup = self.goodsList.goodsGroups[indexPath.row];
            cell.goodsGroup = goodsGroup;
        }
        return cell;
    }
    FQGoodsListCell * cell = [tableView dequeueReusableCellWithIdentifier:@"FQGoodsListCell"];
    if (cell==nil) {
        cell = [[FQGoodsListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FQGoodsListCell"];
    }
    if (indexPath.section<self.goodsList.goodsGroups.count) {
        FQGoodsGroupModel * goodsGroup = self.goodsList.goodsGroups[indexPath.section];
        if (indexPath.row<goodsGroup.goodsList.count) {
            FQGoodsModel * goods = goodsGroup.goodsList[indexPath.row];
            cell.goods = goods;
            cell.delegate = _target;
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView==_leftTbView) {
        return 50.0f;
    }
    return 115.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView==_rightTbView) {
        //        return 30.f;
        return 30.f;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (tableView==_leftTbView) {
        return 0;
    }
    return CGFLOAT_MIN;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    if (tableView==_rightTbView) {
//        GNRSectionHeader * header = (GNRSectionHeader *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@"GNRSectionHeader"];
//        if (!header) {
//            header = (GNRSectionHeader *)[[[NSBundle mainBundle]loadNibNamed:@"GNRSectionHeader" owner:self options:nil]firstObject];
//        }
//        if (section<self.goodsList.goodsGroups.count) {
//            GNRGoodsGroup * goodsGroup = self.goodsList.goodsGroups[section];
//            header.titL.text = goodsGroup.classesName;
//        }
//        return header;
//    }
//    return nil;
//}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    if (relate) {
        NSInteger firstCellSection = [[[tableView indexPathsForVisibleRows] firstObject]section];
        if (tableView==_rightTbView) {//坐标index滚动到中间
            [_leftTbView selectRowAtIndexPath:[NSIndexPath indexPathForItem:firstCellSection inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section{
    if (relate) {
        NSInteger firstCellSection = [[[tableView indexPathsForVisibleRows] firstObject]section];
        if (tableView==_rightTbView) {
            [_leftTbView selectRowAtIndexPath:[NSIndexPath indexPathForItem:firstCellSection inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView==_leftTbView) {
        relate = NO;
        [_leftTbView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];//左边滚动到中间
        [_rightTbView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:indexPath.row] atScrollPosition:UITableViewScrollPositionTop animated:YES];//右边相应section滚动到顶部
    }
    if (tableView == _rightTbView) {
        [_rightTbView deselectRowAtIndexPath:indexPath animated:NO];
    }
    
}

#pragma mark -
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    relate = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == _rightTbView) {
        if (topCanChange) {
            CGFloat y= scrollView.contentOffset.y;
            if ([_delegate respondsToSelector:@selector(scrollViewDidScrollForPositionY:)]) {
                [_delegate scrollViewDidScrollForPositionY:y];
            }
            CGRect toFrame = CGRectZero;
            CGRect leftToFrame = CGRectZero;
            if (y<0) {
                toFrame = CGRectMake(0, 0, BOUNDS.size.width, self.frame.size.height);
                leftToFrame = CGRectMake(0, headerHeight, leftWidth, BOUNDS.size.height-headerHeight);
            }
            else if (y<=NavBarHeight&&y>=0) {
                toFrame = CGRectMake(0, -ChangedHeight*y/NavBarHeight, BOUNDS.size.width, self.frame.size.height);
                leftToFrame = CGRectMake(0, headerHeight, leftWidth, BOUNDS.size.height-headerHeight+ChangedHeight*y/NavBarHeight);
            }
            else{
                toFrame = CGRectMake(0, -ChangedHeight, BOUNDS.size.width, self.frame.size.height);
                leftToFrame = CGRectMake(0, headerHeight, leftWidth, BOUNDS.size.height-NavBarHeight);
            }
            leftToFrame = leftToFrame;
            [UIView animateWithDuration:0.2 animations:^{
                self.frame = toFrame;
                _leftTbView.frame = leftToFrame;
            } completion:^(BOOL finished) {
                
            }];
            if (scrollView.contentOffset.y == 0) {//这里解决点击状态栏回到顶部 左边不滚动的问题
                relate = YES;
                [_rightTbView reloadData];
            }
        }else{
            if (self.frame.origin.y!=0) {
                self.frame = CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height);
                _leftTbView.frame = CGRectMake(0, headerHeight, leftWidth, BOUNDS.size.height-headerHeight);
            }
        }
    }
}


@end
