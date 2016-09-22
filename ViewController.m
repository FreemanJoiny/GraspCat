//
//  ViewController.m
//  围住神经猫


#import "ViewController.h"
#import "CircleLocation.h"

CircleLocation *allCircle[9][9];
int map[9][9];
int hasCircle = 0;
CircleLocation *clickPoint;

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    UIImage *image = [UIImage imageNamed:@"gray.png"];
    
    self.allButtonArray = [NSMutableArray arrayWithCapacity:9];
    for (int i = 0; i < 9; i++) {
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:9];
        [self.allButtonArray addObject:arr];
        for (int j = 0; j < 9; j++) {
            UIButton *btn = [[UIButton alloc] init];
            if (i % 2 == 0) {
                btn.frame = CGRectMake(28*j+20, 28*i+170, 28, 28);
            }
            else {
                btn.frame = CGRectMake(28*j+34, 28*i+170, 28, 28);
            }
            [btn setImage:image forState:UIControlStateNormal];
            [self.view addSubview:btn];
            [arr addObject:btn];
            [btn addTarget:self action:@selector(clickMe:) forControlEvents:UIControlEventTouchUpInside];
            CircleLocation *cl = [[CircleLocation alloc]init];
            cl.row = i;
            cl.col = j;
            cl.path = -100;
            allCircle[i][j] = cl;
        }
    }
    
    self.cat = [[CircleLocation alloc]init];

    UIImage *catMiddleImage = [UIImage imageNamed:@"middle2.png"];
    UIImage *catleftImage = [UIImage imageNamed:@"left2.png"];
    UIImage *catRightImage = [UIImage imageNamed:@"right2.png"];
    self.catImageview = [[UIImageView alloc]initWithFrame:CGRectMake(28*4+20, 28*3+170, 30, 56)];
    self.catImageview.animationImages = [NSArray arrayWithObjects:catleftImage,catMiddleImage,catRightImage, nil];
    self.catImageview.animationDuration = 1.0;
    [self.view addSubview:self.catImageview];
    [self.catImageview startAnimating];
    
    [self redoInitilazation];

}
-(void) produceGameLevel
{
    int level = arc4random() % 50 + 10;
    int num = 0;
    while (num < level) {
        int row = arc4random() % 9;
        int col = arc4random() % 9;
        if (row != 4 && col != 4 &&
            map[row][col] == 0) {
            num++;
            map[row][col] = 1;
            UIImage *image = [UIImage imageNamed:@"yellow2.png"];
            [self.allButtonArray[row][col] setImage:image forState:UIControlStateNormal];
        }
    }
}

-(void)redoInitilazation
{
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            map[i][j] = 0;
            UIImage *image = [UIImage imageNamed:@"gray.png"];
            [self.allButtonArray[i][j] setImage:image forState:UIControlStateNormal];
        }
    }
    self.pathNumber = 0;
    self.isGameOver = 0;
    self.cat.row = 4;
    self.cat.col = 4;
    self.cat.path = 888;
    map[4][4] = 1;
    self.catImageview.frame = CGRectMake(28*4+20, 28*3+170, 30, 56);
    
    [self produceGameLevel];
    [self calAllCost];
    [self printCost];
}
-(void) runAgain
{
    [ self redoInitilazation ];
    
}

-(void) clickMe:(id) sender
{
    UIButton *btn = (UIButton *)sender;
    UIImage *image = [UIImage imageNamed:@"yellow2.png"];
    [btn setImage:image forState:UIControlStateNormal];
    int row = [self getButtonRow:btn];
    int col = [self getButtonCol:btn];
    [self updateCostRow:row col:col];
    self.pathNumber++;
    if (self.isGameOver == 1 && self.cat.row == row && self.cat.col == col) {
        [self performSelector:@selector(showWinAlertView) withObject:nil afterDelay:0.1];
        return;
    }
    else if (self.isGameOver == 1) {
        //只有一个点了，没选中则继续
    }
    else {
        self.isGameOver = [self catAutoGo];
        
        if (self.isGameOver == -1){
            [self performSelector:@selector(showLoseAlertView) withObject:nil afterDelay:0.1];
            return;
        }
        [self calAllCost];
        [self printCost];
    }
    
}

-(void) showWinAlertView
{
    NSString *msg = [NSString stringWithFormat:@"亲，你的步数是：%d次", self.pathNumber];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:msg message:@"你成功抓住猫了！" delegate:self cancelButtonTitle:@"退出游戏？" otherButtonTitles:@"再来一次？", nil];
    [alert show];
}

