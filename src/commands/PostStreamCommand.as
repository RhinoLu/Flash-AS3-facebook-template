package commands 
{
	import com.adobe.serialization.json.JSON;
	import com.facebook.graph.data.FacebookAuthResponse;
	import com.facebook.graph.Facebook;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import gtap.commands.Command;
	
	/**
	 * facebook post command
	 * @example 
		<code>
			var command:PostStreamCommand = new PostStreamCommand();
			command.to = "";
			command.link = "http://example.com/";
			command.picture = "http://example.com/share.jpg";
			command.nameOfLink = "Example";
			command.description = "This is a test.";
			command.privacy = {};
			command.privacy.value = "CUSTOM";
			command.privacy.friends = "SELF";
			command.signal.addOnce(someListener);
			command.start();
		</code>
	 */
	public class PostStreamCommand extends Command
	{
		private var _to:String = "";
		private var _link:String = "";
		private var _picture:String = "";
		private var _nameOfLink:String = "";
		private var _description:String = "";
		private var _privacy:Object;
		
		
		public function PostStreamCommand(delay:Number = 0) 
		{
			
		}
		
		override protected function execute():void
		{
			var far:FacebookAuthResponse = Facebook.getAuthResponse();
			var postObj:Object = { };
			postObj.to = _to;
			postObj.link = _link;
			postObj.picture = _picture;
			postObj.name = _nameOfLink;
			postObj.description = _description;
			postObj.access_token = far.accessToken;
			
			/*var _privacy:Object = { };
			//_privacy.value = "EVERYONE";
			_privacy.value = "CUSTOM";
			_privacy.friends = "SELF";
			//_privacy.friends = "SOME_FRIENDS";
			//_privacy.allow = "100002211152691";*/
			postObj.privacy = JSON.encode(_privacy);
			
			Facebook.api("/" + _to + "/feed", onShare, postObj, "POST");
		}
		
		private function onShare(result:Object, fail:Object):void 
		{
			if (result) {
				t.obj(result);
				complete(Event.COMPLETE, result.id);
			}
			
			if (fail) {
				t.obj(fail);
				complete(ErrorEvent.ERROR);
			}
		}
		
		public function set to(value:String):void 
		{
			_to = value;
		}
		
		public function set link(value:String):void 
		{
			_link = value;
		}
		
		public function set picture(value:String):void 
		{
			_picture = value;
		}
		
		public function set nameOfLink(value:String):void 
		{
			_nameOfLink = value;
		}
		
		public function set description(value:String):void 
		{
			_description = value;
		}
		
		public function set privacy(value:Object):void 
		{
			_privacy = value;
		}
	}

}