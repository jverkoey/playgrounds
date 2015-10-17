/*:

# Enumerating tuples

> *Cross-posted at [featherless software design](http://design.featherless.software/enumerating-swift-tuples/
)*.

Consider the following tuple:
*/

let fibonacci = (0, 1, 1, 2, 3, 5, 8, 13, 21, 34)

/*:
How might we iterate over the tuple's values? We might try a for-in loop:

    for val in fibonacci {
      val
    }
*/

// Paste the for-in loop here.

/*:
But tuples don't conform to SequenceType which the resulting error reiterates:

> *Type '(Int, Int, ..., Int)' does not conform to protocol 'SequenceType'*

So we might then try to enumerate using a subscript:

    fibonacci[0]
*/

// Paste the subscript here.

/*:
But tuples don't implement `subscript` so we're met with the following error:

> *Type '(Int, Int, ..., Int)' has no subscript members*

So how do we iterate over our tuple? The answer is provided by Swift's [Mirror] type.

## Tuple reflection

We create a Mirror by initializing it with the object we intend to reflect.

[Mirror]: https://developer.apple.com/library/ios/documentation/Swift/Reference/Swift_Mirror_Structure/index.html
*/

let mirror = Mirror(reflecting: fibonacci)

/*:
The resulting mirror object allows us to enumerate through the values of the object's children.
*/

for child in mirror.children {
  child.value
}

/*:
## Putting it all together

Rather than create a Mirror every time we want to enumerate a tuple, let's build a helper function that turns tuples into enumerable types.
*/

func generatorForTuple<T>(tuple: T) -> AnyGenerator<Any> {
  return anyGenerator(Mirror(reflecting: tuple).children.lazy.map { $0.value }.generate())
}

/*:
We take advantage of Swift's lazy map in order to lazily extract the `value` from each child.

We can now iterate over tuples like so:
*/

for value in generatorForTuple(fibonacci) {
  value
}
