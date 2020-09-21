//
//  AXBAnnotationView.m
//  iOS14MapBug
//
//  Created by Alexander Botkin on 9/19/20.
//

#import "AXBAnnotationView.h"

@implementation AXBAnnotationView

- (void)setImage:(UIImage *)image {
    // Feedback Assistant ticket: FB8708184
    //
    // With iOS 14, setting the MKAnnotationView's image leads to a glitched CABasicAnimation when using images of the same size
    // from an asset catalog.
    //
    // To work around this, we create our own version of the system animation that isn't glitched, prevent
    // the system from adding the glitched system provided one, & then add our animation once the image sets are done.
    //
    // For demo purposes, we have this code here in the VC, but you could put this in your MKAnnotationView subclass & override
    // -[MKAnnotationView setImage:] to and put this workaround there, replacing "annotationView.image = newImage" with "[super setImage:image]"
    if (@available(iOS 14, *)) {
        CALayer *imageLayer = self.layer.sublayers.firstObject;

        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"contents"];
        animation.fromValue = imageLayer.contents;
        animation.toValue = (__bridge id)image.CGImage;
        animation.fillMode = kCAFillModeBackwards;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        animation.duration = 0.25;

        // Now let's update the image but disable CAAnimations so the buggy iOS 14 contents animation doesn't occur
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue
                         forKey:kCATransactionDisableActions];
        [super setImage:image];
        [CATransaction commit];

        // Add our version of the contents animation
        [imageLayer addAnimation:animation forKey:@"contents"];
    } else {
        // iOS 13 and below don't have the glitched CABasicAnimation, so no workaround needed
        [super setImage:image];
    }
}

@end
