/*
 The MIT License (MIT)
 
 Copyright (c) 2013 Alexander Grebenyuk (github.com/kean).
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#define DWARF_UNUSED        __attribute__((unused))

#pragma mark - Backward Compatibility -

#if OS_OBJECT_USE_OBJC
    #define DWARF_DISPATCH_RETAIN(object)
    #define DWARF_DISPATCH_RELEASE(object)
#else
    #define DWARF_DISPATCH_RETAIN(object) (dispatch_retain(object))
    #define DWARF_DISPATCH_RELEASE(object) (dispatch_release(object))
#endif

#pragma mark - Cross Platform -

#if TARGET_OS_IPHONE
    #define DFApplicationWillResignActiveNotification   UIApplicationWillResignActiveNotification
    #define DFApplicationWillTerminateNotification  UIApplicationWillTerminateNotification
#else
    #define DFApplicationWillResignActiveNotification   NSApplicationWillResignActiveNotification
    #define DFApplicationWillTerminateNotification  NSApplicationWillTerminateNotification
#endif

#pragma mark - Functions -

static inline
void
_dwarf_callback(dispatch_queue_t queue, void (^block)(id), id object) {
    if (!queue) {
        queue = dispatch_get_main_queue();
    }
    dispatch_async(queue, ^{
        block(object);
    });
}