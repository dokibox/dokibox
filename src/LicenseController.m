//
//  LicenseController.m
//  dokibox
//
//  Created by Miles Wu on 05/01/2014.
//
//

#import "LicenseController.h"
#import "CFobLicVerifier.h"

@implementation LicenseController

- (id)init
{
    self = [self initWithNibName:@"LicenseController" bundle:nil];
    if (self) {
    }
    
    return self;
}

- (void)openRegistrationPanel
{
    NSWindow *window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0,0,409,300) styleMask:NSTitledWindowMask backing:NSBackingStoreBuffered defer:NO];
    [window center];
    [window setContentView:[self view]];
    [[NSApplication sharedApplication] runModalForWindow:window];
    [window setReleasedWhenClosed:NO]; // let ARC handle
    [window close];

}

- (void)checkLicense
{
    CFobLicVerifier *verifier = [[CFobLicVerifier alloc] init];
    NSError *err;
    
    NSMutableString *pubKey = [[NSMutableString alloc] init];
    [pubKey appendString:@"-----BEGIN PUBLIC KEY-----\n"];
    [pubKey appendString:@"MIIBtjCCASsGByqGSM44BAEwggEeAoGBAL+x3Mkyrho/a5q0u7Rir8iHfhiLrl3q\n"];
    [pubKey appendString:@"SS1D9l6Kc8TTzHbYIPzgXGTaQJrDYipEmyrNwFFgTOwlMJBNd0ll6iw68fWw6cgS\n"];
    [pubKey appendString:@"DYdgyToJj2IOqIDuTDFSNyFg0VRWNVb0NB2xMRXvfTklPArzTvVfiTR3N2QmztYQ\n"];
    [pubKey appendString:@"HwpAw/NjUa95AhUA62KZsWv89yBXgNPVnneyxGQLyPECgYBvIqVf7rg/HyRAiKZz\n"];
    [pubKey appendString:@"Z3AE7oIokz6WfWTHHgpd1DmuUN5YEDcf7P/p5c5VvDB3XCV9erR4kHljqHcUyPdu\n"];
    [pubKey appendString:@"1DrVTTnJYd7mjoA4jYmt15adiZwfKs3z1F4+3W3NoMfEiD+Jl5iWx4tRdhUECFe/\n"];
    [pubKey appendString:@"xR+J1vRwBGnp+Ha728um5csMGgOBhAACgYBLGof8NsR5x6nzLaMpAqHnjopyrD8y\n"];
    [pubKey appendString:@"VYiWKX7xZy4nzaExKTLo3aChA/YjzCftuH80eYs0kMKMjh9/wEEq8p6nIJmBesHM\n"];
    [pubKey appendString:@"IwS8gqUvVyA0z3EreHOskmrFIghhcG1wquhtpbHop6W9X1YP4JoNcgJqWEokjanN\n"];
    [pubKey appendString:@"zeH0I8MnVj4itw==\n"];
    [pubKey appendString:@"-----END PUBLIC KEY-----\n"];
    [verifier setPublicKey:pubKey error:&err];
    
    BOOL res = [verifier verifyRegCode:@"GAWAE-FCXNS-TSTEF-2X32N-TX9TG-8346R-PJLMD-7U3AC-CRB8C-VWH32-DT6LZ-D85NG-G4LDX-3X5RT-ZTK9" forName:@"test123" error:&err];
    NSLog(@"verifier = %d", res);
}

@end
