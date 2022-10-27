// Copyright 2016-present 650 Industries. All rights reserved.

#import <EXLocation/EXForegroundPermissionRequester.h>
#import <ExpoModulesCore/EXUtilities.h>

#import <objc/message.h>
#import <CoreLocation/CLLocationManagerDelegate.h>

static SEL whenInUseAuthorizationSelector;

@implementation EXForegroundPermissionRequester

+ (NSString *)permissionType
{
  return @"locationForeground";
}

+ (void)load
{
  whenInUseAuthorizationSelector = NSSelectorFromString([@"request" stringByAppendingString:@"WhenInUseAuthorization"]);
}

- (void)requestLocationPermissions
{
  if ([EXBaseLocationRequester isConfiguredForWhenInUseAuthorization] && [self.locationManager  respondsToSelector:whenInUseAuthorizationSelector]) {
    ((void (*)(id, SEL))objc_msgSend)(self.locationManager, whenInUseAuthorizationSelector);
  } else {
    self.reject(@"ERR_LOCATION_INFO_PLIST", @"The `NSLocationWhenInUseUsageDescription` key must be present in Info.plist to be able to use geolocation.", nil);
    
    self.resolve = nil;
    self.reject = nil;
  }
}

- (NSDictionary *)parsePermissions:(CLAuthorizationStatus)systemStatus
{
    EXPermissionStatus status;
    NSString *scope = @"none";
    
    switch (systemStatus) {
        case kCLAuthorizationStatusAuthorizedWhenInUse: {
            status = EXPermissionStatusGranted;
            scope = @"whenInUse";
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways: {
            status = EXPermissionStatusGranted;
            scope = @"always";
            break;
        }
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted: {
            status = EXPermissionStatusDenied;
            break;
        }
        case kCLAuthorizationStatusNotDetermined:
        default: {
            status = EXPermissionStatusUndetermined;
            break;
        }
    }
    
    return @{
        @"status": @(status),
        @"scope": scope
    };
}

@end
