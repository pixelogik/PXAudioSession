//
//  PXAudioSession.h
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

#import <AVFoundation/AVFoundation.h>

/// Protocol for delegates. In my applications the delegate is always the current
/// user (a view controller for example) so the delegate is changing over time, which is fine to me.
@protocol PXAudioSessionDelegate <NSObject>

/// Called when the audio session has been interrupted
- (void)audioSessionBeginInterruption;
/// Called when the interruption has ended. The audio sessions has already been re-activated when this is called
- (void)audioSessionEndInterruption;

@end

/// Simple iOS audio session wrapper (pre-iOS6)
@interface PXAudioSession : NSObject<AVAudioSessionDelegate>

/// The audio session delegate (can change over time - should be the current user object)
@property (nonatomic, assign) id<PXAudioSessionDelegate> delegate;

/// Returns singleton audio session wrapper
+ (PXAudioSession*)sharedAudioSession;

/// Returns YES if audio session is active
- (BOOL)isActive;

/// Sets audio session category to record
- (void)setCategoryToRecord;

/// Sets audio session category to playback
- (void)setCategoryToPlayback;

/// Sets audio session category to ambient
- (void)setCategoryToAmbient;

/// Sets audio session category to solo ambient
- (void)setCategoryToSoloAmbient;

/// Sets audio session category to play and record
- (void)setCategoryToPlayAndRecord;

/// Sets audio session category to audio processing
- (void)setCategoryToAudioProcessing;

/// Use this if you want other apps to get notifications when you deactivate your session by intention
- (void)enableNotifyOthersOnDeactivation;

/// Activates session. You only need to call this if you have deactivated the session by intention
- (void)activateSession;

/// Deactivates session. You do not need to call this ever if you do not have a use case for it
- (void)deactivateSession;

@end