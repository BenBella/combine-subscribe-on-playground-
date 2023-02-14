# Combine`s subscribe(on:options:) operator


## Documentation

Documentation: Specifies the scheduler on which to perform subscribe, cancel, and request operations. In contrast with **receive(on:options:)**, which affects downstream messages, **subscribe(on:options:)** changes the execution context of upstream messages.

## Messages that flow up a pipeline ("upstream") are:

- The actual performance of the subscription (receive subscription)
- Requests from a subscriber to the upstream publisher asking for a new value
- Cancel messages (these percolate upwards from the final subscriber)

## Messages that flow down a pipeline ("downstream") are:

- Values
- Completions, consisting of either a failure (error) or completion-in-good-order (reporting that the publisher emitted its last value)

## Control of the downstram thread

It is possible to control downstram thread with **receive(on:)** operator. If it is not used, it must be assumed nothing about the matter. Some publishers certainly do produce a value on a background thread, such as the data task publisher, which makes perfect sense (the same thing happens with a data task completion handler). Others don't.

What it can be assumed is that operators other than **receive(on:)** will not generally alter the value-passing thread. But whether and how an operator will use the subscription thread to determine the receive thread, that is something it should be assumed nothing about. To take control of the receive thread, take control of it! Call receive(on:) or assume nothing.

Just to give an example

```
Just("Some text")
    .receive(on: DispatchQueue.main)
```

then both **map** and **sink** will report that they are receiving values on the main thread. Why? Because you took control of the receive thread. This works regardless of what you may say in any **subscribe(on:)** commands. They are different matters entirely.

Maybe it cen be called **subscribe(on:)** but it doesn't call **receive(on:)**, some things about the downstream-sending thread are determined by the **subscribe(on:)** thread, but it sure wouldn't rely on there being any hard and fast rules about it, there's nothing saying that in the documentation! **Instead, don't do that**. If its implemented **subscribe(on:)**, then implement **receive(on:)** too so that it is obvious what happens.