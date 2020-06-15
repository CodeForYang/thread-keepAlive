//
//  ViewController.m
//  runloopTest
//
//  Created by 10.12 on 2020/5/10.
//  Copyright © 2020 10.12. All rights reserved.
//

#import "ViewController.h"
#import "MJThread.h"

@interface ViewController ()
@property (nonatomic,strong)MJThread *thread;
@property (nonatomic,assign,getter=isStopped)BOOL stopped;
@end

@implementation ViewController
void  CFRunloopActivities(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info){

    switch (activity) {
        case kCFRunLoopBeforeWaiting:
            NSLog(@"kCFRunLoopBeforeWaiting");
            break;

        case kCFRunLoopAfterWaiting:
            NSLog(@"kCFRunLoopAfterWaiting");
            break;

        case kCFRunLoopBeforeSources:
            NSLog(@"kCFRunLoopBeforeSources");
            break;

        case kCFRunLoopBeforeTimers:
            NSLog(@"kCFRunLoopBeforeTimers");
            break;

        case kCFRunLoopEntry:
            NSLog(@"kCFRunLoopEntry");
            break;
            
        case kCFRunLoopExit:
            NSLog(@"kCFRunLoopExit");
            break;
            
        default:
            break;
    }
}
/**
 kCFRunLoopEntry = (1UL << 0),
 kCFRunLoopBeforeTimers = (1UL << 1),
 kCFRunLoopBeforeSources = (1UL << 2),
 kCFRunLoopBeforeWaiting = (1UL << 5),
 kCFRunLoopAfterWaiting = (1UL << 6),
 kCFRunLoopExit = (1UL << 7),
 kCFRunLoopAllActivities = 0x0FFFFFFFU
 */

- (void)viewDidLoad {
    [super viewDidLoad];
//    NSLog(@"%@-%@",[NSRunLoop currentRunLoop],[NSRunLoop mainRunLoop]);
//    NSLog(@"%p-%p",CFRunLoopGetCurrent(),CFRunLoopGetMain());

    
    
    
    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault,kCFRunLoopAllActivities, YES, 0, CFRunloopActivities, NULL);
    
    CFRunLoopObserverRef observerBlock = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        switch (activity) {

            case kCFRunLoopEntry:{
                CFRunLoopMode mode = CFRunLoopCopyCurrentMode(CFRunLoopGetCurrent());
                
                NSLog(@"kCFRunLoopEntry-%@",mode);
                break;
            }
            case kCFRunLoopExit:{
                CFRunLoopMode mode = CFRunLoopCopyCurrentMode(CFRunLoopGetCurrent());

                NSLog(@"kCFRunLoopExit-%@",mode);
                break;
            }
            default:
                break;
        }

    });
    //kCFRunLoopDefaultMode
    //UITrackingRunLoopMode
    //kCFRunLoopCommonModes
    CFRunLoopAddObserver(CFRunLoopGetMain(), observerBlock, kCFRunLoopCommonModes);
    CFRelease(observer);
    
    /**
     处理source0,source1,observer,selector,block,
     source1捕捉事件,交给source0处理
     */
    static int count = 0;
    
    
//    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
//                
//        NSLog(@"%d",count++);
//
//    }];
//    NSRunLoop *runloop = [NSRunLoop currentRunLoop];//创建runloop
//    [runloop addTimer:timer forMode:NSRunLoopCommonModes];
    
    //此时定时器已经将模式设置为默认的情况下
//    [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
//        NSLog(@"%d",count++);
//    }];
    
    
//    self.thread = [[MJThread alloc]initWithTarget:self selector:@selector(run) object:nil];
//    [self.thread start];
    
    /**
     ff no input sources or timers are attached to the run loop,
     this method exits immediately;
     otherwise, it runs the receiver in the NSDefaultRunLoopMode by repeatedly invoking runMode:beforeDate:.
     In other words, this method effectively begins an infinite loop that processes data from the run loop’s input sources and timers.
     */
    self.stopped = NO;
    __weak typeof(self)weakSelf = self;
    self.thread = [[MJThread alloc ]initWithBlock:^{
        NSLog(@"------start------%@",[NSThread currentThread]);

        [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc]init] forMode:NSDefaultRunLoopMode];
        while (weakSelf && !weakSelf.stopped) {
//            NSLog(@"%@-",weakSelf);
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];//这里保证线程不会死

        }
        NSLog(@"------完事儿了------%@",[NSThread currentThread]);
        
    }];
    
    [self.thread start];
}



- (void)test{
    NSLog(@"%s  %@",__func__,[NSThread currentThread]);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self performSelector:@selector(test) onThread:self.thread withObject:nil waitUntilDone:NO];
}

- (void)stopThread{
    self.stopped = YES;
    CFRunLoopStop(CFRunLoopGetCurrent());//通知runloop停止
  

}

- (IBAction)stop:(id)sender {
    [self performSelector:@selector(stopThread) onThread:self.thread withObject:nil waitUntilDone:NO];
}



- (void)dealloc{
    NSLog(@"%s",__func__);
    [self stop:nil];
}









- (void)run{
    NSLog(@"%s  %@",__func__,[NSThread currentThread]);
    
    [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc]init] forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] run];//这里保证线程不会死
    
    NSLog(@"------end------%@",[NSThread currentThread]);

}

@end
