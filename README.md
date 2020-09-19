# FB8708184
iOS 14 GM Bug - Feedback Assistant FB8708184

## Purpose

This is a sample code project that replicates a bug in iOS 14 GM when the MKAnnotationView's image is set while the view is still on screen. Run "iOS14MapBug" & press the "Cycle Pin Status" button to cycle the MKAnnotationView's image.

### Expected Behavior

As seen on iOS 13

![iOS 13 map view not showing glitched display on annotation view image update](gifs/expectedBehavior.gif)

### Actual Behavior

As seen on iOS 14 GM

![iOS 14 map view showing glitched display on annotation view image update](gifs/actualBehavior.gif)