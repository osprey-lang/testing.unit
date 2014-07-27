The module `testing.unit` is a tiny, extremely basic unit testing module for Osprey. It is extremely barebones at the moment, capable only of what is absolutely necessary for running a series of unit tests.

All members exported by this module are in the namespace `testing.unit`.

Unit tests are organised into test fixtures. Each test fixture defines zero or more tests cases, which in turn may involve any number of test conditions (usually in the form of assertions).

## Defining a test fixture

To define a test fixture, you declare a class that derives from `testing.unit.TestFixture`, which is an abstract class. In order to be usable with `testing.unit`, your test fixture class must define a public constructor that accepts zero arguments.

Then, you define your tests as methods on the test fixture class. Every public instance method whose name begins with “`test_`” is part of the test fixture, and like the constructor, must accept zero arguments. An example follows.

```
use namespace aves;
use namespace testing.unit;

namespace my.module.test;

public class MyClassTests is TestFixture
{
	public new()
	{
		// The TestFixture constructor accepts an optional display name,
		// which will help you identify the test fixture.
		new base("Test for MyClass");
	}

	public test_ConstructionWithNoArguments()
	{
		var myClass;
		// testing.unit.Assert is a helper class
		Assert.doesNotThrow(@ { myClass = new MyClass(); });
		Assert.areEqual(myClass.value, 0);
		// etc.
	}

	public test_ConstructionWithOneArgument()
	{
		var value = 123;
		var myClass;
		Assert.doesNotThrow(@{ myClass = new MyClass(value); });
		Assert.areEqual(myClass.value, value);
	}

	public test_ConstructionWithNegativeArgument()
	{
		Assert.throws(typeof(ArgumentRangeError), @= new MyClass(-1));
	}

	public test_Equality()
	{
		// Manual throwing of AssertionError
		var x = new MyClass(1);
		var y = new MyClass(1);
		if x != y:
			throw new AssertionError("MyClass with same value should equal each other.");
		// Usually better:
		//Assert.areEqual(x, y);
	}

	// etc.
}
```

In the test methods, the part of the name following “`test_`” is displayed (without modification) if the test fails, but not otherwise. The return value of each test method, if any, is ignored.

## Running a test fixture

The type `testing.unit.TestFixture` defines an instance method `run()`, which lets you run the test fixture on demand. A second overload, `run(silent)`, lets you specify whether or not the test fixture should print the results to the console. By default, it does.

Both overloads of `run` return a list of `testing.unit.FailedTest` instances representing the tests that failed. Each `FailedTest` exposes the following properties:

* `index`: The index of the test within the fixture, zero-based. This index corresponds to the index of the `.` or `F` that is printed.
* `name`: The name of the test, which is the method name minus the “`test_`” prefix.
* `error`: The uncaught error that caused the test to fail. This is usually a `testing.unit.AssertionError`, but this is not a guarantee.
* `fixture`: The test fixture object itself.

Using the `MyClassTests` class defined in the previous example, you would run it on demand like so:

```
var myClassTests = new MyClassTests();
var failedTests = myClassTests.run(); // Run and print to console
// Alternatively:
failedTests = myClassTests.run(true); // Run and don't print anything
```

## Running all test fixtures in a module

The class `testing.unit.TestFixture` also has a public static method `runAll`, which can be used to run all test fixtures in a module. The module is given as the first argument to `runAll`, and is an `aves.reflection.Module` instance. The `runAll` method will walk through all the types in the module, and for every type that inherits from `testing.unit.TestFixture`, try to create an instance of the type and run the tests in the fixture.

Running a module full of test fixtures usually involves no more than this bit of code:

```
use namespace aves.reflection; // for Module
use namespace testing.unit;

TestFixture.runAll(Module.getCurrentModule());
```

If you have an explicit main method, put the call to `runAll` there instead.

Unlike `run`, the `runAll` method does not return a list of failed tests.

Note that the `runAll` method always prints its results to the console, in the following format:

    >> Test fixture name
    ...F..F.FF..
    >> Test fixture name 2
    .....F...F......FFFFF..

	Failed tests:
    [Test fixture name #TestIndex: TestName] Error message
	  Stack trace

Where `.` represents a test that succeeded and `F` is a failed test. When you compile the module with the unit tests, you should probably always compile it with debug symbols enabled (which is the default), to ensure the stack traces will contain the line numbers of the parts of the test that failed.