package raix.reactive.scheduling
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import raix.reactive.Cancelable;
	import raix.reactive.ICancelable;
	
	/**
	 * A scheduler that executes actions immediately, or immediately
	 * after their dueTime (if specified).
	 */
	public class ImmediateScheduler implements IScheduler
	{
		private var _runningAction : Boolean = false;
		private var _pendingActions : Array = [];
		
		public function ImmediateScheduler() {}
		
		/**
		 * @inheritDoc
		 */
		public function schedule(action : Function, dueTime : int = 0) : ICancelable
		{
			if (dueTime != 0)
			{
				var timer : Timer = TimerPool.instance.obtain();
				timer.delay = dueTime;
				
				var handler : Function = function():void
				{
					timer.stop();
					timer.removeEventListener(TimerEvent.TIMER, handler);
					TimerPool.instance.release(timer);
					timer = null;
					
					schedule(action, 0);
				};
				
				timer.addEventListener(TimerEvent.TIMER, handler);
				timer.start();
				
				return Cancelable.create(function():void
				{
					if (timer != null)
					{
						timer.stop();
						timer.removeEventListener(TimerEvent.TIMER, handler);
						TimerPool.instance.release(timer);
					}
				});
			}
			else
			{
				_pendingActions.push(action);
				
				if (_runningAction)
				{
					return Cancelable.create(function():void
					{
						var index : int = _pendingActions.indexOf(action);
						if (index != -1)
						{
							_pendingActions.splice(index, 1);						
						}
					});
				}
				else
				{
					_runningAction = true;
					
					try
					{
						while (_pendingActions.length > 0)
						{
							(_pendingActions.shift())();
						}
					}
					catch(err : Error)
					{
						_pendingActions = [];
						throw err;
					}
					finally
					{
						_runningAction = false;
					}
				}
				
				return Cancelable.empty;
			}
		}
		
		public function scheduleRequired():Boolean {
			return _pendingActions.length == 0;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get now() : Date { return new Date(); }
		
		private static var _instance : ImmediateScheduler = new ImmediateScheduler();
		
		/**
		 * Gets the singleton instance of this scheduler
		 */
		public static function get instance() : ImmediateScheduler 
		{
			return _instance;
		}
	}
}