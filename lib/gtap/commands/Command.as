package gtap.commands
{
	/**
	 * @author Allen Chou
	 */
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import org.osflash.signals.Signal;
	
	public class Command extends EventDispatcher
	{
		private var _signal:Signal;
		private var _timer:Timer;
		
		public function Command(delay:Number = 0)
		{
			_timer = new Timer(int(1000 * delay), 1);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			_signal = new Signal();
		}
		
		private function onTimerComplete(e:TimerEvent):void
		{
			execute();
		}
		
		/** 
		 * Starts the command. 
		 * Waits for the timer to complete and calls the execute() method. 
		 * This method can be used directly as an event listener. 
		 */
		public final function start(e:Event = null):void
		{
			_timer.start();
		}
		
		/** 
		 * The abstract method for you to override to create your own command. 
		 */
		protected function execute():void
		{
			
		}
		
		/** 
		 * Completes the command. 
		 * Dispatches a complete event. 
		 * This method can be used directly as an event listener. 
		 */
		protected final function complete(type:String, obj:*= null):void
		{
			//dispatchEvent(new Event(Event.COMPLETE));
			_signal.dispatch(type, obj);
			_signal.removeAll();
		}
		
		public function get signal():Signal 
		{
			return _signal;
		}
	}
}