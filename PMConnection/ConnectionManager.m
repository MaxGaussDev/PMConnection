//
//  ConnectionManager.m
//  BarIn3
//
//  Created by Poslovanje Kvadrat on 18.12.2014..
//  Copyright (c) 2014. Poslovanje Kvadrat. All rights reserved.
//

#import "ConnectionManager.h"


@implementation ConnectionManager

static ConnectionManager *sharedConnection = nil;


-(id)init{
    self = [super init];
    if(self){
    }
    return self;
}

+(ConnectionManager *)sharedConnection{
    @synchronized(sharedConnection){
        if (sharedConnection == nil || !sharedConnection){
            sharedConnection = [[ConnectionManager alloc] init];
        }
    }
    return sharedConnection;
}




#pragma mark custom methods



#pragma mark connection verification

-(BOOL)isImageReachableFromURL:(NSString *)imgUrl{
    
    // checks if the designated image from url is reachable (slow way, because it will try and make the image)
    
    BOOL chk = FALSE;
    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]];
    if (imgData) {
        UIImage *img = [UIImage imageWithData:imgData];
        if (img) {
            chk = TRUE;
        }else{
            [self updateErrorLogWithString:[NSString stringWithFormat:@"Image for: %@ not valid", imgUrl]];
            chk = FALSE;
        }
    }else{
        [self updateErrorLogWithString:[NSString stringWithFormat:@"Image for: %@ not valid", imgUrl]];
        chk = FALSE;
    }
    
    return  chk;
}

-(BOOL)isServerReachable{
    
    // checks if the designated server is reachable
    
    PMConnection *conn = [[PMConnection alloc] init];
    [conn loadContentsOfFileFromURLWithString:self.connectionUrl];
    
    if (conn.responseObject) {
        return TRUE;
    }else{
        [self updateErrorLogWithString:@"Server not reachable"];
        return FALSE;
    }
}

-(void)updateErrorLogWithString:(NSString *)log{
    NSMutableArray *loggedErrors = [NSMutableArray arrayWithArray: self.errorLogs];
    [loggedErrors addObject:log];
    self.errorLogs = loggedErrors;
}

-(void)showerrorLog{
    NSLog(@"Errors: %@", self.errorLogs.description);
}




#pragma mark caching methods

-(void)cacheResponse:(NSData *)responseData forURLRequest:(NSURL *)urlRequest{
    

        NSString *fullDataURL = [NSString stringWithFormat:@"%@", urlRequest];
        NSString *pathToFullURL = [NSString stringWithFormat:@"%@", urlRequest.URLByDeletingLastPathComponent];
        NSString *fileNameGenerated = [fullDataURL stringByReplacingOccurrencesOfString:pathToFullURL withString:@""];
        NSMutableArray *array_tmp = [NSMutableArray arrayWithArray:self.cahcedResponses];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:fileNameGenerated];
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:dataPath]){
            [responseData writeToFile:dataPath atomically:YES];
            NSDictionary *fileInfoDict = @{
                                           @"name" : fileNameGenerated,
                                           @"requestURL" : [NSString stringWithFormat:@"%@", urlRequest]
                                           };
            [array_tmp addObject:fileInfoDict];
            self.cahcedResponses = array_tmp;
            
            //  store response data to defaults
            // TO DO: find other way for storage
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:self.cahcedResponses forKey:@"pmCache"];
            [defaults synchronize];
        }
    });
}

-(BOOL)checkForCachedResponseForURLRequest:(NSURL *)urlRequest{
    
    BOOL check = FALSE;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if([defaults objectForKey:@"pmCache"]){
            self.cahcedResponses = [defaults objectForKey:@"pmCache"];
            for(NSDictionary *tmp_resp_data in self.cahcedResponses){
                if ([[tmp_resp_data valueForKey:@"requestURL"] isEqualToString:[NSString stringWithFormat:@"%@", urlRequest]]) {
                    
                    NSString *localfilename = [tmp_resp_data valueForKey:@"name"];
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:localfilename];
                    
                    if([[NSFileManager defaultManager] fileExistsAtPath:dataPath]){
                        check = TRUE;
                    }
                }
            }
        }else{
            check = FALSE;
        }
    
    return check;
}


-(NSData *)cachedDataForURLRequest:(NSURL *)urlRequest{

    NSData *data = [[NSData alloc] init];
    
    if([self checkForCachedResponseForURLRequest:urlRequest]){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *cachedarray = [defaults objectForKey:@"pmCache"];
        for(NSDictionary *tmp_cache_data in cachedarray){
            if([[tmp_cache_data valueForKey:@"requestURL"] isEqualToString:[NSString stringWithFormat:@"%@",urlRequest]]){
                NSString *localfilename = [tmp_cache_data valueForKey:@"name"];
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:localfilename];
                //NSLog(@"Image data path: %@", dataPath);
                NSData *tmpDat = [NSData dataWithContentsOfFile:dataPath];
                data = tmpDat;
            }
        }
    }else{
        data = nil;
    }
    return data;
}


