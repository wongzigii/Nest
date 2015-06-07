==~~Nest is a library which makes Foundation and Swift works more seamlessly and offers some great missing helpers, utilities in Foundation.

#How to Get Started

##Install via Cocoa Pods

- `pod "Nest.swift"`
- Add `import Nest` to your Swift source file

##Manually Install

- Download or clone the project
- Drag Nest’s Xcode project file to your workspace
- Add Nest to your `Emebed Binaries` field in your target’s general page if you are building an app. Or add Nest to your `Linked Frameworks and Libraries` field in your target’s general page if you are building a framework.
- Add `import Nest` to your Swift source file
- You may need to add dependancies manually in the same way to your project file.
- Enjoy your journey of `Nest`

#Contents

##NSProtocolInterceptor

###Circumstance:
This class comes out of an answer I wrote on Stack Overflow: [Intercept Objective-C delegate messages within a subclass](http://stackoverflow.com/questions/3498158/intercept-objective-c-delegate-messages-within-a-subclass/18777565#18777565). But as the original code was written in Objective-C and Swift's code-level-safety makes it become impossible that assign an object of any type to a pointer, I rewrote it in Swift and added some additional code to make it work in Swift now.
 
###Introduction:
`NSProtocolInterceptor` is an object which masquerade itself as the protocol type(s) which you assigned at the initialization time, and intercepts message to the middle man if it could respond which originally intended to send to the receiver.

###Examples:

####Initialization
	
- NSProtocolInterceptor(aProtocol: `Protocol`)
	
- NSProtocolInterceptor(protocols: `[Protocol]`)
	
- NSProtocolInterceptor(protocols: `Protocol ...`)

####Intercept messages within a subclass
- MyScrollView.swift

````Swift
class MyScrollView: UIScrollView, UIScrollViewDelegate {
    let delegateInterceptor: NSProtocolInterceptor
   	
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if self.delegate?.respondsToSelector("scrollViewDidScroll:") == true {
            self.delegate?.scrollViewDidScroll?(scrollView)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        delegateInterceptor = NSProtocolInterceptor(aProtocol: UIScrollViewDelegate.self)
        super.init(coder: aDecoder)
        delegateInterceptor.middleMan = self
        super.delegate = delegateInterceptor as? UIScrollViewDelegate
    }
    
    override init(frame: CGRect) {
        delegateInterceptor = NSProtocolInterceptor(aProtocol: UIScrollViewDelegate.self)
        super.init(frame: frame)
        delegateInterceptor.middleMan = self
        super.delegate = delegateInterceptor as? UIScrollViewDelegate
    }
}
````

For UIKit bridging header claims `UIScrollView`'s `delegate` property as `unowned(unsafe)` and doesn't mark `UIScrollViewDelegate` up as a class only protocol, we cannot override the `delegate` property in Swift for now. So let's override it in Objective-C.

- MyScrollView+OverrideDelegate.h

````Objective-C
@import UIKit;

#import "ProductModuleName-Swift.h"

@interface MyScrollView (OverrideDelegate)
@end

````

- MyScrollView+OverrideDelegate.m

````Objective-C
@import Nest;

#import "MyScrollView+OverrideDelegate.h"

@implementation MyScrollView (OverrideDelegate)
- (id <UIScrollViewDelegate>)delegate {
    return (id <UIScrollViewDelegate>)self.delegateInterceptor.receiver;
}

- (void)setDelegate:(id <UIScrollViewDelegate>)delegate {
    super.delegate = nil;
    self.delegateInterceptor.receiver = delegate;
    super.delegate = (id <UIScrollViewDelegate>)self.delegateInterceptor;
}
@end

````

##NSReuseCenter & NSReusable

###Circumstance:
Reusing is an usual way to optimize a program's performance. This class it designed for making reusing simpler.

###Introduction:
`NSReuseCenter` offers an enqueue and dequeue mechanism for objects conform to the `NSReusable` protocol.

###Examples: 
####Initializations

````Swift
let theReuseCenter = NSReuseCenter<AParticularReusable>()
````

####Enqueue an unused object

````Swift
theReuseCenter.enqueueUnused(anUnusedObject)
````

####Dequeue a reusable object for a particular reuse identifier

````Swift
theReuseCenter.dequeueReusableWithReuseIdentifier(aReuseIdentifier)
````

####Query all reusable objects for a particular reuse identifier

````Swift
theReuseCenter.reusableForReuseIdentifier(aReuseIdentifier)
````

##Collection Functions

###Circumstance:
There might be a situation you had encountered before where you wanted to find an `NSObjectProtocol` conformed object in a protocol-constrained collection and Swift didn't suppose your `NSObjectProtocol` conformed object implements the `Equatable` protocol which made you unable to use the `find` function in Swift standard library. These collection of functions assume that any `NSObjectProtocol` conformed object has a clear understand on `isEqual:` function and use that function to evaluate equality between objects.

###Functions:
- **Check** an `NSObjectProtocol` conformed object is contained in a collection of `NSObjectProtocol` conformed objects.

	NSContains<`C` where `C`: `CollectionType`, `C.Generator.Element`: `NSObjectProtocol`>(domain: `C`, element: `C.Generator.Element`) -> `Bool`
	
- **Find** the index of an `NSObjectProtocol` conformed object in a collection of `NSObjectProtocol` conformed objects.

	NSFind<`C` : `CollectionType` where `C.Generator.Element`: `NSObjectProtocol`>(domain: `C`, value: `C.Generator.Element`) -> `C.Index?`
	
- **Calculate intersected** objects in two collections of `NSObjectProtocol` conformed objects.
	
	NSIntersected<`C` : `ExtensibleCollectionType` where `C.Generator.Element` : `NSObjectProtocol`>(collectionA: `C`, collectionB: `C`) -> `C`
	
- **Evaluate differences** between two collections of `NSObjectProtocol` conformed objects.

	NSDiff<`Seq`: `SequenceType` where `Seq.Generator.Element`: `NSObjectProtocol`>(from fromSequence: `Seq?`, to toSequence: `Seq?`, differences: `SequenceDifference`, unchangedComparator: `((Seq.Generator.Element, Seq.Generator.Element)->Bool)` = default, usingClosure changesHandler: `(change: SequenceDifference, fromElement: (index: Int, element: Seq.Generator.Element)?, toElement: (index: Int, element: Seq.Generator.Element)?) -> Void`)

- **Remove** an `NSObjectProtocol` conformed object in a collection of `NSObjectProtocol` conformed objects.
	
	NSRemove<`C` : `RangeReplaceableCollectionType` where `C.Generator.Element` : `NSObjectProtocol`, `C.Index`: `protocol<Comparable, BidirectionalIndexType>`> (inout collection: `C`, elements: `C`) -> `C`

##Runtime Functions

###Functions:

- **Check** if selector belongs to a protocol.
	
	sel_belongsToProtocol(aSelector: `Selector`, aProtocol: `Protocol`) -> `Bool`
	
- **Swizzle** a selector with an implementation on a class. The original implementation would be connected with a selector which consists of the given prefix and its original selector.
	
	class_swizzleClass(aClass: `AnyClass`, selector: `Selector`, withImplementation: `IMP`, selectorPrefix: `String`) -> `Bool`


##Conformity of NSDate to `Comparable`

###Circumstance:
I made NSDate conforms to `Comparable` to get avoid of comparing two `NSDate` objects by using its `compare:` function.

###Example:

````Swift
let now = NSDate()
let tenSecondsBefore = now.dateByAddingTimeInterval(-10)

if now > tenSecondsBefore {
	println("Now is later than ten seconds before")
}
````

##Search All Occurrence for Given String in NSString

###Circumstance:
Search all occurrence for given string in an `NSString` without using regular expression.

###Example:

####Search string in the whole string with the current locale

````Swift
let aString = "This is a string"
let aStringInNSString = aString as NSString

let occurrences = aStringInNSString.rangesOfString("s", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil)
````

##NSRangeMake

###Example:

````Swift
let anNSRange = NSRangeMake(location: 0, length: 10)
````

##NSError Initialization Conveniences for Using CoreData

###Example:

####Combine two errors
````Swift
let anError = NSError(error: anError, anotherError: anOtherError)
````

####Combine an error in a pointer with another error
````Swift
let anError = NSError(errorPointer:anErrorPointer, secondError: secondError)
````

####Combine an array of errors
````Swift
let anError = NSError(errors: errors)
````

#Dependancies

- [Swift Extended Library](https://github.com/WeZZard/Swift-Extended-Library)


