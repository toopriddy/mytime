//
//  PublicationPickerView.m
//  MyTime
//
//  Created by Brent Priddy on 8/7/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//
#import "PublicationPickerView.h"
#import "Settings.h"
#import "PSLocalization.h"

#define YEAR_OFFSET 1900
#define ARRAY_SIZE(a) (sizeof(a)/sizeof(a[0]))

#include "PSRemoveLocalizedString.h"
static NSString *MONTHS[] = {
	NSLocalizedString(@"Jan", @"Short month name"),
	NSLocalizedString(@"Feb", @"Short month name"),
	NSLocalizedString(@"Mar", @"Short month name"),
	NSLocalizedString(@"Apr", @"Short month name"),
	NSLocalizedString(@"May", @"Short/Long month name"),
	NSLocalizedString(@"Jun", @"Short month name"),
	NSLocalizedString(@"Jul", @"Short month name"),
	NSLocalizedString(@"Aug", @"Short month name"),
	NSLocalizedString(@"Sep", @"Short month name"),
	NSLocalizedString(@"Oct", @"Short month name"),
	NSLocalizedString(@"Nov", @"Short month name"),
	NSLocalizedString(@"Dec", @"Short month name")
};
#include "PSAddLocalizedString.h"


@implementation PublicationPickerView


// these should be sorted by (in alphabetical order, except for watchtower and awake)
// MAGIZINES
// BROCHURES
// BOOKS
// ADDED TYPES

typedef struct {
	NSString * name;
	NSString * type;
} PublicationInformation;

