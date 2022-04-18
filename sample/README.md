# [simprokmachine](https://github.com/simprok-dev/simprokmachine-ios) sample

## Introduction

This sample is created to showcase the main features of the framework. 


It is hard to demonstrate the functionality of ```simprokmachine``` without an example as the concept behind it affects the way you design, plan and code your application.


The sample is divided into 14 easy steps demonstrating the flow of the app development and API usage.



## Disclaimer

This sample's main idea is to showcase classes, operators and how to use them. It is more about "how to do" instead of "what to do". 


Neither it guarantees that everything here could or should be used in a real life project nor it forces you into using any certain ideas. 


To see our recommended architecture check our [simprokcore framework](https://github.com/simprok-dev/simprokcore-ios).



## Step 0 - Describe application's behavior

Let's assume we want to create a counter app that shows a number on the screen and logcat each time it is incremented. 


When we reopen the app we want to see the same number. So the state must be saved in a persistent storage. 


## Step 1 - Describe application's logic containers

- ```UIViewController``` - rendering UI.
    - Input: String
    - Output: Void
- ```Logger``` - printing the number.
    - Input: String
    - Output: Void
- ```StorageReader``` - reading from ```UserDefautls```.
    - Input: Void
    - Output: Int
- ```StorageWriter``` - writing to ```UserDefaults```.
    - Input: Int
    - Output: Void
- ```Calculator``` - incrementing the number.
    - Input: Void
    - Output: Int


![Components](https://github.com/simprok-dev/simprokmachine-ios/blob/main/sample/images/components1.drawio.png)


## Step 2 - Describe data flows

Build a complete tree of all machines to visualize the connections.

![A tree](https://github.com/simprok-dev/simprokmachine-ios/blob/main/sample/images/components2.drawio.png)


Three instances that we haven't talked about are:
- ```UIWindow```
    - Input: String
    - Output: Void
- ```Display``` 
    - Input: AppEvent
    - Output: AppEvent
- ```Domain```
    - Input: AppEvent
    - Output: AppEvent


They are used as intermediate layers. 


```AppEvent``` is a custom type for communication between ```Domain``` and ```Display```.


## Step 3 - Code data types

We only need ```AppEvent``` as the rest is supported by Swift.

```Swift
enum AppEvent {
    case willChangeState
    case didChangeState(Int)
}
```

## Step 4 - Code Logger

```Swift
final class Logger<Output>: ChildMachine {
    typealias Input = String
    
    let queue: MachineQueue = .main
    
    func process(input: String?, callback: @escaping Handler<Output>) {
        print("\(input ?? "loading")")
    }
}
```

[ChildMachine](https://github.com/simprok-dev/simprokmachine-ios/wiki/ChildMachine) - is a container for your logic. It accepts input and handles it. When needed - emits output.

## Step 5 - Code MainViewController

Create ```MainViewController``` and extend it with ```ChildMachine``` protocol conformance.

```Swift
extension MainViewController: ChildMachine {
    typealias Input = String
    typealias Output = Void
    
    var queue: MachineQueue { .main }
    
    func process(input: String?, callback: @escaping Handler<Void>) {
        label.text = "\(input ?? "loading")"
        listener = { callback(Void()) }
    }
}
```

## Step 6 - Code UIWindow extension

Extend ```UIWindow``` with ```ParentMachine``` protocol conformance.

```Swift
extension UIWindow: ParentMachine {
    public typealias Input = String
    public typealias Output = Void
    
    public var child: Machine<Input, Output> {
        if let rootVC = rootViewController as? MainViewController {
            return rootVC.machine
        } else {
            fatalError("unexpected behavior") // we can return an empty machine here but for the example let's crash it
        }
    }
}

```

[ParentMachine](https://github.com/simprok-dev/simprokmachine-ios/wiki/ParentMachine) - is an intermediate layer for your data flow. It passes input from the parent to the child and vice versa for the output.

    
## Step 7 - Code Display 
    
Code ```Display``` class to connect ```Logger``` and ```UIWindow``` together.
    
```Swift
final class Display: ParentMachine {
    typealias Input = AppEvent
    typealias Output = AppEvent
    
    
    var child: Machine<AppEvent, AppEvent> {
        let window = UIApplication.shared.delegate!.window!!
            
        return Machine.merge(
                ~Logger(),
                window.outward { .set(.willChangeState) }
            ).inward { input in
                switch input {
                case .didChangeState(let val):
                    return .set("\(val)")
                case .willChangeState:
                    return .set()
                }
            }
    }
}
```


- [inward()](https://github.com/simprok-dev/simprokmachine-ios/wiki/MachineType#inward-operator) - maps parent input type into child input type or ignores it.
- [outward()](https://github.com/simprok-dev/simprokmachine-ios/wiki/MachineType#outward-operator) - maps child output type into parent output type or ignores it.
- [Machine.merge()](https://github.com/simprok-dev/simprokmachine-ios/wiki/MachineType#merge-with-varargs) - merges two or more machines into one.
    

    
## Step 8 - Code StorageReader, StorageWriter and Calculator.

```Swift
final class StorageReader: ChildMachine {
    typealias Input = Void
    typealias Output = Int
    
    var queue: MachineQueue { .main }
    
    func process(input: Input?, callback: @escaping Handler<Output>) {
        callback(
            UserDefaults.standard.integer(forKey: calculator_storage_name)
        )
    }
}
```


```Swift
final class StorageWriter<Output>: ChildMachine {
    typealias Input = Int
    
    var queue: MachineQueue { .main }
    
    func process(input: Int?, callback: @escaping Handler<Output>) {
        if let input = input {
            UserDefaults.standard.set(input, forKey: calculator_storage_name)
        }
    }
}
```


```Swift
final class Calculator: ChildMachine {
    typealias Input = Void
    typealias Output = Int
    
    private var state: Int
    
    init(initial: Int) {
        state = initial
    }
    
    var queue: MachineQueue { .main }
    
    func process(input: Input?, callback: @escaping Handler<Output>) {
        if input != nil {
            state += 1
        }
        callback(state)
    }
}
```

## Step 9 - Code Domain

Code a ```Domain``` class to connect ```StorageReader``` and ```Calculator```.


```Swift
final class Domain: ParentMachine {
    typealias Input = AppEvent
    typealias Output = AppEvent
    
    var child: Machine<AppEvent, AppEvent> {
        func calculator(_ initial: Int) -> Machine<DomainInput, DomainOutput> {
            Calculator(initial: initial).outward {
                .set(.fromCalculator($0))
            }.inward {
                switch $0 {
                case .fromParent:
                    return .set(Void())
                case .fromReader:
                    return .set()
                }
            }
        }
        
        let reader: Machine<DomainInput, DomainOutput> = StorageReader().outward { .set(.fromReader($0)) }.inward { _ in .set() }
        
        let connectable: Machine<DomainInput, DomainOutput> = ConnectableMachine(BasicConnection(reader)) { state, input in
            switch input {
            case .fromReader(let val):
                return .reduce(BasicConnection(calculator(val)))
            case .fromParent:
                return .inward
            }
        }.redirect { output in
            switch output {
            case .fromReader(let val):
                return .back(.fromReader(val))
            case .fromCalculator:
                return .prop
            }
        }
        
        return connectable.outward { output in
            switch output {
            case .fromReader:
                return .set()
            case .fromCalculator(let val):
                return .set(.didChangeState(val))
            }
        }.inward {
            switch $0 {
            case .didChangeState:
                return .set()
            case .willChangeState:
                return .set(.fromParent)
            }
        }
    }
}
```

Here we use two helper instances: ```DomainInput``` and ```DomainOutput```.

```Swift
enum DomainInput {
    case fromReader(Int)
    case fromParent
}
```

```Swift
enum DomainOutput {
    case fromReader(Int)
    case fromCalculator(Int)
}
```

[redirect()](https://github.com/simprok-dev/simprokmachine-ios/wiki/MachineType#redirect-operator) - depending on the output either passes it further to the root or sends an array of input data back to the child.
[ConnectableMachine](https://github.com/simprok-dev/simprokmachine-ios/wiki/ConnectableMachine) - dynamically creates and connects a set of machines.


## Step 10 - Update Display

Add ```StorageWriter``` next to the ```Logger``` and ```UIWindow``` in the ```Display``` class.

```Swift
final class Display: ParentMachine {
    typealias Input = AppEvent
    typealias Output = AppEvent
    
    
    var child: Machine<AppEvent, AppEvent> {
        ... // ignoring code
            
        return Machine.merge(
            StorageWriter().inward { input in
                switch input {
                case .willChangeState:
                    return .set()
                case .didChangeState(let val):
                    return .set(val)
                }
            },
            
            Machine.merge(
                ~Logger(),
                window.outward { .set(.willChangeState) }
            ).inward { input in
                switch input {
                case .didChangeState(let val):
                    return .set("\(val)")
                case .willChangeState:
                    return .set()
                }
            }
        )
    }
}

```

As ```StorageWriter```'s input is ```Int``` and not ```String``` we cannot merge it with the other classes. 


We apply ```inward()``` having ```Machine<AppEvent, AppEvent>``` as a result and only then merge it with the others.



## Step 11 - Code AppDelegate extension

Extend ```AppDelegate``` with ```RootMachine``` protocol conformance.  

```Swift
extension AppDelegate: RootMachine {
    typealias Input = AppEvent
    typealias Output = AppEvent

    var child: Machine<AppEvent, AppEvent> {
        .merge(
            ~Domain(),
            ~Display()
        ).redirect { .back($0) }
    }
}
```

[RootMachine](https://github.com/simprok-dev/simprokmachine-ios/wiki/RootMachine) - top-level entry of the application. Starts or stops the flow when needed.


## Step 12 - Run the flow!

Call a ```start()``` method of the ```RootMachine``` to trigger the flow. You can call ```stop()``` any time later to stop the flow.

```Swift

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
    window = UIWindow()
    window?.makeKeyAndVisible()
    window?.rootViewController = MainViewController()
        
    start()
        
    return true
}

```

## Step 13 - Enjoy yourself for a couple of minutes

Run the app and see how things are working.


![result](https://github.com/simprok-dev/simprokmachine-ios/blob/main/sample/images/results.gif)


## To sum up

- ```ChildMachine``` is a container for logic that handles input in a serial queue and may produce an output.  
- ```ParentMachine``` is a proxy/intermediate class used for comfortable logic separation and as a place to apply operators.
- ```RootMachine``` is a top-level machine that starts and stops the flow.
- ```inward()``` is an operator to map the parent's input type into the child's input type or ignore it.
- ```outward()``` is an operator to map the child's output type into the parent's output type or ignore it.
- ```redirect()``` is an operator to either pass the output further to the root or map it into an array of inputs and send back to the child.
- ```merge()``` is an operator to merge two or more machines of the same input and output types.
- ```ConnectableMachine``` is a machine that is used to dynamically create and connect other machines.


Refer to [wiki](https://github.com/simprok-dev/simprokmachine-ios/wiki) for more information.
