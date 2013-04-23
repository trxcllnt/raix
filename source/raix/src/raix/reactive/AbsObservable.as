package raix.reactive
{
	/**
	 * Subclass this class only if you want to implement a completely custom IObservable.
	 * 
	 * <p>If you can avoid it, however, try to stick to subclassing Subject or using 
	 * one of the creation methods.</p>
	 * 
	 * <p>This class may be made inaccessible in future revisions</p>
	 */
	public class AbsObservable extends DynObservable
	{
		public function AbsObservable()
		{
		}
	}
}