//
//  OnboardingRootViewController.m
//  Localite
//
//  Created by Jedd Goble on 4/15/16.
//  Copyright © 2016 Mobile Makers. All rights reserved.
//

#import "OnboardingRootViewController.h"
#import "OnboardingContentViewController.h"

@interface OnboardingRootViewController ()

@end

@implementation OnboardingRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _pageImages = @[@"Artboard1", @"Artboard2", @"Artboard3"];
    
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OnboardingPageViewController"];
    self.pageViewController.dataSource = self;
    
    OnboardingContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    self.pageViewController.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - 30.0);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onConnectInstagramButtonTapped:(UIButton *)sender {
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = ((OnboardingContentViewController *) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
    
    
}
                        


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = ((OnboardingContentViewController *) viewController).pageIndex;
    
    if (index == NSNotFound) {
        
        return nil;
    }
    
    index ++;
    
    if (index == [self.pageImages count]) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
    
}

- (OnboardingContentViewController *)viewControllerAtIndex:(NSUInteger)index {
    
    if (([self.pageImages count] == 0) || (index >= [self.pageImages count])) {
        
        return nil;
    }
    
    OnboardingContentViewController *contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OnboardingContentController"];
    contentViewController.imageFile = self.pageImages[index];
    contentViewController.pageIndex = index;
    
    return contentViewController;
    
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    
    return [self.pageImages count];
}

- (NSInteger) presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    
    return 0;
}



@end
