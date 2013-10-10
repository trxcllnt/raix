package raix.reactive
{
	import raix.reactive.AbsObservable;
	import raix.reactive.ICancelable;
	import raix.reactive.IObserver;
	import raix.reactive.scheduling.Scheduler;
	
	internal class ClosureObservable extends AbsObservable
	{
		private var _observeFunc : Function;
		
		public function ClosureObservable(observeFunc : Function)
		{
			_observeFunc = observeFunc;
		}
		
		public override function subscribeWith(observer : IObserver) : ICancelable 
		{
			// TODO: What if observer is already a SafetyObserver (eg. select().first())?
			var safetyObserver : SafetyObserver = new SafetyObserver(observer);
			
			var subscription : MutableCancelable = new MutableCancelable();
			safetyObserver.setSubscription(subscription);
			
			if(Scheduler.immediate.scheduleRequired()) {
				Scheduler.immediate.schedule(function():void {
					subscription.cancelable = ICancelable(_observeFunc(safetyObserver));
				});
			} else {
				subscription.cancelable = ICancelable(_observeFunc(safetyObserver));
			}
			
			return subscription; 
		}
	}
}
