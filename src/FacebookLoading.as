package  
{
	import com.facebook.graph.controls.Distractor;
	import flash.display.DisplayObjectContainer;
	
	public class FacebookLoading
	{
		private static var distractor:Distractor;
		
		public static function show(__container:DisplayObjectContainer, __x:Number = 0, __y:Number = 0):void
		{
			FacebookLoading.distractor = null;
			for (var i:int = 0; i < __container.numChildren; i++) 
			{
				if (__container.getChildAt(i) is Distractor)
				{
					FacebookLoading.distractor = __container.getChildAt(i) as Distractor;
					break;
				}
			}
			
			if (FacebookLoading.distractor)
			{
				FacebookLoading.distractor.visible = true;
			}
			else
			{
				FacebookLoading.distractor = new Distractor();
				FacebookLoading.distractor.x = __x;
				FacebookLoading.distractor.y = __y;
				__container.addChild(FacebookLoading.distractor);
			}
		}
		
		public static function hide(__container:DisplayObjectContainer):void
		{
			FacebookLoading.distractor = null;
			for (var i:int = 0; i < __container.numChildren; i++) 
			{
				if (__container.getChildAt(i) is Distractor)
				{
					FacebookLoading.distractor = __container.getChildAt(i) as Distractor;
					break;
				}
			}
			
			if (FacebookLoading.distractor)
			{
				FacebookLoading.distractor.visible = false;
			}
		}
	}

}