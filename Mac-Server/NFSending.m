/*
 @Title
	NCForward mesages sending and receiving class.
 
 @Author
	H6nry <henry.anonym@gmail.com>
 
 @Description
	The main part of the NCForward Mac server.
 
 @License
	Do what you want with it, just email me if you are going to publish parts of this. I also would like to be mentioned in the source code, if published in source code form, and credited, if published only in binary form. Due to the informality of this license, you are allowed to ignore this if you really want to.
 
 @TODO
	- Proper implementation of the processNFSending method.
 */

#import "NFSending.h"

static void readCallback (CFSocketRef theSocket, CFSocketCallBackType theType, CFDataRef theAddress, const void *data, void *info) {
	[(__bridge NFSending *)info receivedData:(__bridge NSData *)(data)];
}

@implementation NFSending
-(id) init {
	id ret = [super init];
	
	int err;
	
	if (_socket <= 0) {
		_socket = socket(AF_INET, SOCK_DGRAM, 0); //Create a new BSD socket
		if (_socket <= 0) {
			NSLog(@"NCForward-Mac: Failed creating socket.");
			return ret;
		}
	}
	
	struct sockaddr_in addr; //Create structure of type sockaddr_in named addr
	memset(&addr, 0, sizeof(addr)); //Initialize memory region to 0
	addr.sin_len = sizeof(addr);
	addr.sin_family = AF_INET;
	addr.sin_port = htons(3156); //NCForward port is 3156
	addr.sin_addr.s_addr=htonl(INADDR_ANY);
	
	err = bind(_socket, (const struct sockaddr *)&addr, sizeof(addr));
	if (err != 0) {
		NSLog(@"NCForward-Mac: Failed binding. %i", errno);
		return ret;
	}
	
	CFSocketContext context = {
		.version = 0,
		.info = (void *)CFBridgingRetain(self), //Here we specify our instance which is sent to all callbacks.
		.retain = NULL,
		.release = NULL,
		.copyDescription = NULL
	};
	
	_cfSocket = CFSocketCreateWithNative(kCFAllocatorDefault, _socket, kCFSocketDataCallBack, &readCallback, &context);
	
	return ret;
}

- (void) startReceiving {
	if (!_socketRunLoop) {
		_socketRunLoop = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _cfSocket, 0);
	}
	CFRunLoopAddSource(CFRunLoopGetCurrent(), _socketRunLoop, kCFRunLoopCommonModes);
}

-(void) stopReceiving {
	CFRunLoopRemoveSource(CFRunLoopGetCurrent(), _socketRunLoop, kCFRunLoopCommonModes);
}

-(void) receivedData:(NSData *)data {
	NSDictionary *bulletinDictionary = [self processNFSendingMessage:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
	if ([[bulletinDictionary objectForKey:@"versionString"] isEqualToString:@"NCFV2_PV2"]) {
		
		NSUserNotification *notification = [[NSUserNotification alloc] init];
		[notification setTitle:[bulletinDictionary objectForKey:@"title"]];
		[notification setInformativeText:[bulletinDictionary objectForKey:@"message"]];
		[notification setDeliveryDate:[NSDate dateWithTimeInterval:0 sinceDate:[NSDate date]]];
		[notification setSoundName:NSUserNotificationDefaultSoundName];
		NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
		[center deliverNotification:notification];
	}
}

-(NSDictionary *) processNFSendingMessage:(NSString *)message {
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:1];
	
	int cursor = 0;
	
	NSString *senderVersion = [message substringWithRange:NSMakeRange(cursor, 9)]; //TODO: Bounds check, outsource to a second function/class.
	cursor = cursor + 9;
	[dictionary setObject:senderVersion forKey:@"versionString"];
	
	if ([senderVersion isEqualToString:@"NCFV2_PV2"]) {
		NSString *alreadySent = [message substringWithRange:NSMakeRange(cursor, 1)];
		cursor = cursor + 1;
		[dictionary setObject:@([alreadySent boolValue]) forKey:@"alreadySent"];
		
		NSString *body = [message substringWithRange:NSMakeRange(cursor, 1)];
		cursor = cursor + 1;
		if (![body isEqualToString:@"B"]) return nil; //We are wrong. Better exit now.
		
		NSString *titleLengthField = [message substringWithRange:NSMakeRange(cursor, 5)];
		cursor = cursor + 5;
		NSString *titleField = [message substringWithRange:NSMakeRange(cursor, [titleLengthField integerValue])];
		cursor = cursor + (int)[titleLengthField integerValue];
		[dictionary setObject:titleField forKey:@"title"]; //Parse field title to the dictionary.
		
		NSString *messageLengthField = [message substringWithRange:NSMakeRange(cursor, 5)];
		cursor = cursor + 5;
		NSString *messageField = [message substringWithRange:NSMakeRange(cursor, [messageLengthField integerValue])];
		cursor = cursor + (int)[messageLengthField integerValue];
		[dictionary setObject:messageField forKey:@"message"];
		
		NSString *bundleidLengthField = [message substringWithRange:NSMakeRange(cursor, 5)];
		cursor = cursor + 5;
		NSString *bundleidField = [message substringWithRange:NSMakeRange(cursor, [bundleidLengthField integerValue])];
		cursor = cursor + (int)[bundleidLengthField integerValue];
		[dictionary setObject:bundleidField forKey:@"bundleID"];
		
		NSString *bulletinidLengthField = [message substringWithRange:NSMakeRange(cursor, 5)];
		cursor = cursor + 5;
		NSString *bulletinidField = [message substringWithRange:NSMakeRange(cursor, [bulletinidLengthField integerValue])];
		cursor = cursor + (int)[bulletinidLengthField integerValue];
		[dictionary setObject:bulletinidField forKey:@"bulletinID"];
	}
	
	return dictionary;
}
@end