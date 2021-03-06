//
//  NativityControl.h
//  LiferayNativityClient
//
//  Created by Charles Francoise on 05/02/14.
/**
 * Copyright (c) 2014 Forgetbox. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */

#import <Foundation/Foundation.h>

#import "GCDAsyncSocket.h"

@protocol CommandListener;
@class NativityMessage;

@interface NativityControl : NSObject <GCDAsyncSocketDelegate>

@property (nonatomic, readonly) BOOL loaded;
@property (nonatomic, readonly) BOOL connected;

+ (id)sharedInstance;

- (id)init;

- (BOOL)connect;
- (BOOL)disconnect;

- (NSData*)sendData:(NSData*)data;
- (NSData*)sendMessage:(NativityMessage*)message;
- (NSData*)sendMessageWithCommand:(NSString*)command andValue:(id)value;

- (void)addListener:(id<CommandListener>)listener forCommand:(NSString*)command;
- (void)removeListener:(id<CommandListener>)listener forCommand:(NSString*)command;

- (BOOL)load;
- (BOOL)unload;

- (void)setFilterPath:(NSString*)filterPath;
- (long)registerImage:(NSString*)imagePath;
- (void)unregisterImage:(long)imageId;

@end
