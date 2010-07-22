package rx.tests.operators.creation
{
	import flash.errors.IOError;
	import flash.net.URLRequest;
	
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	
	import rx.Observable;
	
	public class URLLoaderFixture
	{
		private var test : Object = this;
		
		[Test(async)]
		public function loads_text_data() : void
		{
			var result : String = null;
			
			var nextHandler : Function = Async.asyncHandler(test, function(... args) : void
			{
				Assert.assertEquals("<data>text node</data>", result);
			}, 5000);
			
			var completeHandler : Function = Async.asyncHandler(test, null, 5000); 

			Observable.urlLoader(new URLRequest("rx/tests/operators/creation/test.xml"))
				.subscribe(
					function(s:String) : void
					{
						result = s;
						nextHandler(null);
					},
					function():void
					{
						completeHandler(null);
					});
		}
		
		[Test(async)]
		public function passes_error_to_onerror() : void
		{
			var error : Error = null;
			
			var errorHandler : Function = Async.asyncHandler(test, function(... args) : void
			{
				Assert.assertTrue(error is IOError);
			}, 5000); 

			Observable.urlLoader(new URLRequest("rx/tests/operators/creation/does_not_exist.xml"))
				.subscribe(null, null, function(e:Error) : void
				{
					error = e;
					errorHandler(null);
				});
		}
	}
}