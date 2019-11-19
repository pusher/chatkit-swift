# Initialization

In order to use the Chatkit SDK, it must be imported, initialized and
connected.

## Importing

The Chatkit SDK package is called `PusherChatkit`

```swift
import PusherChatkit
```

## Initializing

When initializing the SDK, you must provide your `instanceLocator`. This
string identifies users as belonging to your instance of Chatkit.

```swift
guard let chatkit = try? Chatkit(instanceLocator: "your_instance_locator") else {
  // Something went wrong
}
```

## Connecting

No network connections are created when the SDK is initialized, so to start
using the SDK, you must connect it.

The `connect` method takes a completion handler which receives `nil` on
success, otherwise an error describing what went wrong.

```swift
chatkit.connect { error in
  guard error == nil else {
    // Something went wrong while trying to connect
    return
  }

  // the SDK is connected and ready for use.
}
```

# Next

Now that the SDK is ready for use, you will probably want to access chat data
using either ViewModels or Providers which the SDK offers.

You can also explore the methods offered by the `Chatkit` entry point object.
Now that this object is initialized and connected, it is your handle to all
further interaction with the SDK.