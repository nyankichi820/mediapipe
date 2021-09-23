#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
@class Landmark;

@protocol HolisticTrackerDelegate <NSObject>
@optional
- (void)didReceivedLandmarks:(NSString*)outputType landmark: (NSArray<Landmark *> *)landmarks;
@end

@interface HolisticTracker : NSObject
- (instancetype)init;
- (void)startGraph;
- (void)processVideoFrame:(CVPixelBufferRef)imageBuffer timestamp:(CMTime)timestamp;
@property (weak, nonatomic) id <HolisticTrackerDelegate> delegate;
@end

@interface Landmark: NSObject
@property(nonatomic, readonly) float x;
@property(nonatomic, readonly) float y;
@property(nonatomic, readonly) float z;
@end