#warning add the study version of the Watchtower
#include "PSRemoveLocalizedString.h"
static const PublicationInformation PUBLICATIONS[] = {
    {NSLocalizedString(@"W & A", @"Both Magizines (w and g)"),       PublicationTypeMagazine}
,	{NSLocalizedString(@"Watchtower", @"Magizine Publication Name (w)"),     PublicationTypeMagazine}
,   {NSLocalizedString(@"Awake", @"Magizine Publication Name (g)"),       PublicationTypeMagazine}
,   {NSLocalizedString(@"   CAMPAIGN TRACTS", @"Publication Type and Seperator in the Publication Picker"),    PublicationTypeHeading}
,   {NSLocalizedString(@"Memorial Tract", @"Campaign Tract Publication Name (mi yearly tract)"),   PublicationTypeCampaignTract}

,   {NSLocalizedString(@"   BOOKS", @"Publication Type and Seperator in the Publication Picker"),    PublicationTypeHeading}
,   {NSLocalizedString(@"Bible", @"Book Publication Name"),   PublicationTypeBook}
,   {NSLocalizedString(@"All Scripture is Inspired", @"Book Publication Name (si)"),   PublicationTypeBook}
,   {NSLocalizedString(@"What Does the Bible Really Teach?", @"Book Publication Name (bh)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Yearbook", @"Book Publication Name"),   PublicationTypeBook}
,   {NSLocalizedString(@"Examining the Scriptures Daily", @"Book Publication Name (es)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Draw Close to Jehovah", @"Book Publication Name (cl)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Concordance", @"Book Publication Name (cn)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Is there a Creator Who Cares About You?", @"Book Publication Name (ct)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Mankind's Search for God", @"Book Publication Name (sh)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Come Be My Follower", @"Book Publication Name (cf)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Commentary on James", @"Book Publication Name (cj)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Daniel's Prophecy", @"Book Publication Name (dp)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Evolution or Creation", @"Book Publication Name (ce)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Family Happiness", @"Book Publication Name (fy)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Family Life", @"Book Publication Name (fl)"),   PublicationTypeBook}
,   {NSLocalizedString(@"God's Word", @"Book Publication Name (gm)"),   PublicationTypeBook}
,   {NSLocalizedString(@"God's Eternal Purpose", @"Book Publication Name (po)"),   PublicationTypeBook}
,   {NSLocalizedString(@"God's Kingdom Has Approached", @"Book Publication Name (ka)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Good News to Make You Happy", @"Book Publication Name (gh)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Greatest Man Who Ever Lived", @"Book Publication Name (gt)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Happiness-How to Find It", @"Book Publication Name (hp)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Holy Spirit", @"Book Publication Name (hs)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Insight", @"Book Publication Name (it)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Isaiah's Prophecy I", @"Book Publication Name (ip-1)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Isaiah's Prophecy II", @"Book Publication Name (ip-2)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Is This Life All There Is?", @"Book Publication Name (ts)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Live With Jehovah's Day in Mind", @"Book Publication Name (jd)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Let Your Kingdom Come", @"Book Publication Name (kc)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Listen to the Great Teacher", @"Book Publication Name (te)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Learn From the Great Teacher", @"Book Publication Name (te)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Life Does Have A Purpose", @"Book Publication Name (lp)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Live Forever in Paridise on Earth", @"Book Publication Name (pe)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Nations Shall Know I am Jehovah", @"Book Publication Name (kj)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Knowledge That Leads to Everlasting Life", @"Book Publication Name (kl)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Keep Yourselves in Gods Love", @"Book Publication Name (lv)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Mankind's Search for God", @"Book Publication Name (sh)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Man's Salvation", @"Book Publication Name (sl)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Ministry School", @"Book Publication Name (sg)"),   PublicationTypeBook}
,   {NSLocalizedString(@"My Book of Bible Stories", @"Book Publication Name (my)"),       PublicationTypeBook}
,   {NSLocalizedString(@"Organized To Do Jehovah's Will", @"Book Publication Name (od)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Our Incoming World Government", @"Book Publication Name (go)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Paradise Restored To Mandkind", @"Book Publication Name (pm)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Proclaimers", @"Book Publication Name (jv)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Revelation Climax", @"Book Publication Name (re)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Sing Praises", @"Book Publication Name (Ssb)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Survival Into a New Earth", @"Book Publication Name (su)"),   PublicationTypeBook}
,   {NSLocalizedString(@"True Peace and Security", @"Book Publication Name (tp)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Truth That Leads to Eternal Life", @"Book Publication Name (tr)"),   PublicationTypeBook}
,   {NSLocalizedString(@"United in Worship", @"Book Publication Name (uw)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Worship the Only True God", @"Book Publication Name (wt)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Worldwide Security", @"Book Publication Name (ws)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Young People Ask 1", @"Book Publication Name (ype-1)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Young People Ask 2", @"Book Publication Name (ype-2)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Your Youth", @"Book Publication Name (yy)"),   PublicationTypeBook}
,   {NSLocalizedString(@"Reasoning", @"Book Publication Name (rs)"),   PublicationTypeBook}

,   {NSLocalizedString(@"   BIBLE DVD", @"Publication Type and Seperator in the Publication Picker"),   PublicationTypeHeading}
,   {NSLocalizedString(@"Bible DVD: Matthew", @"Bible DVD Publication Name (1540)"),   PublicationTypeDVDBible}
,   {NSLocalizedString(@"Bible DVD: Mark", @"Bible DVD Publication Name (1541)"),   PublicationTypeDVDBible}
,   {NSLocalizedString(@"Bible DVD: Luke", @"Bible DVD Publication Name (1542)"),   PublicationTypeDVDBible}
,   {NSLocalizedString(@"Bible DVD: John", @"Bible DVD Publication Name (1543)"),   PublicationTypeDVDBible}
,   {NSLocalizedString(@"Bible DVD: Acts", @"Bible DVD Publication Name"),   PublicationTypeDVDBible}
,   {NSLocalizedString(@"Bible DVD: Romans", @"Bible DVD Publication Name"),   PublicationTypeDVDBible}
,   {NSLocalizedString(@"Bible DVD: 1&2 Corinthians", @"Bible DVD Publication Name"),   PublicationTypeDVDBible}
,   {NSLocalizedString(@"Bible DVD: Galatians, Ephesians, Philippians, Colossians", @"Bible DVD Publication Name"),   PublicationTypeDVDBible}
,   {NSLocalizedString(@"Bible DVD: 1&2 Thessalonians, 1&2 Timothy, Titus, Philemon", @"Bible DVD Publication Name"),   PublicationTypeDVDBible}


,   {NSLocalizedString(@"   DVD", @"Publication Type and Seperator in the Publication Picker"),   PublicationTypeHeading}
,   {NSLocalizedString(@"DVD: Bible Teach", @"DVD Publication Name (9232)"),   PublicationTypeDVDBook}
,   {NSLocalizedString(@"DVD: Family Happiness", @"DVD Publication Name (9220)"),   PublicationTypeDVDBook}
,   {NSLocalizedString(@"DVD: Bible Stories", @"DVD Publication Name"),   PublicationTypeDVDBook}
,   {NSLocalizedString(@"DVD: Greatest Man", @"DVD Publication Name (9202)"),   PublicationTypeDVDBook}
,   {NSLocalizedString(@"DVD: Great Teacher", @"DVD Publication Name ()"),   PublicationTypeDVDBook}
,   {NSLocalizedString(@"DVD: Require", @"DVD Publication Name (9201)"),   PublicationTypeDVDBook}
,   {NSLocalizedString(@"DVD: Knowledge", @"DVD Publication Name (1297)"),   PublicationTypeDVDBook}
,   {NSLocalizedString(@"DVD: Keep Yourselves in Gods Love ", @"DVD Publication Name (?)"),   PublicationTypeDVDBook}
,   {NSLocalizedString(@"DVD: Sing Praises Vol 1&2", @"DVD Publication Name (9203)"),   PublicationTypeDVDBook}
,   {NSLocalizedString(@"DVD: Sing Praises Vol 3", @"DVD Publication Name (9229)"),   PublicationTypeDVDBook}

,   {NSLocalizedString(@"DVD: When someone you love dies", @"DVD Publication Name (9221)"),   PublicationTypeDVDBrochure}
,   {NSLocalizedString(@"DVD: Worship God", @"DVD Publication Name (9213)"),   PublicationTypeDVDBrochure}
,   {NSLocalizedString(@"DVD: God's Friend", @"DVD Publication Name (9211)"),   PublicationTypeDVDBrochure}
,   {NSLocalizedString(@"DVD: Keep on the Watch", @"DVD Publication Name (9218)"),   PublicationTypeDVDBrochure}
,   {NSLocalizedString(@"DVD: Spirits of the dead", @"DVD Publication Name (9216)"),   PublicationTypeDVDBrochure}

,   {NSLocalizedString(@"DVD: Would You Like To Know the Truth?", @"DVD Publication Name (?)"),   PublicationTypeDVDNotCount}	
,   {NSLocalizedString(@"DVD Drama: Noah/David", @"DVD Publication Name  (9215)"),   PublicationTypeDVDNotCount}
,   {NSLocalizedString(@"DVD Drama: Pursue Goals", @"DVD Publication Name (9215)"),   PublicationTypeDVDNotCount}
,   {NSLocalizedString(@"DVD Drama: Bore Witness", @"DVD Publication Name (9224)"),   PublicationTypeDVDNotCount}
,   {NSLocalizedString(@"DVD Drama: Troublesome Times/Boldly Witnessing", @"DVD Publication Name (9241)"),   PublicationTypeDVDNotCount}
,   {NSLocalizedString(@"DVD Drama: Submit to Authority", @"DVD Publication Name (9241)"),   PublicationTypeDVDNotCount}
,   {NSLocalizedString(@"DVD Drama: Respect Authority", @"DVD Publication Name "),   PublicationTypeDVDNotCount}

,   {NSLocalizedString(@"   BROCHURES", @"Publication Type and Seperator in the Publication Picker"),   PublicationTypeHeading}
,   {NSLocalizedString(@"Blood", @"Brochures Publication Name (hb)"),   PublicationTypeBrochure}
,   {NSLocalizedString(@"Book for All", @"Brochures Publication Name (ba)"),   PublicationTypeBrochure}
,   {NSLocalizedString(@"The Bible, What is its Message", @"Brochures Publication Name (bm)"),   PublicationTypeBrochure}
,   {NSLocalizedString(@"Divine Name", @"Brochures Publication Name (na)"),   PublicationTypeBrochure}
,   {NSLocalizedString(@"Does God Care", @"Brochures Publication Name (dg)"),   PublicationTypeBrochure}
,   {NSLocalizedString(@"Doing God's Will", @"Brochures Publication Name (je)"),   PublicationTypeBrochure}
,   {NSLocalizedString(@"Education", @"Brochures Publication Name (ed)"),   PublicationTypeBrochure}
,   {NSLocalizedString(@"God's Friend", @"Brochures Publication Name (gf)"),   PublicationTypeBrochure}
,   {NSLocalizedString(@"Good Land", @"Brochures Publication Name (gl)"),   PublicationTypeBrochure}
,   {NSLocalizedString(@"Government", @"Brochures Publication Name (bp)"),   PublicationTypeBrochure}
,   {NSLocalizedString(@"Guidance of God", @"Brochures Publication Name (gu)"),   PublicationTypeBrochure}
,   {NSLocalizedString(@"Jehovah's Witnesses", @"Brochures Publication Name (jt)"),   PublicationTypeBrochure}
,   {NSLocalizedString(@"Lasting Peace", @"Brochures Publication Name (pc)"),   PublicationTypeBrochure}
,   {NSLocalizedString(@"Life on Earth", @"Brochures Publication Name (le)"),   PublicationTypeBrochure}
,   {NSLocalizedString(@"Look!", @"Brochures Publication Name (mn)"),   PublicationTypeBrochure}
,   {NSLocalizedString(@"Good News for People of All Nations", @"Brochures Publication Name "),   PublicationTypeBrochure}
,   {NSLocalizedString(@"Our Problems", @"Brochures Publication Name (op)"),   PublicationTypeBrochure}
,   {NSLocalizedString(@"Purpose of Life", @"Brochures Publication Name (pr)"),   PublicationTypeBrochure}
,   {NSLocalizedString(@"Require", @"Brochures Publication Name (rq)"),   PublicationTypeBrochure}
,   {NSLocalizedString(@"Road to Life", @"Brochures Publication Name (ol)"),   PublicationTypeBrochure}
,   {NSLocalizedString(@"Satisfying Life", @"Brochures Publication Name (la)"),   PublicationTypeBrochure}
,   {NSLocalizedString(@"School", @"Brochures Publication Name (sj)"),   PublicationTypeBrochure}
,   {NSLocalizedString(@"Spirits of the Dead", @"Brochures Publication Name (sp)"),   PublicationTypeBrochure}
,   {NSLocalizedString(@"Trinity", @"Brochures Publication Name (ti)"),   PublicationTypeBrochure}
,   {NSLocalizedString(@"Keep on the Watch!", @"Brochures Publication Name (kp)"),   PublicationTypeBrochure}
,   {NSLocalizedString(@"When Someone Dies", @"Brochures Publication Name (we)"),   PublicationTypeBrochure}
,   {NSLocalizedString(@"When We Die", @"Brochures Publication Name (ie)"),   PublicationTypeBrochure}
,   {NSLocalizedString(@"Why Worship God", @"Brochures Publication Name (wj)"),   PublicationTypeBrochure}
,   {NSLocalizedString(@"World Without War", @"Brochures Publication Name (wi)"),   PublicationTypeBrochure}


,   {NSLocalizedString(@"   TRACTS", @"Publication Type and Seperator in the Publication Picker"),   PublicationTypeHeading}
,   {NSLocalizedString(@"Would You Like To Know the Truth?", @"Campaign Tract Publication Name (kt)"),   PublicationTypeTract}
,   {NSLocalizedString(@"A Peaceful New World-Will It Come?", @"Tracts Publication Name (T-17)"),   PublicationTypeTract}
,   {NSLocalizedString(@"Comfort for the Depressed", @"Tracts Publication Name (T-20)"),   PublicationTypeTract}
,   {NSLocalizedString(@"Enjoy Family Life", @"Tracts Publication Name (T-21)"),   PublicationTypeTract}
,   {NSLocalizedString(@"Does Fate Rule Our Lives", @"Tracts Publication Name (T-71)"),   PublicationTypeTract}
,   {NSLocalizedString(@"The Greatest Name", @"Tracts Publication Name (T-72)"),   PublicationTypeTract}
,   {NSLocalizedString(@"Hellfire-Is It Part of Divine Justice?", @"Tracts Publication Name (T-74)"),   PublicationTypeTract}
,   {NSLocalizedString(@"What Hope for Dead Loved Ones?", @"Tracts Publication Name (T-16)"),   PublicationTypeTract}
,   {NSLocalizedString(@"How to Find the Road to Paradise", @"Tracts Publication Name (rp)"),   PublicationTypeTract}
,   {NSLocalizedString(@"Do You Have an Immortal Spirit", @"Tracts Publication Name (T-25)"),   PublicationTypeTract}
,   {NSLocalizedString(@"Jehovah's Witnesses-What Do They Believe?", @"Tracts Publication Name (T-18)"),   PublicationTypeTract}
,   {NSLocalizedString(@"Who Are Jehovah's Witnesses?", @"Tracts Publication Name (T-73)"),   PublicationTypeTract}
,   {NSLocalizedString(@"Jehovah-Who Is He?", @"Tracts Publication Name (T-23)"),   PublicationTypeTract}
,   {NSLocalizedString(@"Jesus Christ-Who Is He?", @"Tracts Publication Name (T-24)"),   PublicationTypeTract}
,   {NSLocalizedString(@"Know the Bible", @"Tracts Publication Name (T-26)"),   PublicationTypeTract}
,   {NSLocalizedString(@"Life in a Peaceful New World", @"Tracts Publication Name (T-15)"),   PublicationTypeTract}
,   {NSLocalizedString(@"All Suffering Soon to End", @"Tracts Publication Name (T-27)"),   PublicationTypeTract}
,   {NSLocalizedString(@"What Do Jehovah's Witnesses Believe?", @"Tracts Publication Name (T-14)"),   PublicationTypeTract}
,   {NSLocalizedString(@"Who Really Rules the World?", @"Tracts Publication Name (T-22)"),   PublicationTypeTract}
,   {NSLocalizedString(@"Why You Can Trust the Bible", @"Tracts Publication Name (T-13)"),   PublicationTypeTract}
,   {NSLocalizedString(@"Will This World Survive?", @"Tracts Publication Name (T-19)"),   PublicationTypeTract}
,   {NSLocalizedString(@"Your Life", @"Tracts Publication Name (yi)"),   PublicationTypeTract}
};
#include "PSAddLocalizedString.h"

