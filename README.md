# Multithreading in Swift

Multithreading may seem esoteric and dense, but it's super important. With so many apps in the App Store, the [user interface (UI) and user experience (UX)]((https://www.usertesting.com/blog/2016/04/27/ui-vs-ux/)) of your app will have to be as close to flawless as possible for it to stand out. You can hire a team of designers to create the most beautiful graphics for your photo filtering app, but it won't do any good if the whole app freezes without warning when a user attempts to process an image!

![Bluto on Ice](https://media.giphy.com/media/mbDvYG4QfMoQo/giphy.gif "Don't freeze up!")

To that end we can use multithreading to run heavy processes off the main thread of a device, thereby ensuring the user interface doesn't stutter and the user experience is maintained.

In this lab you will fix a broken photo filter app which hangs when the user tries to apply an "antique" filter.

## Goals

* When the `Antique` button is tapped, an activity indicator should be presented and animated. This activity indicator should stop when the image is filtered.
* We also want to allow the user to continue to pan and zoom the image while the filtration occurs in the background.

## Instructions

* Add an activity indicator.
* Start the activity indicator visible when the `Antique!` button is tapped and stop it when the image is filtered.

### Advanced

Play around with other filters and see what you can create! Here's a [list of all available CIFilters](https://developer.apple.com/library/mac/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html) to get you started.

<p data-visibility='hidden'>View <a href='https://learn.co/lessons/swift-multithreading-lab' title='Multithreading in Swift'>Multithreading in Swift</a> on Learn.co and start learning to code for free.</p>
