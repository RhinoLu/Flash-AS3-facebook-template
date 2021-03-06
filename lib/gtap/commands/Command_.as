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
	
	public class Command
	{
		private var _timer:Timer;
		private var _signal:Signal;
		
		public function Command(delay:Number = 0)
		{
			_timer = new Timer(int(1000 * delay), 1);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
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
		protected final function complete(e:Event = null):void
		{
			_signal.dispatch(Event.COMPLETE);
		}
		
		/**
		 * signal
		 */
		public function get signal():Signal 
		{
			return _signal;
		}
	}
}