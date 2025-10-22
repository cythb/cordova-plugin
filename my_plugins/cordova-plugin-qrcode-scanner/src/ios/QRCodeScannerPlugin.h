#import <Cordova/CDVPlugin.h>


@interface QRCodeScannerPlugin : CDVPlugin {}
// The hooks for our plugin commands
- (void)echo:(CDVInvokedUrlCommand *)command;
- (void)getDate:(CDVInvokedUrlCommand *)command;


- (void)show:(CDVInvokedUrlCommand *)command;
- (void)dismiss:(CDVInvokedUrlCommand *)command;

@end
