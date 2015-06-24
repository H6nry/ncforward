#import <Preferences/Preferences.h>

@interface ncfprefsListController: PSListController {
}
@end

@implementation ncfprefsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"ncfprefs" target:self] retain];
	}
	return _specifiers;
}

- (void)twitter {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.twitter.com/H6nry_/"]];
}

- (void)mail {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:henry.anonym@gmail.com"]];
}

- (void)website {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://h6nry.github.io/"]];
}
@end

// vim:ft=objc
