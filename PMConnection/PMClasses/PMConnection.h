//
//  PMConnection.h
//  Porch Monkey Connection Class for JSON response
//
//  Created by Poslovanje Kvadrat on 8.7.2014..
//  Copyright (c) 2014. Poslovanje Kvadrat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLReader.h"

@interface PMConnection : NSObject

#pragma mark Request parameters
@property (nonatomic, strong) NSDictionary *parameters;

#pragma mark Request variables
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *parametersWithString;
@property (nonatomic, strong) NSString *method;
@property (nonatomic, strong) NSString *requestDescription;
@property (nonatomic, strong) NSString *requestJSONdata;
@property (retain, nonatomic) NSURLConnection *connection;

#pragma mark Response variables
@property (nonatomic, strong) NSData *responseResult;
@property (nonatomic, strong) NSString *responseString;
@property (nonatomic, strong) NSArray *responseArray;
@property (nonatomic, strong) NSDictionary *responseDictionary;
@property (nonatomic, strong) id responseObject;
@property (nonatomic, strong) NSData *responseData;
@property (nonatomic, strong) NSString *responseStringRaw;

#pragma mark  Request methods
-(void)sendRequestWithParameters:(NSDictionary *)parametersDictionary withMethod: (NSString *)method withStringURL: (NSString *)urlString;
-(void)sendRequestWithParameters:(NSDictionary *)parametersDictionary withMethod: (NSString *)method withNSURL: (NSURL *)url;
-(void)loadContentsOfFileFromURLWithString:(NSString *)urlString;

#pragma mark  XML JSON STRIG REQUESTS
-(void)sendXMLRequestWithString:(NSString *)string forURLWithString:(NSString *)stringURL;

#pragma mark  Response handling methods
- (void)responseObjectClass;



@end
