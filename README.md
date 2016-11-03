# Multithreading with Image Filtering in Swift

Multithreading may seem esoteric and dense, but it's important in many situations that involve network calls or heavy processing. With so many apps in the App Store, the [user interface (UI) and user experience (UX)](https://www.usertesting.com/blog/2016/04/27/ui-vs-ux/) of your app must be as close to flawless as possible for it to stand out. You can hire a team of designers to create the most beautiful graphics for your photo filtering app, but it won't do any good if the whole thing suddenly freezes when a user attempts to process an image!

[Bluto on Ice](https://media.giphy.com/media/mbDvYG4QfMoQo/giphy.gif "Don't freeze up!")

To that end you can use multithreading to run heavy processes off the main thread of a device, thereby ensuring the user interface doesn't stutter and the user experience is maintained.

[Multithreading](https://raw.githubusercontent.com/JGLaferte/Multi-Threading/master/AshycMultiThreadingProject/Img/MultiThreading.gif)

The image above shows three things. First, on the left, you see a representation of a *synchronous* process being run on a single thread of a processor. Each green block, which represents an action, must complete before the next green block can be processed. Second, on the right, is a representation of a synchronous process being run with multithreading. With more threads, multiple green blocks can be processed at the same time and the process on the right completes more quickly.

The third concept illustrated by this animation is the larger picture of these two processes being run simultaneously. These processes are running *asynchronously*, which means the speed or completion of one process does not rely on the speed or completion of the other.

In this lab you will create a Flatigram app, which applies filters to images that a user can select from their photo library.

[Flatirgram Demo](https://media.giphy.com/media/l3vQZmh2bjC9QLhxm/giphy.gif)

## Goals

* When the `Filter` button is tapped, an activity indicator should be presented and animated to show the user some processing is going on. This activity indicator should stop when the image is filtered.
* We also want to allow the user to continue to pan and zoom the image while the filtration occurs in the background.
* When the camera button is tapped, the user should be able to select a photo from the device's photo library.

## Instructions

There are some hints included in the following instructions. **Try to complete each step step without the hints first, then look at the hints only if you get stuck.** Remember, the struggle of solving a problem is far more valuable than copying and pasting a solution.

### Create a `Flatigram` class

The images the Flatigram app processes are going to need to store more information than just the image itself. We don't want the user to repeatedly apply the same filter to an image, so you're going to create a new class called `Flatigram` which will store both the image to be filtered and the state of the image.

Create a new `.swift` file to contain the new `Flatigram` class.

This class should have two properties: an `image` of type `UIImage?` and a `state` of type `ImageState`. Setting `image` to be an optional allows us to create an instance of `Flatigram` without having to worry about whether we have an image ready.

`ImageState` is an enumeration that doesn't yet exist. Create an enum with two cases: `filtered` and `unfiltered`. Since any new `Flatigram` we create won't have been filtered yet, go back to the `Flatigram` class and set the default value of `state` to `unfiltered`.

### Setting up the `ImageViewController`

Cool, you've got your custom class set up. Now let's go back to the `ImageViewController` where you should add a new property called `flatigram` that has a default value of `Flatigram()`. But nothing is happening to the image yet. Let's fix that by performing some actions when the `filterButton` is tapped.

First, to keep your code clean, create an extension for the `ImageViewController` at the bottom of this file. In this extension, add a function called `filterImage(with:)` that takes a completion block as its only argument. This completion block should accept a `Bool` and return nothing. Call `filterImage(with)` from `filterButtonTapped`, which has already been set up for you.

Inside `filterImage(with:)`, you should now call on the special function called `filter(with:)` that was added in the `UIImage` extension. This function takes in a `String` — the name of the `CIFilter` to be applied to the image — and returns a filtered `UIImage`. As you can see in the `filtersToApply` property on `ImageViewController`, there are three filters which will need to be applied to the `flatirgram` image. Try to apply all these filters and see what happens.

[Waiting](https://media.giphy.com/media/3o7TKxOhkp8gO0LXMI/giphy.gif)

[Hint: Image Filtering](#image-filtering)

> **Note:** The filters can take a *long* time to be applied, especially in the simulator. A message will print to the console log when a filter has been successfully applied.

You should eventually see three lines appear in your console:

```
CIBloom applied to image
CIPhotoEffectProcess applied to image
CIExposureAdjust applied to image
```

But the image looks the same! You may also have noticed that after tapping `Filter`, the image froze and was unable to be panned or zoomed. My oh my. Not a friendly experience.

To sort these issues out we're going to need to move the image processing off the main thread. You're going to do this with two new classes: `FilterOperation` and `PendingOperations`.

### Creating `ImageOperations`

Make a new `.swift` file called `ImageOperations`. Inside, create a new class called `FilterOperation`, which subclasses from `Operation`.

`Operation`s are single-use containers for tasks. An instance of an `Operation` subclass gives you the opportunity to run code synchronously or asynchronously when used in an `OperationQueue`. These queues are super neat and understanding how to use them is a powerful tool on your toolbelt as a developer.

You can create multiple queues with different properties, such as a `name`, `qualityOfService`, and `maxConcurrentOperationCount`. These are the three properties you'll set in a few moments.

The `name` is just as it seems — the name of the queue. The `qualityOfService` determines the 


**HOW DO WE INCREASE THE PRIORITY OF A PARTICULAR TASK? SHOULD THIS BE SHOWN?**

There's a ton of useful information on how `Operation`s and `OperationQueue`s work in the Apple Reference Docs. `option` + `click` on the class names and [you'll get this](#operation-and-operationqueue).





Next, create a class called `PendingOperations`.



### Show an activity indicator
 
* Add a `UIActivityIndicatorView` to the Flatirgram app. Instead of doing this in Interface Builder, add it programmatically.
* Next, within the `setupViews` function in the `ImageViewController` extension, set up the activity indicator. Make the activity indicator `.cyan` and centered in the main view.

> **Hint:** In the `ImageViewController` class, add a property called `activityIndicator` of type `UIActivityIndicatorView!`. Use the following code to set it up properly in the extension:

```swift
activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
activityIndicator.color = UIColor.cyan
activityIndicator.center = view.center
view.addSubview(activityIndicator)
```

> Here we instantiate a `UIActivityIndicatorView` object for the property we just created with the stile of `.whiteLarge`. We then tint the indicator so it fits the theme of our app, and finally align it with the main view.

* If you run the app now and hit `Filter`, you'll see the activity indicator still doesn't appear. We're not done yet! The `UIActivityIndicatorView` has been created, but hasn't been added to the superview. Do this with . This adds our `activityIndicator` to the view controller's `view`.
* The last step we need to make our `activityIndicator` visible is to call it to start. Use the following lines to start and stop the indicator, respectively:

```swift
activityIndicator.startAnimating()  // Presents and starts the activity indicator
activityIndicator.stopAnimating()   // Hides and stops the activity indicator
```

* Add just the `startAnimating` line to your `viewDidLoad` and run your app. You should see a blue spinning activity indicator. We don't want the indicator to start as soon as the app opens, though, and we don't want it to keep going after the image has been filtered. Let's move this start function call to the `FilterButtonTapped` function ahead of the call to `filterImage`.
* Uh oh! If you run the app now and tap `Filter` you'll see that the activity indicator doesn't appear until after the image has finished filtering. Try to add the `stopAnimating` call on the `activityIndicator` to the completion block for the call to `filterImage`. Now the indicator never shows!
* It looks like the filtering process is blocking the indicator, so we'll have to move the filtering to a different thread.

### Allow for user interaction during filtering

* Create a new `OperationQueue` in `FilterButtonTapped` and set its `qualityOfService` to `.userInitiated`. Next, move into this block the call to the `filterImage` function and its completion block, which prints based on the result. The `qualityOfService` parameter, futher discussed in [Apple's documentation](https://developer.apple.com/library/content/documentation/Performance/Conceptual/EnergyGuide-iOS/PrioritizeWorkWithQoS.html#//apple_ref/doc/uid/TP40015243-CH39-SW1), is used to ensure the correct priority for system resources is given to the passed-in block of code.
* Inside the completion block of the call to `filterImage`, add a new operation block on the `mainQueue` which will wrap the previous contents of the completion block. This ensures that when `filterImage` has completed and returned, the activity indicator's status will be updated on the main thread.
* We still need to update the `imageView` in the main thread. Look for the line in `filterImage` where we print out "Setting final result". Add a `mainQueue` operation block and insert the two lines where we set the `imageView`'s `image` to `finalResult` and return `true` to the completion block.
* Now everything should work as expected and the user will never be left *hanging* for a filtering process! 😉

### Advice

Now that you've seen how multithreading works with `Operation` subclassing and an `OperationQueue`, consider reading Apple's documentation on [Concurrency and Application Design](https://developer.apple.com/library/content/documentation/General/Conceptual/ConcurrencyProgrammingGuide/ConcurrencyandApplicationDesign/ConcurrencyandApplicationDesign.html#//apple_ref/doc/uid/TP40008091-CH100-SW12). It may sound boring, but this is useful knowledge when it comes to understanding when and where the use of concurrency is and isn't appropriate. Just because you can doesn't always mean you should!

### Advanced

* Play around with other filters and see what you can create! Here's a [list of all available CIFilters](https://developer.apple.com/library/mac/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html) to get you started.
* Add a camera button to the nav bar which presents an alert asking if the user wants to load a photo from the library or take a photo with the camera. In either case, the new photo should be loaded into the Flatigram app, ready for antiquing.
* Figure out a way to cache filtered images so if they've already been filtered, the filtered version is loaded right away upon selecting that photo.
* Add the ability to cancel a filter operation midway.

## Hints

### Image Filtering

You might start off looping through your filters like this:

```swift
for filter in filtersToApply {
    imageView.image = flatigram.image?.filter(with: filter)
}
```

## Reference

### Operation and OperationQueue

> **Operation:**
> The NSOperation class is an abstract class you use to encapsulate the code and data associated with a single task. Because it is abstract, you do not use this class directly but instead subclass or use one of the system-defined subclasses (NSInvocationOperation or BlockOperation) to perform the actual task. Despite being abstract, the base implementation of NSOperation does include significant logic to coordinate the safe execution of your task. The presence of this built-in logic allows you to focus on the actual implementation of your task, rather than on the glue code needed to ensure it works correctly with other system objects.
> 
> An operation object is a single-shot object—that is, it executes its task once and cannot be used to execute it again. You typically execute operations by adding them to an operation queue (an instance of the OperationQueue class). An operation queue executes its operations either directly, by running them on secondary threads, or indirectly using the libdispatch library (also known as Grand Central Dispatch).
> 
> **Operation Queue:**
> The NSOperationQueue class regulates the execution of a set of Operation objects. After being added to a queue, an operation remains in that queue until it is explicitly canceled or finishes executing its task. Operations within the queue (but not yet executing) are themselves organized according to priority levels and inter-operation object dependencies and are executed accordingly. An application may create multiple operation queues and submit operations to any of them.
> 
> Inter-operation dependencies provide an absolute execution order for operations, even if those operations are located in different operation queues. An operation object is not considered ready to execute until all of its dependent operations have finished executing. For operations that are ready to execute, the operation queue always executes the one with the highest priority relative to the other ready operations. For details on how to set priority levels and dependencies, see Operation.
> 
> You cannot directly remove an operation from a queue after it has been added. An operation remains in its queue until it reports that it is finished with its task. Finishing its task does not necessarily mean that the operation performed that task to completion. An operation can also be canceled. Canceling an operation object leaves the object in the queue but notifies the object that it should abort its task as quickly as possible. For currently executing operations, this means that the operation object’s work code must check the cancellation state, stop what it is doing, and mark itself as finished. For operations that are queued but not yet executing, the queue must still call the operation object’s start method so that it can processes the cancellation event and mark itself as finished.

> -Apple Docs


<p data-visibility='hidden'>View <a href='https://learn.co/lessons/swift-multithreading-lab' title='Multithreading in Swift'>Multithreading in Swift</a> on Learn.co and start learning to code for free.</p>
