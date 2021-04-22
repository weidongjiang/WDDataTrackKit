//
//  HTDTNetwork.h
//
//  Copyright (c) 2012-2016 HTDTNetwork https://github.com/yuantiku
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <Foundation/Foundation.h>

#ifndef _HTDTNETWORK_
    #define _HTDTNETWORK_

#if __has_include(<HTDTNetwork/HTDTNetwork.h>)

    FOUNDATION_EXPORT double HTDTNetworkVersionNumber;
    FOUNDATION_EXPORT const unsigned char HTDTNetworkVersionString[];

    #import <HTDTNetwork/HTDTRequest.h>
    #import <HTDTNetwork/HTDTBaseRequest.h>
    #import <HTDTNetwork/HTDTNetworkAgent.h>
    #import <HTDTNetwork/HTDTBatchRequest.h>
    #import <HTDTNetwork/HTDTBatchRequestAgent.h>
    #import <HTDTNetwork/HTDTChainRequest.h>
    #import <HTDTNetwork/HTDTChainRequestAgent.h>
    #import <HTDTNetwork/HTDTNetworkConfig.h>

#else

    #import "HTDTRequest.h"
    #import "HTDTBaseRequest.h"
    #import "HTDTNetworkAgent.h"
    #import "HTDTBatchRequest.h"
    #import "HTDTBatchRequestAgent.h"
    #import "HTDTChainRequest.h"
    #import "HTDTChainRequestAgent.h"
    #import "HTDTNetworkConfig.h"

#endif /* __has_include */

#endif /* _HTDTNETWORK_ */
