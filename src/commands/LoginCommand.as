package commands 
{
	import com.facebook.graph.Facebook;
	import flash.events.Event;
	import gtap.commands.Command;
	
	public class LoginCommand extends Command
	{
		
		private var _result:Boolean;
		
		public function LoginCommand(delay:Number = 0) 
		{
			
		}
		
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
				_result = true;
			} else {
				// 未登入
				_result = false;
			}
			complete();
		}
		
		override protected final function complete(e:Event = null):void
		{
			if (_result) {
				
			}else {
				
			}
			_signal.dispatch();
		}
	}
}