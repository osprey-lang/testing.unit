The module `testing.unit` is a tiny, extremely basic unit testing module for Osprey. It is extremely barebones at the moment, capable only of what is absolutely necessary for running a series of unit tests.

All members exported by this module are in the namespace `testing.unit`.

Unit tests are organised into test suites. Each test suite defines zero or more tests, which in turn may involve any number of test conditions (usually in the form of assertions).

## Defining a test suite

To define a test suite, you declare a class that derives from `testing.unit.TestSuite`, which is an abstract class. In order to be usable with `testing.unit`, your test suite class must define a public constructor that accepts zero arguments.

Then, you define your tests as methods on the test suite class. Every public instance method whose name begins with “`test_`” is part of the test suite, and like the constructor, must accept zero arguments. An example follows.

```
use namespace testing.unit;
public class MyTests is TestSuite
{
	public new()
	{
		// The TestSuite constructor accepts an optional display name,
		// which will help you identify the test suite.
		new base("Example tests");
	}

	public test_Construction()
	{
		// testing.unit.Assert is a helper class
		Assert.doesNotThrow(@= new MyClass());
		Assert.throws(typeof(ArgumentRangeError), @= new MyClass(-1));
		// etc.
	}

	public test_Equality()
	{
		// Manual throwing of AssertionError
		var a = new MyClass(1);
		var b = new MyClass(2);
		if a == b:
			throw new AssertionError("Different values should not equal each other.");
		// Alternatively:
		//Assert.areNotEqual(new MyClass(1), new MyClass(2));
	}

	// etc.
}
```

In the test methods, the part of the name following “`test_`” is displayed (without modification) if the test fails, but not otherwise. The return value of each test method, if any, is ignored.

## Running a test suite

The type `testing.unit.TestSuite` defines an instance method `run()`, which lets you run the test suite on demand. A second overload, `run(silent)`, lets you specify whether or not the test suite should print the results to the console. By default, it does.

Both overloads of `run` return a list of lists representing the tests that failed. Each inner list contains the following items (list index in parentheses):

* (0) The index of the test, zero-based. If `silent` is false, then this index corresponds to the index of the `.` or `F` that is printed.
* (1) The name of the test, which is the method name minus the “`test_`” prefix.
* (2) The uncaught error that caused the test to fail. This is usually a `testing.unit.AssertionError`, but this is not a guarantee.
* (3) The test suite object itself.

Using the `MyTests` class defined in the previous example, you would run it on demand like so:

```
var myTests = new MyTests();
var failedTests = myTests.run(); // Run and print to console
// Alternatively:
failedTests = myTests.run(true); // Run and don't print anything
```

## Running all test suites in a module

The class `testing.unit.TestSuite` also has a public static method `runAll`, which can be used to run all test suites in a module. The module is given as the first argument to `runAll`, and is an `aves.reflection.Module` instance. The `runAll` method will walk through all the types in the module, and for every type that inherits from `testing.unit.TestSuite`, try to create an instance of the type and run the tests in the suite.

Running a module full of test suites usually involves no more than this bit of code:

```
use namespace aves.reflection; // for Module
use namespace testing.unit;

// Or put this in your main method, if it is explicit
TestSuite.runAll(Module.getCurrentModule());
```

Unlike `run`, the `runAll` method does not return a list of failed tests.

Note that the `runAll` method always prints its results to the console, in the following format:

    >> Test suite name
    ...F..F.FF..
    >> Test suite name 2
    .....F...F......FFFFF..

	Failed tests:
    [Test suite name #TestIndex: TestName] Error message
	  Stack trace

Where `.` represents a test that succeeded and `F` is a failed test. You should probably always compile the module that contains the unit tests with debug symbols enabled (which is the default), to ensure the stack traces will contain the line numbers of the parts of the test that failed.