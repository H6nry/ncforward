/*
 @Title
	NCForward App delegate.
 
 @Author
	H6nry <henry.anonym@gmail.com>
 
 @Description
	The App delegate.
 
 @License
	Do what you want with it, just email me if you are going to publish parts of this. I also would like to be mentioned in the source code, if published in source code form, and credited, if published only in binary form. Due to the informality of this license, you are allowed to ignore this if you really want to.
 
 @TODO
	Nothing here.
 */

#import "AppDelegate.h"
#import "NFSending.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property NFSending *forwardClass;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	NSMenuItem *aboutMenuItem = [[NSMenuItem alloc] initWithTitle:@"About" action:@selector(itemClicked:) keyEquivalent:@""];
	aboutMenuItem.tag = 315;
	
	NSMenuItem *quitMenuItem = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(itemClicked:) keyEquivalent:@""];
	quitMenuItem.tag = 316;
	
	NSMenu *statusMenu = [[NSMenu alloc] initWithTitle:@"NCForward"];
	[statusMenu addItem:aboutMenuItem];
	[statusMenu addItem:quitMenuItem];
	
	 self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	_statusItem.image = [NSImage imageNamed:@"NCForward-Mac-Icon-27@3x.png"];
	[_statusItem.image setTemplate:YES];
	_statusItem.menu = statusMenu;
	
	self.forwardClass = [[NFSending alloc] init];
	[self.forwardClass startReceiving];
	[self.forwardClass stopReceiving];
	[self.forwardClass startReceiving];
	[self.forwardClass stopReceiving];
	[self.forwardClass startReceiving];
	[self.forwardClass stopReceiving];
	[self.forwardClass startReceiving];
	[self.forwardClass stopReceiving];
	[self.forwardClass startReceiving];
	[self.forwardClass stopReceiving];
	[self.forwardClass startReceiving];
	[self.forwardClass stopReceiving];
	[self.forwardClass startReceiving];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
	[self.forwardClass stopReceiving];
}

-(void) itemClicked:(NSMenuItem *)sender {
	if (sender.tag == 315) {
		NSAlert * alert = [[NSAlert alloc] init];
		alert.alertStyle = NSInformationalAlertStyle;
		alert.informativeText = @"NCForward made with love by H6nry in 2015. Visit https://h6nry.github.io/ for more information.";
		alert.messageText = @"About NCForward";
	
		[alert runModal];
	} else if (sender.tag == 316) {
		[[NSApplication sharedApplication] terminate:self];
		return;
	}
}

@end
