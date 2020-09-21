//
//  ViewController.m
//  iOS14MapBug
//
//  Created by Alexander Botkin on 9/17/20.
//

#import "ViewController.h"


@interface CPTMapAnnotation : NSObject<MKAnnotation>

// Center latitude and longitude of the annotation view.
// The implementation of this property must be KVO compliant.
@property (nonatomic, assign, readwrite) CLLocationCoordinate2D coordinate;

@end

@implementation CPTMapAnnotation


@end


#pragma mark -


@interface ViewController ()

@property (nonatomic, assign) BOOL pinsInUse;
@property (nonatomic, assign) BOOL useWorkaround;

@property (nonatomic, weak) IBOutlet UISwitch *workaroundSwitch;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(37.331275, -122.031874);

    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.1, 0.1));
    self.mapView.region = region;

    NSMutableArray<CPTMapAnnotation *> *annotations = [[NSMutableArray alloc] init];
    CPTMapAnnotation *annotation = [[CPTMapAnnotation alloc] init];
    annotation.coordinate = coordinate;
    [annotations addObject:annotation];

    [self.mapView addAnnotations:annotations];

    self.useWorkaround = self.workaroundSwitch.on;
}

- (IBAction)toggleUseWorkaround:(UISwitch *)sender {
    self.useWorkaround = sender.on;
}

- (IBAction)updatePinStatusImage:(id)sender {
    self.pinsInUse = !self.pinsInUse;

    NSString *currentImage = self.pinsInUse ? @"ev_station-full" : @"ev_station";

    UIImage *newImage = [UIImage imageNamed:currentImage];

    for (id<MKAnnotation> annotation in self.mapView.annotations) {
        MKAnnotationView *annotationView = [self.mapView viewForAnnotation:annotation];

        // Let's update that MKAnnotationView image
        if (self.useWorkaround) {
            // Feedback Assistant ticket: FB8708184
            //
            // With iOS 14, setting the MKAnnotationView's image leads to a glitched CABasicAnimation when using images of the same size
            // from an asset catalog.
            //
            // To work around this, we create our own version of the system animation that isn't glitched, prevent
            // the system from adding the glitched system provided one, & then add our animation once the image sets are done.
            //
            // For demo purposes, we have this code here in the VC. See "AXBAnnotationView.h" for an MKAnnotationView subclass version you can
            // use to implement the workaround without cluttering your code.
            if (@available(iOS 14, *)) {
                CALayer *imageLayer = annotationView.layer.sublayers.firstObject;

                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"contents"];
                animation.fromValue = imageLayer.contents;
                animation.toValue = (__bridge id)newImage.CGImage;
                animation.fillMode = kCAFillModeBackwards;
                animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
                animation.duration = 0.25;

                // Now let's update the image but disable CAAnimations so the buggy iOS 14 contents animation doesn't occur
                [CATransaction begin];
                [CATransaction setValue:(id)kCFBooleanTrue
                                 forKey:kCATransactionDisableActions];
                annotationView.image = newImage;
                [CATransaction commit];

                // Add our version of the contents animation
                [imageLayer addAnimation:animation forKey:@"contents"];
            } else {
                // iOS 13 and below don't have the glitched CABasicAnimation, so no workaround needed
                annotationView.image = newImage;
            }
        } else {
            // User in demo project has disabled the workaround to see iOS 14 GM behavior
            annotationView.image = newImage;
        }
    }
}

- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:@"ABCD"];
    if (!view) {
        view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"ABCD"];
    }

    NSString *pinImageName = self.pinsInUse ? @"ev_station-full" : @"ev_station";
    UIImage *pinImage = [UIImage imageNamed:pinImageName];
    view.image = pinImage;

    return view;
}


@end
