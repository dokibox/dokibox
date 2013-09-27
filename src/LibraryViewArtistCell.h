//
//  LibraryViewArtistCell.h
//  dokibox
//
//  Created by Miles Wu on 06/02/2013.
//
//

#import <Foundation/Foundation.h>
#import "LibraryArtist.h"

@interface LibraryViewArtistCell : NSView {
    LibraryArtist *_artist;
    
    NSTextField *_nameTextField;
    NSTextField *_altTextField;
}

@property() LibraryArtist* artist;
@property(weak) NSSet* searchMatchedObjects;

@end