+ (NSString *)watchtowerAndAwake
{
	return [[PSLocalization localizationBundle] localizedStringForKey:PUBLICATIONS[0].name value:PUBLICATIONS[0].name table:@""];
}

+ (NSString *)watchtower
{
	return [[PSLocalization localizationBundle] localizedStringForKey:PUBLICATIONS[0].name value:PUBLICATIONS[1].name table:@""];
}

+ (NSString *)awake
{
	return [[PSLocalization localizationBundle] localizedStringForKey:PUBLICATIONS[1].name value:PUBLICATIONS[2].name table:@""];
}

- (BOOL)publicationIsWatchtowerAndAwake:(int)publication
{
	return [[_publicationLookupTable objectAtIndex:publication] intValue] == 0;
}

- (BOOL)publicationIsWatchtower:(int)publication
{
	return [[_publicationLookupTable objectAtIndex:publication] intValue] == 1;
}

- (BOOL)publicationIsAwake:(int)publication
{
	return [[_publicationLookupTable objectAtIndex:publication] intValue] == 2;
}

- (BOOL)publicationIsYearbook:(int)publication
{
	return [[_publicationLookupTable objectAtIndex:publication] intValue] == 10;
}



// Delegate Methods

#define PUBLICATION_WIDTH 140
#define MONTH_WIDTH 53
#define YEAR_WIDTH 58
#define DAY_WIDTH 45

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    VERY_VERBOSE(NSLog(@"pickerView: widthForComponent:%d", component);)
	
    // based on what we already know about the publication, lets
    // setup the width of the picker.
    switch([self numberOfComponentsInPickerView: pickerView])
    {
			
        case 1:
            // if there is only one publication, then set the only column to 
            // the width of the entire picker
            return PUBLICATION_WIDTH + MONTH_WIDTH + YEAR_WIDTH + DAY_WIDTH;
			
        case 2:
            // if there are three columns then the "last two" columns are combined
            // to make the picker look like it is adjusting for the years
            switch(component)
			{
				case 0:
					return PUBLICATION_WIDTH + MONTH_WIDTH + DAY_WIDTH;
				case 1:
					return YEAR_WIDTH;
			}
			break;
			
        case 3:
            // if there are three columns then the "last two" columns are combined
            // to make the picker look like it is adjusting for the years
            switch(component)
			{
				case 0:
					return PUBLICATION_WIDTH;
				case 1:
					return MONTH_WIDTH;
				case 2:
					return YEAR_WIDTH + DAY_WIDTH;
			}
			break;
			
        case 4:
            // if there are four columns then report each of the column widths
            switch(component)
			{
				case 0:
					return PUBLICATION_WIDTH;
				case 1:
					return MONTH_WIDTH;
				case 2:
					return YEAR_WIDTH;
				case 3:
					return DAY_WIDTH;
			}
			break;
	}
	return 1;
}
#if 0
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    VERY_VERBOSE(NSLog(@"pickerView: viewForRow:%d inComponent:%d", row, component);)
	
	UILabel *cell = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, [self pickerView:pickerView widthForComponent:component] - 6.0, 44.0)] autorelease];
	cell.autoresizingMask  = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	
