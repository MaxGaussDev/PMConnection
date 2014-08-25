//
//  PMConnection.h
//  Porch Monkey Connection Class for JSON response
//
//  Created by Poslovanje Kvadrat on 8.7.2014..
//  Copyright (c) 2014. Poslovanje Kvadrat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import "XMLReader.h"
#import "Base64.h"

@interface PMConnection : NSObject

// Request parameters
@property (nonatomic, weak) NSDictionary *parameters;

// Request variables
@property (nonatomic, weak) NSString *url;
@property (nonatomic, weak) NSString *parametersWithString;
@property (nonatomic, weak) NSString *method;
@property (nonatomic, weak) NSString *requestDescription;
@property (nonatomic, weak) NSString *requestJSONdata;
@property (retain, nonatomic) NSURLConnection *connection;

// Response variables
@property (nonatomic, weak) NSData *responseResult;
@property (nonatomic, weak) NSString *responseString;
@property (nonatomic, weak) NSArray *responseArray;
@property (nonatomic, weak) NSDictionary *responseDictionary;
@property (nonatomic, weak) id responseObject;
@property (nonatomic, weak) NSData *responseData;
@property (nonatomic, weak) NSString *responseStringRaw;

// Request methods
-(void)sendRequestWithStringParameters;
-(void)sendRequestWithParameters;
-(void)sendRequestWithParameters:(NSDictionary *)parametersDictionary;
-(void)sendRequestWithParameters:(NSDictionary *)parametersDictionary withMethod: (NSString *)method withStringURL: (NSString *)urlString;
-(void)sendRequestWithParameters:(NSDictionary *)parametersDictionary withMethod: (NSString *)method withNSURL: (NSURL *)url;

-(void)generateJSONRequestWith:(NSDictionary *)dictionary toUrlWithString: (NSString *)stringUrl withMethod: (NSString *)method;
-(void)loadContentsOfFileFromURLWithString:(NSString *)urlString;

// Response handling methods
- (void)responseObjectClass;

// HELPING ADDITIONAL METHODS
- (NSString *) md5:(NSString *)input;
- (NSString *) encodeImageToBase64: (UIImage *)image;
- (UIImage *) imageByScalingAndCroppingForSize:(CGSize)targetSize forImage:(UIImage *)sourceImage;
- (NSString *) checkGUDCode;

@end