-(void) showLoseAlertView
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"亲，猫跑掉了！" message:@"你失败了！加油啊！" delegate:self cancelButtonTitle:@"退出游戏？" otherButtonTitles:@"再来一次？", nil];
    [alert show];
}


#pragma mark -更新ui

-(void) updateCostRow:(int) row col:(int) col
{
    CircleLocation * loc = allCircle[row][col];
    map[loc.row][loc.col] = 1;
    clickPoint = loc;
    [self clearAllCost];
    [self calAllCost];
    [self printCost];
}

-(int) getButtonRow:(UIButton *) btn
{
    int y = btn.frame.origin.y;
    int row = (y - 170) / 28;
    return row;
}

-(int) getButtonCol:(UIButton *) btn
{
    int x = btn.frame.origin.x;
    int y = btn.frame.origin.y;
    int row = (y - 170) / 28;
    
    int col = 0;
    if (row % 2 == 0) {
        col = (x - 20) / 28;
    }
    else {
        col = (x - 34) / 28;
    }
    return col;
}

-(void) printCatConnectedPointCost
{
    NSArray *catAllSelects = [self.cat getAllConnectLocation];
    int i = 0;
    for (i = 0; i < 6; i++) {
        CircleLocation *tmp = (CircleLocation*)[catAllSelects objectAtIndex:i];
        printf("%2d ", tmp.cost);
    }
    printf("\n");
}

-(CircleLocation *) calMaxCostOne:(CircleLocation*) p1 two:(CircleLocation*)p2
{
    if (hasCircle == 0) {
        return nil;
    }
    
    int cost = [p1 calMaxCost];
    int cost1 = [p2 calMaxCost];
    if (cost >= cost1) {
        return p1;
    }
    else {
        return p2;
    }
}

-(int) isSplitTwoParts
{
    if (hasCircle == 0) {
        return 0;
    }
    int i = self.cat.row;
    int j = self.cat.col;
    CircleLocation *pCat = allCircle[i][j];
    NSArray *allConnectLocation = [pCat getAllConnectLocation];
    CircleLocation *p = (CircleLocation*)[allConnectLocation objectAtIndex:0];
    CircleLocation *p1 = nil;
    for (i = 0; i < 6; i++) {
        p = (CircleLocation*)[allConnectLocation objectAtIndex:i];
        if (p.cost == 100) {
            break;
        }
    }
    p1 = [p getOppositePoint:pCat];
    if (p1.cost == 100) {
        return 1;
    }
    else {
        return 0;
    }
}

-(CircleLocation *) calMaxCost
{
    int i = self.cat.row;
    int j = self.cat.col;
    CircleLocation *pCat = allCircle[i][j];
    NSArray *allConnectLocation = [pCat getAllConnectLocation];
    //找到相对的两个非墙点
    CircleLocation *p = (CircleLocation*)[allConnectLocation objectAtIndex:0];
    CircleLocation *p1 = nil;
    int isFound = 0;
    for (i = 0; i < 6; i++) {
        p = (CircleLocation*)[allConnectLocation objectAtIndex:i];
        p1 = [p getOppositePoint:pCat];
        if (p.cost < 100 && p1.cost < 100) {
            isFound = 1;
            break;
        }
    }
    if (isFound == 1) {
        return [self calMaxCostOne:p two:p1];
    }
    
    return p;
}

-(CircleLocation *) getMaxCost:(int *)pMax
{
    if (hasCircle == 0) {
        return nil;
    }
    int i = self.cat.row;
    int j = self.cat.col;
    CircleLocation *p = allCircle[i][j];
    NSArray *allConnectLocation = [p getAllConnectLocation];
    p = (CircleLocation*)[allConnectLocation objectAtIndex:0];
    int max = p.cost;
    int index = 0;
    int wallNum = 0;
    CircleLocation *p1 = nil;
    for (i = 0; i < 6; i++) {
        p = (CircleLocation*)[allConnectLocation objectAtIndex:i];
        if (p.cost < 100) {
            max = p.cost;
            p1 = p;
            index = i;
            break;
        }
    }
    for (i = 0; i < 6; i++) {
        p = (CircleLocation*)[allConnectLocation objectAtIndex:i];
        if (p.cost == 100) {
            wallNum++;
            continue;
        }
        if (max < p.cost) {
            max = p.cost;
            index = i;
        }
    }
    //判断猫是否能把剩余点数分成两部分，如果是分成了两部分，那么就启动最大通路法。
//    if (wallNum > 1 && wallNum < 5) {
//        int isSplit = [self isSplitTwoParts];
//        if (isSplit == 1) {
//            p = [self calMaxCost];
//            *pMax = p.cost;
//            return p;
//        }
//    }
    
    if (wallNum < 6) {
        *pMax = p.cost;
        p = (CircleLocation*)[allConnectLocation objectAtIndex:index];
        return p;
    }
    else {
        *pMax = -1;
        return nil;
    }
}

