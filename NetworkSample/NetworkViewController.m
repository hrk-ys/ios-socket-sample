//
//  NetworkViewController.m
//  NetworkSample
//
//  Created by Yoshifuji Hiroki on 12/04/02.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NetworkViewController.h"

@interface NetworkViewController ()

@end




@implementation NetworkViewController

NSMutableData *data;

NSInputStream *iStream;
NSOutputStream *oStream;

CFReadStreamRef readStream = NULL;
CFWriteStreamRef writeStream = NULL;

-(void) connectToServerUsingStream:(NSString *)urlStr 
                            portNo: (uint) portNo {
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, 
                                       (CFStringRef) urlStr, 
                                       portNo, 
                                       &readStream, 
                                       &writeStream);
    
    if (readStream && writeStream) {
        CFReadStreamSetProperty(readStream, 
                                kCFStreamPropertyShouldCloseNativeSocket, 
                                kCFBooleanTrue);
        CFWriteStreamSetProperty(writeStream, 
                                 kCFStreamPropertyShouldCloseNativeSocket, 
                                 kCFBooleanTrue);
        
        iStream = (NSInputStream *)readStream;
        [iStream retain];
        [iStream setDelegate:self];
        [iStream scheduleInRunLoop:[NSRunLoop currentRunLoop] 
                           forMode:NSDefaultRunLoopMode];
        [iStream open];
        
        oStream = (NSOutputStream *)writeStream;
        [oStream retain];
        [oStream setDelegate:self];
        [oStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                           forMode:NSDefaultRunLoopMode];
        [oStream open];
    }
}

-(void) writeToServer:(const uint8_t *) buf {
    [oStream write:buf maxLength:strlen((char*)buf)];
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
    switch(eventCode) {
        case NSStreamEventHasBytesAvailable:
        {
            if (data == nil) {
                data = [[NSMutableData alloc] init];
            }
            uint8_t buf[1024];
            unsigned int len = 0;
            len = [(NSInputStream *)stream read:buf maxLength:1024];
            if(len) {    
                [data appendBytes:(const void *)buf length:len];
                int bytesRead = 0;
                bytesRead += len;
            } else {
                NSLog(@"No data.");
            }
            
            NSString *str = [[NSString alloc] initWithData:data 
                                                  encoding:NSUTF8StringEncoding];
            NSLog(@"recv:%@", str);

            [self appendStringForTextView:[NSString stringWithFormat:@"[recv] %@", str]];
            
            [str release];
            [data release];        
            data = nil;
        }
            break;
    }
}

-(void) disconnect {
    [iStream close];
    [oStream close];
}

- (void)dealloc {
    [self disconnect];
    
    [iStream release];
    [oStream release];
    
    if (readStream) CFRelease(readStream);
    if (writeStream) CFRelease(writeStream);
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    CGRect bounds = self.view.bounds;
    [self.view setBackgroundColor:[UIColor grayColor]];

    UITextField *textField = [[[UITextField alloc] initWithFrame:CGRectMake(10, 10, 280, 30)] autorelease];
    textField.delegate = self;
    [textField setBackgroundColor:[UIColor whiteColor]];

    textView = [[[UITextView alloc] initWithFrame:CGRectMake(0, 45, bounds.size.width, 300)] autorelease];
    textView.editable = NO;

    [self.view addSubview:textView];
    [self.view addSubview:textField];
    [self connectToServerUsingStream:@"localhost" portNo:2525];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)appendStringForTextView:(NSString*)str {
    NSMutableString* text = [NSMutableString stringWithString:textView.text];
    [text appendString:str];
    textView.text = text;
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField{
    [textField resignFirstResponder];

    NSString* text = textField.text;
    if ([text isEqualToString:@""]) {
        return YES;
    }

    NSLog(@"send:%@", text);
    NSString* message = [NSString stringWithFormat:@"%@\r\n", text];

    [self appendStringForTextView:[NSString stringWithFormat:@"[send] %@\r", text]];
    [self writeToServer:(uint8_t *)[message cStringUsingEncoding:NSASCIIStringEncoding]];
    
    textField.text = @"";
    
    return YES;
}

@end
