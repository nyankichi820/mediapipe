#import "HolisticTracker.h"
#import "mediapipe/objc/MPPGraph.h"
#import "mediapipe/objc/MPPCameraInputSource.h"
#import "mediapipe/objc/MPPLayerRenderer.h"
#include "mediapipe/framework/formats/landmark.pb.h"

static NSString* const kGraphName = @"hand_tracking_mobile_gpu";
static const char* kInputStream = "input_video";
static const char* kOutputStream = "output_video";
static const char* kLandmarksOutputStream = "holistic_landmarks";

static const char* kVideoQueueLabel = "com.google.mediapipe.example.videoQueue";

@interface HolisticTracker() <MPPGraphDelegate>
@property(nonatomic) MPPGraph* mediapipeGraph;
@end

@interface Landmark()
- (instancetype)initWithX:(float)x y:(float)y z:(float)z;
@end

@implementation HolisticTracker {
    /// Process camera frames on this queue.
    dispatch_queue_t _videoQueue;
}

#pragma mark - Cleanup methods

- (void)dealloc {
    self.mediapipeGraph.delegate = nil;
    [self.mediapipeGraph cancel];
    // Ignore errors since we're cleaning up.
    [self.mediapipeGraph closeAllInputStreamsWithError:nil];
    [self.mediapipeGraph waitUntilDoneWithError:nil];
}

#pragma mark - MediaPipe graph methods

+ (MPPGraph*)loadGraphFromResource:(NSString*)resource {
    // Load the graph config resource.
    NSError* configLoadError = nil;
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    if (!resource || resource.length == 0) {
        return nil;
    }
    NSURL* graphURL = [bundle URLForResource:resource withExtension:@"binarypb"];
    NSData* data = [NSData dataWithContentsOfURL:graphURL options:0 error:&configLoadError];
    if (!data) {
        NSLog(@"Failed to load MediaPipe graph config: %@", configLoadError);
        return nil;
    }
    
    // Parse the graph config resource into mediapipe::CalculatorGraphConfig proto object.
    mediapipe::CalculatorGraphConfig config;
    config.ParseFromArray(data.bytes, data.length);
    
    // Create MediaPipe graph with mediapipe::CalculatorGraphConfig proto object.
    MPPGraph* newGraph = [[MPPGraph alloc] initWithGraphConfig:config];
    [newGraph addFrameOutputStream:kOutputStream outputPacketType:MPPPacketTypePixelBuffer];
    [newGraph addFrameOutputStream:kLandmarksOutputStream outputPacketType:MPPPacketTypeRaw];
    return newGraph;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        dispatch_queue_attr_t qosAttribute = dispatch_queue_attr_make_with_qos_class(
                                                                                     DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INTERACTIVE, /*relative_priority=*/0);
        _videoQueue = dispatch_queue_create(kVideoQueueLabel, qosAttribute);
        
        self.mediapipeGraph = [[self class] loadGraphFromResource:kGraphName];
        self.mediapipeGraph.delegate = self;
        // Set maxFramesInFlight to a small value to avoid memory contention for real-time processing.
        self.mediapipeGraph.maxFramesInFlight = 2;
    }
    return self;
}

- (void)startGraph {
    // Start running self.mediapipeGraph.
    NSError* error;
    if (![self.mediapipeGraph startWithError:&error]) {
        NSLog(@"Failed to start graph: %@", error);
    }
}

#pragma mark - MPPGraphDelegate methods

// Receives CVPixelBufferRef from the MediaPipe graph. Invoked on a MediaPipe worker thread.
- (void)mediapipeGraph:(MPPGraph*)graph
  didOutputPixelBuffer:(CVPixelBufferRef)pixelBuffer
            fromStream:(const std::string&)streamName {
    //  if (streamName == kOutputStream) {
    //    // Display the captured image on the screen.
    //    CVPixelBufferRetain(pixelBuffer);
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //      CVPixelBufferRelease(pixelBuffer);
    //    });
    //  }
}

// Receives a raw packet from the MediaPipe graph. Invoked on a MediaPipe worker thread.
- (void)mediapipeGraph:(MPPGraph*)graph
       didOutputPacket:(const ::mediapipe::Packet&)packet
            fromStream:(const std::string&)streamName {
    if (streamName == kLandmarksOutputStream) {
        if (packet.IsEmpty()) { return; }
        const auto& multiHandLandmarks = packet.Get<std::vector<::mediapipe::NormalizedLandmarkList>>();
        NSLog(@"[TS:%lld] Number of hand instances with landmarks: %lu", packet.Timestamp().Value(),
              multiHandLandmarks.size());
        for (int handIndex = 0; handIndex < multiHandLandmarks.size(); ++handIndex) {
          const auto& landmarks = multiHandLandmarks[handIndex];
          NSLog(@"\tNumber of landmarks for hand[%d]: %d", handIndex, landmarks.landmark_size());
          for (int i = 0; i < landmarks.landmark_size(); ++i) {
            NSLog(@"\t\tLandmark[%d]: (%f, %f, %f)", i, landmarks.landmark(i).x(),
                  landmarks.landmark(i).y(), landmarks.landmark(i).z());
          }
        }
      
    }
}

#pragma mark - MPPInputSourceDelegate methods

// Must be invoked on _videoQueue.
- (void)processVideoFrame:(CVPixelBufferRef)imageBuffer {
    [self.mediapipeGraph sendPixelBuffer:imageBuffer
                              intoStream:kInputStream
                              packetType:MPPPacketTypePixelBuffer];
}

@end


@implementation Landmark

- (instancetype)initWithX:(float)x y:(float)y z:(float)z
{
    self = [super init];
    if (self) {
        _x = x;
        _y = y;
        _z = z;
    }
    return self;
}

@end
