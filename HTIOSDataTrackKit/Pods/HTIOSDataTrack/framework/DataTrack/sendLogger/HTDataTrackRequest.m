//
//  HTDataTrackRequest.m
//  HTIOSDataTrackKit
//
//  Created by 伟东 on 2020/9/7.
//  Copyright © 2020 伟东. All rights reserved.
//

#import "HTDataTrackRequest.h"

@implementation HTDataTrackRequest
- (NSString *)requestUrl {
    return @"https://datacenter.hetao101.com/app/eventdata/transfer/v1";
}

- (HTDTRequestMethod)requestMethod {
    return HTDTRequestMethodPOST;
}

- (NSURLRequest *)buildCustomUrlRequest {

    NSData *rawData = self.rawData;
    NSString *requestStr = self.requestUrl;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestStr]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:rawData];
    
    return request;
    
}
@end
