package rx.tests.operators
{
	import org.flexunit.Assert;
	
	import rx.IObservable;
	import rx.Observable;
	import rx.Subject;
	import rx.tests.mocks.StatsObserver;
	
	public class AnyFixture extends AbsDecoratorOperatorFixture
	{
		protected override function createEmptyObservable(source:IObservable):IObservable
		{
			return source.any();
		}
		
		[Test]
		public function negative_value_is_received_on_completion() : void
		{
			var stats : StatsObserver = new StatsObserver();
			
			var source : Subject = new Subject(int);
			
			source.any(function(i:int):Boolean { return i > 2; })
				.subscribe(stats);
			
			source.onNext(0);
            source.onNext(1);
            source.onNext(2);
            Assert.assertFalse(stats.nextCalled);

            source.onCompleted();
            Assert.assertTrue(stats.completedCalled);
            Assert.assertTrue(stats.nextCalled);
            Assert.assertFalse(stats.nextValues[0]);
		}
		
		[Test]
		public function positive_value_is_received_immediately() : void
		{
			var stats : StatsObserver = new StatsObserver();
			
			var source : Subject = new Subject(int);
			
			source.any(function(i:int):Boolean { return i > 2; })
				.subscribe(stats);

            source.onNext(3);
            Assert.assertTrue(stats.nextCalled);
            Assert.assertTrue(stats.nextValues[0]);
		}
		
		[Test]
		public function sequence_completes_after_positive_result() : void
		{
			var stats : StatsObserver = new StatsObserver();
			
			var source : Subject = new Subject(int);
			
			source.any(function(i:int):Boolean { return i > 2; })
				.subscribe(stats);

            source.onNext(3);
            Assert.assertTrue(stats.completedCalled);
		}
		
		[Test]
		public function sequence_errors_after_error_thrown_in_predicate() : void
		{
			var stats : StatsObserver = new StatsObserver();
			
			var source : Subject = new Subject(int);
			
			source.any(function(i:int):Boolean { throw new Error(); })
				.subscribe(stats);

            source.onNext(0);
            Assert.assertTrue(stats.errorCalled);
		}
		
		[Test]
		public function sequence_errors_after_error_in_source() : void
		{
			var stats : StatsObserver = new StatsObserver();
			
			var source : Subject = new Subject(int);
			
			source.any(function(i:int):Boolean { return i > 2; })
				.subscribe(stats);

            source.onError(new Error());
            Assert.assertTrue(stats.errorCalled);
		}

		[Test(expects="Error")]
		public function errors_thrown_by_subscriber_are_bubbled() : void
		{
			var manObs : Subject = new Subject(int);
			
			var obs : IObservable = createEmptyObservable(manObs);
			
			obs.subscribeFunc(
				function(pl:int):void { throw new Error(); },
				function():void { },
				function(e:Error):void { Assert.fail("Unexpected call to onError"); }
			);

			manObs.onNext(0);
			manObs.onCompleted();
		}
		
		[Test]
		public function empty_source_outputs_negative_result() : void
		{
			var stats : StatsObserver = new StatsObserver();
			
			Observable.empty(int).any(function(i:int):Boolean { return i > 2; })
				.subscribe(stats);
				
			Assert.assertTrue(stats.completedCalled);
			Assert.assertTrue(stats.nextCalled);
			Assert.assertFalse(stats.nextValues[0]);
		}
		
		[Test]
		public override function is_normalized_for_oncompleted() : void
		{
			var manObs : Subject = new Subject(int);
			
			var index : int = 0;
			
			var obs : IObservable = createEmptyObservable(manObs);
			
			var stats : StatsObserver = new StatsObserver();
			
			obs.subscribe(stats);
			
			manObs.onCompleted();
			manObs.onNext(new Object());
			manObs.onError(new Error());
			
			Assert.assertEquals(1, stats.nextCount);
			Assert.assertFalse(stats.errorCalled);
		}
	}
}