/*:

# Swift Dictionary: get with default

> *Cross-posted at [featherless software design](http://design.featherless.software/swift-dictionary-get-with-default/)*.

Let's build a Dictionary extension that fills in empty keys with "default" values when accessed. This extension will replace the following logic:

    if dictionary[key] == nil {
      dictionary[key] = DefaultValue()
    }
    let value = dictionary[key]!

with something that can be expressed in a single line.

## An implementation

Presented below is an extension of Dictionary that defines the mutating func `get`. Because we're always going to return *something*, we can make this `get` function return a non-optional `Value` type.
*/

extension Dictionary {
  mutating func get(key: Key, @autoclosure withDefault value: Void -> Value) -> Value {
    if self[key] == nil {
      self[key] = value()
    }
    return self[key]!
  }
}

/*:
Some interesting things going on here:

- `value` is a closure so that we may lazily evaluate the parameter.
- `value` is also an [@autoclosure]. Autoclosures are a powerful language feature that implicitly turns arguments into closures. For example, rather than writing 

  `fn({SomeObject()})`

  you write

  `fn(SomeObject())`

  and `SomeObject()` will be implicitly wrapped in a closure for evaluation by the function at a later point. Use this feature sparingly and with great care.

Now we can write the following:

[@autoclosure]: https://developer.apple.com/swift/blog/?id=4
*/

struct Device {
  func addObserver() -> String { return "added observer" }
}

var dictionary: [String: Device] = [:]
dictionary.get("foo", withDefault: Device()).addObserver()

/*:
## Array values can't be modified

Consider the following:

*/

var stringDictionary: [String:[String]] = [:]
//stringDictionary.get("foo", withDefault: []).append("bar")

/*:
Uncomment the code above and you'll get the following error:

    Cannot use mutating member on immutable value: function call
    returns immutable value

If we ignore what it's saying and try to get it to compile, we might change the code to:
*/

var strings = stringDictionary.get("foo", withDefault: [])
strings.append("bar")

/*:
But check out what happens when we print out `stringDictionary`:
*/

stringDictionary

/*:
Our default array was stored, but "bar" isn't in it!

Why? **Arrays returned by functions in Swift 2 are copies**, so any modifications made to the return value will not be reflected in the dictionary's value.

So why, then, does the following code work?
*/

stringDictionary["foo"] = []
stringDictionary["foo"]?.append("bar")
stringDictionary

/*:
After all, we're using Dictionary's subscript function &mdash; isn't it copying the returned array which should result in the same behavior as our `get` function?

Interestingly enough: **it is returning a copy!** But there's some magic going on when we execute `dictionary[key]?.append("bar")`:

1. `dictionary`'s subscript `get` is called and the corresponding value is returned.
2. `.append("bar")` is then invoked on the returned value. The copy of the array that was returned now contains "bar".
3. And here's the interesting part: **subscript `set` is called with the modified array.**

These three steps give the illusion that we're modifying the array in-place. Note that, without step 3, the dictionary won't end up storing the modified array:
*/

stringDictionary["foo"] = []
var array = stringDictionary["foo"]! // 1.
array.append("bar")            // 2.
stringDictionary["foo"] = array   // 3. try commenting this out
stringDictionary

/*:
## A better solution

Armed with a better understanding of how in-place dictionary modifications work we can revisit our original implementation.

We'll use `subscript` because it allows for inline get/set semantics. But how do we provide a default value?

Tucked away in the [Swift 2 Subscripts documentation](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Subscripts.html#//apple_ref/doc/uid/TP40014097-CH16-ID308) is our answer:

> *Subscripts are not limited to a single dimension, and you can define subscripts with multiple input parameters to suit your custom type’s needs.*

So let's rewrite our method using `subscript`:
*/

extension Dictionary {
  subscript(key: Key, @autoclosure withDefault value: Void -> Value) -> Value {
    mutating get {
      if self[key] == nil {
        self[key] = value()
      }
      return self[key]!
    }
    set {
      self[key] = newValue
    }
  }
}

/*:
- `get` must be marked `mutating` in order to modify self.
- `set` must be implemented in order to support inline value modifications.

And this is how you use it:
*/

stringDictionary["foo", withDefault: []].append("bar")

/*:
Much better!

## Final notes

I learned how subscript in-place modifications work by doing the following:

1. Created a new Playground.
2. Wrote a simple class with a subscript get/set implementation.
3. Added print statements to the get/set.
4. Wrote a simple example of what I wanted to achieve.
*/

class Foo {
  var array: [String] = []
  subscript(name: String) -> [String] {
    get {
      print("get")
      return array
    }
    set {
      print("set")
      array = newValue
    }
  }
}

let f = Foo()
f["foo"].append("bar")

/*:
Much to my surprise, observing the logs revealed:

    get
    set

- A drawback to the subscript solution is that autocomplete will not help.
- [View the final implementation](https://gist.github.com/jverkoey/0b993932ddc9bd69120d).

[Next playground](@next)
*/
