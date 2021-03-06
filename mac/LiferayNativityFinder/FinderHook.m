/**
 * Copyright (c) 2000-2012 Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */

#import "ContentManager.h"
#import "FinderHook.h"
#import "IconCache.h"
#import "objc/objc-class.h"
#import "RequestManager.h"

static BOOL installed = NO;

@implementation FinderHook

+ (void)hookClassMethod:(SEL)oldSelector inClass:(NSString*)className toCallToTheNewMethod:(SEL)newSelector
{
	Class hookedClass = NSClassFromString(className);
	Method oldMethod = class_getClassMethod(hookedClass, oldSelector);
	Method newMethod = class_getClassMethod(hookedClass, newSelector);
	
	Class classClass = object_getClass(hookedClass);
	class_addMethod(classClass, oldSelector, class_getMethodImplementation(classClass, oldSelector), method_getTypeEncoding(oldMethod));
	class_addMethod(classClass, newSelector, class_getMethodImplementation(classClass, newSelector), method_getTypeEncoding(newMethod));

	method_exchangeImplementations(class_getClassMethod(hookedClass, oldSelector), class_getClassMethod(hookedClass, newSelector));
}

+ (void)hookMethod:(SEL)oldSelector inClass:(NSString*)className toCallToTheNewMethod:(SEL)newSelector
{
	Class hookedClass = NSClassFromString(className);
	Method oldMethod = class_getInstanceMethod(hookedClass, oldSelector);
	Method newMethod = class_getInstanceMethod(hookedClass, newSelector);
	
	class_addMethod(hookedClass, oldSelector, class_getMethodImplementation(hookedClass, oldSelector), method_getTypeEncoding(oldMethod));
	class_addMethod(hookedClass, newSelector, class_getMethodImplementation(hookedClass, newSelector), method_getTypeEncoding(newMethod));
	
	method_exchangeImplementations(class_getInstanceMethod(hookedClass, oldSelector), class_getInstanceMethod(hookedClass, newSelector));
}

+ (void)install
{
	if (installed)
	{
		NSLog(@"LiferayNativityFinder: already installed");

		return;
	}

	NSLog(@"LiferayNativityFinder: installing");

	[RequestManager sharedInstance];

	[self doHooks];
	
	installed = YES;

    NSLog(@"LiferayNativityFinder: installed");
}

+ (void)uninstall
{
	if (!installed)
	{
		NSLog(@"LiferayNativityFinder: not installed");

		return;
	}

	NSLog(@"LiferayNativityFinder: uninstalling");

	[[ContentManager sharedInstance] dealloc];

	[[IconCache sharedInstance] dealloc];

	[[RequestManager sharedInstance] dealloc];
	
	[self doHooks];

	installed = NO;

    NSLog(@"LiferayNativityFinder: uninstalled");
}

+ (void)doHooks
{
	// Icons
	[self hookMethod:@selector(drawImage:) inClass:@"IKImageBrowserCell" toCallToTheNewMethod:@selector(IconOverlayHandlers_drawImage:)]; // 10.7 & 10.8 & 10.9
	
	[self hookMethod:@selector(drawIconWithFrame:) inClass:@"TListViewIconAndTextCell" toCallToTheNewMethod:@selector(IconOverlayHandlers_drawIconWithFrame:)]; // 10.7 & 10.8 & 10.9
	
	[self hookMethod:@selector(drawRect:) inClass:@"TDimmableIconImageView" toCallToTheNewMethod:@selector(IconOverlayHandlers_drawRect:)];
	
	// Context Menus
	[self hookClassMethod:@selector(addViewSpecificStuffToMenu:browserViewController:context:) inClass:@"TContextMenu" toCallToTheNewMethod:@selector(ContextMenuHandlers_addViewSpecificStuffToMenu:browserViewController:context:)]; // 10.7 & 10.8
	
	[self hookClassMethod:@selector(addViewSpecificStuffToMenu:clickedView:browserViewController:context:) inClass:@"TContextMenu" toCallToTheNewMethod:@selector(ContextMenuHandlers_addViewSpecificStuffToMenu:clickedView:browserViewController:context:)]; // 10.9
	
	[self hookClassMethod:@selector(handleContextMenuCommon:nodes:event:view:windowController:addPlugIns:) inClass:@"TContextMenu" toCallToTheNewMethod:@selector(ContextMenuHandlers_handleContextMenuCommon:nodes:event:view:windowController:addPlugIns:)]; // 10.7
	
	[self hookClassMethod:@selector(handleContextMenuCommon:nodes:event:view:browserController:addPlugIns:) inClass:@"TContextMenu" toCallToTheNewMethod:@selector(ContextMenuHandlers_handleContextMenuCommon:nodes:event:view:browserController:addPlugIns:)]; // 10.8
	
	[self hookClassMethod:@selector(handleContextMenuCommon:nodes:event:clickedView:browserViewController:addPlugIns:) inClass:@"TContextMenu" toCallToTheNewMethod:@selector(ContextMenuHandlers_handleContextMenuCommon:nodes:event:clickedView:browserViewController:addPlugIns:)]; // 10.9
	
	[self hookMethod:@selector(configureWithNodes:windowController:container:) inClass:@"TContextMenu" toCallToTheNewMethod:@selector(ContextMenuHandlers_configureWithNodes:windowController:container:)]; // 10.7
	
	[self hookMethod:@selector(configureWithNodes:browserController:container:) inClass:@"TContextMenu" toCallToTheNewMethod:@selector(ContextMenuHandlers_configureWithNodes:browserController:container:)]; // 10.8
	
	[self hookMethod:@selector(configureFromMenuNeedsUpdate:clickedView:container:event:selectedNodes:) inClass:@"TContextMenu" toCallToTheNewMethod:@selector(ContextMenuHandlers_configureFromMenuNeedsUpdate:clickedView:container:event:selectedNodes:)]; // 10.9
	
	// Debug
	[self hookMethod:@selector(toolbarWillAddItem:) inClass:@"TToolbarController" toCallToTheNewMethod:@selector(ToolbarItemHandlers_toolbarWillAddItem:)];
	[self hookMethod:@selector(toolbarDidRemoveItem:) inClass:@"TToolbarController" toCallToTheNewMethod:@selector(ToolbarItemHandlers_toolbarDidRemoveItem:)];
	[self hookMethod:@selector(toolbarAllowedItemIdentifiers:) inClass:@"TToolbarController" toCallToTheNewMethod:@selector(ToolbarItemHandlers_toolbarAllowedItemIdentifiers:)];
	
	[self hookMethod:@selector(setSizeMode:) inClass:@"TToolbar" toCallToTheNewMethod:@selector(ToolbarItemHandlers_setSizeMode:)];
	[self hookMethod:@selector(_newItemFromItemIdentifier:propertyListRepresentation:requireImmediateLoad:willBeInsertedIntoToolbar:) inClass:@"TToolbar" toCallToTheNewMethod:@selector(ToolbarItemHandlers__newItemFromItemIdentifier:propertyListRepresentation:requireImmediateLoad:willBeInsertedIntoToolbar:)];
    [self hookMethod:@selector(_notifyView_MovedFromIndex:toIndex:) inClass:@"TToolbar" toCallToTheNewMethod:@selector(ToolbarItemHandlers__notifyView_MovedFromIndex:toIndex:)];
}

@end