-(CircleLocation *) getBestLocation
{
    CircleLocation *best = nil;
    int max = 0;
    best = [self getMaxCost:&max];
    if (best != nil) {
        return best;
    }
    else if (hasCircle == 1) {
        return best;
    }
    
    NSArray *catAllSelects = [self.cat getAllConnectLocation];
    int i = 0;
    for (i = 0; i < 6; i++) {
        CircleLocation *tmp = (CircleLocation*)[catAllSelects objectAtIndex:i];
        if (map[tmp.row][tmp.col] == 0) {
            best = tmp;
            break;
        }
    }
    for (int j = i+1; j < 6; j++) {
        CircleLocation *tmp = (CircleLocation*)[catAllSelects objectAtIndex:j];
        if ( map[tmp.row][tmp.col] == 0 && [tmp compare:best] == 1) {
            best = tmp;
        }
    }
    if (best != NULL) {
        printf("Cat's Best location: row is %d, col is %d\n",best.row, best.col);
    }
    return best;
}
//  Created by jamszhy on 14-7-30.
//  Copyright (c) 2014年 jamszhy. All rights reserved.
//  我的新浪博客：blog.sina.com.cn/jamszhy
//  我的新浪微博：weibo.com/jamszhy
//  我的QQ交流群：307561190

-(int) catAutoGo
{
    CircleLocation *best = [self getBestLocation];
    if (best != NULL) {
        int i = self.cat.row;
        int j = self.cat.col;
        if (clickPoint.row == allCircle[i][j].row && clickPoint.col == allCircle[i][j].col) {
            //什么都不做
        }
        else {
            map[i][j] = 0;
        }
        self.cat.row = best.row;
        self.cat.col = best.col;
        i = self.cat.row;
        j = self.cat.col;
        map[i][j] = 1;
        if (i%2 == 0) {
            self.catImageview.frame = CGRectMake(28*j+20, 28*(i-1)+170, 30, 56);
        }
        else {
            self.catImageview.frame = CGRectMake(28*j+34, 28*(i-1)+170, 30, 56);
        }
        if (i == 0 || i == 8 || j == 0 || j == 8) {
            return -1;//到边界
        }
    }
    else {
        return 1; //Only one point
    }
    return 0;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) { //退出游戏
        exit(1);
    }
    else {//重玩一次
        [self runAgain];
    }
}
-(void) clearAllCost
{
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            allCircle[i][j].path = -100;
            allCircle[i][j].cost = -100;
        }
    }
}
//  Created by jamszhy on 14-7-30.
//  Copyright (c) 2014年 jamszhy. All rights reserved.
//  我的新浪博客：blog.sina.com.cn/jamszhy
//  我的新浪微博：weibo.com/jamszhy
//  我的QQ交流群：307561190

-(void) calAllCost
{
    [self clearAllCost];

    //按照这个方向搜索
    //    o o o o
    //     o o o
    //    o o o
    //     o o
    for (int i = 0; i < 9; i++) {
        int k = i;
        for (int j = 0; j <= i; j++) {
            [allCircle[j][k] calculatePath];
            [allCircle[8-j][8-k] calculatePath];
            k--;
        }
    }
    
    //按照这个方向搜索
    //    o o o o
    //     o o o
    //      o o o
    //       o o
    for (int i = 0; i < 9; i++) {
        int k = 8-i;
        for (int j = 0; j <= i; j++) {
            [allCircle[j][k] calculatePath];
            [allCircle[k][j] calculatePath];
            k++;
        }
    }
    
    //按照从左右、上下四个方向进行搜索
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            [allCircle[j][i] calculatePath];
            [allCircle[i][j] calculatePath];
            [allCircle[j][8-i] calculatePath];
            [allCircle[8-i][j] calculatePath];
        }
    }
    
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            [allCircle[i][j] calculateCost];
        }
    }
    
    //判断猫是否在一个圈中
    hasCircle = [self.cat isInCircle];
}

-(void) printCost
{
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            int a = allCircle[i][j].path;
            if (a < 0) {
                a = -a;
            }
            if (i % 2 == 1) {
                printf("  ");
            }
            if (i == self.cat.row && j == self.cat.col) {
                printf("%4d ", self.cat.path);
            }
            else {
                if (a < 100) {
                    printf("%4d ", a);
                }
                else {
                    printf("%d ", a);
                }
            }
            
        }
        printf("\n");
    }
    printf("\n\n");
    [self printCatConnectedPointCost];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
