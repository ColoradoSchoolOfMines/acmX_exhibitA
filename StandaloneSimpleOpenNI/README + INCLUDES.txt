Required Binaries:

core.jar (Processing)
blobDetection.jar (blob detection/analysis)
SimpleOpenNI.jar (SimpleOpenNI)
libSimpleOpenNI.jnilib (Native code for OSX)
libSimpleOpenNI32.so (Native code for Linux)
SimpleOpenNI32.dll (Native code for Windows)



Place the three jars and your system's native library binary into this folder, then add the jars to the project's build path. You will also need to set SimpleOpenNI's Native Library path to point to this folder.