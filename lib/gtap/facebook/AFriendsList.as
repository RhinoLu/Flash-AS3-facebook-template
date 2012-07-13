package gtap.facebook
{
	import com.adobe.utils.ArrayUtil;
	import com.facebook.graph.data.FacebookAuthResponse;
	import com.facebook.graph.Facebook;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import gtap.display.MyScrollBar;
	import gtap.utils.JS;
	import gtap.utils.Online;
	import gtap.utils.QuickBtn;
	import org.casalib.util.ArrayUtil;
	import org.osflash.signals.Signal;
	
	public class AFriendsList extends Sprite
	{
		public var ok_mc:MovieClip; // --------------------- 送出
		public var reset_mc:MovieClip; // ------------------ 重選
		public var cont_mc:Sprite; // ---------------------- clips 容器
		public var mask_mc:Sprite; // ---------------------- 容器遮罩
		public var pick_txt:TextField; // ------------------ 顯示已選數量
		public var signal:Signal;
		
		protected var scroll_mc:Sprite; // ----------------- scroll
		protected var clip_class:Class; // ----------------- clip 的文件類
		protected var clipDefaultX:Number = 3; // ---------- clip 位置
		protected var clipDefaultY:Number = 2; // ---------- clip 位置
		protected var clipSegWidth:Number = 134 + 5; // ---- clip 寬度 + X間距
		protected var clipSegHeight:Number = 65 + 1; // ---- clip 高度 + Y間距
		
		private var default_array:Array; // ---------------- 預設已選朋友
		private var friends_array:Array; // ---------------- 所有朋友
		private var selected_array:Array; // --------------- 已選的朋友 FBID Array(例如從塗鴉牆過來的)
		private var selected_most_limit:uint; // ----------- 選擇人數上限
		private var selected_least_limit:uint; // ---------- 選擇人數下限
		private var filter_array:Array; // ----------------- 要過濾掉的朋友 FBID Array(例如上次已邀請過)
		
		/**
		 * 
		 * @param	most_limit 最多可選幾位
		 * @param	least_limit 至少選幾位
		 * @param	_default 預設已選朋友 FBID Array
		 * @param	_filter 要過濾掉的朋友 FBID Array
		 */
		public function AFriendsList(most_limit:uint = 5, least_limit:uint = 1, _default:Array = null, _filter:Array = null):void
		{
			selected_most_limit = most_limit;
			selected_least_limit = least_limit;
			default_array = _default;
			filter_array = _filter;
			signal = new Signal();
			
			stage?init():addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		protected function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
			
			pick_txt.autoSize = TextFieldAutoSize.LEFT;
			pick_txt.text = "(0)";
			cont_mc.mask = mask_mc;
			selected_array = [];
			getFriends();
		}
		
		private function onRemoveFromStage(e:Event):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
			removeClip()
			removeBtn();
			signal.removeAll();
		}
		
		private function checkDefault():void
		{
			if (default_array) {
				var i:uint;
				var len:uint = friends_array.length;
				var clip:IFriendClip;
				for (i = 0; i < len ; i++) {
					clip = cont_mc.getChildAt(i) as IFriendClip;
					if (clip.FBID == default_array[i]["fid"]) {
						selected_array.push( { "id":clip.FBID, "name":clip.FBNAME } );
						clip.overEffect();
						return;
					}
				}
				pick_txt.text = "(" + selected_array.length + ")";
			}
		}
		
		// 查詢朋友ID **************************************************************************************************************************************
		private function getFriends():void 
		{
			if (Online()) {
				var far:FacebookAuthResponse = Facebook.getAuthResponse();
				Facebook.api('/me/friends', handleFriendsComplete, { access_token:far.accessToken }, 'GET');
			}else {
				friends_array = makeFakeFriends();
				attFriendsClip();
				addScrollbar();
				setupBtn();
			}
		}
		
		private function handleFriendsComplete(response:Object, fail:Object):void
		{
			//trace("handleFriendsComplete : " + "Facebook 查詢朋友ID");
			//t.obj(response); // !!
			//t.obj(fail);
			if (response && stage) {
				friends_array = response as Array;
				if (friends_array.length < 1) {
					// 沒有朋友
					signal.dispatch(FriendsListEvent.OK, null);
					return;
				}
				attFriendsClip();
				checkDefault();
				addScrollbar();
				setupBtn();
				if (friends_array.length < selected_least_limit) {
					selected_least_limit = friends_array.length;
				}
			}
		}
		
		/**
		 * 離線狀態時
		 * @return
		 */
		protected function makeFakeFriends():Array { return []; }
		
		// Clip ******************************************************************************************************************************************
		private function attFriendsClip():void 
		{
			var i:uint = 0;
			var len:uint = friends_array.length;
			var clipSegNum:uint = Math.floor(mask_mc.width / clipSegWidth); // clip 每列數量
			var clip:IFriendClip;
			for (i = 0; i < len ; i++) {
				clip = new clip_class(friends_array[i].name, friends_array[i].id);
				DisplayObject(clip).x = clipDefaultX + (clipSegWidth * (i % clipSegNum));
				DisplayObject(clip).y = clipDefaultY + (clipSegHeight * Math.floor(i / clipSegNum));
				QuickBtn.setBtn(Sprite(clip), onClipOver, onClipOut, onClipClick);
				cont_mc.addChild(DisplayObject(clip));
			}
			
			trace(clipSegWidth, clipSegHeight, clipSegNum, mask_mc.width);
		}
		
		private function onClipOver(e:MouseEvent):void 
		{
			var clip:IFriendClip = e.target as IFriendClip;
			if (!org.casalib.util.ArrayUtil.getItemByKey(selected_array, "id", clip.FBID)) {
				clip.overEffect();
			}
		}
		
		private function onClipOut(e:MouseEvent):void 
		{
			var clip:IFriendClip = e.target as IFriendClip;
			if (!org.casalib.util.ArrayUtil.getItemByKey(selected_array, "id", clip.FBID)) {
				clip.outEffect();
			}
		}
		
		private function onClipClick(e:MouseEvent):void 
		{
			var clip:IFriendClip = e.target as IFriendClip;
			if (!org.casalib.util.ArrayUtil.getItemByKey(selected_array, "id", clip.FBID)) {
				// 未選
				if (selected_most_limit < 1 || selected_array.length < selected_most_limit) {
					// 加入
					selected_array.push( { "id":clip.FBID, "name":clip.FBNAME } );
					//signal.dispatch("PICKUP_ONE", clip.FBID);
					signal.dispatch(FriendsListEvent.PICK_UP_ONE, { "id":clip.FBID, "name":clip.FBNAME } );
				}else {
					// 已滿
					JS.alert("您已挑選" + selected_most_limit + "名朋友！");
				}
			}else {
				// 已選，移除
				var obj:Object = org.casalib.util.ArrayUtil.getItemByKey(selected_array, "id", clip.FBID);
				//t.obj("obj : " + obj);
				org.casalib.util.ArrayUtil.removeItem(selected_array, obj);
				clip.outEffect();
			}
			t.obj(selected_array);
			pick_txt.text = "(" + selected_array.length + ")";
		}
		
		private function resetClip():void 
		{
			var i:uint = 0;
			var len:uint = cont_mc.numChildren;
			var clip:IFriendClip;
			for (i = 0; i < len ; i++) {
				clip = cont_mc.getChildAt(i) as IFriendClip;
				clip.outEffect();
			}
		}
		
		private function removeClip():void 
		{
			var i:uint = 0;
			var len:uint = cont_mc.numChildren;
			var clip:IFriendClip;
			for (i = 0; i < len ; i++) {
				clip = cont_mc.getChildAt(i) as IFriendClip;
				QuickBtn.removeBtn(Sprite(clip), onClipOver, onClipOut, onClipClick);
			}
		}
		
		// OK, RESET **************************************************************************************************************************************
		private function setupBtn():void
		{
			QuickBtn.setBtn(ok_mc   , QuickBtn.onOver, QuickBtn.onOut, onOkClick);
			QuickBtn.setBtn(reset_mc, QuickBtn.onOver, QuickBtn.onOut, onResetClick);
		}
		
		private function onOkClick(e:MouseEvent):void 
		{
			//trace("OK");
			if (selected_array.length < selected_least_limit) {
				JS.alert("至少挑選" + selected_least_limit + "名朋友！");
			}else {
				t.obj(selected_array);
				signal.dispatch(FriendsListEvent.OK, selected_array);
			}
		}
		
		private function onResetClick(e:MouseEvent):void 
		{
			pick_txt.text = "(0)";
			selected_array = [];
			resetClip();
		}
		
		private function removeBtn():void
		{
			QuickBtn.removeBtn(ok_mc   , QuickBtn.onOver, QuickBtn.onOut, onOkClick);
			QuickBtn.removeBtn(reset_mc, QuickBtn.onOver, QuickBtn.onOut, onResetClick);
		}
		
		// scroll bar ***************************************************************************************************************************************
		protected function addScrollbar():void { }
		
		// Reset ********************************************************************************************************************************************
		public function resetAll():void
		{
			var i:uint = 0;
			var len:uint = cont_mc.numChildren;
			var clip:IFriendClip;
			for (i = 0; i < len ; i++) {
				clip = cont_mc.getChildAt(i) as IFriendClip;
				clip.outEffect();
			}
			
			pick_txt.text = "(0)";
			selected_array = [];
		}
	}
}