package commands 
{
	import com.adobe.serialization.json.JSON;
	import com.facebook.graph.data.FacebookAuthResponse;
	import com.facebook.graph.Facebook;
	import flash.display.BitmapData;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import gtap.commands.Command;
	
	/**
	 * facebook post command
	 * @example 
		<code>
			var command:UploadPhotoCommand = new UploadPhotoCommand();
			command.message = "";
			command.source = "";
			command.signal.addOnce(someListener);
			command.start();
		</code>
	 */
	public class UploadPhotoCommand extends Command
	{
		private var _message:String = "";
		private var _source:BitmapData;
		
		public function UploadPhotoCommand(delay:Number = 0) 
		{
			
		}
		
		override protected function execute():void
		{
			var far:FacebookAuthResponse = Facebook.getAuthResponse();
			var postObj:Object = { };
			postObj.fileName = "test";
			postObj.message = _message;
			//postObj.source = _source;
			t.obj(_source);
			//postObj.file = _source;
			postObj.image = _source;
			postObj.access_token = far.accessToken;
			
			Facebook.api("me/photos", onUploaded, postObj, "POST");
		}
		
		private function onUploaded(result:Object, fail:Object):void 
		{
			if (result) {
				t.obj(result);
				complete(Event.COMPLETE);
			}
			
			if (fail) {
				t.obj(fail);
				complete(ErrorEvent.ERROR);
			}
		}
		
		public function set message(value:String):void 
		{
			_message = value;
		}
		
		public function set source(value:BitmapData):void 
		{
			_source = value;
		}
		
		
	}

}