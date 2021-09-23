# Copyright 2020 The MediaPipe Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

load(
    "@build_bazel_rules_apple//apple:ios.bzl",
    "ios_framework",
)
load(
    "//mediapipe/examples/ios:bundle_id.bzl",
    "BUNDLE_ID_PREFIX",
    "example_provisioning",
)

licenses(["notice"])

MIN_IOS_VERSION = "13.0"

ios_framework(
    name = "HolisticTracker",
    hdrs = [
        "HolisticTracker.h",
    ],
    infoplists = ["Info.plist"],
    bundle_id = "jp.wchr.HolisticTracker",
    families = ["iphone", "ipad"],
    minimum_os_version = MIN_IOS_VERSION,
    deps = [
        ":HolisticTrackingGpuAppLibrary",
        "@ios_opencv//:OpencvFramework",
    ],
)


objc_library(
    name = "HolisticTrackingGpuAppLibrary",
    srcs = [
        "HolisticTracker.mm",
    ],
    hdrs = [
        "HolisticTracker.h",
    ],
    data = [
        "//mediapipe/graphs/holistic_tracking:holistic_tracking_gpu.binarypb",
        "//mediapipe/modules/face_detection:face_detection_short_range.tflite",
        "//mediapipe/modules/face_landmark:face_landmark.tflite",
        "//mediapipe/modules/hand_landmark:hand_landmark.tflite",
        "//mediapipe/modules/hand_landmark:handedness.txt",
        "//mediapipe/modules/holistic_landmark:hand_recrop.tflite",
        "//mediapipe/modules/pose_detection:pose_detection.tflite",
        "//mediapipe/modules/pose_landmark:pose_landmark_full.tflite",
    ],
    copts = ["-std=c++17"],
    deps = [
        "//mediapipe/examples/ios/common:CommonMediaPipeAppLibrary",
    ] + select({
        "//mediapipe:ios_i386": [],
        "//mediapipe:ios_x86_64": [],
        "//conditions:default": [
            "//mediapipe/graphs/holistic_tracking:holistic_tracking_gpu_deps",
        ],
    }),
)
