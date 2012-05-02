//
//  WSCaptureButton.m
//  wsabi2
//
//  Created by Matt Aronoff on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSCaptureButton.h"

@implementation WSCaptureButton

@synthesize state;
@synthesize activityIndicator;
@synthesize delayedMessageTimer;

@synthesize inactiveImage;
@synthesize captureImage;
@synthesize stopImage;
@synthesize warningImage;
@synthesize waitingImage;
@synthesize waitingRestartCaptureImage;

@synthesize inactiveMessage;
@synthesize captureMessage;
@synthesize stopMessage;
@synthesize warningMessage;
@synthesize waitingMessage;
@synthesize waitingRestartCaptureMessage;

- (void)delayedMessageTimerFired:(NSTimer *)theTimer {

    NSString *targetString = (NSString*)theTimer.userInfo;
    
    [self setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    
    [UIView animateWithDuration:kMediumFadeAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState 
                     animations:^{
                         [self setTitle:targetString forState:UIControlStateNormal];
                     }
                     completion:^(BOOL completed) {
                         
                     }
     ];
}

-(void) setWaitingIndicatorState:(BOOL)onOrOff withMessage:(NSString*)message messageDelay:(float)delaySeconds
{
    if(!self.activityIndicator)
    {
        //add and tint the indicator.
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityIndicator.hidesWhenStopped = YES;
        [self.activityIndicator stopAnimating];
        [[UIActivityIndicatorView appearance] setColor:[UIColor darkTextColor]];
        
        //center the activity indicator at 1/4 of the way down the button.
        self.activityIndicator.center = CGPointMake(self.center.x, self.bounds.size.height/4.0);
        [self.activityIndicator startAnimating];
        
        [self addSubview:self.activityIndicator];
    }
    
    if (onOrOff) {
        [self.activityIndicator startAnimating];
        
        //if there's an existing delayed message timer, stop it.
        if (self.delayedMessageTimer) {
            [self.delayedMessageTimer invalidate];
        }
        self.delayedMessageTimer = [NSTimer scheduledTimerWithTimeInterval:delaySeconds
                                                                    target:self 
                                                                  selector:@selector(delayedMessageTimerFired:) 
                                                                  userInfo:message 
                                                                   repeats:NO];
    }
    else {
        [self.activityIndicator stopAnimating];
    }
}

-(void) setState:(WSCaptureButtonState)newState
{
    
    //Animate the transition to the new state.
    /*	WSCaptureButtonStateInactive,
     WSCaptureButtonStateCapture,
     WSCaptureButtonStateStop,
     WSCaptureButtonStateWarning,
     WSCaptureButtonStateWaiting,
     WSCaptureButtonStateWaitingRestartCapture,
     */
    
    self.userInteractionEnabled = (newState != WSCaptureButtonStateInactive);
     switch (newState) {
         case WSCaptureButtonStateInactive:
             [self setImage:self.inactiveImage forState:UIControlStateNormal];
             [self setTitle:self.inactiveMessage forState:UIControlStateNormal];
             self.backgroundColor = [UIColor clearColor];
             [self.activityIndicator stopAnimating]; //stop and hide the spinner.
             [self.delayedMessageTimer invalidate];
             break;
         case WSCaptureButtonStateCapture:
             [self setImage:self.captureImage forState:UIControlStateNormal];
             [self setTitle:self.captureMessage forState:UIControlStateNormal];
             self.backgroundColor = [UIColor clearColor];
             [self.activityIndicator stopAnimating]; //stop and hide the spinner.
             [self.delayedMessageTimer invalidate];
             break;
         case WSCaptureButtonStateStop:
             [self setImage:self.stopImage forState:UIControlStateNormal];
             [self setTitle:self.stopMessage forState:UIControlStateNormal];
             self.backgroundColor = [UIColor clearColor];
             [self.activityIndicator stopAnimating]; //stop and hide the spinner.
             [self.delayedMessageTimer invalidate];
             break;
         case WSCaptureButtonStateWarning:
             [self setImage:self.warningImage forState:UIControlStateNormal];
             [self setTitle:self.warningMessage forState:UIControlStateNormal];
             self.backgroundColor = [UIColor clearColor];
             [self.activityIndicator stopAnimating]; //stop and hide the spinner.
             [self.delayedMessageTimer invalidate];
             break;
         case WSCaptureButtonStateWaiting:
             [self setImage:self.waitingImage forState:UIControlStateNormal];
             [self setTitle:nil forState:UIControlStateNormal]; //clear the title to start
             self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
             [self setWaitingIndicatorState:YES withMessage:self.waitingMessage messageDelay:4.0]; //wait 4 seconds, then display the waiting message
             break;
         case WSCaptureButtonStateWaitingRestartCapture:
             [self setImage:self.waitingRestartCaptureImage forState:UIControlStateNormal];
             [self setTitle:nil forState:UIControlStateNormal]; //clear the title to start
             self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
             [self setWaitingIndicatorState:YES withMessage:self.waitingRestartCaptureMessage messageDelay:2.0]; //wait 2 seconds, then display the waiting-with-restart message
             break;

         default:
             break;
     }
    
    if (state != newState && newState == WSCaptureButtonStateCapture) {
        //start the capture button animation.
        self.imageView.transform = CGAffineTransformIdentity;
        [UIView animateWithDuration:0.8
                              delay:0 options:(UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat|UIViewAnimationOptionCurveEaseOut)
                         animations:^{
                             self.imageView.transform = CGAffineTransformMakeScale(1.2, 1.2);
                         }
                         completion:nil];
    }
    else {
        //cancel all animations for this button.
        self.imageView.transform = CGAffineTransformIdentity;
        [self.imageView.layer removeAllAnimations];
    }
    
    state = newState;

 }

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
