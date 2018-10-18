# ChainIt
### Gain full control over what is going in your code!
[![Build Status](https://travis-ci.com/tier-tools/chainit.svg?branch=master)](https://travis-ci.com/tier-tools/chainit)

## What exactly is `ChainIt`?
It's the  Ruby implementation of a railway-oriented programming concept. <a href="https://fsharpforfunandprofit.com/rop">read more</a>

The gem makes it super easy to control complex operations flow - the next step will happen only if the previous one was successful.

Ideally suited for handling task sequences that should be  interrupted as soon as any subsequent task fails.

## Supported Ruby versions
`ChainIt` is currently tested to work well on MRI Ruby ~> 2.3.

## How should I use `ChainIt`?
As not hard to guess, all is about chaining subsequent `#chain` method calls to a `ChainIt` instance.

### Prerequisites
The gem supports design-by-contract programming concept assuming `ChainIt` will be used together with both `#value` and `#failure?` aware object that have to be returned by every `#chain`related block. It is used to consider the operation successful or failed.

We recommend using `Struct`:

```ruby
Result = Struct.new(:success, :value) do
  def failure?
    !success
  end
end

```
### Interface explanation
`#initialize` - Initiates the operation. Auto exception handling mode is configurable here. (see examples section)</br>
`#chain` - Performs the code in its related block and memorizes the internal result value. This is done only when the state of the operation allows it.</br>
`#skip_next` - Skips the next `#chain` call when it's block evaluates to `true`.</br>
`#result` - The result of the operation representing success of failure. </br>

### `ChainIt` modes
`auto_exception_handling` - default `false` - Decide if any `StandardError` exception should be rescued from any `#chain` call. If so the rescued exception will be memorized as operation result object.

### Examples </br>
#### Success path
```ruby
success = ->(value) { Result.new(true, value) }

ChainIt.new.
        chain { success.call 2 }.               
        chain { |num| success.call(num * 2) }.  # The operation result is passed as block argument if used.
        result.                                 #=> <struct Result success=true, value=4>
        value                                   #=> 4

```

#### Failure path
```ruby
failure = ->(value) { Result.new(false, value) }

ChainIt.new.
        chain { success.call 2 }.
        chain { failure.call 0 }.               # All later steps calls will be skipped.
        chain { success.call 4 }.
        result.                                 #=> <struct Result success=false, value=0>
        value                                   #=> 0
```
#### Working with `#skip_next`
```ruby
ChainIt.new.
        chain { success.call 2 }.               
        skip_next { |num| num == 2 }.           # The next chain will be skipped as the block evaluates to true.
        chain { success.call 8 }.              
        result.                                 #=> <struct Result success=true, value=2>
        value                                   #=> 2
```

#### With `auto_exception_handling` mode disabled
```ruby
ChainIt.new.
        chain { raise StandardError.new }.      #=> StandardError: StandardError                             
        result.                                 
        value
```

#### With `auto_exception_handling` mode enabled
```ruby
ChainIt.new(auto_exception_handling: true).
        chain { raise StandardError.new }.
        result.                                  #=> <StandardError: StandardError>
        value                                    #=> <StandardError: StandardError>
```

## Develop `ChainIt`
All the contributions are really welcome on GitHub at https://github.com/tier-tools/chainit according to the open-source spirit.

## `ChainIt` License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
