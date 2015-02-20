//
//  PMConnection.m
//  Porch Monkey Connection Class for JSON response
//
//  Created by Poslovanje Kvadrat on 8.7.2014..
//  Copyright (c) 2014. Poslovanje Kvadrat. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "PMConnection.h"

@implementation PMConnection

#pragma mark  Request methods

-(void)sendRequestWithStringParameters{

    if ([self.method isEqualToString:@"POST"]) {
        //NSLog(@"Request method: %@", self.method);
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]];
        NSString *params = self.parametersWithString;
        [request setHTTPMethod:self.method];
        [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
        [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
        NSURLResponse* response;
        NSError* error = nil;
        
        //Capturing server response
        
            self.responseResult = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
            self.responseData = self.responseResult;
            NSString *rawString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
            self.responseStringRaw = rawString;
            //RESOLVE JSON XML
            if ([response.MIMEType hasPrefix:@"application/xml"]) {
                // NSLog(@"XML");
                [self manageXMLResponse];
            }else if ([response.MIMEType hasPrefix:@"application/json"]){
                // NSLog(@"JSON");
                [self manageJSONResponse];
            }else{
                NSLog(@"Wrong document header = %@", response.MIMEType);
            }
    }else if([self.method isEqualToString:@"GET"]){
        
        //NSLog(@"Request method: %@", self.method);
        
        NSString *q = @"?";
        NSString *urlString = self.url;
        NSString *urlStringQ = [NSString stringWithFormat:@"%@%@", urlString, q];
        NSString *urlStringWithParams = [NSString stringWithFormat:@"%@%@", urlStringQ, self.parametersWithString];
        
        NSString *stringC = [urlStringWithParams stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *stringCo = [stringC stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        urlStringWithParams = stringCo;
        //REQUEST URL FOR GET METHOD CHECK
        //NSLog(@"REQUEST STRING: %@", urlStringWithParams);
        [self loadContentsOfFileFromURLWithString:urlStringWithParams];
        
    }else{
        //IF THE REQUEST METHOD ISN'T SPECIFIED OR SUPPORTED
        NSLog(@"Unknown request method: %@", self.method);
    }
}

-(void)manageJSONResponse{
    NSError* error = nil;
    self.responseObject = [NSJSONSerialization
                           JSONObjectWithData:self.responseData
                           options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                           error:&error];
    if ([self.responseObject isKindOfClass:[NSArray class]]) {
        self.responseArray = (NSArray *)self.responseObject;
        self.responseString = self.responseArray.description;
    }
    else {
        self.responseDictionary = (NSDictionary *)self.responseObject;
        self.responseString = self.responseDictionary.description;
    }
}

-(void)manageXMLResponse{
    NSData * data = self.responseData;
    NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLData:data error:nil];
    self.responseDictionary = xmlDictionary;
    self.responseString = self.responseDictionary.description;
}

-(void)sendRequestWithParameters{
    
    NSString *recheckForPlusFilter = [[NSString alloc] init];
    NSArray * parameterKeys = [[NSMutableArray alloc] init];
    NSArray * parameterValues = [[NSMutableArray alloc] init];
    
    parameterKeys = [self.parameters allKeys];
    parameterValues = [self.parameters allValues];
    
    NSMutableString *preRequestString = [NSMutableString stringWithFormat:@""];
    
    for (int i=0; i< [parameterKeys count]; i++) {
    
    if ([[parameterValues objectAtIndex:i] isKindOfClass:[NSString class]]){
        recheckForPlusFilter = [[parameterValues objectAtIndex:i] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        NSString *keyAndValue = [NSString stringWithFormat:@"%@=%@", [parameterKeys objectAtIndex:i], recheckForPlusFilter];
        if (i==0) {
            [preRequestString appendString:keyAndValue];
        }else{
            [preRequestString appendString:[NSString stringWithFormat:@"&%@", keyAndValue]];
        }
        
    }else{
        NSString *keyAndValue = [NSString stringWithFormat:@"%@=%@", [parameterKeys objectAtIndex:i], [parameterValues objectAtIndex:i]];
        if (i==0) {
            [preRequestString appendString:keyAndValue];
        }else{
            [preRequestString appendString:[NSString stringWithFormat:@"&%@", keyAndValue]];
        }
    }
    }
    self.parametersWithString = preRequestString;
    [self sendRequestWithStringParameters];
}

-(void)sendRequestWithParameters:(NSDictionary *)parametersDictionary withMethod: (NSString *)method withStringURL: (NSString *)urlString{
    
    self.method = method;
    self.parameters = parametersDictionary;
    self.url = urlString;
    [self sendRequestWithParameters];
    
}

-(void)sendRequestWithParameters:(NSDictionary *)parametersDictionary{
    
    self.parameters = parametersDictionary;
    [self sendRequestWithParameters];
    
}

-(void)sendRequestWithParameters:(NSDictionary *)parametersDictionary withMethod: (NSString *)method withNSURL: (NSURL *)url{
    
    self.method = method;
    self.parameters = parametersDictionary;
    self.url = [NSString stringWithFormat:@"%@",url];
    [self sendRequestWithParameters];
    
}

-(void)responseObjectClass{
    NSString *className = NSStringFromClass([self.responseObject class]);
    NSLog(@"Response Object for *%@*: is %@ Class", self.requestDescription, className);
}


#pragma mark  XML JSON STRIG REQUESTS

-(void)sendXMLRequestWithString:(NSString *)string forURLWithString:(NSString *)stringURL {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:stringURL]];
    
    [request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    [request setHTTPBody:[string dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLResponse* response;
    NSError* error = nil;
    
    
    NSLog(@"REQUEST: %@", string);
    //Capturing server response
    
    self.responseResult = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
    self.responseData = self.responseResult;
    NSString *rawString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
    self.responseStringRaw = rawString;
    //RESOLVE JSON XML
    if ([response.MIMEType hasPrefix:@"text/xml"]) {
        // NSLog(@"XML");
        [self manageXMLResponse];
    }else if ([response.MIMEType hasPrefix:@"application/json"]){
        // NSLog(@"JSON");
        [self manageJSONResponse];
    }else{
        NSLog(@"Wrong document header = %@", response.MIMEType);
        [self manageXMLResponse];
    }
    
}


#pragma mark file contents

-(void)loadContentsOfFileFromURLWithString:(NSString *)urlString{
    NSString *fileString = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    NSString *string = fileString;
    if (!string) {
        NSLog(@"File couldn't be read!");
        NSLog(@"GET Request path could be wrong, check url index file!");
        return;
    }else{
        //NSLog(@"File could be read!");
        self.responseStringRaw = string;
        //NSLog(@"FILE CONTENTS: %@", self.responseStringRaw);
        NSData *dataFromFile = [string dataUsingEncoding:NSUTF8StringEncoding];
        self.responseData = dataFromFile;
        //NSLog(@"DATA CONTENTS: %@", dataFromFile);
        
        //RESOLVE JSON XML FROM GET METHOD OR FILE
        NSError* errorForGet = nil;
        self.responseObject = [NSJSONSerialization
                               JSONObjectWithData:self.responseData
                               options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                               error:&errorForGet];
        if (!self.responseObject) {
            // NSLog(@"Coudln't read JSON Data checking for XML");
            NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLData:self.responseData error:nil];
            if (!xmlDictionary) {
                NSLog(@"Coudln't read XML Data");
            }else{
                [self manageXMLResponse];
            }
        }else{
            [self manageJSONResponse];
        }
    }
}




@end
