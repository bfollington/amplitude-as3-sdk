# Amplitude AS3 SDK
An unofficial AS3 SDK for Amplitude (http://amplitude.com).

Allows posting of events to the Amplitude HTTP API, documentation here: https://amplitude.zendesk.com/hc/en-us/articles/204771828

This is in use within my own project's, and will be extended if I need to. Pull requests and issue reports welcome.

# Usage

```as3
    var userId: String = Amplitude.generateUserId(8);

    Amplitude.init("<API_KEY_GOES_HERE>", userId);
    Amplitude.addMetadata("app_version", "1.0");
    Amplitude.addUserData("name", "Ben");
		
    try {
      Amplitude.logEvent(
        "test_event",
        {"key": 123, "test": true}, 
        function(): void {
          trace("COMPLETED SEND");
        }
      );	
    } catch (e: Error) {
      trace(e, "uh oh");
    }
```
