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
@property (nonatomic, strong) NSDictionary *parameters;

// Request variables
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *parametersWithString;
@property (nonatomic, strong) NSString *method;
@property (nonatomic, strong) NSString *requestDescription;
@property (nonatomic, strong) NSString *requestJSONdata;
@property (retain, nonatomic) NSURLConnection *connection;

// Response variables
@property (nonatomic, strong) NSData *responseResult;
@property (nonatomic, strong) NSString *responseString;
@property (nonatomic, strong) NSArray *responseArray;
@property (nonatomic, strong) NSDictionary *responseDictionary;
@property (nonatomic, strong) id responseObject;
@property (nonatomic, strong) NSData *responseData;
@property (nonatomic, strong) NSString *responseStringRaw;

// Request methods

-(void)sendRequestWithParameters:(NSDictionary *)parametersDictionary withMethod: (NSString *)method withStringURL: (NSString *)urlString;
-(void)sendRequestWithParameters:(NSDictionary *)parametersDictionary withMethod: (NSString *)method withNSURL: (NSURL *)url;
-(void)loadContentsOfFileFromURLWithString:(NSString *)urlString;


// Response handling methods
- (void)responseObjectClass;



// HELPING ADDITIONAL METHODS
- (NSString *) md5:(NSString *)input;
- (NSString *) encodeImageToBase64: (UIImage *)image;
- (UIImage *) imageByScalingAndCroppingForSize:(CGSize)targetSize forImage:(UIImage *)sourceImage;


//TO DO OR TO UPGRADE
-(void)generateJSONRequestWith:(NSDictionary *)dictionary toUrlWithString: (NSString *)stringUrl;
- (NSString *) checkGUDCode;


@end
