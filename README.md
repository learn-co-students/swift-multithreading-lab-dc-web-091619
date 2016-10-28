# Multithreading with Image Filtering in Swift

Multithreading may seem esoteric and dense, but it's important in many situations that involve network calls or heavy processing. With so many apps in the App Store, the [user interface (UI) and user experience (UX)](https://www.usertesting.com/blog/2016/04/27/ui-vs-ux/) of your app must be as close to flawless as possible for it to stand out. You can hire a team of designers to create the most beautiful graphics for your photo filtering app, but it won't do any good if the whole thing suddenly freezes when a user attempts to process an image!

![Bluto on Ice](https://media.giphy.com/media/mbDvYG4QfMoQo/giphy.gif "Don't freeze up!")

To that end we can use multithreading to run heavy processes off the main thread of a device, thereby ensuring the user interface doesn't stutter and the user experience is maintained.

In this lab you will fix a broken photo filter app which hangs when the user tries to apply an "antique" filter.

## Goals

* When the `Antique` button is tapped, an activity indicator should be presented and animated to show the user some processing is going on. This activity indicator should stop when the image is filtered.
* We also want to allow the user to continue to pan and zoom the image while the filtration occurs in the background.

## Instructions

### Show an activity indicator
 
* Let's add an activity indicator to our filtering app. Instead of doing this in Interface Builder, we'll add it programmatically. In the `ImageViewController` class, add a property called `activityIndicator` of type `UIActivityIndicatorView!`.
* Next, after `setupViews` in `viewDidLoad`, we'll create the actual view and set it up. Paste in the following lines of code:

```swift
activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
activityIndicator.color = UIColor.cyan
activityIndicator.center = view.center
```

* Here we instantiate a `UIActivityIndicatorView` object for the property we just created with the stile of `.whiteLarge`. We then tint the indicator so it fits the theme of our app, and finally align it with the main view.
* If you run the app now and hit `Antique`, you'll see the activity indicator still doesn't appear. We're not done yet! The `UIActivityIndicatorView` has been created, but hasn't been added to the superview. Do this by inserting `view.addSubview(activityIndicator)` into your `viewDidLoad`. This adds our `activityIndicator` to the view controller's `view`.
* The last step we need to make our `activityIndicator` visible is to call it to start. Use the following lines to start and stop the indicator, respectively:

```swift
activityIndicator.startAnimating()  // Presents and starts the activity indicator
activityIndicator.stopAnimating()   // Hides and stops the activity indicator
```

* Add just the `startAnimating` line to your `viewDidLoad` and run your app. You should see a blue spinning activity indicator. We don't want the indicator to start as soon as the app opens, though, and we don't want it to keep going after the image has been filtered. Let's move this start function call to the `antiqueButtonTapped` function ahead of the call to `filterImage`.
* Uh oh! If you run the app now and tap `Antique` you'll see that the activity indicator doesn't appear until after the image has finished filtering. Try to add the `stopAnimating` call on the `activityIndicator` to the completion block for the call to `filterImage`. Now the indicator never shows!
* It looks like the filtering process is blocking the indicator, so we'll have to move the filtering to a different thread.

### Allow for user interaction during filtering

* Create a new `NSOperationQueue` in `antiqueButtonTapped` and set its `qualityOfService` to `.userInitiated`. Next, move into this block the call to the `filterImage` function and its completion block, which prints based on the result. The `qualityOfService` parameter, futher discussed in [Apple's documentation](https://developer.apple.com/library/content/documentation/Performance/Conceptual/EnergyGuide-iOS/PrioritizeWorkWithQoS.html#//apple_ref/doc/uid/TP40015243-CH39-SW1), is used to ensure the correct priority for system resources is given to the passed-in block of code.
* Inside the completion block of the call to `filterImage`, add a new operation block on the `mainQueue` which will wrap the previous contents of the completion block. This ensures that when `filterImage` has completed and returned, the activity indicator's status will be updated on the main thread.
* We still need to update the `imageView` in the main thread. Look for the line in `filterImage` where we print out "Setting final result". Add a `mainQueue` operation block and insert the two lines where we set the `imageView`'s `image` to `finalResult` and return `true` to the completion block.
* Now everything should work as expected and the user will never be left *hanging* for a filtering process! 😉

### Advanced

Play around with other filters and see what you can create! Here's a [list of all available CIFilters](https://developer.apple.com/library/mac/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html) to get you started.

<p data-visibility='hidden'>View <a href='https://learn.co/lessons/swift-multithreading-lab' title='Multithreading in Swift'>Multithreading in Swift</a> on Learn.co and start learning to code for free.</p>
