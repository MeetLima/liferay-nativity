//
//  LiferayNativityClientTests.m
//  LiferayNativityClientTests
//
//  Created by Charles Francoise on 05/02/14.
//  Copyright (c) 2014 Charles Francoise. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LiferayNativityClient.h"

@interface LiferayNativityClientTests : XCTestCase

@end

@implementation LiferayNativityClientTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NativityControl* nativityControl = [NativityControl sharedInstance];
    XCTAssert([nativityControl load], @"Could not load Nativity");
    XCTAssert([nativityControl loaded], @"Nativity not loaded during setup");
    XCTAssert([nativityControl connect], @"Could not connect to Nativity");
}

- (void)tearDown
{
    NativityControl* nativityControl = [NativityControl sharedInstance];
    XCTAssert([nativityControl loaded], @"Nativity not loaded during teardown");
    [nativityControl disconnect];
    XCTAssert([nativityControl unload], @"Could not unload Nativity");
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFileIcons
{
    NativityControl* nativityControl = [NativityControl sharedInstance];
    [nativityControl setFilterPath:@"/Users/chrales/Work/lima/overlay-test"];
    
    FileIconControl* fileIconControl = [[[FileIconControl alloc] initWithNativityControl:nativityControl] autorelease];
    
    [fileIconControl enableFileIcons];
    
    long iconId = [fileIconControl registerIcon:@"/Users/chrales/Work/lima/overlay-test/test_icon.icns"];
    
    [fileIconControl setIcon:iconId forPath:@"/Users/chrales/Work/lima/overlay-test/test.db"];
    
    [fileIconControl disableFileIcons];
    
    [fileIconControl enableFileIcons];
    
    [fileIconControl removeIconForPath:@"/Users/chrales/Work/lima/overlay-test/test.db"];
    
    [fileIconControl unregisterIcon:iconId];
    
    [fileIconControl disableFileIcons];
}

@end