-(BOOL)removeCachedDataForURLRequestWithString:(NSString *)urlRequest{

    BOOL check = FALSE;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *cachedarray = [NSMutableArray arrayWithArray:[defaults objectForKey:@"pmCache"]];
    NSMutableArray *cachedarrayToDelete = [NSMutableArray arrayWithArray:cachedarray];
    
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    for(NSDictionary *tmp_cache_data in cachedarray){
        if([[tmp_cache_data valueForKey:@"requestURL"] isEqualToString:urlRequest]){
            
            NSString *localfilename = [tmp_cache_data valueForKey:@"name"];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:localfilename];
            
            if(![[NSFileManager defaultManager] fileExistsAtPath:dataPath]){
                // if there is no file, remove log from cache data
                NSLog(@"File found in cache log, but not on disc, clearing cache record log");
                [cachedarrayToDelete removeObject:tmp_cache_data];
                check = TRUE;
            }else{
                // if the file exsists, delete it and remove record from the data dictionary
                NSLog(@"File found, deleteing and clearing cache record log");
                [[NSFileManager defaultManager] removeItemAtPath:dataPath error:nil];
                [cachedarrayToDelete removeObject:tmp_cache_data];
                check = TRUE;
            }
        }else{
            // request isn't in the cache records log
            NSLog(@"Request not found in the cache data log. - %@", urlRequest);
        }
    } //});
    
    cachedarray = cachedarrayToDelete;
    
    [defaults setObject:cachedarray forKey:@"pmCache"];
    [defaults synchronize];
    
    return check;
}

#pragma mark image chaching methods

-(UIImage *)fetchImageWithCacheFromURLWithString:(NSString *)urlString{

    NSURL *imgURL = [NSURL URLWithString:urlString];
    UIImage *img = [self fetchImageWithCacheFromURL:imgURL];
    return img;
}



-(UIImage *)fetchImageWithCacheFromURL:(NSURL *)imgURL{
    
  if([self checkForCachedResponseForURLRequest:imgURL]){
      UIImage *img = [self cachedImageForURLRequest:imgURL];
      return img;
   }else{
      NSData *imgData = [NSData dataWithContentsOfURL:imgURL];
      UIImage *img = [UIImage imageWithData:imgData];
      [self cacheResponse:imgData forURLRequest:imgURL];
      return img;
   }
}



-(UIImage *)cachedImageForURLRequest:(NSURL *)imgURL{
    UIImage *image = [[UIImage alloc] init];
    if([self checkForCachedResponseForURLRequest:imgURL]){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *cachedarray = [defaults objectForKey:@"pmCache"];
        for(NSDictionary *tmp_cache_data in cachedarray){
            if([[tmp_cache_data valueForKey:@"requestURL"] isEqualToString:[NSString stringWithFormat:@"%@",imgURL]]){
                NSString *localfilename = [tmp_cache_data valueForKey:@"name"];
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:localfilename];
                //NSLog(@"Image data path: %@", dataPath);
                UIImage *img = [UIImage imageWithContentsOfFile:dataPath];
                image = img;
            }
        }
    }
    return image;
}


#pragma mark chache managing and maintenance

-(NSString *)cacheDirectory{

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //NSLog(@"docs directory: %@", documentsDirectory);
    return  documentsDirectory;
}

-(void)clearCache{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *cachedarray = [defaults objectForKey:@"pmCache"];
    for(NSDictionary *tmp_cache_data in cachedarray){
        
        NSString *localfilename = [tmp_cache_data valueForKey:@"name"];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:localfilename];
        
       // NSLog(@"found cached url: %@", [tmp_cache_data valueForKey:@"requestURL"]);
       // NSLog(@"cached data path: %@", dataPath);
        
        if([[NSFileManager defaultManager] removeItemAtPath:dataPath error:nil]){
          //  NSLog(@"Cached data removed for request: %@", [tmp_cache_data valueForKey:@"requestURL"]);
        }else{
            NSLog(@"Error while removing request: %@", [tmp_cache_data valueForKey:@"requestURL"]);
        }
 
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"pmCache"];
    NSLog(@"Cache data cleared");
}


-(float)cacheSize{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *cachedarray = [defaults objectForKey:@"pmCache"];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    unsigned long long sizeFull = 0;
    
    for(NSDictionary *tmp_cache_data in cachedarray){
        
        NSString *localfilename = [tmp_cache_data valueForKey:@"name"];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:localfilename];
        
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:dataPath error:nil];
        
        if (fileAttributes != nil) {
            NSNumber *fileSize;
            if ((fileSize = [fileAttributes objectForKey:NSFileSize])) {
                //NSLog(@"File size for file: %@: %qi\n",[tmp_cache_data valueForKey:@"name"], [fileSize unsignedLongLongValue]);
                sizeFull = sizeFull + [fileSize unsignedLongLongValue];
            }
        }else{
          //  NSLog(@"Path (%@) is invalid.", dataPath);
          //  TO DO: clear from cache log in this case
        }
    }
    
    return (float)sizeFull/1024;
}



@end
