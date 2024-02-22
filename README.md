# PiPlayground

A simple iOS app exploring how to implement Picture in Picture in a custom player.

## TODOS:
 - [x] Add the project UI
 - [x] Add video playback components
 - [x] Add control for starting pip
 - [x] Add support for pip restoration
 - [x] Document how PiP works in this README file

## Screenshot

 TODO

## PiP: Pragmatic Information

### What it is
- Allows users to watch a video in a little floating window, controlled by iOS
- Users then are free to navigate in the app or OS itself (open different apps, for example)
- Users are able to restore playback, allowing them to return to the original playback context
- It's part of the `AVKit` framework
- `AVKit` contains UI facilities for visualization of media playback 

### How to make it work
- You'll be interfacing with the `AVPictureInPictureController` class (check `PictureInPicture.swift` in this project)
- Use an `AVPlayerLayer` to instantiate it:
```swift
AVPictureInPictureController(playerLayer: playerLayer)
```
- Initialization follows this order:
  - Create an `AVPlayer` ready for playback
  - Create an `AVPlayerLayer`, which will have AVPlayer as its player
  - Create the `AVPictureInPictureController`
- You'll then need to check if pip is possible:
```swift
publisher(for: \.isPictureInPicturePossible)
    .filter { $0 == false }
    .receive(on: RunLoop.main)
    .timeout(.seconds(1), scheduler: RunLoop.main)
    .removeDuplicates()
    .sink(receiveCompletion: { completion in
        switch completion {
        case .failure:
            continuation.resume(returning: false)
        default:
            break
        }
        
        cancellable?.cancel()
    }, receiveValue: { _ in
        debugPrint("Pip is possible.")
        continuation.resume(returning: true)
    })
```
- Once pip is possible, use `startPictureInPicture()` and `stopPictureInPicture()` methods to control it
- Use delegation (`AVPictureInPictureControllerDelegate`) to receive its state:
```swift
func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
    debugPrint("Pip is active.")
}
    
func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
    debugPrint("Pip is inactive.")
}
    
func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
    debugPrint("Pip error: \(error)")
}
```
- PiP provides a way for you to restore the app UI, so users can navigate back to the original playback context:
```swift
func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController) async -> Bool {
    guard let playbackRestorer else { return false }
    return await playbackRestorer.restore()
}
// Check:
// 1. PictureInPicture.swift (for pip encapsulation and restoration definitions)
// 2. MovieSession.swift (for playback and pip creation)
// 3. MoviesCatalogView.swift (for playback context restoration)
```

### Limitations
- Lack of controls customization. The only documented method for controlling some of the controls is when you set `requiresLinearPlayback`
- Other customization options are described in [this repository](https://github.com/CaiWanFeng/PiP) (although they are not documented by Apple) 
- PiP doesn't work on iPhone simulators
