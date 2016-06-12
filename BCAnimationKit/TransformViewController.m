//
//  TransformViewController.m
//  BCAnimationKit
//
//  Created by Jack on 16/6/2.
//  Copyright © 2016年 毕研超. All rights reserved.
//

#import "TransformViewController.h"
#import "SecondViewController.h"
@interface TransformViewController ()
{
    CGRect testRect;

}
@end

@implementation TransformViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    testRect = CGRectMake(BCWidth - 10, 10, 10, 10);
    self.view.backgroundColor = [UIColor cyanColor];
    
    
    UILabel *showLabel = [[UILabel alloc] initWithFrame:CGRectMake((BCWidth - 100)/2, 80, 150, 50)];
    showLabel.text = @"这是第一界面";
    showLabel.textColor = DefaultColor;
    showLabel.font = NewText20Font;
    [self.view addSubview:showLabel];

}

- (void)viewWillAppear:(BOOL)animated {//放大

    [super viewWillAppear:animated];
    
    CGRect tempRect = CGRectInset(testRect, -1000, -1000);
    CGPathRef startPath = CGPathCreateWithEllipseInRect(tempRect, NULL);
    CGPathRef endPath   = CGPathCreateWithEllipseInRect(testRect, NULL);
    
    CAShapeLayer *showLayer = [CAShapeLayer layer];
    showLayer.path = startPath;
    self.view.layer.mask = showLayer;
    CABasicAnimation *pingAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    pingAnimation.fromValue = (__bridge id)(endPath);
    pingAnimation.toValue  = (__bridge id)(startPath);
    pingAnimation.duration  = 1;
    pingAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [pingAnimation setValue:@"animate2" forKey:@"animate2"];
    [showLayer addAnimation:pingAnimation forKey:@"BackPath"];
    
    CGPathRelease(startPath);
    CGPathRelease(endPath);



}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

[self.navigationController pushViewController:[SecondViewController new] animated:NO];

    
    //下面是缩小回来的动画
//    CGRect tempRect = CGRectInset(testRect, -600, -600);
//    CGPathRef startPath;
//    CGPathRef endPath;
//    
//    
//    startPath = CGPathCreateWithEllipseInRect(tempRect, NULL);
//    endPath = CGPathCreateWithEllipseInRect(testRect, NULL);
//    
//    CAShapeLayer *showLayer = [CAShapeLayer layer];
//    showLayer.path = endPath;
//    self.view.layer.mask = showLayer;
//    CABasicAnimation *pingAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
//    pingAnimation.fromValue = (__bridge id)(startPath);
//    pingAnimation.toValue  = (__bridge id)(endPath);
//    pingAnimation.delegate = self;
//    pingAnimation.duration  = 1;
//    pingAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    [pingAnimation setValue:@"animate1" forKey:@"animate1"];
//    [showLayer addAnimation:pingAnimation forKey:@"StartPath"];
//    
//    CGPathRelease(startPath);
//    CGPathRelease(endPath);
    
    
    


}

//- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
//    if ([[anim valueForKey:@"animate1"] isEqualToString:@"animate1"]) {
//        
//    if (flag) {
       // [self.navigationController pushViewController:[SecondViewController new] animated:NO];
//    }
//        
//    }
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end