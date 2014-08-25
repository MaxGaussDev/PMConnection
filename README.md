HOW TO USE:

Including library into the view controller:

#import "PMConnection.h"


Sending synchronous request: 

PMConnection *pm = [[PMConnection alloc] init];
    NSDictionary * testDict = @{
                                @"username" : @"somstring" ,
                                @"somekey"  : @"somevalue"
                                };
    
[pm sendRequestWithParameters:testDict withMethod:@"POST" withStringURL:@"http://your-url-goes-here"];


Handling response:

NSLog(@"Response: %@", pm.responseString);

(Optional, will be set automatically): 

NSLog(@"Response NS Dictionary: %@", pm.responseDictionary);
NSLog(@"Response NS Array: %@", pm.responseArray);
NSLog(@"Response NS Data: %@", pm.responseData);

NSLog(@"Response raw response: %@", pm.responseStringRaw);

JSON or XML Requests will be handled automaticaly and stored into dictionary or array. If response headers aren't set to "application/json" or "application/xml" - response will be NULL! 



******** Sending asynchronous request:

- (IBAction)testAction:(id)sender{
    // SETTING UP ASYNC CONNECTION WITH STANDARD PMCONNECTION
    NSOperationQueue *queue = [NSOperationQueue new];
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadDataWithOperation) object:nil];
    [queue addOperation:operation];
}

- (void) loadDataWithOperation {
    PMConnection *pm = [[PMConnection alloc] init];
    [pm loadContentsOfFileFromURLWithString:@"http://www.url-to-file-goes-here"];
    NSLog(@"Result of large request with Async connection: %@", pm.responseString);
}


Handling response is the same as it is with synchronous connection. 



METHODS THAT COULD BE USED ADDITIONALLY: 

-(void)sendRequestWithStringParameters;
-(void)sendRequestWithParameters;
-(void)sendRequestWithParameters:(NSDictionary *)parametersDictionary;
-(void)sendRequestWithParameters:(NSDictionary *)parametersDictionary withMethod: (NSString *)method withStringURL: (NSString *)urlString;
-(void)sendRequestWithParameters:(NSDictionary *)parametersDictionary withMethod: (NSString *)method withNSURL: (NSURL *)url;

-(void)generateJSONRequestWith:(NSDictionary *)dictionary toUrlWithString: (NSString *)stringUrl withMethod: (NSString *)method;
-(void)loadContentsOfFileFromURLWithString:(NSString *)urlString;


HELPING ADDITIONAL METHODS:

- (NSString *) md5:(NSString *)input;
- (NSString *) encodeImageToBase64: (UIImage *)image;
- (UIImage *) imageByScalingAndCroppingForSize:(CGSize)targetSize forImage:(UIImage *)sourceImage;
- (NSString *) checkGUDCode;
