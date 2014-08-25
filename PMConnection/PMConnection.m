//
//  PMConnection.m
//  Porch Monkey Connection Class for JSON response
//
//  Created by Poslovanje Kvadrat on 8.7.2014..
//  Copyright (c) 2014. Poslovanje Kvadrat. All rights reserved.
//

#import "PMConnection.h"

@implementation PMConnection

// CONNECTION REQUEST STUFF

-(void)sendRequestWithStringParameters{

    if ([self.method isEqualToString:@"POST"]) {
        //NSLog(@"Request method: %@", self.method);
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]];
        NSString *params = self.parametersWithString;
        [request setHTTPMethod:self.method];
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
        //NSLog(@"RESPONSE ARRAY FOR *%@*: %@",self.requestDescription, self.responseArray);
    }
    else {
        self.responseDictionary = (NSDictionary *)self.responseObject;
        self.responseString = self.responseDictionary.description;
        //NSLog(@"RESPONSE DICTIONARY FOR *%@*: %@",self.requestDescription, self.responseDictionary);
    }
}

-(void)manageXMLResponse{
    NSData * data = self.responseData;
    NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLData:data error:nil];
    self.responseDictionary = xmlDictionary;
//    NSLog(@"RESPONSE DATA RAW: %@", self.responseData);
//    NSLog(@"RESPONSE DATA: %@", data);
//    NSLog(@"RESPONSE DICT: %@", xmlDictionary);
    self.responseString = self.responseDictionary.description;
}

-(void)sendRequestWithParameters{
    
    NSArray * parameterKeys = [[NSMutableArray alloc] init];
    NSArray * parameterValues = [[NSMutableArray alloc] init];
    
    parameterKeys = [self.parameters allKeys];
    parameterValues = [self.parameters allValues];
    
    NSMutableString *preRequestString = [NSMutableString stringWithFormat:@""];
    
    for (int i=0; i< [parameterKeys count]; i++) {
        
        //NSLog(@"%@ :: %@", [parameterKeys objectAtIndex:i], [parameterValues objectAtIndex:i]);
        NSString *keyAndValue = [NSString stringWithFormat:@"%@=%@", [parameterKeys objectAtIndex:i], [parameterValues objectAtIndex:i]];
        if (i==0) {
            [preRequestString appendString:keyAndValue];
        }else{
            [preRequestString appendString:[NSString stringWithFormat:@"&%@", keyAndValue]];
        }
    }
    
    //NSLog(@"PARAMETERS FOR REQUEST: %@", preRequestString);
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

// JSON GENERATED REQUESTS

-(void)generateJSONRequestWith:(NSDictionary *)dictionary toUrlWithString: (NSString *)stringUrl withMethod: (NSString *)method{

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error while generating JSON: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        self.requestJSONdata = jsonString;
        self.method = method;
        NSDictionary * paramsTemp = @{
                                    @"JSON" : jsonString ,
                                    };
        self.parameters = paramsTemp;
        self.url = [NSString stringWithFormat:@"%@",stringUrl];
        [self sendRequestWithParameters];
        
        //JSON GENERATION CHECKS
        //NSLog(@"REQUEST IS: %@",  self.requestJSONdata);
        //NSLog(@"GENERATED REQUEST IS: %@",  self.parametersWithString);
    }
}

// ADDITIONAL HELPING METHODS

- (NSString *) md5:(NSString *)input{
    
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}


- (NSString *) encodeImageToBase64: (UIImage *)image{
    NSData* imagedata = UIImageJPEGRepresentation(image, 0.5f);
    NSString *imageencoded = [Base64 encode:imagedata];
    imageencoded = [imageencoded stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"]; // WHY APPLE WHY???
    return imageencoded;
}


- (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize forImage:(UIImage *)sourceImage
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
        {
            scaleFactor = widthFactor; // scale to fit height
        }
        else
        {
            scaleFactor = heightFactor; // scale to fit width
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
        {
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil)
    {
        NSLog(@"could not scale image");
    }
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (NSString *) checkGUDCode{

    NSDictionary* errorlist= @{
                               @"100" : @"Continue" ,
                               @"101" : @"Switching Protocols" ,
                               @"200" : @"OK" ,
                               @"201" : @"Created" ,
                               @"202" : @"Accepted" ,
                               @"203" : @"Non-Authoritative Information" ,
                               @"204" : @"No Content" ,
                               @"205" : @"Reset Content" ,
                               @"206" : @"Partial Content" ,
                               @"300" : @"Multiple Choices" ,
                               @"301" : @"Moved Permanently" ,
                               @"302" : @"Found" ,
                               @"303" : @"See Other" ,
                               @"304" : @"Not Modified" ,
                               @"305" : @"Use Proxy" ,
                               @"306" : @"Missing action" ,
                               @"307" : @"Temporary Redirect" ,
                               @"400" : @"Bad Request" ,
                               @"401" : @"Unauthorized" ,
                               @"402" : @"Payment Required" ,
                               @"403" : @"Forbidden" ,
                               @"404" : @"Not Found" ,
                               @"405" : @"Method Not Allowed" ,
                               @"406" : @"Not Acceptable" ,
                               @"407" : @"Proxy Authentication Required" ,
                               @"408" : @"Request Timeout" ,
                               @"409" : @"Conflict" ,
                               @"410" : @"Gone" ,
                               @"411" : @"Length Required" ,
                               @"412" : @"Precondition Failed" ,
                               @"413" : @"Request Entity Too Large" ,
                               @"414" : @"Request-URI Too Long" ,
                               @"415" : @"Unsupported Media Type" ,
                               @"416" : @"Requested Range Not Satisfiable" ,
                               @"417" : @"Expectation Failed" ,
                               @"500" : @"Internal Server Error" ,
                               @"501" : @"Not Implemented" ,
                               @"502" : @"Bad Gateway" ,
                               @"503" : @"Service Unavailable" ,
                               @"504" : @"Gateway Timeout" ,
                               @"505" : @"HTTP Version Not Supported" ,
                               @"600" : @"Out of date" ,
                               @"700" : @"Missing parameters" ,
                               @"701" : @"Allready pending" ,
                               @"800" : @"Declined" ,
                               @"801" : @"Invalid username" ,
                               @"802" : @"Invalid email" ,
                               @"802" : @"Missing video URL"
     };
    NSString * resultString = [[NSString alloc] init];
    if (!self.responseDictionary) {
        resultString = nil;
    }else{
        if (![self.responseDictionary valueForKey:@"EchoRequest"]) {
            
            NSNumber * codeValue = [self.responseDictionary valueForKey:@"code"];
            resultString = [errorlist valueForKey:[NSString stringWithFormat:@"%@", codeValue]];
            
        }else{
            NSDictionary *EchoRequest = [self.responseDictionary valueForKey:@"EchoRequest"];
            NSDictionary *Error = [EchoRequest valueForKey:@"Error"];
            NSDictionary *Code = [Error valueForKey:@"code"];
            NSNumber *code = [Code valueForKey:@"value"];
            resultString = [errorlist valueForKey:[NSString stringWithFormat:@"%@", code]];
        }
    }
    return resultString;
}

@end
