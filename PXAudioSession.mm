//
//  PXAudioSession.mm
//
//  Copyright (c) 2012 Ole Krause-Sparmann
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software
//  and associated documentation files (the "Software"), to deal in the Software without restriction,
//  including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
//  LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "PXAudioSession.h"

@interface PXAudioSession ()

/// Sets up audio session
- (void)setup;

/// Trys to set category
- (void)setCategoryTo:(NSString*)categoryString;

/// Indicates if audio session is active.
@property (nonatomic, readwrite) BOOL isActive;
/// Used as an argument to the session activation
@property (nonatomic, readwrite) BOOL notifyOthersOnDeactivation;

@end

@implementation PXAudioSession

@synthesize isActive = _isActive;
@synthesize notifyOthersOnDeactivation = _notifyOthersOnDeactivation;
@synthesize delegate = _delegate;

#pragma mark - Singleton method

+ (PXAudioSession*)sharedAudioSession
{
    static PXAudioSession *gSharedAudioSession = nil;
    static dispatch_once_t once = 0;
    
    // Only call this block once (new clean way to initialize singletons)
    dispatch_once(&once, ^{
        gSharedAudioSession = [[PXAudioSession alloc] init];
    });
    
    return gSharedAudioSession;
}

#pragma mark - Object lifecycle 

- (id)init
{
    self = [super init];
    if (self!=nil) {
        // We do not want this
        self.notifyOthersOnDeactivation = NO;
        
        // Set up audio session
        [self setup];
    }
    return self;
}

- (void)setup
{
    // Implicitly create audio session singleton
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    // Set delegate (i know it is deprecated in iOS 6, but i am working with SDK5 deploying on iOS 5)
    audioSession.delegate = self;
    
    // Just activate in order to find out if everything is alright (session should be active anyway).
    [self activateSession];
}

#pragma mark - Audio session state

- (void)activateSession
{
    // We are interested in errors
    NSError *error = nil;
    
    // Set flags
    NSInteger flags = self.notifyOthersOnDeactivation ? AVAudioSessionSetActiveFlags_NotifyOthersOnDeactivation : 0;
 
    // Call setActive and keep result
    self.isActive = [[AVAudioSession sharedInstance] setActive:YES withFlags:flags error:&error];
    
    // Do console print in case of failure
    if (error!=nil) {
        NSLog(@"Could not activate the audio session: %@", [error description]);
    }
}

- (void)deactivateSession
{
    // We are interested in errors
    NSError *error = nil;
        
    // Call setActive and keep result
    if ([[AVAudioSession sharedInstance] setActive:NO error:&error]==NO) {
        // Do console print in case of failure
        if (error!=nil) {
            NSLog(@"Could not deactivate the audio session: %@", [error description]);
        }
    }
    else {
        // If case of success, the session is deactivated now
        self.isActive = NO;
    }    
}

- (void)enableNotifyOthersOnDeactivation
{
    // Set this to YES
    self.notifyOthersOnDeactivation = YES;
    // If session is currently active, re-activate it with this flag
    if (self.isActive) {
        [self activateSession];
    }
}

- (BOOL)isActive
{
    return self.isActive;
}

#pragma mark - Audio session states 

- (void)setCategoryTo:(NSString*)categoryString
{
	NSError *error = nil;    
	[[AVAudioSession sharedInstance] setCategory:categoryString error:&error];
	if (error) {
		NSLog(@"Could not set audio session category to '%@': %@", categoryString, [error description]);
	}
}

- (void)setCategoryToRecord
{
    [self setCategoryTo:AVAudioSessionCategoryRecord];
}

- (void)setCategoryToPlayback
{
    [self setCategoryTo:AVAudioSessionCategoryPlayback];
}

- (void)setCategoryToAmbient
{
    [self setCategoryTo:AVAudioSessionCategoryAmbient];
}

- (void)setCategoryToSoloAmbient
{
    [self setCategoryTo:AVAudioSessionCategorySoloAmbient];
}

- (void)setCategoryToPlayAndRecord
{
    [self setCategoryTo:AVAudioSessionCategoryPlayAndRecord];
}

- (void)setCategoryToAudioProcessing
{
    [self setCategoryTo:AVAudioSessionCategoryAudioProcessing];
}

#pragma mark - AVAudioSessionDelegate methods

- (void)beginInterruption
{
    // Notifiy current delegate
    [self.delegate audioSessionBeginInterruption];
}

- (void)endInterruptionWithFlags:(NSUInteger)flags
{
    // Re-activate session (does not matter if it has already been re-activated by the system).
    [self activateSession];
    
    // Notifiy current delegate
    [self.delegate audioSessionEndInterruption];
}

@end

