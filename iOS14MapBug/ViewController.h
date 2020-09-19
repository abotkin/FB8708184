//
//  ViewController.h
//  iOS14MapBug
//
//  Created by Alexander Botkin on 9/17/20.
//

#import <UIKit/UIKit.h>

@import MapKit;


@interface ViewController : UIViewController<MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@end

