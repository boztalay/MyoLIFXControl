//
//  BOZHomeViewController.m
//  MyoLIFXControl
//
//  Created by Ben Oztalay on 9/10/14.
//  Copyright (c) 2014 Ben Oztalay. All rights reserved.
//

#import "BOZLightsViewController.h"
#import "BOZLightTableViewCell.h"
#import <LIFXKit/LIFXKit.h>

@interface BOZLightsViewController () <LFXNetworkContextObserver, LFXLightCollectionObserver, LFXLightObserver>

@property (nonatomic) LFXNetworkContext *lifxNetworkContext;
@property (nonatomic) NSArray *lights;

@end

@implementation BOZLightsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.lightViewController = (BOZLightViewController*)[[self.splitViewController.viewControllers objectAtIndex:1] topViewController];
    
    self.lifxNetworkContext = [LFXClient sharedClient].localNetworkContext;
    [self.lifxNetworkContext addNetworkContextObserver:self];
    [self.lifxNetworkContext.allLightsCollection addLightCollectionObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self updateTitle];
	[self updateLights];
}

#pragma mark - LFXNetworkContextObserver

- (void)networkContextDidConnect:(LFXNetworkContext *)networkContext
{
	[self updateTitle];
}

- (void)networkContextDidDisconnect:(LFXNetworkContext *)networkContext
{
	[self updateTitle];
}

- (void)updateTitle
{
	self.title = [NSString stringWithFormat:@"Lights (%@)", self.lifxNetworkContext.isConnected ? @"Connected" : @"Searching"];
}

#pragma mark - LFXLightCollectionObserver

- (void)lightCollection:(LFXLightCollection *)lightCollection didAddLight:(LFXLight *)light
{
	[light addLightObserver:self];
	[self updateLights];
}

- (void)lightCollection:(LFXLightCollection *)lightCollection didRemoveLight:(LFXLight *)light
{
	[light removeLightObserver:self];
	[self updateLights];
}

- (void)updateLights
{
	self.lights = self.lifxNetworkContext.allLightsCollection.lights;
	[self.tableView reloadData];
}

#pragma mark - LFXLightObserver

- (void)light:(LFXLight *)light didChangeLabel:(NSString *)label
{
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
    BOZLightTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[BOZLightTableViewCell reuseIdentifier] forIndexPath:indexPath];
    
    LFXLight* light = self.lights[indexPath.row];
    [cell setWithLight:light];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LFXLight* light = self.lights[indexPath.row];
    self.lightViewController.light = light;
}

@end
