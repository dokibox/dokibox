//
//  PluginManager.m
//  dokibox
//
//  Created by Miles Wu on 31/12/2012.
//
//

#import "PluginManager.h"

@implementation PluginManager
@synthesize plugins = _plugins;

+(PluginManager *)sharedInstance
{
    static dispatch_once_t pred;
    static PluginManager *shared = nil;

    dispatch_once(&pred, ^{
        shared = [[PluginManager alloc] init];
    });
    return shared;
}

-(PluginManager *)init
{
    if(self = [super init]) {
        _plugins = [[NSMutableArray alloc] init];
        _decoderPlugins = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)loadAll
{
    NSBundle *appBundle = [NSBundle mainBundle];
    NSString *plugInsPath = [appBundle builtInPlugInsPath];

    NSError *error;
    NSArray *dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:plugInsPath error:&error];
    if(dirs) {
        NSString *dir;
        for(dir in dirs) {
            if([[dir pathExtension] compare:@"bundle"] != NSOrderedSame) continue;
            NSString *fullPath = [[NSString alloc] initWithFormat:@"%@/%@", plugInsPath, dir];
            [self loadFromPath:fullPath];
        }
    }
    else {
        NSLog(@"There was a problem loading the dirs");
    }
}

-(void)loadFromPath:(NSString*)path
{
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    [bundle load];
    Class principalClass = [bundle principalClass];

    if(![principalClass conformsToProtocol:@protocol(PluginProtocol)] || ![principalClass instancesRespondToSelector:@selector(initWithPluginManager:)]) {
        NSLog(@"%@: invalid plugin", path);
        return;
    }

    id<PluginProtocol> plugin = [((id<PluginProtocol>)[principalClass alloc]) initWithPluginManager:self];
    [_plugins addObject:plugin];
}

-(void)registerDecoderClass:(Class)decoderClass forExtension:(NSString*)extension
{
    if(![decoderClass conformsToProtocol:@protocol(DecoderProtocol)]) {
        NSLog(@"Invaid decoder class");
        return;
    }
    [_decoderPlugins setObject:decoderClass forKey:extension];
}

-(Class)decoderClassForExtension:(NSString*)extension
{
    return (Class)[_decoderPlugins objectForKey:extension];
}



@end
