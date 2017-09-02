//
//	ReaderContentView.m
//	Reader v2.8.7
//
//	Created by Julius Oklamcak on 2011-07-01.
//	Copyright © 2011-2016 Julius Oklamcak. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//	of the Software, and to permit persons to whom the Software is furnished to
//	do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "ReaderConstants.h"
#import "ReaderContentView.h"
#import "ReaderContentPage.h"
#import "ReaderThumbCache.h"

#import <QuartzCore/QuartzCore.h>

static CGFloat fBtnWidth = 35.f;
static CGFloat fBtnHeight = 35.f;
static CGFloat fLbWidth = 80.f;
static CGFloat fLbHeight = 30.f;

@interface ReaderContentView () <UIScrollViewDelegate>
@property (nonatomic, strong) UIImageView *iv_Guide;
@end

@implementation ReaderContentView
{
	UIView *theContainerView;

	UIUserInterfaceIdiom userInterfaceIdiom;

	ReaderContentPage *theContentPage;

	ReaderContentThumb *theThumbView;

	CGFloat realMaximumZoom;
	CGFloat tempMaximumZoom;

	BOOL zoomBounced;
}

#pragma mark - Constants

#define ZOOM_FACTOR 2.0f
#define ZOOM_MAXIMUM 16.0f

#define PAGE_THUMB_SMALL 144
#define PAGE_THUMB_LARGE 240

static void *ReaderContentViewContext = &ReaderContentViewContext;

static CGFloat g_BugFixWidthInset = 0.0f;

#pragma mark - Properties

@synthesize message;

#pragma mark - ReaderContentView functions

static inline CGFloat zoomScaleThatFits(CGSize target, CGSize source)
{
	CGFloat w_scale = (target.width / (source.width + g_BugFixWidthInset));

	CGFloat h_scale = (target.height / source.height);

	return ((w_scale < h_scale) ? w_scale : h_scale);
}

#pragma mark - ReaderContentView class methods

+ (void)initialize
{
	if (self == [ReaderContentView self]) // Do once - iOS 8.0 UIScrollView bug workaround
	{
		if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) // Not iPads
		{
			NSString *iosVersion = [UIDevice currentDevice].systemVersion; // iOS version as a string

			if ([@"8.0" compare:iosVersion options:NSNumericSearch] != NSOrderedDescending) // 8.0 and up
			{
//				if ([@"8.2" compare:iosVersion options:NSNumericSearch] == NSOrderedDescending) // Below 8.2
//				{
					g_BugFixWidthInset = 2.0f * [[UIScreen mainScreen] scale]; // Reduce width of content view
//				}
			}
		}
	}
}

#pragma mark - ReaderContentView instance methods

- (void)updateMinimumMaximumZoom
{
	CGFloat zoomScale = zoomScaleThatFits(self.bounds.size, theContentPage.bounds.size);

	self.minimumZoomScale = zoomScale; self.maximumZoomScale = (zoomScale * ZOOM_MAXIMUM);

	realMaximumZoom = self.maximumZoomScale; tempMaximumZoom = (realMaximumZoom * ZOOM_FACTOR);
}

- (void)centerScrollViewContent
{
	CGFloat iw = 0.0f; CGFloat ih = 0.0f; // Content width and height insets

	CGSize boundsSize = self.bounds.size; CGSize contentSize = self.contentSize; // Sizes

	if (contentSize.width < boundsSize.width) iw = ((boundsSize.width - contentSize.width) * 0.5f);

	if (contentSize.height < boundsSize.height) ih = ((boundsSize.height - contentSize.height) * 0.5f);

	UIEdgeInsets insets = UIEdgeInsetsMake(ih, iw, ih, iw); // Create (possibly updated) content insets

	if (UIEdgeInsetsEqualToEdgeInsets(self.contentInset, insets) == false) self.contentInset = insets;
}

- (void)setAudioFrame
{
    if( theContainerView )
    {
        theContainerView.frame = CGRectMake(0, 64, theContainerView.bounds.size.width, theContainerView.bounds.size.height);
    }
}

