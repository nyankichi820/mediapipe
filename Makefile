
holistic_framework:
	 bazel build --apple_bitcode=embedded  --copt=-fembed-bitcode  --verbose_failures  --config=ios_fat  mediapipe/examples/ios/holistictrackinggpu_framework:HolisticTracker
