package commands 
{
	import com.facebook.graph.Facebook;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import gtap.commands.Command;
	
	public class LoginCommand extends Command
	{
		
		private var _result:Boolean;
		
		public function LoginCommand(delay:Number = 0) 
		{
			
		}
		
		/**
		 * Pop up login
		 */
		override protected function execute():void
		{
			var opts:Object = { "scope":FacebookScope.SCOPE };
			Facebook.login(onLogin, opts);
		}
		
		private function onLogin(result:Object, fail:Object):void
		{
			if (result) {
				t.obj(result);
				// 已登入
				complete(Event.COMPLETE);
			} else {
				// 未登入
				complete(ErrorEvent.ERROR);
			}
		}
	}
}