#warning need to setup height	
    // if this is the publicaiton column then just display the
    // publication name
    if(component == 0)
    {
		
		cell.textAlignment = UITextAlignmentLeft;
		int index = [[_publicationLookupTable objectAtIndex:row] intValue];
		cell.text = [[PSLocalization localizationBundle] localizedStringForKey:PUBLICATIONS[index].name value:PUBLICATIONS[index].name table:@""];
    }
    else
    {
        // if the publicaiton is a watchtower or an awake, then
        // we have to display the month year and possibly date of
        // the publication
		if([self publicationIsWatchtowerAndAwake:_publication])
		{
            // W & A Jan 2007
			switch(component)
			{
				case 1: // Month
					cell.textAlignment = UITextAlignmentCenter;
					cell.text = [[PSLocalization localizationBundle] localizedStringForKey:MONTHS[row] value:MONTHS[row] table:@""];
					break;
				case 2: // Year
					cell.textAlignment = UITextAlignmentLeft;
					// we offset the _year from 1900
					cell.text = [NSString stringWithFormat:@"%d", row+YEAR_OFFSET];
					break;
			}
		} 
		else if([self publicationIsWatchtower:_publication])
		{
            // Watchtower Jan 2007 15
			switch(component)
			{
				case 1: // Month
				{
					cell.textAlignment = UITextAlignmentCenter;
					cell.text = [[PSLocalization localizationBundle] localizedStringForKey:MONTHS[row] value:MONTHS[row] table:@""];
					break;
				}	
				case 2: // Year
					cell.textAlignment = UITextAlignmentLeft;
					// we offset the _year from 1900
					cell.text = [NSString stringWithFormat:@"%d", row+YEAR_OFFSET];
					break;
					
				case 3: // day
					cell.textAlignment = UITextAlignmentCenter;
					// when the watchtower was bimonthly, it came out on the 1st and 15th
					cell.text = row == 0 ? @"1" : @"15";
					break;
			}
		} 
		else if([self publicationIsAwake:_publication])
		{
			// Awake Jan 2007 15
			switch(component)
			{
				case 1: // Month
				{
					cell.textAlignment = UITextAlignmentCenter;
					cell.text = [[PSLocalization localizationBundle] localizedStringForKey:MONTHS[row] value:MONTHS[row] table:@""];
					break;
				}	
				case 2: // Year
					cell.textAlignment = UITextAlignmentLeft;
					// we offset the _year from 1900
					cell.text = [NSString stringWithFormat:@"%d", row+YEAR_OFFSET];
					break;
					
				case 3: // day
					cell.textAlignment = UITextAlignmentCenter;
					// when the awake was bimonthly, it came out on the 8th and 22nd
					cell.text = row == 0 ? @"8" : @"22";
					break;
			}
        }
		else if([self publicationIsYearbook:_publication])
		{
			// Awake Jan 2007 15
			switch(component)
			{
				case 1: // Year
					cell.textAlignment = UITextAlignmentLeft;
					// we offset the _year from 1900
					cell.text = [NSString stringWithFormat:@"%d", row+YEAR_OFFSET];
					break;
			}
        }
    }    
	return(cell);
}
#else
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    VERY_VERBOSE(NSLog(@"pickerView: viewForRow:%d inComponent:%d", row, component);)
	NSString *ret = @"";
	
    // if this is the publicaiton column then just display the
    // publication name
    if(component == 0)
    {
		int index = [[_publicationLookupTable objectAtIndex:row] intValue];
		ret = [[PSLocalization localizationBundle] localizedStringForKey:PUBLICATIONS[index].name value:PUBLICATIONS[index].name table:@""];
    }
    else
    {
        // if the publicaiton is a watchtower or an awake, then
        // we have to display the month year and possibly date of
        // the publication
		if([self publicationIsWatchtowerAndAwake:_publication])
		{
			// W & A Jan 2007
			switch(component)
			{
				case 1: // Month
					ret = [[PSLocalization localizationBundle] localizedStringForKey:MONTHS[row] value:MONTHS[row] table:@""];
					break;
				case 2: // Year
					// we offset the _year from 1900
					ret = [NSString stringWithFormat:@"%d", row+YEAR_OFFSET];
					break;
			}
		}
		else if([self publicationIsWatchtower:_publication])
		{
			// Watchtower Jan 2007 15
			switch(component)
			{
				case 1: // Month
					ret = [[PSLocalization localizationBundle] localizedStringForKey:MONTHS[row] value:MONTHS[row] table:@""];
					break;
				case 2: // Year
					// we offset the _year from 1900
					ret = [NSString stringWithFormat:@"%d", row+YEAR_OFFSET];
					break;
					
				case 3: // day
					// when the watchtower was bimonthly, it came out on the 1st and 15th
					ret = row == 0 ? @"1" : @"15";
					break;
			}
		}
		else if([self publicationIsAwake:_publication])
		{
            // Awake Jan 2007 15
			switch(component)
			{
				case 1: // Month
				{
					ret = [[PSLocalization localizationBundle] localizedStringForKey:MONTHS[row] value:MONTHS[row] table:@""];
					break;
				}	
				case 2: // Year
					// we offset the _year from 1900
					ret = [NSString stringWithFormat:@"%d", row+YEAR_OFFSET];
					break;
					
				case 3: // day
					// when the awake was bimonthly, it came out on the 8th and 22nd
					ret = row == 0 ? @"8" : @"22";
					break;
			}
        }
		else if([self publicationIsYearbook:_publication])
		{
            // Awake Jan 2007 15
			switch(component)
			{
				case 1: // Year
					// we offset the _year from 1900
					ret = [NSString stringWithFormat:@"%d", row+YEAR_OFFSET];
					break;
			}
        }
    }    
	return(ret);
}
#endif
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // save off the previous information before the change (we need to know this
    // because we should not look for the year if the previous publication was not
    // a watchtower or an awake
    int previousPublication = _publication;
    int previousYear = _year;
    int previousMonth = _month;
    int previousDay = _day;
	
	int index = [[_publicationLookupTable objectAtIndex:_publication] intValue];
    VERBOSE(NSLog(@"publication:%@ month:%@ year:%d day:%d", PUBLICATIONS[index], MONTHS[_month], _year + YEAR_OFFSET, _day);)
	
	// what is the new publication?
	if(component == 0)
	{
		_publication = row;
    }
    // if the previous publication was a watchtower or awake, then 
    // lets get at the month year and possibly date of the magazine
    if([self publicationIsWatchtower:previousPublication] || 
	   [self publicationIsAwake:previousPublication] || 
	   [self publicationIsWatchtowerAndAwake:previousPublication])
    {
        if(component == 1)
			_month = row;
        if(component == 2)
			_year = row;
        // if the previous year selected was < 2008 then the watchtower would have had a date 
        // column in the picker
        if(component == 3 && [self publicationIsWatchtower:previousPublication] && previousYear + YEAR_OFFSET < 2008)
            _day = row;
        
        // if the previous year selected was < 2007 then the awake would have had a date 
        // column in the picker
        if(component == 3 && [self publicationIsAwake:previousPublication] && previousYear + YEAR_OFFSET < 2007)
            _day = row;
    }
    if([self publicationIsYearbook:previousPublication])
    {
        if(component == 1)
			_year = row;
    }
	
    // if anything changed, update the picker so that it will dynamically display the columns
    // (for example if you went from a watchtower to a bible teach book we would only have one
    // column in the picker).  This is to work around a problem that if you select a value before
    // it has time to be animated to the selection point (straight down the middle of the picker) it
    // will get reset and will not pick the correct value, we only update when the values have changed.
    if(previousYear != _year ||
       previousMonth != _month || 
       previousDay != _day ||
       previousPublication != _publication)
    {

		index = [[_publicationLookupTable objectAtIndex:_publication] intValue];
        DEBUG(NSLog(@"DATA CHANGED:\npublication:%@ month:%@ year:%d day:%d", PUBLICATIONS[index], MONTHS[_month], _year + YEAR_OFFSET, _day);)
        [pickerView reloadAllComponents];
		
		BOOL skipped = NO;
		// advance past any headings (might have more than once because of translators)
		while(component == 0 &&
		   [PUBLICATIONS[[[_publicationLookupTable objectAtIndex:_publication] intValue]].type isEqualToString:PublicationTypeHeading])
		{
			// skip past the heading
			_publication++;
			skipped = YES;
		}
		if(skipped)
		{
			[self selectRow:_publication inComponent:0 animated:YES];
		}

		// the watchtower and awake are the only ones that have a subscription
		// type of placement, all others are just books that do not have a release
		// time
		if([self publicationIsWatchtower:_publication] || [self publicationIsAwake:_publication])
		{
			[self selectRow:_month inComponent:1 animated:NO];
			[self selectRow:_year inComponent:2 animated:NO];
			
			// in 2008, the watchtower went from bimonthly to monthly
			if(_publication == 0 && _year + YEAR_OFFSET < 2008)
				[self selectRow:_day inComponent:3 animated:NO];
			
			// in 2007, the awake went from bimonthly to monthly
			if(_publication == 1 && _year + YEAR_OFFSET < 2007)
				[self selectRow:_day inComponent:3 animated:NO];
		}
		else if([self publicationIsWatchtowerAndAwake:_publication])
		{
			[self selectRow:_month inComponent:1 animated:NO];
			[self selectRow:_year inComponent:2 animated:NO];
		}
		else if([self publicationIsYearbook:_publication])
		{
			[self selectRow:_year inComponent:1 animated:NO];
		}
    }
}

