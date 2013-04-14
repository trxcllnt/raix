package raix.reactive.subjects
{
	public class BehaviorSubject extends ReplaySubject
	{
		public function BehaviorSubject(initialValue:* = null)
		{
			super(1, 0, null);
			
			if(initialValue !== null) {
				onNext(initialValue);
			}
		}
		
		private var _value:* = null;
		
		public function get value():* {
			return _value;
		}
		
		override public function onNext(value:Object):void {
			super.onNext(_value = value);
		}
	}
}