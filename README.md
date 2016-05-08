
# Xmap

*A JavaScript Map type that compares keys by value, not identity*

## Rationale 

Yesterday while reading [a random article on programming](https://www.reddit.com/r/javascript/comments/4hy2cc/what_is_this_and_is_it_worth_it/) about a [PHP-style crossover of a list and  
a hashmap](https://www.npmjs.com/package/hasharray) it suddenly occurred to me that **(1)** my
[Hollerith Codec](https://github.com/loveencounterflow/hollerith-codec) could be put to 
service to implement a hash mapp that compares entries by value (for which see below), and that
**(2)** the encoding could also be used to implement a sound generic ordering algorithm
that uses NodeJS `Buffer`s and works in memory instead of in LevelDB. The second point is 
pretty irrelevant to Xmap, so let's go on with the first point.

## Problem

JavaScript finally got proper hash maps (and proper sets) that accept not only primitive 
values (Booleans, numbers, strings) as keys, but lists (a.k.a. 'arrays' in JS-parlance) and,
actually, arbitrary `Object`s as keys. 

Here's how you'd traditionally do hash mapping in JS: you create a generic `Object`, most
of the time using bracket notation, and tack on your key / value pairs (N.B. all code samples
written in CoffeeScript):

```coffee
d = { x: 42, name: 'gnu', 'some-key': some_value, }  
```

This solution is good enough for a large class of applications, but it does have some serious
limitations; these limitations all originate in the fact that the hash-map-like behavior
of JS `Object`s is more of an serendipitous side-effect of the language's overall design 
than the result of a deliberate design decision: You get a value that has some prototypal 
members that stick around and may unexpectedly turn up in some kinds of iterations over
the keys and values; you don't get a way to determine how many members a given object has 
(short of collecting all lists in a list and looking at the list of that one); whether
or not insertion order is preserved and to what degree is somewhat contentious (the specs
saying little about this and JS engine vendors doing it ever so slightly differently).

Worst of all, JS plain objects only accept strings as keys; all other values will be 
transparently turned into strings when used as keys. That means when you want to associate
a value with a key that is, say, a number, a Boolean, or—God forbid—a list of values,
you will end up with a structure that looks more like this:

```coffee
d = {}
d[ 108                ] = 42
d[ true               ] = 'gnu'
d[ [ 'some', 'key', ] ] = some_value
console.log Object.keys d 
# >>> [ '108', 'true', 'some,key' ]
```

This even Just Works in a way: `d[ [ 'some', 'key', ] ]` will indeed return `some_value`
from the object—but so will, of course, `d[ 'some,key' ]`. In other words, you'll have
to closely monitor what exactly will go into this poor man's hash map or you'll end up
with nasty name clashes. Received wisdom has it that you shouldn't use anything but 
strings (and maybe integer numbers) as keys for objects; it's probably sound advice.

## Solution (Almost There)

So JS objects don't store anything but strings as keys—but JS has recently gotten 
*real* maps (and sets), right? So let's try that:

```coffee
d = new Map()
d.set 108,                42
d.set true,               'gnu'
d.set [ 'some', 'key', ], some_value
console.log Array.from d.keys() 
# >>> [ 108, true, [ 'some', 'key', ] ]
```

That's awesome! Those arbitrary keys do not converted into strings, which is great!
Now let's try to retrieve some values:

```coffee
console.log d.get 108
# >>> 42
console.log d.get true
# >>> 'gnu'
console.log d.get [ 'some', 'key', ]
# >>> undefined
```

Awww... that last one went wrong. Alas, JS never had an equality operator that worked for
complex values like Python has. Instead, JS has one broken equality operator `==` (not
recommended, ever, except to do `a == null` to check for `null` and `undefined` in a single
go) and one confusing mixed equality / object identity operator, `===`: this will check
for value equality when used with simple values like strings and numbers, but check for 
object identity for anything else—like in the above, where we used one list literal 
to `d.set` a key / value pair, and, crucially, *another* list literal to do `d.get`.

> Even more confusingly, what Python calls `==` and `is` is called `===` in JavaScript,
> whereas CoffeeScript uses both `==` and `is` for JS's `===`. 
> 
> There is, in fact, another way to look at the issue with `===`, and that is to assume that
> there is, in fact, only ever a single allocation for a given numerical or string value 
> stored within a single JavaScript VM at any point in time, such that comparing the 
> memory addresses for two given numbers or strings in fact will answer whether they're
> of equal value or not. JavaScript Arrays like `[ 8, ]` here and `[ 8, ]` there live
> independent lives and may be modified independently of each other, but primitive values
> like `8` and `foo` (which cannot be modified anway) do not: conceptually, an `8` is
> always the same (immutable) `8` as the next one, so using a single memory location to 
> store all the `8`s in a program makes sense. Keep in mind this is only a conceptualization,
> not a necessarily a truthful description of how things really work under the hood. 

## Solution (For Reals Now)

WHile comparing non-primitive values by identity instead of by equality is just what
you need sometimes, at other times you really want true (and deep) equality. In other words,
we want something along the lines of

```coffee
key_a = [ 'some', 123, [ 'nested', 'key', ], ] 
key_b = [ 'some', 123, [ 'nested', 'key', ], ] 
value = { some: 'value', }
d = new Map()
d.set key_a, value
### ... add key / value pairs to `d` ... ###
T.eq ( d.get key_a ), value
T.eq ( d.get key_a ), ( d.get key_b ) 
T.ok ( d.get key_a ) is value
T.ok ( d.get key_b ) is value
```

to hold for any reasonable / desirable equality test `T.eq` (or identity test, for that matter) test 
and truth test `T.ok` (think `assert.deepEquals` if you like to but [that specific test is 
broken](https://github.com/loveencounterflow/jseq)).

Turns out that going back to strings-as-keys is part of the solution.

In JavaScript, the easiest way to get a reasonable serialization for a wide range of
values is `JSON.stringify`. Indeed,

```coffee
key_a = [ 'some', 123, [ 'nested', 'key', ], ] 
key_b = [ 'some', 123, [ 'nested', 'key', ], ] 
value = { some: 'value', }
d = new Map()
d.set ( JSON.stringify key_a ), value
### ... add key / value pairs to `d` ... ###
T.eq ( d.get ( JSON.stringify key_a ) ), value
T.eq ( d.get ( JSON.stringify key_a ) ), ( d.get ( JSON.stringify key_b ) ) 
T.ok ( d.get ( JSON.stringify key_a ) ) is value
T.ok ( d.get ( JSON.stringify key_b ) ) is value
```

works. There are several minor drawbacks to this approach: **(1)** the API is not so nice,
so probably it would be good to hide all those `JSON.stringify` calls inside regular 
method calls; **(2)** `JSON.stringify` does not work properly with things like JS Date 
objects 