// DataSource Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    int ret = 1;
	if([self publicationIsWatchtowerAndAwake:_publication])
	{
		// W & A Jan 2007
		ret = 3;
	}
	else if([self publicationIsWatchtower:_publication])
	{
		// Watchtower Jan 2007 15
		// check to see if they chose something before 2008, if so then
		// we need to specify the 1st or the 15th of the month
		if( _year + YEAR_OFFSET < 2008)
		{
			ret = 4;
		}
		else
		{
			// we went to only one a month in 2008
			ret = 3;
		}
	}
	else if([self publicationIsAwake:_publication])
	{
        // Awake Jan 2006 22
		// check to see if they chose something before 2007, if so then
		// we need to specify the 1st or the 15th of the month
		if( _year + YEAR_OFFSET < 2007)
		{
			ret = 4;
		}
		else
		{
			// we went to only one a month in 2008
			ret = 3;
		}
    }
	else if([self publicationIsYearbook:_publication])
	{
        // Yearbook 2006
		// check to see if they chose something before 2007, if so then
		// we need to specify the 1st or the 15th of the month
		ret = 2;
    }
    VERY_VERBOSE(NSLog(@"numberOfComponentsInPickerView: %d", ret);)
    return(ret);
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    VERY_VERBOSE(NSLog(@"pickerView: numberOfRowsInComponent: %d", component);)
	
    // col 0 is the publications column
    if(component == 0)
    {
        return(_publicationLookupTable.count);
    }
    else
    {
        // if the publication is a watchtower or an awake
        // then there might be 3 or four columns
		if([self publicationIsWatchtower:_publication] || 
		   [self publicationIsAwake:_publication] ||
		   [self publicationIsWatchtowerAndAwake:_publication])
		{
            // Watchtower Jan 2007 15
            // Awake Jan 2006 22
			switch(component)
			{
				case 1: // Month
					return(12);
				case 2: // Year
					return(200);
				case 3: // day
					return(2);
					
			}
		}		
		else if([self publicationIsYearbook:_publication])
		{
            // Yearbook 2009
			switch(component)
			{
				case 1: // Year
					return(200);
			}
		}
		
    }
	return(0);
}

