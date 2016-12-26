//
//  NewOrExistinigCircuitVC.m
//  Beast
//
//  Created by Trevor Beasty on 12/26/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "NewOrExistinigCircuitVC.h"

#import "CoreDataController.h"

#import "TJBCircuitDesignVC.h"
#import "TJBActiveCircuitGuidance.h"

@interface NewOrExistinigCircuitVC () <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *createNewChainButton;

- (IBAction)didPressCreateNewChain:(id)sender;

// core data
@property (nonatomic, strong) NSFetchedResultsController *frc;

@end

@implementation NewOrExistinigCircuitVC

#pragma mark - View Cycle

- (void)viewDidLoad{
    [self configureNavigationBar];
    [self fetchCoreDataAndConfigureTableView];
}

- (void)viewWillAppear:(BOOL)animated{
    NSError *error = nil;
    [self.frc performFetch: &error];
    [self.tableView reloadData];

}

- (void)configureNavigationBar{
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle: @"Chain Selectin"];
    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithTitle: @"Home"
                                                                   style: UIBarButtonItemStyleDone
                                                                  target: self
                                                                  action: @selector(didPressHomeButton)];
    [navItem setLeftBarButtonItem: homeButton];
    [self.navBar setItems: @[navItem]];
}

- (void)fetchCoreDataAndConfigureTableView{
    // table view configuration
    [self.tableView registerClass: [UITableViewCell class]
           forCellReuseIdentifier: @"basicCell"];
    
    // NSFetchedResultsController
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"ChainTemplate"];
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey: @"name"
                                                               ascending: YES];
    [request setSortDescriptors: @[nameSort]];
    NSManagedObjectContext *moc = [[CoreDataController singleton] moc];
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest: request
                                                                          managedObjectContext: moc
                                                                            sectionNameKeyPath: @"name"
                                                                                     cacheName: nil];
    frc.delegate = self;
    self.frc = frc;
    NSError *error = nil;
    if (![self.frc performFetch: &error])
    {
        NSLog(@"Failed to initialize fetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSUInteger sectionCount = [[[self frc] sections] count];
    return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self frc] sections][section];
    NSUInteger numberOfObjects = [sectionInfo numberOfObjects];
    return numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"basicCell"];
    TJBChainTemplate *chainTemplate = [self.frc objectAtIndexPath: indexPath];
    cell.textLabel.text = chainTemplate.name;
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TJBChainTemplate *chainTemplate = [self.frc objectAtIndexPath: indexPath];
    
    TJBActiveCircuitGuidance *vc = [[TJBActiveCircuitGuidance alloc] initWithChainTemplate: chainTemplate];
    [self presentViewController: vc
                       animated: YES
                     completion: nil];
}

#pragma mark - Button Actions

- (IBAction)didPressCreateNewChain:(id)sender {
    TJBCircuitDesignVC *vc = [[TJBCircuitDesignVC alloc] init];
    [self presentViewController: vc
                       animated: YES
                     completion: nil];
}

- (void)didPressHomeButton{
    [self dismissViewControllerAnimated: NO
                             completion: nil];
}

@end






















