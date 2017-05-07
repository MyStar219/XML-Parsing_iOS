//
//  Mission.h
//  Kanotguiden-2
//
//  Created by Prince on 5/3/17.
//  Copyright © 2017 developteam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Mission : NSObject
@property (nonatomic, strong) NSString *missionTitle;
@property (nonatomic, strong) NSString *missionDescription;
@property (nonatomic, strong) NSString *missionUrl;
@property (nonatomic, strong) NSString *missionLat;
@property (nonatomic, strong) NSString *missionLon;
@end
