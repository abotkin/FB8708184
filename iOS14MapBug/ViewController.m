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
}

- (IBAction)updatePinStatusImage:(id)sender {
    self.pinsInUse = !self.pinsInUse;

    NSString *currentImage = self.pinsInUse ? @"ev_station-full" : @"ev_station";

    UIImage *newImage = [UIImage imageNamed:currentImage];

    for (id<MKAnnotation> annotation in self.mapView.annotations) {
        MKAnnotationView *annotationView = [self.mapView viewForAnnotation:annotation];

        annotationView.image = newImage;
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
