The module `testing.unit` is a tiny and basic unit testing module for Osprey. It is extremely barebones at the moment, capable only of what is absolutely necessary for running a series of unit tests.

All members exported by this module are in the namespace `testing.unit`.

Unit tests are organised into test fixtures. Each test fixture defines zero or more tests cases, which are methods that may involve any number of test conditions, usually in the form of assertions.

## Defining a test fixture

To define a test fixture, declare a class that derives from the abstract class `testing.unit.TestFixture`. In order to be usable with `testing.unit`, your test fixture class must define a public constructor that accepts zero arguments.

Then, define your tests as methods on the test fixture class. Every public instance method whose name begins with “`test_`” is part of the test fixture, and like the constructor, must accept zero arguments. An example follows.

```
use aves.*;
use testing.unit.*;

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
    var myClass = new MyClass();
    // testing.unit.Assert is a helper class
    Assert.areEqual(myClass.value, 0);
    // etc.
  }

  public test_ConstructionWithOneArgument()
  {
    var value = 123;
    var myClass = new MyClass(value);
    Assert.areEqual(myClass.value, value);
  }

  public test_ConstructionWithNegativeArgument()
  {
    Assert.throws(typeof(ArgumentRangeError), @=> new MyClass(-1));
  }

  public test_Equality()
  {
    // Assertion errors can be thrown explicitly:
    var x = new MyClass(1);
    var y = new MyClass(1);
    if x != y {
      throw new AssertionError("MyClass with same value should equal each other.");
    }

    // Usually better:
    Assert.areEqual(x, y, "MyClass with same value should equal each other.");
  }

  // etc.
}
```

The part of the test method name following “`test_`” is displayed (without modification) if the test fails, but not otherwise. The return value of each test method, if any, is ignored.

## Running all test fixtures in a module

The class `testing.unit.TestFixture` also has a public static method `runAll`, which can be used to run all test fixtures in a module. The module is given as the first argument to `runAll`, and is an `aves.reflection.Module` instance. The `runAll` method will walk through all the types in the module, and for every type that inherits from `testing.unit.TestFixture`, try to create an instance of the type and run the tests in the fixture.

Running a module full of test fixtures usually involves no more than this bit of code:

```
use aves.reflection.Module;
use testing.unit.TestFixture;

TestFixture.runAll(Module.getCurrentModule());
```

If you have an explicit main method, put the call to `runAll` there instead.

Note that the `runAll` method always prints its results to the console, in the following format:

    >> Test fixture name
    ...F..F.FF..
    >> Test fixture name 2
    .....F...F......FFFFF..

    [Test fixture name: TestName] Failed test error message
      Stack trace

Where `.` represents a test that succeeded and `F` is a failed test. When you compile the unit test module, you should probably always compile it with debug symbols enabled (which is the default), to ensure the stack traces will contain the line numbers of the parts of the test that failed.

## Running test fixtures explicitly

If you don't want to just run all the tests in a module for any reason, you can use the type `testing.unit.TestRunner` to run tests manually. It has three methods for running unit tests:

* `run`: Takes a single `TestFixture`, or an `aves.reflection.Type` that refers to a type that inherits from `TestFixture`. It runs all the test methods in that test fixture.
* `runAll`: Takes any number of test fixtures, as described above, and runs all the test methods in all of them.
* `runAllInModule`: Takes an `aves.reflection.Module` and runs all the test methods of all the test fixture types in it.

All three methods return a list of `testing.unit.TestResult` instances, which contain information about each individual test method that was run.

Once you have your list of `TestResult` values, you can print them to the console using the `testing.unit.TestResultPrinter` and its `printResults` method. This class contains a variety of configurable options; consult the class documentation for more information.

Using the `MyClassTests` class defined in the previous example, you would run it on demand like so:

```
var testRunner = new TestRunner();
var myClassTests = new MyClassTests();
var results = testRunner.run(myClassTests);
// Alternatively:
results = testRunner.run(typeof(MyClassTests));
```

And print the results to the console like so:

```
var resultPrinter = new TestResultPrinter();
resultPrinter.printResults(results);
```
