//
//  YouTubeTableViewCell.h
//  MyTime
//
//  Created by Brent Priddy on 9/14/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface YouTubeTableViewCell : UITableViewCell 
{
}
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UILabel *label;

- (void)setYouTubeVideo:(NSString *)url;
- (void)playVideo;
@end
