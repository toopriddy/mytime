#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class MetadataPickerViewController;

@protocol MetadataPickerViewDelegate
- (void)metadataPickerViewControllerDone:(MetadataPickerViewController *)metadataPickerViewController;
- (void)metadataPickerViewControllerChanged:(MetadataPickerViewController *)metadataPickerViewController;
@end

@interface MetadataPickerViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
{	
@private	
    IBOutlet UINavigationItem *navigationTitle;
    IBOutlet UIPickerView *pickerView;

	NSArray *_metadataArray;
	NSInteger _selection;
	id _delegate;
}
@property (nonatomic, assign) id<MetadataPickerViewDelegate> delegate;
@property (nonatomic, assign) NSString *metadata;
- (IBAction)done;
- (id) initWithMetadata:(NSString *)metadata;
@end
