# SwiftColorSampler
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

SwiftColorSampler is a UIImage extension for sampling prominent colors from an image. I built this to mimic the cover art color palette generation in iTunes 11.  See [this StackOverflow question](http://stackoverflow.com/questions/13637892/how-does-the-algorithm-to-color-the-song-list-in-itunes-11-work) for more details.

## Installation

### Carthage

SwiftColorSampler is available to install with [Carthage](https://github.com/Carthage/Carthage). To integrate SwiftColorSampler into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "mhmiles/SwiftColorSampler" ~> 1.0
```

### Manually

If you prefer not to use Carthage, you can integrate SwiftColorSampler into your project manually.

#### Embedded Framework

- Open up Terminal, `cd` into your top-level project directory, and run the following command "if" your project is not initialized as a git repository:

```bash
$ git init
```

- Add SwiftColorSampler as a git [submodule](http://git-scm.com/docs/git-submodule) by running the following command:

```bash
$ git submodule add https://github.com/mhmiles/SwiftColorSampler.git
```

- Open the new `SwiftColorSampler` folder, and drag the `SwiftColorSampler.xcodeproj` into the Project Navigator of your application's Xcode project.

    > It should appear nested underneath your application's blue project icon. Whether it is above or below all the other Xcode groups does not matter.

- Select the `SwiftColorSampler.xcodeproj` in the Project Navigator and verify the deployment target matches that of your application target.
- Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
- In the tab bar at the top of that window, open the "General" panel.
- Click on the `+` button under the "Embedded Binaries" section.
- Select the `SwiftColorSampler.framework`.

- And that's it!

> The `SwiftColorSampler.framework` is automagically added as a target dependency, linked framework and embedded framework in a copy files build phase which is all you need to build on the simulator and a device.

## Usage

```Swift
UIImage.sampleColors(count: Int, colorDepth: Int = 4)
```

Reduces the full color palette an image to a reduce palette of size `count`.  `colorDepth` is an optional parameter that affects the precision of the quantization with a maximum of 8 and a default of 4.  A higher `colorDepth` increases precision at the cost of performance.  Values nearer to 8 are only recommended for images with a very low color count and where high precision is desired.

```Swift
UIImage.sampleColors(count: Int, rect: CGRect, colorDepth: Int = 4)
```

Applies sampleColors to a subregion of an image bounded by `rect`.

## Contributing

All pull requests will be considered.  Feel free to contact me with any questions or suggestions.

## Special Thanks

- Thanks to Dan Bloomberg and Leptonica for this incredibly informative [PDF on Octree Color Quantization](http://www.leptonica.com/papers/colorquant.pdf).
- Thanks to the [Alamofire Software Foundation](http://alamofire.org/) for the much of the formatting and content of this readme.

## License

SwiftColorSampler is released under the MIT license.
