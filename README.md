# simprokmachine


## Introduction

Every application consists of the classes that refer to the other classes which refer to the other classes etc. It is a tree of classes where each one knows about its children and doesn't know about its parent.

In general, classes communicate with each other by calling methods and properties of their children to pass data "down" or by triggering a callback passing data "up" to the parent.

Moreover, we have many patterns to make this communication easier such as delegate, facade, observable, command, etc.

## Problem

Every time the communication must be organized it is up to us to decide which pattern to use, and how to handle it. This requires attention and can easily result in unexpected bugs.

## Solution

```simprokmachine``` is a framework that automates the communication between the application's components called "machines".

## How to use

Machine - is an instance in your application that receives and processes input data and may emit output. It never exists on its own but rather combined with a root machine instance.

![concept](https://github.com/simprok-dev/simprokmachine-ios/blob/main/images/simprokmachine.drawio.png)

To create it use ```ChildMachine``` protocol.

```Swift
final class PrinterMachine: ChildMachine {
    typealias Input = String
    typealias Output = Void
    
    var queue: MachineQueue { .main } // defines dispatch queue on which process() method works 
    
    func process(input: String?, callback: @escaping Handler<Void>) {
        print(input)
    }
}
```

To start the flow use ```RootMachine``` protocol in your top-level class.

```Swift
extension AppDelegate: RootMachine {
    typealias Input = String
    typealias Output = Void
    
    var child: Machine<String, Void> {
        ~PrinterMachine() // or PrinterMachine().machine or Machine(PrinterMachine())
    }
}
```

and don't forget to call ```start()``` to trigger the flow.

```Swift
func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
    start()
    return true
}
```

This does not print anything but ```nil``` because after ```start()``` is called the root is subscribed to the child machine triggering ```process()``` method with ```nil``` value.

Use ```callback: Handler<Output>``` to emit output. 

```Swift
final class EmittingMachine: ChildMachine {
    typealias Input = String
    typealias Output = Void
    
    var queue: MachineQueue { .main } 
    
    func process(input: String?, callback: @escaping Handler<Void>) {
        if let input = input { 
            print("input: \(input)")
        } else {
            callback(Void()) // Emits output
        }
    }
}
```

Standard implementations of ```ChildMachine``` are ```BasicMachine``` and ```WeakMachine```.

```Swift
... = BasicMachine<Int, Void> { (input: Int?, callback: @escaping Handler<Void>) in
    // handle input here
    // emit output if needed
}
```

and

```Swift
... = WeakMachine<Int, Void>(self) { weaklyReferencedSelf, input, callback in 
    // handle input here
    // emit output if needed
}
```


To separate machines into classes instead of cluttering them up in the root - use ```ParentMachine``` protocol.

```Swift
final class IntermediateLayer: ParentMachine {
    typealias Input = String
    typealias Output = Void
    
    var child: Machine<String, Void> {
        ~PrinterMachine() 
    }
}
```

To map or ignore input - use ```inward()```.

```Swift
... = machine.inward { (parentInput: ParentInput) -> Ward<ChildInput> in 
    return Ward.set(ChildInput(), ChildInput()) // pass zero, one or more inputs.
}
```

To map or ignore output - use ```outward()```. 


```Swift
... = machine.outward { (childOutput: ChildOutput) -> Ward<ParentOutput> in 
    return Ward.set(ParentOutput(), ParentOutput()) // pass zero, one or more outputs.
}
```

To send input back to the child when output received - use ```redirect()```.

```Swift
... = machine.redirect { (childOutput: ChildOutput) -> Direction<ChildInput> in 
    // Direction.prop - for pushing ChildOutput further to the root.
    // Direction.back([ChildInput]) - for sending child inputs back to the child.
    ...
}
```

To merge more than 1 machine together - use ```merge()```.

```Swift

let machine1: Machine<Input, Output> = ...
let machine2: Machine<Input, Output> = ...

... = Machine.merge(
    machine1,
    machine2
)
```

To dynamically create and connect machines when new input received - use ```ConnectableMachine```.

```Swift
... = ConnectableMachine<Int, Void>(
    BasicConnection<Int, Void>(MyMachine1(), MyMachine2())
) { (state: BasicConnection<Int, Void>, input: Int) -> ConnectionType<BasicConnection<Int, Void>> in
    // Return 
    // ConnectionType.reduce(BasicConnection<Int, Void>) - when new machines have to be connected.
    // ConnectionType.inward - when existing machines have to receive input: Int
    ...
}
```

Check out the [sample](https://github.com/simprok-dev/simprokmachine-ios/tree/main/sample) and the [wiki](https://github.com/simprok-dev/simprokmachine-ios/wiki) for more information about API and how to use it.


## Killer-features

- Declarative way of describing your application's behavior.
- Automated concurrency management saves from race conditions, deadlocks, and headache.
- Flexible. Every existing component can become a machine.
- Modular. Every machine can be described once and reused easily.
- Cross-platform. [Kotlin](https://github.com/simprok-dev/simprokmachine-kotlin) and [Flutter](https://github.com/simprok-dev/simprokmachine-flutter) supported.


## Installation

As for now, ```Swift Package Manager``` is the only option to use for adding the framework to your project. 
Once you have your Swift package set up, adding ```simprokmachine``` as a dependency is as easy as adding it to the dependencies value of your Package.swift.

```
dependencies: [
    .package(url: "https://github.com/simprok-dev/simprokmachine-ios.git", .upToNextMajor(from: "1.1.1"))
]
```

## What to check next

Check out these [tools](https://github.com/simprok-dev/simproktools-ios) to see an existing library of useful machines and the [architectural approach](https://github.com/simprok-dev/simprokcore-ios) we suggest using.