- (void) dealloc
{
    VERY_VERBOSE(NSLog(@"PublicationPicker: dealloc");)
	[_publicationLookupTable release];
    [super dealloc];
}

- (id) initWithFrame: (CGRect)rect
{
    // initalize the data to the current date
	NSDate *date = [NSDate date];
	NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit|NSMonthCalendarUnit) fromDate:date];
    // set the default publication to be the watchtower this month and year
	int month = [dateComponents month];
	int year = [dateComponents year];
    int day = 1;
	
    return([self initWithFrame:rect publication:[PublicationPickerView watchtowerAndAwake] year:year month:month day:day]);
}

- (id) initWithFrame: (CGRect)rect filteredToType:(NSString *)filter
{
    // initalize the data to the current date
	NSDate *date = [NSDate date];
	NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit|NSMonthCalendarUnit) fromDate:date];
    // set the default publication to be the watchtower this month and year
	int month = [dateComponents month];
	int year = [dateComponents year];
    int day = 1;

	return([self initWithFrame:rect publication:[PublicationPickerView watchtowerAndAwake] year:year month:month day:day filter:filter]);
}

- (id) initWithFrame: (CGRect)rect publication: (NSString *)publication year: (int)year month: (int)month day: (int)day
{
	return([self initWithFrame:rect publication:[PublicationPickerView watchtowerAndAwake] year:year month:month day:day filter:nil]);
}

