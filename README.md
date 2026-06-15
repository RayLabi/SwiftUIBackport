# SwiftUI backported
A library backporting in SwiftUI.


## Overview
The library back-ports swiftUI's `.containerRelativeFrame`, `.onChange`, and more all
the way back to iOS 16. 

## Sponsor
I develop these tools in my personal time, so please consider sponsoring me (https://github.com/sponsors/RayLabi). This will help me continue developing useful libraries like this.
本人目前失业状态，请考虑点Sponsor，将帮助我继续开发这类开源库。 

## Installation 

### Swift Package Manager(Recommended) 
You can add this repo as a dependency in Xcode26+:
1. Open your project.
2. Go to File > Add Package Dependencies…
3. Enter the URL: https://github.com/RayLabi/SwiftUIBackport
4. Choose the latest version and add it to your app target.

### You can install manually (by copying the files in the `Sources` directory) 


## Usage
No more nested if #available blocks

Instead of writing:

```swift
    if #available(iOS 17.0, *) {
        MyView()
            .xxx()
    } else {
        MyView()
    }
```

You can write:

```swift
    MyView()
        .xxxBackport()
```

## Backported Modifiers
| iOS Version | Modifier                                | Tested Platform                                  |
|-------------|-----------------------------------------|--------------------------------------------------|
|iOS 17.0|scrollTargetBehavior(_ behavior:)|✅ iOS16.0 ✅ iOS26.3.1|

## Contributing
Got a new SwiftUI modifier you'd like to backport? Open a PR or file an issue — contributions are welcome!

## License
This library is released under the MIT license. See [LICENSE](LICENSE) for details.
