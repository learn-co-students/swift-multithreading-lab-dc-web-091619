# Flatigram: Multithreading with Image Filtering in Swift

Multithreading may seem esoteric and dense, but it's important in many situations that involve network calls or heavy processing. With so many apps in the App Store, the [user interface (UI) and user experience (UX)](https://www.usertesting.com/blog/2016/04/27/ui-vs-ux/) of your app must be as close to flawless as possible for it to stand out. You can hire a team of designers to create the most beautiful graphics for your photo filtering app, but it won't do any good if the whole thing suddenly freezes when a user attempts to process an image!

![Bluto on Ice](https://media.giphy.com/media/mbDvYG4QfMoQo/giphy.gif "Don't freeze up!")

To that end you can use multithreading to run heavy processes off the main thread of a device, thereby ensuring the user interface doesn't stutter and the user experience is maintained.

![Multithreading](https://raw.githubusercontent.com/JGLaferte/Multi-Threading/master/AshycMultiThreadingProject/Img/MultiThreading.gif)

The image above shows three things. First, on the left, you see a representation of a *synchronous* process being run on a single thread of a processor. Each green block, which represents an action, must complete before the next green block can be processed. Second, on the right, is a representation of a synchronous process being run with multithreading. With more threads, multiple green blocks can be processed at the same time and the process on the right completes more quickly.

The third concept illustrated by this animation is the larger picture of these two processes being run simultaneously. These processes are running *asynchronously*, which means the speed or completion of one process does not rely on the speed or completion of the other.

In this lab you will create a Flatigram app, which applies filters to images that a user can select from their photo library.

Click here to see a demo of the app: [Flatirgram Demo](https://media.giphy.com/media/l3vQZmh2bjC9QLhxm/giphy.gif)

(The filter in this demo is different than what's in your project.)

## Goals

* Subclass `Operation` and implement a customized `OperationQueue` to add multithreading capabilities to our code.


## Instructions

There are some hints included in the following instructions. **Try to complete each step step without the hints first, then look at the hints only if you get stuck.** Remember, the struggle of solving a problem is far more valuable than copying and pasting a solution.

### Create a `Flatigram` class

The images the Flatigram app processes are going to need to store more information than just the image itself. We don't want the user to repeatedly apply the same filter to an image, so you're going to create a new class called `Flatigram` which will store both the image to be filtered and the state of the image.

Create a new `.swift` file to contain the new `Flatigram` class.

This class should have two properties: an `image` of type `UIImage?` and a `state` of type `ImageState`. Setting `image` to be an optional allows us to create an instance of `Flatigram` without having to worry about whether we have an image ready.

`ImageState` is an enumeration that doesn't yet exist. Create an enum with two cases: `filtered` and `unfiltered`. Since any new `Flatigram` we create won't have been filtered yet, go back to the `Flatigram` class and set the default value of `state` to `unfiltered`.

### Set up the `ImageViewController`

Cool, you've got your custom class set up. Now let's go back to the `ImageViewController` where you should add a new property called `flatigram` that has a default value of `Flatigram()`. But nothing is happening to the image yet. Let's fix that by performing some actions when the `filterButton` is tapped.

First, to keep your code clean, create an extension for the `ImageViewController` at the bottom of this file. In this extension, add a function called `filterImage(with:)` that takes a completion block as its only argument. This completion block should accept a `Bool` and return nothing. Call `filterImage(with)` from `filterButtonTapped(_:)`, which has already been set up for you.

Inside `filterImage(with:)`, you should call on `filter(with:)`, which was added in the `UIImage` extension. This function takes in a `String` — the name of the `CIFilter` to be applied to the image — and returns a filtered `UIImage`. As you can see in the `filtersToApply` property on `ImageViewController`, there are three filters which will need to be applied to the `flatirgram` image. Try to apply all these filters with a `for` loop and see what happens.

![Waiting](https://media.giphy.com/media/3o7TKxOhkp8gO0LXMI/giphy.gif)

[Hint: Image Filtering](#image-filtering)

> **Note:** The filters can take a *long* time to be applied, especially in the simulator. A message will print to the console log when a filter has been successfully applied.

You should eventually see three lines appear in your console:

```
CIBloom applied to image
CIPhotoEffectProcess applied to image
CIExposureAdjust applied to image
```

But the image looks the same! You may also have noticed that after tapping `Filter`, the image froze and was unable to be panned or zoomed. My oh my. Not a friendly experience.

To sort these issues out we're going to need to move the image processing off the main thread. You're going to do this with a subclass of `Operation` and an `OperationQueue`.

### Create `FilterOperation`

Make a new `.swift` file called `FilterOperation`. Inside, create a new class called `FilterOperation`, which subclasses from `Operation`.

`Operation`s are single-use containers for tasks. An instance of an `Operation` subclass gives you the opportunity to run code synchronously or asynchronously when used in an `OperationQueue`. These queues are extremely useful when used appropriately, and understanding how to use them is a powerful tool on your toolbelt as a developer.

You can create multiple queues with different properties, such as a `name`, `qualityOfService`, and `maxConcurrentOperationCount`. These are the three properties you'll set in a few moments.

The `name` is just as it seems — the name of the queue. The `qualityOfService` determines the priority an operation will receive for use of system resources. Higher priority means more resources. Lastly, `maxConcurrentOperationCount` defines how many operations on the queue can be processed at the same time. You can add dependencies to your operations, which guarantee those tasks are processed in a particular order, but here you'll use `maxConcurrentOperationCount` to achieve that same goal. (Don't set this property if you want to use the maximum number of threads available. This might increase performance, but it will also consume system resources.)

There's a ton of useful information on how `Operation`s and `OperationQueue`s work in the Apple Reference Docs. `option` + `click` on the class names and [you'll get this](#operation-and-operationqueue).

Okay. That's a lot of theory, and not all of it may make sense at first. That's okay. Stand up, do some stretches, then let's make it all come together.

![Stretchy Cat](https://media.giphy.com/media/WUuSHzgWLsZMs/giphy.gif)

Cool. Now add two properites to `FilterOperation`: `flatigram` of type `Flatigram`, and `filter` of type `String`. Instead of giving these default values, create an initializer that takes in a `Flatigram` and `String` argument which are then mapped to their respective properties.

Next, override the `main()` function of `Operation`. This is where the magic happens. Add code here to `filter(with:)` the `image` property of the `flatigram` connected to the `FilterOperation` and it will be run when the operation is processed.

Don't let this seem intimidating! When this operation is run, the `main()` function will get called automatically. As soon as it does, the image will be run through the filter function in the `UIImage` extension.

[Hint: Filter Operation](#filter-operation)

### Finish `filterImage(with:)`

Head back to your `ImageViewController` and the `filterImage(with:)` function. At the top of the function, create a new instance of `OperationQueue` called `queue` and set its properties as follows:

* `name`: "Image Filtration Queue"
* `qualityOfService`: .userInitiated
* `maxConcurrentOperationCount`: 1

We now have a wrapper for the code we want to queue up, plus a custom queue in which to put it. In this same function, add a `FilterOperation` to the `OperationQueue` for each filter listed in the array of `filtersToApply` and set the `completionBlock` of each operation to evaluate the queue's `operationCount`. If the queue is empty, set `flatigram`'s `state` to `.filtered` and call the completion block to announce the operations have finished and the filters have been applied.

After the operation has been added to the queue, add the following line of code:

```swift
print("Added FilterOperation with \(filter) to \(queue.name!)")
```

This will help illustrate the order of operations taking place.

[Hint: Filter Image](#filter-image)

### `startProcess()`

Create a new function in the extension for `ImageViewController` named `startProcess()`, which returns nothing. Take the call to `filterImage(with:)` out of `filterButtonTapped(_)` and put it in `startProcess()`.

When the `Filter` button is tapped, the `state` of `flatigram` should be checked. `startProcess()` should be called only if the photo is still unfiltered. Otherwise, make a call to `presentFilteredAlert()`.

`startProcess()` should disable the `filterButton` and `chooseImageButton`, then call the provided `activityIndicator` to start.

In the completion block for `filterImage(with:)`, print out the result from `filterImage(with:)`, re-enable the buttons, stops the `activityIndicator`, and set the `imageView`'s `image` property to the `image` on `flatigram`.

[Hint: Start Process](#start-process)

## Conclusion

Great job! You've just subclassed `Operation` and made use of a customized `OperationQueue` to prevent UI elements from freezing. This also left open the possibility for you to increase your app's performance by upping the number of concurrent threads allowed in your `queue`. Play around and see what you can achieve!

### Advice

Now that you've seen how multithreading works with `Operation` subclassing and an `OperationQueue`, consider reading Apple's documentation on [Concurrency and Application Design](https://developer.apple.com/library/content/documentation/General/Conceptual/ConcurrencyProgrammingGuide/ConcurrencyandApplicationDesign/ConcurrencyandApplicationDesign.html#//apple_ref/doc/uid/TP40008091-CH100-SW12). It may sound boring, but this is useful knowledge when it comes to understanding when and where the use of concurrency is and isn't appropriate. Just because you can doesn't always mean you should!

### Advanced

* Play around with other filters and see what you can create. Here's a [list of all available CIFilters](https://developer.apple.com/library/mac/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html) to get you started.
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

### Filter Operation

```swift
class FilterOperation: Operation {
    
    let flatigram: Flatigram
    let filter: String
    
    init(flatigram: Flatigram, filter: String) {
        self.flatigram = flatigram
        self.filter = filter
    }
    
    override func main() {
        
        if let filteredImage = self.flatigram.image?.filter(with: filter) {
            self.flatigram.image = filteredImage
        }
    }
    
}
```

### Operation Queue

```swift
var queue = OperationQueue()
queue.name = "Image Filtration queue"
queue.maxConcurrentOperationCount = 1
queue.qualityOfService = .userInitiated
```

### Filter Image

```swift
func filterImage(with completion: @escaping (Bool) -> ()) {
        
    let queue = OperationQueue()
    queue.name = "Image Filtration queue"
    queue.maxConcurrentOperationCount = 1
    queue.qualityOfService = .userInitiated
    
    for filter in filtersToApply {
        
        let filterer = FilterOperation(flatigram: flatigram, filter: filter)
        filterer.completionBlock = {
            
            if filterer.isCancelled {
                completion(false)
                return
            }
            
            if queue.operationCount == 0 {
                DispatchQueue.main.async(execute: {
                    self.flatigram.state = .filtered
                    completion(true)
                })
            }
        }
        
        queue.addOperation(filterer)
        print("Added FilterOperation with \(filter) to \(queue.name!)")
    }
}
```

### Start Process

```swift
func startProcess() {
        
    activityIndicator.startAnimating()
    filterButton.isEnabled = false
    chooseImageButton.isEnabled = false
    
    filterImage { result in
        
        OperationQueue.main.addOperation {
            result ? print("Image successfully filtered") : print("Image filtering did not complete")
            self.imageView.image = self.flatigram.image
            self.activityIndicator.stopAnimating()
            self.filterButton.isEnabled = true
            self.chooseImageButton.isEnabled = true
        }
    }
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
