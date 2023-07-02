/*
 * Copyright (C) 2016 The CyanogenMod Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <cutils/log.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <libexif/exif-entry.h>
#include <media/stagefright/MediaBufferGroup.h>
#include <media/IMediaSource.h>
#include <media/stagefright/MediaSource.h>

extern "C" {

extern android::MediaBufferGroup*   _ZN7android16MediaBufferGroupC1Ev() {
#ifdef AOSP
    return new android::MediaBufferGroup();
#else
    return new android::MediaBufferGroup(0);
#endif
}

/* TODO pstglia: This is causing a bootloop - check
ref: https://github.com/petya230/android_device_huawei_hi6250/blob/n-emui4/libshim/shim.cpp
extern int _ZN7android16MediaBufferGroup14acquire_bufferEPPNS_11MediaBufferEb(void *obj,android::MediaBuffer **out, 
								bool nonBlocking, size_t requestedSize) {
    android::MediaBufferGroup *mbg = static_cast<android::MediaBufferGroup *>(obj);
    return mbg->acquire_buffer(out,nonBlocking,requestedSize);

}
*/

extern void _ZNK7android11MediaSource11ReadOptions9getSeekToEPxPNS1_8SeekModeE(void * obj, int64_t time_us, android::MediaSource::ReadOptions::SeekMode mode) {
    android::IMediaSource::ReadOptions *rop = static_cast<android::IMediaSource::ReadOptions *>(obj);
    rop->setSeekTo(time_us, mode);
}

extern bool _ZNK7android11MediaSource11ReadOptions14getNonBlockingEv(void * obj) {
    android::IMediaSource::ReadOptions *rop = static_cast<android::IMediaSource::ReadOptions *>(obj);
    return rop->getNonBlocking();
}

}
