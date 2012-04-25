//
//  WSCDDeviceDefinition.h
//  wsabi2
//
//  Created by Matt Aronoff on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WSCDItem;

@interface WSCDDeviceDefinition : NSManagedObject

@property (nonatomic, retain) NSNumber * inactivityTimeout;
@property (nonatomic, retain) NSString * modalities;
@property (nonatomic, retain) NSString * mostRecentSessionId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * parameterDictionary;
@property (nonatomic, retain) NSString * submodalities;
@property (nonatomic, retain) NSDate * timeStampLastEdit;
@property (nonatomic, retain) NSString * uri;
@property (nonatomic, retain) WSCDItem *item;

@end