- (instancetype)initWithFrame:(CGRect)frame fileURL:(NSURL *)fileURL page:(NSUInteger)page password:(NSString *)phrase
{
	if ((self = [super initWithFrame:frame]))
	{
		self.scrollsToTop = NO;
		self.delaysContentTouches = NO;
		self.showsVerticalScrollIndicator = NO;
		self.showsHorizontalScrollIndicator = NO;
		self.contentMode = UIViewContentModeRedraw;
		self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		self.backgroundColor = [UIColor clearColor];
		self.autoresizesSubviews = NO;
		self.clipsToBounds = NO;
		self.delegate = self;

		userInterfaceIdiom = [UIDevice currentDevice].userInterfaceIdiom; // User interface idiom

		theContentPage = [[ReaderContentPage alloc] initWithURL:fileURL page:page password:phrase];

		if (theContentPage != nil) // Must have a valid and initialized content page
		{
            //실제 PDF뷰 사이즈 여백으로 100 더 줌 출처도 표시해야 하고 하니까~ 100 더 안주면 PDF뷰가 짧아서 버튼 이벤트가 안먹음
			theContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, theContentPage.bounds.size.width, theContentPage.bounds.size.height + 100)];

			theContainerView.autoresizesSubviews = NO;
			theContainerView.userInteractionEnabled = NO;
			theContainerView.contentMode = UIViewContentModeRedraw;
			theContainerView.autoresizingMask = UIViewAutoresizingNone;
			theContainerView.backgroundColor = [UIColor whiteColor];

#if (READER_SHOW_SHADOWS == TRUE) // Option

			theContainerView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
			theContainerView.layer.shadowRadius = 4.0f; theContainerView.layer.shadowOpacity = 1.0f;
			theContainerView.layer.shadowPath = [UIBezierPath bezierPathWithRect:theContainerView.bounds].CGPath;

#endif // end of READER_SHOW_SHADOWS Option

			self.contentSize = theContentPage.bounds.size; [self centerScrollViewContent];

#if (READER_ENABLE_PREVIEW == TRUE) // Option

			theThumbView = [[ReaderContentThumb alloc] initWithFrame:theContentPage.bounds]; // Page thumb view

			[theContainerView addSubview:theThumbView]; // Add the page thumb view to the container view

#endif // end of READER_ENABLE_PREVIEW Option

			[theContainerView addSubview:theContentPage]; // Add the content page to the container view

			[self addSubview:theContainerView]; // Add the container view to the scroll view

			[self updateMinimumMaximumZoom]; // Update the minimum and maximum zoom scales

			self.zoomScale = self.minimumZoomScale; // Set the zoom scale to fit page content

			[self addObserver:self forKeyPath:@"frame" options:0 context:ReaderContentViewContext];
            
		}

		self.tag = page; // Tag the view with the page number
	}

	return self;
}

- (void)updatePdfView:(NSDictionary *)dic
{
    if( self.isWrong )  return;
    
    __block CGFloat fScale = (self.bounds.size.width - 34) / [[dic objectForKey:@"width"] floatValue];

    self.iv_Guide = [[UIImageView alloc] initWithFrame:CGRectMake([[dic objectForKey:@"startX"] floatValue], [[dic objectForKey:@"startY"] floatValue] + 100,
                                                                  [[dic objectForKey:@"width"] floatValue] * fScale, [[dic objectForKey:@"height"] floatValue] * fScale)];
    self.iv_Guide.tag = 987;
    self.iv_Guide.layer.borderColor = [UIColor redColor].CGColor;
    self.iv_Guide.layer.borderWidth = 1.f;
    //    iv_Guide.center = self.center;
    [self addSubview:self.iv_Guide];
    
    [UIView animateWithDuration:1.0f animations:^{
        
        self.zoomScale = fScale;
        self.contentOffset = CGPointMake([[dic objectForKey:@"startX"] floatValue], [[dic objectForKey:@"startY"] floatValue]);
    }];
}

- (void)dealloc
{
	[self removeObserver:self forKeyPath:@"frame" context:ReaderContentViewContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == ReaderContentViewContext) // Our context
	{
		if ((object == self) && [keyPath isEqualToString:@"frame"])
		{
			[self centerScrollViewContent]; // Center content

			CGFloat oldMinimumZoomScale = self.minimumZoomScale;

			[self updateMinimumMaximumZoom]; // Update zoom scale limits

			if (self.zoomScale == oldMinimumZoomScale) // Old minimum
			{
				self.zoomScale = self.minimumZoomScale;
			}
			else // Check against minimum zoom scale
			{
				if (self.zoomScale < self.minimumZoomScale)
				{
					self.zoomScale = self.minimumZoomScale;
				}
				else // Check against maximum zoom scale
				{
					if (self.zoomScale > self.maximumZoomScale)
					{
						self.zoomScale = self.maximumZoomScale;
					}
				}
			}
		}
	}
}

