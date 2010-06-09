package rx.tests.operators
{
	import org.flexunit.Assert;
	
	import rx.Observable;
	import rx.Subject;
	import rx.tests.mocks.StatsObserver;
	
	public class ForkJoinFixture
	{
		private var selector : Function = function (x:int, y:int) : String { return x.toString() + "," + y.toString(); };

        [Test]
        public function no_values_are_emitted_if_one_source_is_empty() : void
        {
            var stats : StatsObserver = new StatsObserver();

            Observable.forkJoin([Observable.empty(), Observable.returnValue(int, 1)])
                    .subscribe(stats);

            Assert.assertEquals(0, stats.nextCount);
            Assert.assertTrue(stats.completedCalled);
        }

        [Test]
        public function value_array_is_emitted_if_both_sources_have_one_value() : void
        {
            var stats : StatsObserver = new StatsObserver();

            Observable.forkJoin([Observable.returnValue(int, 1), Observable.returnValue(int, 2)])
                    .subscribe(stats);

            Assert.assertEquals(1, stats.nextCount);
            Assert.assertEquals("1,2", stats.nextValues[0]);
            Assert.assertTrue(stats.completedCalled);
        }

        [Test]
        public function first_values_are_emitted_if_both_sources_have_multiple_values() : void
        {
            var stats : StatsObserver = new StatsObserver();

            Observable.forkJoin([Observable.range(0, 2), Observable.range(2, 2)])
                    .subscribe(stats);

            Assert.assertEquals(1, stats.nextCount);
            Assert.assertEquals("0,2", stats.nextValues[0]);
            Assert.assertTrue(stats.completedCalled);
            Assert.assertTrue(stats.completedCalled);
        }

        [Test]
        public function values_are_emitted_after_all_are_available() : void
        {
            var subjectA : Subject = new Subject(int);
            var subjectB : Subject = new Subject(int);

            var stats : StatsObserver = new StatsObserver();

            Observable.forkJoin([subjectA, subjectB])
                    .subscribe(stats);

            subjectA.onNext(0);
            subjectB.onNext(1);

            Assert.assertEquals(1, stats.nextCount);
            Assert.assertEquals("0,1", stats.nextValues[0]);
            Assert.assertTrue(stats.completedCalled);
        }

        [Test]
        public function sequence_completes_when_all_values_are_available() : void
        {
            var subjectA : Subject = new Subject(int);
            var subjectB : Subject = new Subject(int);

            var stats : StatsObserver = new StatsObserver();

            Observable.forkJoin([subjectA, subjectB])
                    .subscribe(stats);

            subjectA.onNext(0);
            Assert.assertFalse(stats.completedCalled);

            subjectB.onNext(1);
            Assert.assertTrue(stats.completedCalled);
        }
        
        [Test]
        public function observable_order_is_preserved() : void
        {
            var subjectA : Subject = new Subject(int);
            var subjectB : Subject = new Subject(int);

            var stats : StatsObserver = new StatsObserver();

            Observable.forkJoin([subjectA, subjectB])
                    .subscribe(stats);

            subjectB.onNext(1);
            subjectA.onNext(0);

            Assert.assertEquals(1, stats.nextCount);
            Assert.assertEquals(0, stats.nextValues[0][0]);
            Assert.assertEquals(1, stats.nextValues[0][1]);
        }
	}
}