//
//  ToolbarManager.m
//  LiferayNativityFinder
//
//  Created by Charles Francoise on 17/02/14.
//
//

#import "ToolbarManager.h"

#import <AppKit/NSApplication.h>
#import <AppKit/NSWindow.h>
#import <objc/message.h>

#import "Finder/Finder.h"

#import "IconCache.h"

static ToolbarManager* _sharedInstance = nil;

@implementation ToolbarManager
{
	NSMutableDictionary* _toolbarItems;
	NSMutableArray* _itemsToAdd;
}

+ (id)sharedInstance
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		if (_sharedInstance == nil)
		{
			_sharedInstance = [[ToolbarManager alloc] init];
		}
	});
	
	return _sharedInstance;
}

- (id)init
{
	self = [super init];
	if (self != nil)
	{
		_toolbarItems = [[NSMutableDictionary alloc] init];
		_itemsToAdd = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[_toolbarItems release];
	[_itemsToAdd release];
	
	[super dealloc];
}

- (NSArray*)itemIdentifiers
{
	return _toolbarItems.allKeys;
}

- (void)addToolbarItem:(NSDictionary*)itemDictionary
{
	[_itemsToAdd addObject:itemDictionary];
	
	[self addToolbarItems];
}

- (TToolbarItem*)toolbarItemForIdentifier:(NSString*)identifier insertedIntoToolbar:(TToolbar*)toolbar
{
	NSDictionary* itemDictionary = _toolbarItems[identifier];
	
	TToolbarItem* item = objc_msgSend(objc_getClass("TToolbarItem"), @selector(alloc));
	item = [item initWithItemIdentifier:identifier];
	//					item.label = itemDictionary[@"title"];
	item.paletteLabel = itemDictionary[@"title"];
	item.toolTip = itemDictionary[@"toolTip"];
	
	NSButton* templateButton = [toolbar.delegate toolbarButtonTemplate];
	NSPopUpButton* button = [[[NSPopUpButton alloc] initWithFrame:templateButton.frame pullsDown:YES] autorelease];
	button.autoenablesItems = NO;
	button.bezelStyle = templateButton.bezelStyle;
	
	NSMenu* menu = [[[NSMenu alloc] initWithTitle:@""] autorelease];
	NSMenuItem* menuItem = [[[NSMenuItem alloc] init] autorelease];
	menuItem.title = @"";
	[menuItem setEnabled:YES];
	[menu insertItem:menuItem atIndex:0];
	button.menu = menu;
	[button selectItemAtIndex:0];
	
	NSNumber* imageId = itemDictionary[@"image"];
	if (imageId != nil)
	{
		NSImage* image = [[IconCache sharedInstance] getIcon:imageId];
		menuItem.image = image;
	}
	
	if (button.image == nil)
	{
		menuItem.title = itemDictionary[@"title"];
		[button sizeToFit];
	}
	item.view = button;
	
	return item;
}

- (void)addToolbarItems
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (_itemsToAdd.count == 0)
		{
			return;
		}
		
		NSApplication* application = [NSApplication sharedApplication];
		NSArray* windows = application.windows;
		
		for (NSWindow* window in windows)
		{
			if ([window.className isEqualToString:@"TBrowserWindow"])
			{
				TToolbar* toolbar = (TToolbar*)[[window browserWindowController] toolbar];
				
				for (NSDictionary* itemDictionary in _itemsToAdd)
				{
					NSString* identifier = itemDictionary[@"identifier"];
					_toolbarItems[identifier] = itemDictionary;
								  
					[toolbar insertItemWithItemIdentifier:identifier atIndex:5];
				}
				
				[_itemsToAdd removeAllObjects];
				
				break;
			}
		}
	});
}


@end
