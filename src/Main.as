package 
{
	import com.adobe.serialization.json.JSON;
	import com.adobe.images.JPGEncoder;
	import com.bit101.components.PushButton;
	import com.bit101.components.TextArea;
	import com.facebook.graph.controls.Distractor;
	import com.facebook.graph.data.FacebookAuthResponse;
	import com.facebook.graph.Facebook;
	import com.greensock.loading.data.ImageLoaderVars;
	import com.greensock.loading.ImageLoader;
	import commands.LoginCommand;
	import commands.PostStreamCommand;
	import commands.UploadPhotoCommand;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.utils.ByteArray;
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
		private var uploadPhoto_btn:PushButton;
		private var like_btn:PushButton;
		private var publishWithoutLogin_btn:PushButton;
		private var getCheckin_btn:PushButton;
		
		private var info:TextArea;
		
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
			
			if (Online()) {
				FlashVars.APP_ID = FlashVarUtil.getValue("APP_ID");
				facebookInit();
			}
			
			setupButton();
		}
		
		// setup button ****************************************************************************************************************************
		private function setupButton():void
		{
			info = new TextArea(this, 200, 50);
			info.width  = 500;
			info.height = 500;
			
			connect_btn = new PushButton(this, 10, 50, "Connect", popupLogin);
			connect_btn.enabled = false;
			publishAS3_btn = new PushButton(this, 10, 80, "Publish By AS3", publishByAS3);
			publishAS3_btn.enabled = false;
			publishJS_btn = new PushButton(this, 10, 110, "Publish By JS", popupPublishJS);
			publishJS_btn.enabled = false;
			publishDiaglogs_btn = new PushButton(this, 10, 140, "Publish By Diaglogs", popupPublishDiaglogs);
			publishDiaglogs_btn.enabled = false;
			uploadPhoto_btn = new PushButton(this, 10, 170, "Upload Photo", uploadPhoto);
			uploadPhoto_btn.enabled = false;
			like_btn = new PushButton(this, 10, 200, "Like", doLike);
			like_btn.enabled = false;
			publishWithoutLogin_btn = new PushButton(this, 10, 230, "Publish Without Login", publishWithoutLogin);
			//publishWithoutLogin_btn.enabled = false;
			getCheckin_btn = new PushButton(this, 10, 260, "Get Checkin", getCheckin);
			getCheckin_btn.enabled = false;
		}
		
		// facebook init ***************************************************************************************************************************
		private function facebookInit():void
		{
			FacebookLoading.show(this, -55, 10);
			Facebook.init(FlashVars.APP_ID, onInit);
		}
		
		private function onInit(result:Object, fail:Object):void
		{
			FacebookLoading.hide(this);
			
			// 測試不用登入只要有ID也能撈到大頭照
			/*var imageLoader:ImageLoader;
			imageLoader = new ImageLoader(Facebook.getImageUrl("100000105021682", "large"), new ImageLoaderVars().container(this).x(200).y(10).vars);
			imageLoader.load();
			imageLoader = new ImageLoader(Facebook.getImageUrl("1462721030", "large"), new ImageLoaderVars().container(this).x(200).y(210).vars);
			imageLoader.load();*/
			//imageLoader = new ImageLoader(Facebook.getImageUrl("100000107102287", "large"), new ImageLoaderVars().container(this).x(200).y(310).vars);
			//imageLoader.load();
			
			if (result) {
				info.text = t.obj(result);
				var far:FacebookAuthResponse = result as FacebookAuthResponse;
				if (far == null || far.uid == null) {
					// 未登入
					connect_btn.enabled = true;
				}else {
					// 已登入
					publishAS3_btn.enabled = true;
					publishJS_btn.enabled = true;
					publishDiaglogs_btn.enabled = true;
					uploadPhoto_btn.enabled = true;
					like_btn.enabled = true;
					publishWithoutLogin_btn.enabled = true;
					getCheckin_btn.enabled = true;
					return;
				}
			}else {
				connect_btn.enabled = true;
			}
		}
		
		// facebook login **************************************************************************************************************************
		private function popupLogin(e:MouseEvent):void 
		{
			connect_btn.mouseEnabled = false;
			
			var _command:LoginCommand = new LoginCommand();
			_command.signal.addOnce(onLogin);
			_command.start();
			
			FacebookLoading.show(this, -55, 10);
		}
		
		private function onLogin(type:String, obj:*= null):void
		{
			if (type == Event.COMPLETE) {
				// 已登入
				connect_btn.enabled = false;
				publishAS3_btn.enabled = true;
				publishJS_btn.enabled = true;
				publishDiaglogs_btn.enabled = true;
				uploadPhoto_btn.enabled = true;
				like_btn.enabled = true;
				publishWithoutLogin_btn.enabled = true;
				getCheckin_btn.enabled = true;
			} else if (type == ErrorEvent.ERROR) {
				// 未登入
				connect_btn.mouseEnabled = true;
			}
			FacebookLoading.hide(this);
		}
		
		// facebook post by AS3 ********************************************************************************************************************
		private function publishByAS3(e:MouseEvent):void 
		{
			publishAS3_btn.mouseEnabled = false;
			
			var command:PostStreamCommand = new PostStreamCommand();
			command.to = "";
			command.link = "http://google.com/";
			command.picture = "";
			command.nameOfLink = "Example";
			command.description = "This is a test.";
			var privacy_obj:Object = { };
			privacy_obj.value = "CUSTOM";
			privacy_obj.friends = "SELF";
			command.privacy = privacy_obj;
			command.signal.addOnce(onShare);
			command.start();
			
			FacebookLoading.show(this, -55, 10);
		}
		
		private function onShare(type:String, obj:*= null):void
		{
			if (type == Event.COMPLETE) {
				//trace("post 成功");
				info.text = "post success";
			} else if (type == ErrorEvent.ERROR) {
				//trace("post 失敗 或 不分享");
				info.text = "post fail";
			}
			publishAS3_btn.enabled = true;
			FacebookLoading.hide(this);
		}
		
		// facebook post by AS3 without login ******************************************************************************************************
		private function publishWithoutLogin(e:MouseEvent):void 
		{
			publishWithoutLogin_btn.enabled = false;
			
			var postObj:Object = { };
			postObj.to = "";
			postObj.link = "http://lab.letsplay.com.tw/rhinolu/facebook/template/";
			postObj.picture = "http://lab.letsplay.com.tw/rhinolu/facebook/template/images/share.jpg";
			postObj.name = "Publish Without Login Test";
			postObj.description = "test...";
			//postObj.access_token = far.accessToken;
			Facebook.ui("me/feed", postObj, onPublishWithoutLogin, "popup");
			
			FacebookLoading.show(this, -55, 10);
		}
		
		private function onPublishWithoutLogin(result:Object, fail:Object = null):void 
		{
			if (result) {
				//t.obj(result);
				//trace("publishWithoutLogin 成功");
				info.text = t.obj(result);
			}
			
			if (fail) {
				//t.obj(fail);
				//trace("publishWithoutLogin 失敗");
				info.text = t.obj(fail);
			}
			publishWithoutLogin_btn.enabled = true;
			FacebookLoading.hide(this);
		}
		
		// facebook post by popup JS ***************************************************************************************************************
		private function popupPublishJS(e:MouseEvent):void 
		{
			publishJS_btn.mouseEnabled = false;
			
			if (ExternalInterface.available) {
				ExternalInterface.addCallback("onPublishPostComplete", onPublishPostComplete);
				ExternalInterface.call("myShare", "onPublishPostComplete");
			}
			
			FacebookLoading.show(this, -55, 10);
		}
		
		public function onPublishPostComplete(result:*):void 
		{
			//removeFBLoading();
			FacebookLoading.hide(this);
			publishJS_btn.enabled = true;
			t.obj(result);
			if (result && result.id) {
				//trace("post 成功");
				info.text = "post success";
			}else {
				//trace("post 失敗");
				info.text = "post fail";
			}
		}
		
		// facebook post by JS Diaglog *************************************************************************************************************
		private function popupPublishDiaglogs(e:MouseEvent):void 
		{
			publishDiaglogs_btn.mouseEnabled = false;
			
			if (ExternalInterface.available) {
				ExternalInterface.addCallback("onPublishDiaglogsComplete", onPublishDiaglogsComplete);
				ExternalInterface.call("shareByDiaglogs", "onPublishDiaglogsComplete");
			}
			
			//addFBLoading();
			FacebookLoading.show(this, -55, 10);
		}
		
		public function onPublishDiaglogsComplete(result:*):void 
		{
			//removeFBLoading();
			FacebookLoading.hide(this);
			publishDiaglogs_btn.enabled = true;
			t.obj(result);
			if (result && result.post_id) {
				//trace("post 成功");
				info.text = "post success";
			}else {
				//trace("post 失敗");
				info.text = "post fail";
			}
		}
		
		// facebook upload photo *******************************************************************************************************************
		private function uploadPhoto(e:MouseEvent):void 
		{
			uploadPhoto_btn.mouseEnabled = false;
			
			// 使用 command 因沒偵測到按鈕動作會發生安全性問題
			/*var _command:UploadPhotoCommand = new UploadPhotoCommand();
			_command.message = "test" + new Date().toString();
			_command.source = createBitmapFile();
			_command.signal.addOnce(onUploaded);
			_command.start();*/
			
			var far:FacebookAuthResponse = Facebook.getAuthResponse();
			var postObj:Object = { };
			postObj.fileName = "test";
			postObj.message = "test" + new Date().toString();
			postObj.image = createBitmapFile();
			postObj.access_token = far.accessToken;
			Facebook.api("me/photos", onUploaded, postObj, "POST");
			
			
			FacebookLoading.show(this, -55, 10);
		}
		
		private function onUploaded(result:Object, fail:Object):void 
		{
			if (result) {
				t.obj(result);
				info.text = t.obj(result);
				//trace(result.id);
				//trace(result.post_id);
				//trace("upload 成功");
				
				tagPhoto(result.id);
			}
			
			if (fail) {
				//t.obj(fail);
				info.text = t.obj(fail);
				//trace("upload 失敗");
			}
			uploadPhoto_btn.enabled = true;
			FacebookLoading.hide(this);
		}
		
		private function createBitmapFile():BitmapData
		{
			return new BitmapData(400, 300, false, 0xFF00FF);
		}
		
		// facebook tag photo *******************************************************************************************************************
		private function tagPhoto(photoID:String):void 
		{
			uploadPhoto_btn.mouseEnabled = false;
			
			var far:FacebookAuthResponse = Facebook.getAuthResponse();
			var postObj:Object = { };
			postObj.to = "100002211152691";
			postObj.x = "50";
			postObj.y = "50";
			postObj.access_token = far.accessToken;
			Facebook.api(photoID + "/tags", onTagged, postObj, "POST");
			
			FacebookLoading.show(this, -55, 10);
		}
		
		private function onTagged(result:Object, fail:Object):void 
		{
			if (result) {
				//t.obj(result);
				info.text = t.obj(result);
				//trace("tag 成功");
			}
			
			if (fail) {
				//t.obj(fail);
				info.text = t.obj(fail);
				//trace("tag 失敗");
			}
			uploadPhoto_btn.enabled = true;
			FacebookLoading.hide(this);
		}
		
		// like ********************************************************************************************************************************
		private function doLike(e:MouseEvent):void
		{
			like_btn.mouseEnabled = false;
			
			var far:FacebookAuthResponse = Facebook.getAuthResponse();
			var postObj:Object = { };
			postObj.object = "http://google.com/";
			postObj.access_token = far.accessToken;
			Facebook.api("me/og.likes", onLiked, postObj, "POST");
			
			FacebookLoading.show(this, -55, 10);
		}
		
		private function onLiked(result:Object, fail:Object):void 
		{
			if (result) {
				//t.obj(result);
				info.text = t.obj(result);
				//trace("like 成功");
			}
			
			if (fail) {
				//t.obj(fail);
				info.text = t.obj(fail);
				//trace("like 失敗");
			}
			like_btn.enabled = true;
			FacebookLoading.hide(this);
		}
		
		// get checkin ************************************************************************************************************************
		private function getCheckin(e:MouseEvent):void
		{
			getCheckin_btn.mouseEnabled = false;
			// user_status permission to read the user's checkins.
			// friends_status permission to read the user's friend's checkins.
			Facebook.fqlQuery("SELECT coords, tagged_uids, page_id FROM checkin WHERE author_uid= me()", onGetCheckins);
			FacebookLoading.show(this, -55, 10);
		}
		
		private function onGetCheckins(result:Object, fail:Object):void 
		{
			if (result) {
				//t.obj(result);
				info.text = t.obj(result);
			}
			
			if (fail) {
				//t.obj(fail);
				info.text = t.obj(fail);
			}
			getCheckin_btn.enabled = true;
			FacebookLoading.hide(this);
		}
	}
}