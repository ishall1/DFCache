/*
 The MIT License (MIT)
 
 Copyright (c) 2013 Alexander Grebenyuk (github.com/kean).
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "DFCrypto.h"
#import "DFStorage.h"
#import "dwarf_private.h"


@implementation DFStorage {
    NSFileManager *_fileManager;
}

- (id)initWithPath:(NSString *)path {
    if (self = [super init]) {
        if (!path.length) {
            [NSException raise:@"DFCache" format:@"Attempting to initialize cache without root folder path"];
        }
        _fileManager = [NSFileManager defaultManager];
        _path = path;
        if (![_fileManager fileExistsAtPath:_path]) {
            [_fileManager createDirectoryAtPath:_path withIntermediateDirectories:YES attributes:nil error:NULL];
        }
    }
    return self;
}

- (NSData *)dataForKey:(NSString *)key {
    if (!key) {
        return nil;
    }
    return [_fileManager contentsAtPath:[self filePathForKey:key]];
}

- (void)setData:(NSData *)data forKey:(NSString *)key {
    if (!data || !key) {
        return;
    }
    [_fileManager createFileAtPath:[self filePathForKey:key] contents:data attributes:nil];
}

- (void)removeDataForKey:(NSString *)key {
    [_fileManager removeItemAtPath:[self filePathForKey:key] error:nil];
}

- (void)removeAllData {
    [_fileManager removeItemAtPath:_path error:nil];
    [_fileManager createDirectoryAtPath:_path withIntermediateDirectories:YES attributes:nil error:NULL];
}

- (NSString *)fileNameForKey:(NSString *)key {
    const char *string = [key UTF8String];
    return dwarf_sha1(string, (uint32_t)strlen(string));
}

- (NSString *)filePathForKey:(NSString *)key {
    if (!key.length) {
        return nil;
    }
    return [_path stringByAppendingPathComponent:[self fileNameForKey:key]];
}

- (BOOL)containsDataForKey:(NSString *)key {
    if (!key) {
        return NO;
    }
    return [_fileManager fileExistsAtPath:[self filePathForKey:key]];
}

- (_dwarf_bytes)contentsSize {
    _dwarf_bytes contentsSize = 0;
    NSArray *contents = [self contentsWithResourceKeys:@[NSURLFileAllocatedSizeKey]];
    for (NSURL *fileURL in contents) {
        NSNumber *fileSize;
        [fileURL getResourceValue:&fileSize forKey:NSURLFileAllocatedSizeKey error:NULL];
        contentsSize += [fileSize unsignedLongLongValue];
    }
    return contentsSize;
}

- (NSArray *)contentsWithResourceKeys:(NSArray *)keys {
    NSURL *rootURL = [NSURL fileURLWithPath:_path isDirectory:YES];
    return [_fileManager contentsOfDirectoryAtURL:rootURL includingPropertiesForKeys:keys options:NSDirectoryEnumerationSkipsHiddenFiles error:NULL];
}

@end