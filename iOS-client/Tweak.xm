#import "Tweak.h"

%group main
//Some weird callback method...
static void socketCallback(CFSocketRef cfSocket, CFSocketCallBackType type, CFDataRef address, const void *data, void *userInfo) {
    NSLog(@"NCForward:WTF? socketCallback was called??");
}

//Some convenient stuff to make creating messages easier
@interface NSString (NCForwardCategory)
-(NSString *) addToNFString:(NSString *)string;
@end

@implementation NSString (NCForwardCategory)
-(NSString *) addToNFString:(NSString *)string {
	if (string == NULL) {
		self = [[self stringByAppendingString:@"%!"] stringByAppendingString:@"NULL"];
	} else {
		self = [[self stringByAppendingString:@"%!"] stringByAppendingString:string];
	}
	return self;
}
@end


//The class for sending (and recieving) NCForward messages
@class NFSending;
static NFSending *_sharedInstance = nil;

@interface NFSending : NSObject <NSStreamDelegate>
+(id) sharedInstance;
-(BOOL) sendMessage:(NSString *)message;
@end

@implementation NFSending
+(id) sharedInstance {
	@synchronized(self) {
		if (!_sharedInstance) {
			_sharedInstance = [[self alloc] init];
		}
		return _sharedInstance;
	}
}

-(BOOL) sendMessage:(NSString *)message {
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
	dispatch_async(queue, ^{ //Dispatch asynchronous to not block everything
		CFSocketContext socketContext = {0, self, NULL, NULL, NULL};
		
		CFSocketRef socket = CFSocketCreate(kCFAllocatorDefault, 0, SOCK_DGRAM, IPPROTO_UDP, kCFSocketNoCallBack, (CFSocketCallBack)socketCallback, &socketContext );
		
		if (socket) {
			NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/org.h6nry.ncforward.prefs.plist"];
			//NSLog(@"-----prefs:%@         %s",prefs, (const char*)[[prefs objectForKey:@"ip"] cStringUsingEncoding:NSASCIIStringEncoding]);
			int yes = 1;
			int setSockResult = setsockopt(CFSocketGetNative(socket), SOL_SOCKET, SO_BROADCAST, (void *)&yes, sizeof(yes));

			if(setSockResult < 0) NSLog(@"NCForward: Could not setsockopt for broadcast");
			NSString* ipp = [prefs objectForKey:@"ip"];
			if (prefs == NULL || ipp == NULL || [ipp isEqualToString:@""]) {
				//NSLog(@"NCForward: No IP specified. Using 255.255.255.255");
				ipp = @"255.255.255.255";
			}
			
			struct sockaddr_in addr; //create  structure of type sockaddr_in named addr
			memset(&addr, 0, sizeof(addr));
			addr.sin_len = sizeof(addr);
			addr.sin_family = AF_INET;
			addr.sin_port = htons(3156); //port
			inet_aton([ipp cStringUsingEncoding:NSASCIIStringEncoding], &addr.sin_addr); //ip adress vllt auch 255.255.255.255 ??? 192.168.0.255
			
			CFSocketConnectToAddress(socket, CFDataCreate(kCFAllocatorDefault, (const UInt8*)&addr, sizeof(addr)), 0.5);

			//const char* messagec = [message cStringUsingEncoding:NSUTF8StringEncoding];
			const char* messagec = (const char*)[message dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES].bytes;
			//NSLog(@"-------%s",messagec);
			CFDataRef Data = CFDataCreate(kCFAllocatorDefault, (const UInt8*)messagec, strlen(messagec));
			CFSocketError sendError = CFSocketSendData(socket, NULL, Data, 0.5);
			if (sendError == kCFSocketSuccess) {
				//NSLog(@"NCForward: Sent a notification.");
			} else {
				NSLog(@"NCForward: Some error occured while sending: %li", sendError);
			}
			CFRelease(Data);
			CFSocketInvalidate(socket);
			CFRelease(socket);
		} else {
				NSLog(@"NCForward: Creating socket failed!");
		}
	});
	return NO;
}
@end




%hook SBBulletinBannerController
- (void)observer:(id)observer addBulletin:(BBBulletin *)bulletin forFeed:(NSUInteger)feed {
	NSString *BulletinMessageToSend = @"NCFV1_PV1"; //NCF: magic. V1: ncforward version number. P:magic. V1: protocol version number.
	BulletinMessageToSend = [BulletinMessageToSend addToNFString:bulletin.sectionDisplayName];
	BulletinMessageToSend = [BulletinMessageToSend addToNFString:bulletin.topic];
	BulletinMessageToSend = [BulletinMessageToSend addToNFString:bulletin.sectionID];
	BulletinMessageToSend = [BulletinMessageToSend addToNFString:bulletin.content.title];
	BulletinMessageToSend = [BulletinMessageToSend addToNFString:bulletin.content.subtitle];
	BulletinMessageToSend = [BulletinMessageToSend addToNFString:bulletin.content.message];
	BulletinMessageToSend = [BulletinMessageToSend addToNFString:[bulletin.date description]];
	
	[[NFSending sharedInstance] sendMessage:BulletinMessageToSend];
	
	%orig;
}
%end

/*%hook SBVoiceControlController
-(BOOL)handleHomeButtonHeld {
	NSString *BulletinMessageToSend = @"NCFV1_PV1"; //NCF: magic. V1: ncforward version number. P:magic. V1: protocol version number.
	BulletinMessageToSend = [BulletinMessageToSend addToNFString:@"Test"];
	BulletinMessageToSend = [BulletinMessageToSend addToNFString:@"Test"];
	BulletinMessageToSend = [BulletinMessageToSend addToNFString:@"Test"];
	BulletinMessageToSend = [BulletinMessageToSend addToNFString:@"Test"];
	BulletinMessageToSend = [BulletinMessageToSend addToNFString:@"Test"];
	BulletinMessageToSend = [BulletinMessageToSend addToNFString:@"Test"];
	BulletinMessageToSend = [BulletinMessageToSend addToNFString:@"Test"];
	
	[[NFSending sharedInstance] sendMessage:BulletinMessageToSend];
	
	return nil;
}
%end*/ //test and debug stuff!

%end

%ctor {
	@autoreleasepool {
		%init(main);
	}
}