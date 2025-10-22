#import "QRCodeScannerPlugin.h"
#import "HelloCordova-Swift.h"

#import <Cordova/CDVAvailability.h>
#import <MercariQRScanner-Swift.h>


@interface QRCodeScannerPlugin() <QRScannerViewControllerDelegate>
@property (weak, nonatomic) QRScannerViewController *scannerViewController;
@property (copy, nonatomic) NSString *showCallbackId;
@end

@implementation QRCodeScannerPlugin
- (void)pluginInitialize {
}

- (void)echo:(CDVInvokedUrlCommand *)command {
  NSString* phrase = [command.arguments objectAtIndex:0];
  NSLog(@"%@", phrase);
}

- (void)getDate:(CDVInvokedUrlCommand *)command {
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
  [dateFormatter setLocale:enUSPOSIXLocale];
  [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];

  NSDate *now = [NSDate date];
  NSString *iso8601String = [dateFormatter stringFromDate:now];

  CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:iso8601String];
  [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)show:(CDVInvokedUrlCommand *)command {
    self.showCallbackId = command.callbackId;
    // confirm that release memory when dismiss scannerViewController
    QRScannerViewController* scannerViewController = [[QRScannerViewController alloc] initWithNibName:nil bundle:nil];
    self.scannerViewController = scannerViewController;
    self.scannerViewController.delegate = self;
    [self.viewController presentViewController:self.scannerViewController animated:YES completion:^{}];
}

- (void)dismiss:(CDVInvokedUrlCommand *)command {
    [self.scannerViewController dismissViewControllerAnimated:YES completion:^{}];
}

// MARK: - QRScannerViewControllerDelegate
- (void)didScanWithCode:(NSString *)code error:(NSError *)error {
    __weak __typeof(self) weakSelf = self;
    [self.scannerViewController dismissViewControllerAnimated:YES completion:^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }

        CDVPluginResult *result = nil;
        if (error != nil || code.length == 0) {
            NSString *message = error != nil ? error.localizedDescription : @"Scan failed";
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message];
        } else {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:code];
        }

        if (strongSelf.showCallbackId != nil) {
            [strongSelf.commandDelegate sendPluginResult:result callbackId:strongSelf.showCallbackId];
            strongSelf.showCallbackId = nil;
        }
    }];
}

@end