- (void)showPageThumb:(NSURL *)fileURL page:(NSInteger)page password:(NSString *)phrase guid:(NSString *)guid
{
#if (READER_ENABLE_PREVIEW == TRUE) // Option

	CGSize size = ((userInterfaceIdiom == UIUserInterfaceIdiomPad) ? CGSizeMake(PAGE_THUMB_LARGE, PAGE_THUMB_LARGE) : CGSizeMake(PAGE_THUMB_SMALL, PAGE_THUMB_SMALL));

	ReaderThumbRequest *request = [ReaderThumbRequest newForView:theThumbView fileURL:fileURL password:phrase guid:guid page:page size:size];

	UIImage *image = [[ReaderThumbCache sharedInstance] thumbRequest:request priority:YES]; // Request the page thumb

	if ([image isKindOfClass:[UIImage class]]) [theThumbView showImage:image]; // Show image from cache

#endif // end of READER_ENABLE_PREVIEW Option
}

- (id)processSingleTap:(UITapGestureRecognizer *)recognizer
{
	return [theContentPage processSingleTap:recognizer];
}

- (CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center
{
	CGRect zoomRect; // Centered zoom rect

	zoomRect.size.width = (self.bounds.size.width / scale);
	zoomRect.size.height = (self.bounds.size.height / scale);

	zoomRect.origin.x = (center.x - (zoomRect.size.width * 0.5f));
	zoomRect.origin.y = (center.y - (zoomRect.size.height * 0.5f));

	return zoomRect;
}

- (void)zoomIncrement:(UITapGestureRecognizer *)recognizer
{
	CGFloat zoomScale = self.zoomScale; // Current zoom

	CGPoint point = [recognizer locationInView:theContentPage];

	if (zoomScale < self.maximumZoomScale) // Zoom in
	{
		zoomScale *= ZOOM_FACTOR; // Zoom in by zoom factor amount

		if (zoomScale > self.maximumZoomScale) zoomScale = self.maximumZoomScale;

		CGRect zoomRect = [self zoomRectForScale:zoomScale withCenter:point];

		[self zoomToRect:zoomRect animated:YES];
	}
	else // Handle fully zoomed in
	{
		if (zoomBounced == NO) // Zoom bounce
		{
			self.maximumZoomScale = tempMaximumZoom;

			[self setZoomScale:tempMaximumZoom animated:YES];
		}
		else // Zoom all the way out
		{
			zoomScale = self.minimumZoomScale;

			[self setZoomScale:zoomScale animated:YES];
		}
	}
}

- (void)zoomDecrement:(UITapGestureRecognizer *)recognizer
{
	CGFloat zoomScale = self.zoomScale; // Current zoom

	CGPoint point = [recognizer locationInView:theContentPage];

	if (zoomScale > self.minimumZoomScale) // Zoom out
	{
		zoomScale /= ZOOM_FACTOR; // Zoom out by zoom factor amount

		if (zoomScale < self.minimumZoomScale) zoomScale = self.minimumZoomScale;

		CGRect zoomRect = [self zoomRectForScale:zoomScale withCenter:point];

		[self zoomToRect:zoomRect animated:YES];
	}
	else // Handle fully zoomed out
	{
		zoomScale = self.maximumZoomScale; // Full zoom in

		CGRect zoomRect = [self zoomRectForScale:zoomScale withCenter:point];

		[self zoomToRect:zoomRect animated:YES];
	}
}

- (void)zoomResetAnimated:(BOOL)animated
{
	if (self.zoomScale > self.minimumZoomScale) // Reset zoom
	{
		if (animated) [self setZoomScale:self.minimumZoomScale animated:YES]; else self.zoomScale = self.minimumZoomScale; zoomBounced = NO;
	}
}

- (void)updatePdfScroll
{
    [self scrollViewDidScroll:self];
}

#pragma mark - UIScrollViewDelegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    if( self.isWrong )  return;
    
//    CGFloat fBtnWidth = 35.f;
//    CGFloat fBtnHeight = 35.f;
//    
//    CGFloat fLbWidth = 80.f;
//    CGFloat fLbHeight = 30.f;

    if( self.isWrong )
    {
        if( scrollView.contentSize.height < scrollView.frame.size.height )
        {
            scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, scrollView.frame.size.height);
        }
        
        CGFloat fBtnWidth = 300.f;

        for( NSInteger i = 0; i < self.ar_Guide.count; i++ )
        {
            NSDictionary *dic = self.ar_Guide[i];
            NSArray *ar_Tmp = [dic objectForKey:@"examQuestionInfos"];
            if( ar_Tmp.count <= 0 ) return;
            NSDictionary *dic_PdfInfo = [ar_Tmp firstObject];
            CGFloat fOriX = 180;//[[dic_PdfInfo objectForKey:@"startX"] floatValue];
            CGFloat fOriY = 47;//[[dic_PdfInfo objectForKey:@"startY"] floatValue];
            CGFloat fOriWidth = [[dic_PdfInfo objectForKey:@"width"] floatValue];
            CGFloat fOriHeight = [[dic_PdfInfo objectForKey:@"height"] floatValue];

            if( self.isAudio )
            {
                fOriY = 47 + 60;
            }
            UIButton *btn_Owner = [self viewWithTag:[[dic objectForKey:@"questionId"] integerValue] + 1111];
            if( btn_Owner )
            {
                btn_Owner.frame = CGRectMake((fOriX * self.zoomScale) + (fOriWidth * self.zoomScale) - ((fBtnWidth) * self.zoomScale) - ((fBtnWidth / 1.5) * self.zoomScale),
//                btn_Owner.frame = CGRectMake( 0,
                                             (fOriY * self.zoomScale) + (fOriHeight * self.zoomScale) - ((fBtnHeight + 16) * self.zoomScale),
                                             fBtnWidth * self.zoomScale,
//                                             self.frame.size.width - 20,
                                             fBtnHeight * self.zoomScale);

//                btn_Owner.frame = CGRectMake(150, 150, 300, 50);
//                btn_Owner.frame = CGRectMake((fOriX * self.zoomScale) + (fOriWidth * self.zoomScale) - ((fBtnWidth + 24) * self.zoomScale) ,
//                                               (fOriY * self.zoomScale) + (fOriHeight * self.zoomScale) - ((fBtnHeight + 6) * self.zoomScale),
//                                               fBtnWidth * self.zoomScale, fBtnHeight * self.zoomScale);
//                btn_Wrong.layer.cornerRadius = btn_Wrong.frame.size.width/2;
                [btn_Owner.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:12.f * (btn_Owner.frame.size.width / fBtnWidth)]];
            }

        }

        [[NSNotificationCenter defaultCenter] postNotificationName:@"contentsDidScroll" object:scrollView];

        return;
    }
    
    for( NSInteger i = 0; i < self.ar_Guide.count; i++ )
    {
        NSDictionary *dic = self.ar_Guide[i];
        NSArray *ar_Tmp = [dic objectForKey:@"examQuestionInfos"];
        if( ar_Tmp.count <= 0 ) return;
        NSDictionary *dic_PdfInfo = [ar_Tmp firstObject];
        CGFloat fOriX = [[dic_PdfInfo objectForKey:@"startX"] floatValue];
        CGFloat fOriY = [[dic_PdfInfo objectForKey:@"startY"] floatValue];
        CGFloat fOriWidth = [[dic_PdfInfo objectForKey:@"width"] floatValue];
        CGFloat fOriHeight = [[dic_PdfInfo objectForKey:@"height"] floatValue];
        
        if( [[dic objectForKey:@"questionId"] integerValue] == self.nSelectedIdx )
        {
            UIImageView *iv_Guide = [self viewWithTag:2222];
            if( iv_Guide )
            {
                CGFloat fStartX = fOriX * self.zoomScale;
                CGFloat fStartY = fOriY * self.zoomScale;
                CGFloat fWidth = fOriWidth * self.zoomScale;
                CGFloat fHeight = fOriHeight * self.zoomScale;
                iv_Guide.frame = CGRectMake(fStartX + 2, fStartY, fWidth - 4, fHeight - 4);
            }
        }
        
        UIButton *btn_Correct = [self viewWithTag:[[dic objectForKey:@"questionId"] integerValue] + 100];
        if( btn_Correct )
        {
            btn_Correct.frame = CGRectMake((fOriX * self.zoomScale) + (fOriWidth * self.zoomScale) - ((fBtnWidth + 24) * self.zoomScale) - ((fBtnWidth / 1.5) * self.zoomScale),
                                           (fOriY * self.zoomScale) + (fOriHeight * self.zoomScale) - ((fBtnHeight + 6) * self.zoomScale),
                                           fBtnWidth * self.zoomScale, fBtnHeight * self.zoomScale);
            btn_Correct.layer.cornerRadius = btn_Correct.frame.size.width/2;
            [btn_Correct.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:15.f * (btn_Correct.frame.size.width / fBtnWidth)]];
        }
        
        UIButton *btn_MyCorrect = [self viewWithTag:[[dic objectForKey:@"questionId"] integerValue] + 1000];
        if( btn_MyCorrect )
        {
            btn_MyCorrect.frame = CGRectMake((fOriX * self.zoomScale) + (fOriWidth * self.zoomScale) - ((fBtnWidth + 24) * self.zoomScale) ,
                                             (fOriY * self.zoomScale) + (fOriHeight * self.zoomScale) - ((fBtnHeight + 6) * self.zoomScale),
                                             fBtnWidth * self.zoomScale, fBtnHeight * self.zoomScale);
            btn_MyCorrect.layer.cornerRadius = btn_MyCorrect.frame.size.width/2;
            [btn_MyCorrect.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:15.f * (btn_MyCorrect.frame.size.width / fBtnWidth)]];
        }
        
        UIButton *btn_Star = [self viewWithTag:[[dic objectForKey:@"questionId"] integerValue] + 10000];
        if( btn_Star )
        {
            btn_Star.frame = CGRectMake((fOriX * self.zoomScale) + (fOriWidth * self.zoomScale) - ((fBtnWidth + 24) * self.zoomScale) - ((fBtnWidth * 2) * self.zoomScale),
                                             (fOriY * self.zoomScale) + (fOriHeight * self.zoomScale) - ((fBtnHeight + 6) * self.zoomScale),
                                             fBtnWidth * self.zoomScale, fBtnHeight * self.zoomScale);
            [btn_Star setBackgroundImage:BundleImage(@"star_yellow.png") forState:UIControlStateNormal];
        }
        
        
        
        
        
        UILabel *lb_Correct = [self viewWithTag:[[dic objectForKey:@"questionId"] integerValue] + 900];
        if( lb_Correct )
        {
            lb_Correct.frame = CGRectMake((fOriX * self.zoomScale) + (fOriWidth * self.zoomScale) - ((fLbWidth + 24) * self.zoomScale) ,
                                          (fOriY * self.zoomScale) + (fOriHeight * self.zoomScale) - ((fLbHeight + 6) * self.zoomScale),
                                          fLbWidth * self.zoomScale,
                                          fLbHeight * self.zoomScale);
            [lb_Correct setFont:[UIFont fontWithName:@"Helvetica" size:14.f * (lb_Correct.frame.size.width / fLbWidth)]];
        }

        UILabel *lb_MyCorrect = [self viewWithTag:[[dic objectForKey:@"questionId"] integerValue] + 9000];
        if( lb_MyCorrect )
        {
            lb_MyCorrect.frame = CGRectMake((fOriX * self.zoomScale) + (fOriWidth * self.zoomScale) - ((fLbWidth + 24) * self.zoomScale),
                                            lb_Correct.frame.origin.y - (self.zoomScale * fLbHeight),
                                            fLbWidth * self.zoomScale,
                                            fLbHeight * self.zoomScale);
            [lb_MyCorrect setFont:[UIFont fontWithName:@"Helvetica" size:14.f * (lb_MyCorrect.frame.size.width / fLbWidth)]];
        }

    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"contentsDidScroll" object:scrollView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return theContainerView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
	if (self.zoomScale > realMaximumZoom) // Bounce back to real maximum zoom scale
	{
		[self setZoomScale:realMaximumZoom animated:YES]; self.maximumZoomScale = realMaximumZoom; zoomBounced = YES;
	}
	else // Normal scroll view did end zooming
	{
		if (self.zoomScale < realMaximumZoom) zoomBounced = NO;
	}
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
	[self centerScrollViewContent]; // Center content
}

#pragma mark - UIResponder instance methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event]; // Message superclass

	[message contentView:self touchesBegan:touches]; // Message delegate
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event]; // Message superclass
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event]; // Message superclass
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event]; // Message superclass
}

@end

#pragma mark -

//
//	ReaderContentThumb class implementation
//

@implementation ReaderContentThumb

#pragma mark - ReaderContentThumb instance methods

- (instancetype)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame])) // Superclass init
	{
		imageView.contentMode = UIViewContentModeScaleAspectFill;

		imageView.clipsToBounds = YES; // Needed for aspect fill
	}

	return self;
}

@end