// initialize this view given the curent configuration
- (id) initWithFrame: (CGRect)rect publication: (NSString *)publication year: (int)year month: (int)month day: (int)day filter:(NSString *)filter
{
    if((self = [super initWithFrame: rect])) 
    {
        int i;
        DEBUG(NSLog(@"PublicationPickerView initWithFrame: publication:\"%@\" year:%d month:%d day:%d", publication, year, month, day);)

		self.showsSelectionIndicator = YES;
        // we are managing the picker's data and display
		self.delegate = self;
		self.dataSource = self;
		_publicationLookupTable = [[NSMutableArray alloc] init];
		BOOL foundFilter = filter == nil;
		const BOOL usingFilter = filter != nil;
		for(i = 0; i < ARRAY_SIZE(PUBLICATIONS); i++)
		{
			if(foundFilter)
			{
				// we are adding to the display list and if we hit a headding stop
				if(usingFilter && [PUBLICATIONS[i].type isEqualToString:PublicationTypeHeading])
				{
					break;
				}
				NSString *translatedName = [[PSLocalization localizationBundle] localizedStringForKey:PUBLICATIONS[i].name value:PUBLICATIONS[i].name table:@""];
				if(translatedName.length)
				{
					[_publicationLookupTable addObject:[NSNumber numberWithInt:i]];
				}
				else
				{
					DEBUG(NSLog(@"%s missing %@", __FUNCTION__, PUBLICATIONS[i].name);)
				}
			}
			else
			{
				if([filter isEqualToString:PUBLICATIONS[i].type])
				{
					foundFilter = YES;
					--i; // subtract one from the count so that we can try again
				}
			}
		}

        _publication = 0;
		i = 0;
        for(NSNumber *number in _publicationLookupTable)
        {
			int index = [number intValue];
            if([publication isEqualToString:PUBLICATIONS[index].name])
            {
                _publication = i;
                break;
            }
			++i;
        }
		
        if([self publicationIsWatchtower:_publication] || 
		   [self publicationIsAwake:_publication] ||
		   [self publicationIsWatchtowerAndAwake:_publication])
        {
            _year = year - YEAR_OFFSET;
            _month = month - 1;
            // translate the publication date, otherwise leave it at index 0
            if([self publicationIsWatchtower:_publication])
                _day = day == 15 ? 1 : 0;
            if([self publicationIsAwake:_publication])
                _day = day == 22 ? 1 : 0;
        }
        else if([self publicationIsYearbook:_publication])
        {
            _year = year - YEAR_OFFSET;
            // initalize the date information to the current date, since it is just a book
            // and does not have a publication date (if they want to change the publication
            // to a magazine, at least they will see the current date's magazine)
			NSDate *date = [NSDate date];
			NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit|NSMonthCalendarUnit) fromDate:date];
            // set the default publication to be the watchtower this month and year
            _month = [dateComponents month] - 1;
            _day = 0; // 1st or 22nd
        }
        else
        {
            // initalize the date information to the current date, since it is just a book
            // and does not have a publication date (if they want to change the publication
            // to a magazine, at least they will see the current date's magazine)
			NSDate *date = [NSDate date];
			NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit|NSMonthCalendarUnit) fromDate:date];
            // set the default publication to be the watchtower this month and year
            _year = [dateComponents year] - YEAR_OFFSET;
            _month = [dateComponents month] - 1;
            _day = 0; // 1st or 22nd
        }
		
		[self reloadAllComponents];
		// select the publication
		[self selectRow:_publication inComponent: 0 animated: NO];
		
		// the watchtower and awake are the only ones that have a subscription
		// type of placement, all others are just books that do not have a release
		// time
		if([self publicationIsWatchtowerAndAwake:_publication])
		{
			[self selectRow:_month inComponent:1 animated:NO];
			[self selectRow:_year inComponent:2 animated:NO];
		}
		else if([self publicationIsWatchtower:_publication] || [self publicationIsAwake:_publication])
		{
			[self selectRow:_month inComponent:1 animated:NO];
			[self selectRow:_year inComponent:2 animated:NO];
			
			// in 2008, the watchtower went from bimonthly to monthly
			if([self publicationIsWatchtower:_publication] && _year + YEAR_OFFSET < 2008)
				[self selectRow:_day inComponent:3 animated:NO];
			
			// in 2007, the awake went from bimonthly to monthly
			if([self publicationIsAwake:_publication] && _year + YEAR_OFFSET < 2007)
				[self selectRow:_day inComponent:3 animated:NO];
		}
		else if([self publicationIsYearbook:_publication])
		{
			[self selectRow:_year inComponent:1 animated:NO];
		}
    }
    
    return(self);
}

