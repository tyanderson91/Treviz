//
//  ViewController.m
//  temp
//
//  Created by Tyler Anderson on 10/4/18.
//  Copyright © 2018 Tyler Anderson. All rights reserved.
//

/*
#import "analysisInputsViewController.h"
#import "AnalysisInput.h"

@implementation analysisInputsViewController
- (void)awakeFromNib{//fixit: figure out why this is loading multiple times
    [super awakeFromNib];
    //[super awakeFromNib];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"AnalysisInputs" ofType:@"plist"];
    if (filePath) {
        [AnalysisInput resetAllParams];
        self.inputs = [AnalysisInput inputList:filePath];
        self.allParams = [AnalysisInput getAllParams];
    }
    // Do any additional setup after loading the view.
}


- (void)viewDidLoad{
    [super viewDidLoad];
    [_outlineView setRowHeight:(CGFloat)19];
    [_outlineView reloadData];
    [_tableView reloadData];
}

#pragma mark - NSOutlineViewDelegate

- (IBAction)setParam:(id)sender {
    NSInteger curRow;
    curRow = [_outlineView rowForView:sender];
    NSLog(@"Name: %u",(int)curRow);
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item{
    NSTableCellView *view;
    if ([item isKindOfClass:[AnalysisInput class]]){
        AnalysisInput* curItem = (AnalysisInput*)item;
        if ([tableColumn.identifier isEqualToString:@"ValueColumn"]) {
            view = (NSTableCellView *)[outlineView makeViewWithIdentifier:@"ValueCellView" owner:self];
            NSTextField *textField = view.textField;
            if (textField){
                float floatval = [curItem.value floatValue];
                NSString* valtext;
                if ([curItem.inputType isEqualToString:@"float"]){
                    valtext = [[NSString alloc] initWithFormat:@"%g",floatval];}
                else{valtext = curItem.value;}
                textField.stringValue = valtext;
                [textField sizeToFit];
            }
        }
        else if ([tableColumn.identifier isEqualToString:@"NameColumn"]) {
            if ([curItem.itemType isEqualToString:@"header"]){
                view = (NSTableCellView *)[outlineView makeViewWithIdentifier:@"HeaderCellView" owner:self];
                NSImageView* isValidImageView = [view imageView];
                isValidImageView.image = [NSImage imageNamed: (curItem.isValid? NSImageNameStatusAvailable : NSImageNameStatusUnavailable)];
                
            }
            else if ([curItem.itemType isEqualToString:@"subHeader"]){
                view = (NSTableCellView *)[outlineView makeViewWithIdentifier:@"SubHeaderCellView" owner:self];
            }
            else if ([curItem.itemType isEqualToString:@"variable"]){
                view = (NSTableCellView *)[outlineView makeViewWithIdentifier:@"NameCellView" owner:self];
            }
            NSTextField *textField = view.textField;
            if (textField){
                textField.stringValue = curItem.name;
                //[textField sizeToFit];
            }
        }
        else if ([tableColumn.identifier isEqualToString:@"UnitsColumn"]) {
            view = (NSTableCellView *)[outlineView makeViewWithIdentifier:@"UnitsCellView" owner:self];
            NSTextField *textField = view.textField;
            if (textField){
                textField.stringValue = curItem.units;
                [textField sizeToFit];
            }
        }
        else if ([tableColumn.identifier isEqualToString:@"ParamColumn"]) {
            //view = (NSTableCellView *)[outlineView makeViewWithIdentifier:@"ParamCellView" owner:self];
            view = (NSTableCellView *)[outlineView makeViewWithIdentifier:@"paramCheckBoxView" owner:self];
            
            NSButton* paramButton = (NSButton*)view;
            
            if ([curItem.itemType isEqualToString:@"variable"]){
                paramButton.state = curItem.isParam ? NSOnState : NSOffState;
            }
            else if ([curItem.itemType isEqualToString:@"header"] || [curItem.itemType isEqualToString:@"subHeader"]){
                paramButton.state = [curItem hasParams] ? NSOnState : NSOffState;
            }
            //view.textField.stringValue = @"";
            /*
            NSTextField *textField = view.textField;
            if (textField){
                textField.stringValue = @"YES";//curItem.isParam;
                [textField sizeToFit];
            }*/
/*
        }

    }
    
    return view;
}

#pragma mark - NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item{
    return [item children] ? [[item children] count] : [self.inputs count];
}


- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item{
        return [item children] ? [[item children] objectAtIndex:index] : [self.inputs objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item{
    return [item children] ? [[item children] count]>0 : NO;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item{
    
    AnalysisInput* curInput = (AnalysisInput*)item;
    if ([item isKindOfClass:[AnalysisInput class]]){
        if ([tableColumn.identifier isEqualToString:@"ValueColumn"]) {
            return curInput.value;}
        else if ([tableColumn.identifier isEqualToString:@"NameColumn"]) {
            return curInput.name;}
        else if ([tableColumn.identifier isEqualToString:@"UnitsColumn"]) {
            return curInput.units;}
    }
    
    return nil;
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return _allParams ? [_allParams count] + 1: 0;
}

#pragma mark - NSTableViewDelegate

- (id)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    
    if (row == [_allParams count]){
        NSTableCellView* view;
        view = [tableColumn.identifier isEqualToString:@"AddRemoveColumn"] ? (NSTableCellView *)[tableView makeViewWithIdentifier:@"AddParamCellView" owner:self] : nil;
        return view;
    }
    
    AnalysisInput* curItem = [_allParams objectAtIndex:row];
    NSTableCellView* view = nil;
    if ([tableColumn.identifier isEqualToString:@"ValueColumn"]) {
        view = (NSTableCellView *)[tableView makeViewWithIdentifier:@"ValueCellView" owner:self];
        NSTextField *textField = view.textField;
        if (textField){
            float floatval = [curItem.value floatValue];
            NSString* valtext;
            if ([curItem.inputType isEqualToString:@"float"]){
                valtext = [[NSString alloc] initWithFormat:@"%g",floatval];}
            else{valtext = curItem.value;}
            textField.stringValue = valtext;
            [textField sizeToFit];
        }
    }
    else if ([tableColumn.identifier isEqualToString:@"NameColumn"]) {
        view = (NSTableCellView *)[tableView makeViewWithIdentifier:@"NameCellView" owner:self];
        NSTextField *textField = view.textField;
        if (textField){
            textField.stringValue = curItem.name;
        }
    }
    else if ([tableColumn.identifier isEqualToString:@"UnitsColumn"]) {
        view = (NSTableCellView *)[tableView makeViewWithIdentifier:@"UnitsCellView" owner:self];
        NSTextField *textField = view.textField;
        if (textField){
            textField.stringValue = curItem.units;
            [textField sizeToFit];
        }
    }
    else if ([tableColumn.identifier isEqualToString:@"AddRemoveColumn"]){
        view = (NSTableCellView *)[tableView makeViewWithIdentifier:@"RemoveParamCellView" owner:self];
    }
    
    
    return view;
}

/*
- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
}
*/

/*
@end

*/
