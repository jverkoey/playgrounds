/*:

# Hashable CFString

> *Cross-posted at [featherless software design](http://design.featherless.software/hashable-cfstring-in-swift/
)*.

If you find that you need to use a CFString in a Swift switch statement you'll likely run into the following cryptic error:

    Expression pattern of type 'CFString' cannot match values of type 'CFString'

or the slightly more helpful error when attempting to use a Set<CFString>:

    Type 'CFString' does not conform to protocol 'Hashable'

So let's make CFString [Hashable].

[Hashable]: http://swiftdoc.org/v2.0/protocol/Hashable/
*/

import CoreFoundation

extension CFString: Hashable {
  public var hashValue: Int { return Int(CFHash(self)) }
}

public func ==(lhs: CFString, rhs: CFString) -> Bool {
  return CFStringCompare(lhs, rhs, CFStringCompareFlags()) == .CompareEqualTo
}

/*:
We can now use CFStrings in switch statements:
*/

let someString = CFStringCreateWithCString(kCFAllocatorDefault, "foo", CFStringGetSystemEncoding())

let fooString = CFStringCreateWithCString(kCFAllocatorDefault, "foo", CFStringGetSystemEncoding())
let barString = CFStringCreateWithCString(kCFAllocatorDefault, "bar", CFStringGetSystemEncoding())

switch fooString {
case fooString:
  "Is foo"
case barString:
  "Is bar"
default:
  "Unknown"
}

/*:
And sets:
*/

let stringSet = Set(arrayLiteral: someString, fooString)

stringSet.contains(fooString)
stringSet.contains(barString)

/*:
- We take advantage of [CFHash] to implement the hashValue.
- The `==` operator is a simple mapping to [CFStringCompare].

[CFHash]: https://developer.apple.com/library/prerelease/ios/documentation/CoreFoundation/Reference/CFTypeRef/index.html#//apple_ref/c/func/CFHash
[CFStringCompare]: https://developer.apple.com/library/mac/documentation/CoreFoundation/Reference/CFStringRef/#//apple_ref/c/func/CFStringCompare

[Previous playground](@previous)

*/
