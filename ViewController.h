//
//  ViewController.h
//  围住神经猫
//
//  Created by wxl on 15-7-30.
//  Copyright (c) 2015年 wxl. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CircleLocation;

@interface ViewController : UIViewController <UIAlertViewDelegate>

@property (strong, nonatomic) NSMutableArray *allButtonArray;
@property (strong, nonatomic) UIImageView *catImageview;
@property (strong, nonatomic) CircleLocation *cat;
@property int pathNumber, isGameOver;

@end
