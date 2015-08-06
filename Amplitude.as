package amplitude
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;

	/**
	 * 
	 * Simple AS3 binding for the Amplitude analytics HTTP API.
	 * 
	 * @author Ben Follington
	 * Voltic Games 2015
	 * 
	 */	
	public class Amplitude
	{
		private static const BASE_URL: String = "https://api.amplitude.com/httpapi";
		private static var amplitudeApiKey: String;
		private static var user: String;
		private static var userProps: Object = {};
		private static var metadata: Object = {};
		
		private static var initialised: Boolean = false;
	
		/**
		 * Initialise the API with an API key and user ID.
		 * 
		 * Currently the user ID is not persisted by this SDK. This is planned as a future
		 * improvement. 
		 * 
		 * @param apiKey Amplitude API key
		 * @param userId User ID, used to identify a user in the system
		 * 
		 */		
		public static function init(apiKey: String, userId: String): void {
			amplitudeApiKey = apiKey;
			user = userId;
			initialised = true;
		}
		
		/**
		 * Throw an error if we haven't actually initialised the system yet.
		 */
		private static function checkInitialisation(): void {
			if (!initialised) {
				throw new Error("Before using any Amplitude functionality, the init() must be called");
			}
		}
		
		/**
		 * Store custom information to be included with every request.
		 * 
		 * This is intended to include information such as app configuration and version,
		 * os versioning and other environment data.
		 * 
		 * See https://amplitude.zendesk.com/hc/en-us/articles/204771828 for full list of
		 * important metadata keys.
		 * 
		 * @param key 		The name to store data under
		 * @param value 	The data to be stored
		 */
		public static function addMetadata(key: String, value: Object): void {
			metadata[key] = value;
		}
		
		/**
		 * Helper method to generate a user ID, however this is not guaranteed to
		 * be unique, merely random. 
		 * 
		 * Amplitude requires the user ID be supplied with every event, so
		 * this value must be stored between sessions. The API makes no attempt to do this.
		 * 
		 * @param strlen How many characters should this ID be?
		 */
		public static function generateUserId(strlen: uint): String {
			var chars: String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
			var numChars: uint = chars.length - 1;
			var randomChar: String = "";
			
			for (var i: uint = 0; i < strlen; i++){
				randomChar += chars.charAt(Math.floor(Math.random() * numChars));
			}
			
			return randomChar;
		}
		
		/**
		 * Add metadata relevant to the user, this updates the user record within the
		 * Amplitude system.
		 * 
		 * @param key Name to store data under
		 * @param value Data to store
		 * 
		 */		
		public static function addUserData(key: String, value: Object): void {
			userProps[key] = value;
		}
		
		/**
		 * Store an actual event in the Amplitude system.
		 *  
		 * @param event The name of the event to store, this should be unique
		 * @param data 	Data attached to this particular event, can be a nested key-value store.
		 * 				Only stringifyable keys and values are permitted.
		 * @param success Optional success callback
		 * 
		 */		
		public static function logEvent(event: String, data: Object, success: Function = null): void {
			
			checkInitialisation();
			
			var request: URLRequest = new URLRequest(BASE_URL);
			
			// Include required keys as per documentation
			var payload: Object = {
				event_properties: data,
				user_properties: userProps,
				user_id: user,
				event_type: event
			};
			
			// Insert custom user data
			for (var key: String in metadata) {
				payload[key] = metadata[key];
			}
			
			// As per https://amplitude.zendesk.com/hc/en-us/articles/204771828
			var variables: URLVariables = new URLVariables();
			variables.api_key = amplitudeApiKey;
			variables.event =  JSON.stringify(payload);
			
			request.data = variables;
			
			var loader: URLLoader = new URLLoader();
			
			if (success) {
				loader.addEventListener(Event.COMPLETE, success);
			}
			
			loader.load(request);
		}
	}
}