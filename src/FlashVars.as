package  
{
	/**
	 * 存放 FlashVars
	 */
	public class FlashVars
	{
		private static var _instance:FlashVars;
		private static var _canInit:Boolean = false;
		
		private var _APP_ID:String; // ---------------- APP ID
		
		/**
		 * Creates an instance of FlashVars.
		 */
		public function FlashVars()
		{
			if (_canInit == false) {
				throw new Error(
				  'FlashVars is an singleton and cannot be instantiated.'
				);
			}
		}
		
		
		/**
		 * APP ID
		 */
		public static function get APP_ID():String { return getInstance().APP_ID; }
		public static function set APP_ID(value:String):void { getInstance().APP_ID = value; }
		private function get APP_ID():String { return _APP_ID; }
		private function set APP_ID(value:String):void { _APP_ID = value; }
		
		
		
		
		
		private static function getInstance():FlashVars
		{
			if (_instance == null) {
				_canInit = true;
				_instance = new FlashVars();
				_canInit = false;
			}
			
			return _instance;
		}
	}
}