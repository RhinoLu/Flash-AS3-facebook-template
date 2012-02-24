package 
{
	import com.adobe.serialization.json.JSON;
	import com.bit101.components.PushButton;
	import com.facebook.graph.controls.Distractor;
	import com.facebook.graph.data.FacebookAuthResponse;
	import com.facebook.graph.Facebook;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import gtap.utils.Online;
	import org.casalib.util.FlashVarUtil;
	import org.casalib.util.StageReference;
	
	public class Main extends Sprite 
	{
		private var fb_loading:Distractor;
		
		private var connect_btn:PushButton;
		private var publishAS3_btn:PushButton;
		private var publishJS_btn:PushButton;
		private var publishDiaglogs_btn:PushButton;
		
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.HIGH;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.stageFocusRect = false;
			
			StageReference.setStage(stage);
			addFBLoading();
			if (Online()) {
				Facebook.init(FlashVarUtil.getValue("APP_ID"), onInit);
			}
			
			setupButton();
		}
		
		private function onInit(result:Object, fail:Object):void
		{
			removeFBLoading();
			if (result) {
				t.obj(result);
				var far:FacebookAuthResponse = result as FacebookAuthResponse;
				if (far == null || far.uid == null) {
					// 未登入
					
				}else {
					// 已登入
					publishAS3_btn.enabled = true;
					publishJS_btn.enabled = true;
					publishDiaglogs_btn.enabled = true;
					return;
				}
			}
			connect_btn.enabled = true;
		}
		
		private function popupLogin(e:MouseEvent):void 
		{
			connect_btn.mouseEnabled = false;
			
			var opts:Object = {};
			opts.scope = "publish_stream,read_stream";
			Facebook.login(onLogin, opts);
			addFBLoading();
		}
		
		private function popupPublishAS3(e:MouseEvent):void 
		{
			publishAS3_btn.mouseEnabled = false;
			
			//share("100002211152691");
			share();
			addFBLoading();
		}
		
		private function share(toWho:String = "me"):void
		{
			var far:FacebookAuthResponse = Facebook.getAuthResponse();
			var postObj:Object = { };
			postObj.link = "http://google.com/";
			postObj.picture = "";
			postObj.name = "Flash Template " + new Date().getMilliseconds() + ", post by AS3";
			postObj.description = "This is a test.";
			postObj.access_token = far.accessToken;
			
			var _privacy:Object = { };
			//_privacy.value = "EVERYONE";
			_privacy.value = "CUSTOM";
			_privacy.friends = "SELF";
			//_privacy.friends = "SOME_FRIENDS";
			//_privacy.allow = "100002211152691";
			postObj.privacy = JSON.encode(_privacy);
			//postObj.privacy = _privacy;
			Facebook.api("/" + toWho + "/feed", onShare, postObj, "POST");
			
		}
		
		private function onShare(result:Object, fail:Object):void 
		{
			removeFBLoading();
			publishAS3_btn.enabled = true;
			t.obj(result);
			if (result) {
				trace("post 成功");
			}
			if (fail) {
				trace("post 失敗 或 不分享");
			}
		}
		
		private function onLogin(result:Object, fail:Object):void
		{
			if (result) {
				t.obj(result);
				// 已登入
				connect_btn.enabled = false;
				publishAS3_btn.enabled = true;
				publishJS_btn.enabled = true;
				publishDiaglogs_btn.enabled = true;
			} else {
				// 未登入
				removeFBLoading();
				connect_btn.mouseEnabled = true;
			}
		}
		
		private function popupPublishJS(e:MouseEvent):void 
		{
			publishJS_btn.mouseEnabled = false;
			
			if (ExternalInterface.available) {
				ExternalInterface.addCallback("onPublishPostComplete", onPublishPostComplete);
				ExternalInterface.call("myShare", "onPublishPostComplete");
			}
			
			addFBLoading();
		}
		
		public function onPublishPostComplete(result:*):void 
		{
			removeFBLoading();
			publishJS_btn.enabled = true;
			t.obj(result);
			if (result && result.id) {
				trace("post 成功");
			}else {
				trace("post 失敗");
			}
		}
		
		private function popupPublishDiaglogs(e:MouseEvent):void 
		{
			publishDiaglogs_btn.mouseEnabled = false;
			
			if (ExternalInterface.available) {
				ExternalInterface.addCallback("onPublishDiaglogsComplete", onPublishDiaglogsComplete);
				ExternalInterface.call("shareByDiaglogs", "onPublishDiaglogsComplete");
			}
			
			addFBLoading();
		}
		
		public function onPublishDiaglogsComplete(result:*):void 
		{
			removeFBLoading();
			publishDiaglogs_btn.enabled = true;
			t.obj(result);
			if (result && result.post_id) {
				trace("post 成功");
			}else {
				trace("post 失敗");
			}
		}
		
		private function setupButton():void
		{
			connect_btn = new PushButton(this, 10, 50, "Connect", popupLogin);
			connect_btn.enabled = false;
			publishAS3_btn = new PushButton(this, 10, 80, "Publish By AS3", popupPublishAS3);
			publishAS3_btn.enabled = false;
			publishJS_btn = new PushButton(this, 10, 110, "Publish By JS", popupPublishJS);
			publishJS_btn.enabled = false;
			publishDiaglogs_btn = new PushButton(this, 10, 140, "Publish By Diaglogs", popupPublishDiaglogs);
			publishDiaglogs_btn.enabled = false;
		}
		
		// Facebook Loading **********************************************************************************************************************************
		private function addFBLoading():void 
		{
			if (fb_loading) {
				fb_loading.visible = true;
			}else {
				fb_loading = new Distractor();
				fb_loading.x = -55;
				fb_loading.y = 10;
				fb_loading.mouseChildren = fb_loading.mouseEnabled = false;
				addChild(fb_loading);
			}
		}
		
		private function removeFBLoading():void 
		{
			if (fb_loading) {
				fb_loading.visible = false;
			}
		}
	}
	
}