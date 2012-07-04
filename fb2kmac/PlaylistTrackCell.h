//
//  PlaylistTrackCell.h
//  fb2kmac
//
//  Created by Miles Wu on 01/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TUIKit.h"
#import "PlaylistTrack.h"
#import "Column.h"

@interface PlaylistTrackCell : TUITableViewCell
{
    TUITextRenderer *_textRenderer;
    TUIFont *_font;
    PlaylistTrack *_track;
    
}
@property() PlaylistTrack *track;

@end
