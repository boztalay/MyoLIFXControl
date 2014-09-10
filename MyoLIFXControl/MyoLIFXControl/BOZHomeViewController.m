//
//  BOZHomeViewController.m
//  MyoLIFXControl
//
//  Created by Ben Oztalay on 9/10/14.
//  Copyright (c) 2014 Ben Oztalay. All rights reserved.
//

#import "BOZHomeViewController.h"
#import "BOZLightTableViewCell.h"
#import <LIFXKit/LIFXKit.h>

@interface BOZHomeViewController () <LFXNetworkContextObserver, LFXLightCollectionObserver, LFXLightObserver>

@property (nonatomic) LFXNetworkContext *lifxNetworkContext;
@property (nonatomic) NSArray *lights;

@end

@implementation BOZHomeViewController

+ (NSString*)nibName
{
    return @"BOZHomeViewController";
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.lifxNetworkContext = [LFXClient sharedClient].localNetworkContext;
		[self.lifxNetworkContext addNetworkContextObserver:self];
		[self.lifxNetworkContext.allLightsCollection addLightCollectionObserver:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:[BOZLightTableViewCell nibName] bundle:nil]
         forCellReuseIdentifier:[BOZLightTableViewCell reuseIdentifier]];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self updateTitle];
	[self updateLights];
}

- (void)updateLights
{
	self.lights = self.lifxNetworkContext.allLightsCollection.lights;
	[self.tableView reloadData];
}

- (void)updateTitle
{
	self.statusLabel.text = [NSString stringWithFormat:@"LIFX Browser (%@)", self.lifxNetworkContext.isConnected ? @"connected" : @"searching"];
}

#pragma mark - LFXNetworkContextObserver

- (void)networkContextDidConnect:(LFXNetworkContext *)networkContext
{
	NSLog(@"Network Context Did Connect");
	[self updateTitle];
}

- (void)networkContextDidDisconnect:(LFXNetworkContext *)networkContext
{
	NSLog(@"Network Context Did Disconnect");
	[self updateTitle];
}

#pragma mark - LFXLightCollectionObserver

- (void)lightCollection:(LFXLightCollection *)lightCollection didAddLight:(LFXLight *)light
{
	NSLog(@"Light Collection: %@ Did Add Light: %@", lightCollection, light);
	[light addLightObserver:self];
	[self updateLights];
}

- (void)lightCollection:(LFXLightCollection *)lightCollection didRemoveLight:(LFXLight *)light
{
	NSLog(@"Light Collection: %@ Did Remove Light: %@", lightCollection, light);
	[light removeLightObserver:self];
	[self updateLights];
}

#pragma mark - LFXLightObserver

- (void)light:(LFXLight *)light didChangeLabel:(NSString *)label
{
	NSLog(@"Light: %@ Did Change Label: %@", light, label);
	NSUInteger rowIndex = [self.lights indexOfObject:light];
	[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:rowIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.lights.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[BOZLightTableViewCell reuseIdentifier] forIndexPath:indexPath];
    
    LFXLight *light = self.lights[indexPath.row];
    
    cell.textLabel.text = light.label;
    cell.detailTextLabel.text = light.deviceID;
	
    return cell;
}

@end
