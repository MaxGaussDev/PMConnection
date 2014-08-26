#Porch Monkey Connection

Small Connection class for XCode that handles server request and response. PMConnection can handle GET and POST requests and it will return NSArray or NSDictionary automatically from either XML or JSON response.

#Importing

Insert PMConnection folder into your project and import the PMConnection.h class where you want it.

```
#import PMConnection.h
```

#How to use

PMConnection is by default synchronous connection. 

```

    NSDictionary *stuff = @{
                            @"key" : @"value",
                            @"key" : @"value" ,
                            @"key" : @"value"
                            };

    PMConnection *myconnection = [[PMConnection alloc] init];
    
    [myconnection sendRequestWithParameters:stuff withMethod:@"POST" withStringURL:@"url-goes-here"];
    
    NSLog(@"SERVER RESPONSE: %@", myconnection.responseString);
    NSDictionary *response = myconnection.responseDictionary;
    
    //Handle the dictionary stuff here

```
Available request methods are both POST and GET, they are handled automatically from the dictionary.

Types of response properties:

```
(NSString) responseString - dictionary or array description
(NSString) responseStringRaw - raw JSON or XML string as returned from the server

(NSArray) responseArray - only if the JSON response is returned as an array
(NSDictionary) responseDictionary - default for XML

(id) responseObject 
(NSData) responseData 

```

Making asynchronous request can be handled via NSOperationQueue for larger responses:

```
- (void)getResponse{

      NSOperationQueue *queue = [NSOperationQueue new];
      NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self     selector:@selector(getResponse) object:nil];
      [queue addOperation:operation];
      
}

- (void)getResponse{

    NSDictionary *stuff = @{
                            @"key" : @"value",
                            @"key" : @"value" ,
                            @"key" : @"value"
                            };

    PMConnection *myconnection = [[PMConnection alloc] init];
    [myconnection sendRequestWithParameters:stuff withMethod:@"POST" withStringURL:@"url-goes-here"];
    
    NSLog(@"SERVER RESPONSE: %@", myconnection.responseString);
}
    
```

Methods for handling requests:

```
-(void)sendRequestWithParameters:(NSDictionary *)parametersDictionary;
-(void)sendRequestWithParameters:(NSDictionary *)parametersDictionary withMethod: (NSString *)method withStringURL: (NSString *)urlString;
-(void)sendRequestWithParameters:(NSDictionary *)parametersDictionary withMethod: (NSString *)method withNSURL: (NSURL *)url;
-(void)loadContentsOfFileFromURLWithString:(NSString *)urlString;

```

Additional methods for other stuff that comes in handy sometimes: 

MD5 code encryption, Base64 image conversion and Image Scaling. These methods will probably get upgraded over time.

```
- (NSString *) md5:(NSString *)input;
- (NSString *) encodeImageToBase64: (UIImage *)image;
- (UIImage *) imageByScalingAndCroppingForSize:(CGSize)targetSize forImage:(UIImage *)sourceImage;

```