+ (BOOL)areTherePublicationsForFilter:(NSString *)filter
{
	if(filter == nil || filter.length == 0)
		return YES;
		
	for(int i = 0; i < ARRAY_SIZE(PUBLICATIONS); i++)
	{
		if([filter isEqualToString:PUBLICATIONS[i].type])
		{
			NSString *translatedName = [[PSLocalization localizationBundle] localizedStringForKey:PUBLICATIONS[i].name value:PUBLICATIONS[i].name table:@""];
			if(translatedName.length)
			{
				return YES;
			}
		}
	}
	return NO;
}

// year of our common era
- (int)year
{
    return(YEAR_OFFSET + _year);
}

// 0-11 where 0=Jan
- (int)month
{
    if([self publicationIsWatchtower:_publication] || 
	   [self publicationIsAwake:_publication] ||
	   [self publicationIsWatchtowerAndAwake:_publication])
        return(_month + 1);
    else
        return(0);
}

// string of the publication name
- (NSString *)publication
{
	int index = [[_publicationLookupTable objectAtIndex:_publication] intValue];
    return([NSString stringWithString:PUBLICATIONS[index].name]);
}

// string of the publication title
- (NSString *)publicationTitle
{
    int day = [self day];
    int year = [self year];
    int month = [self month];

	int index = [[_publicationLookupTable objectAtIndex:_publication] intValue];
    if([self publicationIsWatchtower:_publication] || 
	   [self publicationIsAwake:_publication] ||
	   [self publicationIsWatchtowerAndAwake:_publication])
    {
        if(day)
            return([NSString stringWithFormat:NSLocalizedString(@"%@ %@ %d, %d", @"This is a representation for the watchtower or awake when it was published on the 1, 15 and 2, 22 respectively, like Watchtower March 15, 2001, please use %1$@ as the magazine type %2$@ as the month %3$d as the day of the month and %4$d as the year"),
							                                    [[PSLocalization localizationBundle] localizedStringForKey:PUBLICATIONS[index].name value:PUBLICATIONS[index].name table:@""], 
																[[PSLocalization localizationBundle] localizedStringForKey:MONTHS[month-1] value:MONTHS[month-1] table:@""], 
																day, 
																year ]);
        else
            return([NSString stringWithFormat:NSLocalizedString(@"%@ %@ %d", @"This is a representation for the watchtower or awake (or W & A combo) when it was published on the 1, 15 and 2, 22 respectively, like Watchtower March 15, 2001, please use %1$@ as the magazine type %2$@ as the month and %3$d as the year"),
			                                                    [[PSLocalization localizationBundle] localizedStringForKey:PUBLICATIONS[index].name value:PUBLICATIONS[index].name table:@""], 
																[[PSLocalization localizationBundle] localizedStringForKey:MONTHS[month-1] value:MONTHS[month-1] table:@""], 
																year ]);
    }
    else if([self publicationIsYearbook:_publication])
    {
		return([NSString stringWithFormat:NSLocalizedString(@"%d %@", @"This is a representation for the yearbook when it was published on what year, like 2009 Yearbook, please use %2$@ as the placeholder for 'Yearbook' %1$d as the year"),
																year,
																[[PSLocalization localizationBundle] localizedStringForKey:PUBLICATIONS[index].name value:PUBLICATIONS[index].name table:@""]]);
    }
    else
    {
        return([NSString stringWithString: [[PSLocalization localizationBundle] localizedStringForKey:PUBLICATIONS[index].name value:PUBLICATIONS[index].name table:@""]] );
    }
}

- (BOOL)isWatchtowerAndAwake
{
	return [self publicationIsWatchtowerAndAwake:_publication];
}

// string of the publication name
- (NSString *)publicationType
{
	int index = [[_publicationLookupTable objectAtIndex:_publication] intValue];
	if(index == 0)
		return PublicationTypeTwoMagazine;
	else
		return [NSString stringWithString:PUBLICATIONS[index].type];
}



// 0 = not used and 1, 8, 15, 22 for the day of the month
- (int)day
{
    // if the previous year selected was < 2008 then the watchtower would have had a date 
    // column in the picker, so figure out which date it is
    if([self publicationIsWatchtower:_publication] && _year + YEAR_OFFSET < 2008)
        return(_day ? 15 : 1);
    
    // if the previous year selected was < 2007 then the awake would have had a date 
    // column in the picker, so figure out which date it is
    if([self publicationIsAwake:_publication] && _year + YEAR_OFFSET < 2007)
        return(_day ? 22 : 8);
	
    return(0);
}


- (BOOL)respondsToSelector:(SEL)selector
{
	BOOL ret = [super respondsToSelector:selector];
    VERY_VERBOSE(NSLog(@"%s respondsToSelector: %s ? %s", __FILE__, selector, ret ? "YES" : "NO");)
    return ret;
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"%s methodSignatureForSelector: %s", __FILE__, selector);)
    return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
    VERY_VERBOSE(NSLog(@"%s forwardInvocation: %s", __FILE__, [invocation selector]);)
    [super forwardInvocation:invocation];
}


@end

