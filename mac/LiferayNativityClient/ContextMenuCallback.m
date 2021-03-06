//
//  ContextMenuCallback.m
//  LiferayNativityClient
//
//  Created by Charles Francoise on 06/02/14.
//  Copyright (c) 2014 Forgetbox. All rights reserved.
//

#import "ContextMenuCallback.h"

#import "Constants.h"
#import "NativityControl.h"
#import "NativityMessage.h"
#import "MenuItem.h"

#import "DDLog.h" 

#import "NSArray+FilterMapReduce.h"

@implementation ContextMenuCallback
{
    NativityControl* _nativityControl;
    NSMutableDictionary* _menuItemActions;
}

- (id)initWithNativityControl:(NativityControl*)nativityControl
{
    self = [super init];
    {
        _nativityControl = [nativityControl retain];
        _menuItemActions = [[NSMutableDictionary alloc] init];
        
        [_nativityControl addListener:self forCommand:GET_CONTEXT_MENU_ITEMS];
        [_nativityControl addListener:self forCommand:FIRE_CONTEXT_MENU_ACTION];
    }
    return self;
}

- (void)dealloc
{
    [_nativityControl removeListener:self forCommand:GET_CONTEXT_MENU_ITEMS];
    [_nativityControl removeListener:self forCommand:FIRE_CONTEXT_MENU_ACTION];
    
    [_nativityControl release];
    [_menuItemActions release];
    
    [super dealloc];
}

- (void)registerActionForItem:(MenuItem*)menuItem
{
    if (menuItem.action != nil)
    {
        _menuItemActions[menuItem.uuid.UUIDString] = menuItem.action;
    }
    
    NSUInteger childCount = menuItem.numberOfChildren;
    for (NSUInteger i = 0; i < childCount; i++)
    {
        [self registerActionForItem:[menuItem childAtIndex:i]];
    }
}

- (NativityMessage*)onCommand:(NSString*)command withValue:(id)value
{
    if ([command isEqualToString:GET_CONTEXT_MENU_ITEMS])
    {
        [_menuItemActions removeAllObjects];
        
        NSArray* paths = value;
        NSArray* menuItems = [self getMenuItemsForPaths:paths];
        
        for (MenuItem* item in menuItems)
        {
            [self registerActionForItem:item];
        }
        
        NSArray* messageValue = [menuItems map:^id(MenuItem* item) {
            return [item asDictionary];
        }];
        
        return [NativityMessage messageWithCommand:MENU_ITEMS andValue:messageValue];
    }
    else if ([command isEqualToString:FIRE_CONTEXT_MENU_ACTION])
    {
        NSDictionary* commandDict = value;
        NSString* uuid = commandDict[@"uuid"];
        ActionBlock action = _menuItemActions[uuid];
        if (action != nil)
        {
            NSArray* files = commandDict[@"files"];
            DDLogVerbose(@"Firing action uuid: %@ for: %@", uuid, files);
            dispatch_async(dispatch_get_main_queue(), ^{
                action(files);
            });
        }
    }
    
    return nil;
}

- (NSArray*)getMenuItemsForPaths:(NSArray*)paths
{
    DDLogWarn(@"-[ContextMenuCallback getMenuItemsForPaths:] should be reimplemented in your subclass.");
    
    return @[];
}

@end
