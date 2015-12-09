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
	Nothing here.
 */

#import <Foundation/Foundation.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

@interface NFSending : NSObject {
	int _socket;
	//NSTimer *_timer;
	CFSocketRef _cfSocket;
	CFRunLoopSourceRef _socketRunLoop;
}

-(void) startReceiving;
-(void) stopReceiving;
-(void) receivedData:(NSData *)data;
-(NSDictionary *) processNFSendingMessage:(NSString *)message;
@end
