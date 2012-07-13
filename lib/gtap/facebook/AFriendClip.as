package gtap.facebook
{
	import com.facebook.graph.Facebook;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.data.ImageLoaderVars;
	import com.greensock.loading.ImageLoader;
	import com.greensock.TweenMax;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import gtap.utils.Online;
	
	public class AFriendClip extends MovieClip implements IFriendClip
	{
		public var name_txt:TextField;
		public var pic_container:Sprite;
		
		private var _loader:ImageLoader; // ----- 
		private var _FBNAME:String; // ---------- Facebook Name
		private var _FBID:String; // ------------ Facebook ID
		
		/**
		 * 
		 * @param	name Facebook Name
		 * @param	id Facebook id
		 */
		public function AFriendClip(name:String, id:String):void
		{
			//trace(name, id);
			_FBNAME = name;
			_FBID = id;
			
			stage?init():addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		protected function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
			//trace(FBNAME, FBID);
			//trace(name_txt);
			
			name_txt.text = FBNAME;
			if (Online()) {
				//trace(Facebook.getImageUrl(FBID, "square"));
				loadPic();
			}
		}
		
		protected function onRemoved(e:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
			if (_loader) {
				_loader.dispose(true);
				_loader = null;
			}
		}
		
		private function loadPic():void
		{
			_loader = new ImageLoader(Facebook.getImageUrl(FBID, "square"), new ImageLoaderVars().autoDispose(true).smoothing(true).onComplete(onPicComplete).vars );
			_loader.load();
		}
		
		private function onPicComplete(e:LoaderEvent):void 
		{
			pic_container.addChild(_loader.content);
			setupPic();
		}
		
		protected function setupPic():void{}
		
		public function overEffect():void { }
		
		public function outEffect():void { }
		
		public function get FBNAME():String { return _FBNAME; }
		
		public function get FBID():String { return _FBID; }
		
	}
}