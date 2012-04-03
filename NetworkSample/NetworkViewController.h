//
//  NetworkViewController.h
//  NetworkSample
//
//  Created by Yoshifuji Hiroki on 12/04/02.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NetworkViewController : UIViewController<UITextFieldDelegate, NSStreamDelegate> {
    UITextView *textView;
}

@end
