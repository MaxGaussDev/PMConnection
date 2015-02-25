//
//  ConnectionManager.h
//  BarIn3
//
//  Created by Poslovanje Kvadrat on 18.12.2014..
//  Copyright (c) 2014. Poslovanje Kvadrat. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "PMConnection.h"
#import "PMTools.h"

@interface ConnectionManager : NSObject

#pragma mark Shared Connection singleton

+(ConnectionManager *)sharedConnection;

#pragma mark connection properties

@property (nonatomic, strong) NSString* baseConnectionUrl;
@property (nonatomic, strong) NSString* connectionUrl;

@property (nonatomic, strong) NSArray *errorLogs;
@property (nonatomic, strong) NSArray *cahcedResponses;

#pragma mark custom Connection Managing methods



#pragma mark connection verification

-(BOOL)isImageReachableFromURL:(NSString *)imgUrl;
-(BOOL)isServerReachable;
-(void)updateErrorLogWithString:(NSString *)log;
-(void)showerrorLog;


#pragma mark caching methods

-(void)cacheResponse:(NSData *)responseData forURLRequest:(NSURL *)urlRequest;
-(BOOL)checkForCachedResponseForURLRequest:(NSURL *)urlRequest;
-(NSData *)cachedDataForURLRequest:(NSURL *)urlRequest;
-(BOOL)removeCachedDataForURLRequestWithString:(NSString *)urlRequest;

#pragma mark caching
-(UIImage *)cachedImageForURLRequest:(NSURL *)imgURL;
-(UIImage *)fetchImageWithCacheFromURLWithString:(NSString *)urlString;
-(UIImage *)fetchImageWithCacheFromURL:(NSURL *)imgURL;

#pragma mark managing and maintenance
-(NSString *)cacheDirectory;
-(void)clearCache;
-(float)cacheSize;


@end
