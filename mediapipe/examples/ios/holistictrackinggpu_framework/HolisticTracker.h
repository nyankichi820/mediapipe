#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>

@class Landmark;

@protocol HolisticTrackerDelegate <NSObject>
@optional
- (void)didReceived: (NSArray<Landmark *> *)landmarks;
@end

@interface HolisticTracker : NSObject
- (instancetype)init;
- (void)startGraph;
- (void)processVideoFrame:(CVPixelBufferRef)imageBuffer;
@property (weak, nonatomic) id <HolisticTrackerDelegate> delegate;
@end

@interface Landmark: NSObject
@property(nonatomic, readonly) float x;
@property(nonatomic, readonly) float y;
@property(nonatomic, readonly) float z;
@end