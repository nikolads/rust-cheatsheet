# Quick introduction to the Rust programming language

This document is meant to be a jump start for people that are not familiar with the Rust programming language. It covers the basic syntax and features of Rust and provides comparison with C++. After learning the basic syntax you should be able to read most Rust code and at least get an intuitive understanding of the program logic, even if not everything is clear. Hopefuly then you can decide if you are interested in the language.

### Other materials

Documentation:
- <https://doc.rust-lang.org/std> - Rust standard library docs
- <https://docs.rs/> - Third party library docs

Learning:
- <https://doc.rust-lang.org/book/> - "The Rust Programming Language" - the official book. Starts a bit slow, but if you want to learn the language this is probably the best thing.
- <https://doc.rust-lang.org/stable/rust-by-example/> - Official interactive tutorial. Quicker introduction, but not as in depth as the book.

Blogs and other:
- <https://cheats.rs/> - Cheatsheet with all the Rust syntax and some other things
- <https://github.com/nrc/r4cppp> - Rust tutorial aimed at C++ programmers
- <https://fasterthanli.me/articles/a-half-hour-to-learn-rust> - Another 30 minutes tutorial


## TOC

- [Types](#types)
- [Syntax](#syntax)
- [Data types](#data-types)
- [Iteration](#iteration)
- [Error handling](#error-handling)
- [Lifetimes](#lifetimes)
- [Borrow rules](#borrow-rules)


## Types

### Fundamental types

| C++ type                          | Rust type         | Notes                                              |
| --------------------------------- | ----------------  | -------------------------------------------------- |
| `void`                            | `()`              | not exactly - see bellow                           |
| `int`, `unsigned`                 | `i32`, `u32`      | also `i8`, `i16`, `i64`, etc                       |
| `ssize_t`, `size_t`               | `isize`, `usize`  |                                                    |
| `float`, `double`                 | `f32`, `f64`      |                                                    |
| `char32_t`                        | `char`            | Unicode code point                                 |
| `char`                            | `u8`              | byte                                               |
| `const char*`, `std::string_view` | `&str`            | string slice - ptr + len                           |
| `std::string`                     | `String`          |                                                    |
| `std::span` (c++20)               | `&[T]`, `&mut[T]` | array slice - ptr + len                            |
| `T[N]`, `std::array<T, N>`        | `[T; N]`          |                                                    |
| `std::vector<T>`                  | `Vec<T>`          |                                                    |
| `std::tuple<A, B, C>`             | `(A, B, C)`       | field access with `.0`, `.1`, ... or destructuring |
| `*const T`, `const T&`            | `&T`              | non-null and always valid                          |
| `*T`, `T&`                        | `&mut T`          | non-null and always valid                          |

* the type `()` (called "unit") is usually used similarily to `void` in C++ - as the return type of functions that don't return anything. However there is a small difference:
    * `void` in C++ is not a type, it is a special syntax to denote "lack of value".
    * `()` is Rust is a proper type with a single possible value - `()`. It is a zero-sized type. As it is an ordinary type you can assign it to a variable, or, more importantly, use it as a type parameter in a generic function or struct

### Common containers

| C++ type                                  | Rust type                       | Notes                                                                  |
| ----------------------------------------- | ------------------------------- | ---------------------------------------------------------------------- |
| `vector<T>`                               | `Vec<T>`                        |                                                                        |
| `deque<T>`                                | `VecDeque<T>`                   |                                                                        |
| `stack<T>`                                | -                               | use a `Vec<T>` instead                                                 |
| `queue<T>`                                | -                               | use a `VecDeque<T>` instead                                            |
| `map<K, V>`, `set<T>`                     | `BTreeMap<K, V>`, `BTteeSet<T>` | uses a B-tree instead of a binary tree                                 |
| `unordered_map<K, V>`, `unordered_set<T>` | `HashMap<K, V>`, `HashSet<T>`   | uses a flat table algorithm (<https://github.com/rust-lang/hashbrown>) |

### Smart pointers

| C++ type              | Rust type              | Notes                                                                                       |
| --------------------- | ---------------------- | ------------------------------------------------------------------------------------------- |
| `unique_ptr<T>`       | `Box<T>`               | always non-null                                                                             |
| `unique_ptr<T>`       | `Option<Box<T>>`       | box or null                                                                                 |
| `shared_ptr<const T>` | `Arc<T>`               | atomic reference counter; always non-null; stored value is immutable                        |
| `shared_ptr<const T>` | `arc_swap::ArcSwap<T>` | from third-party library; like `Arc`, but allows atomically changing the underlying pointer |
| `shared_ptr<const T>` | `Rc<T>`                | single-thread only version of `Arc`                                                         |

* Rust doesn't allow both sharing and mutating a value (see [borrow rules](#borrow-rules)).
* Because `Rc` and `Arc` allow shearing, they disallow mutation - unless we can prove we are the only ones currently accessing the value (again see [borrow rules](#borrow-rules)).


## Syntax

### Variables

```rust
// Variable declaration. Type can be omitted if it can be inferred from the surrounding code.
let x = 12;
let mut y = 23;

// Type can also be specified explicitly
let x: i32 = 12;

// Assignment performs a move operation. Every type is move-able.
// Moves are just a `memcpy` of the struct and cannot be overridden by the user.
// Old variable cannot be accessed after it has been moved from.
let str1 = "hello".to_string();
let str2 = str1;         // `str1` is moved here
// println!("{}", str1); // compilation error - use of moved value

// Copies are explicit with `.clone()`
// (except on primitives like numbers where a copy is the same as a move)
let str1 = "hello".to_string();
let str2 = str1.clone();

// `let` can destructure values via pattern matching.
// If we don't want to bind some part to a variable, `_` can be used as a placeholder
let (a, _) = (12, 23);
```

### Literals

```rust
let x = 10_234_567;     // '_' can be used as separator in numbers
let y = 10_234_567_u64; // explicit integer type with `u64` suffix

let arr = [1, 2, 3, 4];     // fixed array `[i32; 4]`
let slice = &[1, 2, 3, 4];  // reference to array `&[i32; 4]`
                            // will implicitly cast to array slice `&[i32]` if needed
let vec = vec![1, 2, 3, 4]; // vector `Vec<i32>`; `vec!` is a macro

let arr = ['a'; 4];     // `[char; 4]` - array of 4 elements each with the value 'a'
let vec = vec!['a'; 4]; // vector `Vec<char>` with 4 elements each with value 'a'

let ivan = Person { name: String::from("Ivan"), email: String::from("ivan@abv.bg") };
{
    let name = String::from("Ivan");
    let email = String::from("ivan@abv.bg");
    let ivan = Persion { name, email }; // shorthand if field name mathes variable name
}
```

### Strings

```rust
// Rust strings (`&str`, `String`) are always valid utf8 and are not null terminated.
// If you need to work with a string that may not be utf8 you should use byte arrays
// instead (`&[u8]`, `Vec<u8>`).

let s1: &str  = "...";  // string literal
let c1: char  = 'x';    // character literal
let s2: &[u8] = b"..."; // ASCII byte string literal
let c2: u8    = b'x';   // ASCII byte literal
```

### Control flow

```rust
// standard `if` statement
// no brackets around condition, brackets around body are mandatory
if x < 10 {
    println!("less than 10");
} else {
    println!("10 or more");
}

// `if` is an expression, i.e. it has a value and can be assigned to a variable.
// There is no ternary operator `?` - an if-else expression is used instead.
let result = if x < 10 { "less than 10" } else { "10 or more" };

// `match` is like `switch` but much more powerful.
// Can be used with any type. Allows pattern matching (which is needed for unpacking enums)
// Match arms are tried from top to bottom, the first that matches is executed.
match x {
    0 => println!("x is zero"),
    10 => println!("x is ten");
    _ => println!("x is other");
}

// `match` is also an expression
let x = match val { ... };

// a block is also an expression
// the last expression in a block is the value of the block
let x = { let sum = 1 + 2; sum };
```

### Functions

```rust
// The last expression in a function is the value of that functions (no `return` required)
fn add(a: i32, b: i32) -> i32 {
    a + b
}

// Closures
|arg1, arg2| expr      // basic syntax
|arg1, arg2| { block } // a block is an expression
|| expr                // closure with no arguments
|| { block }           // closure with no arguments

// Variables are captured by reference. Captured variables are determined from the body
let good_numbers = vec![1, 3, 5];
let is_good = |x| good_numbers.contains(&x); // `is_good` holds a reference to `good_numbers`

// Move closures - same, but variables are captured by value
let good_numbers = vec![1, 3, 5];
let is_good = move |x| good_numbers.contains(&x); // vector `good_numbers` is moved into `is_good`

// Things that end in '!' are macros, not functions. They expand to some rust code.
println!("Hello {}", name);
```

### Generic functions

```rust
// Generic functions declared with `<>` after the name
fn size_of<T>() { /* ... */ }

// When used in an expression, generic arguments are usually inferred.
// If they can't be, they are specified via turbofish `::<>`
let size = std::mem::size_of::<i32>();

// Only the ambiguous types or part of types need to be specified.
// If something is set to `_`, it is filled with the type inference algorithm.
//
// Ex: we need to specify the collection for `collect` - it could be `Vec`, `HashSet`, etc.
// We don't need to specify the item in the collection - it is known to be `i32` from the iterator.
let vec = [1, 2, 3].iter().collect::<Vec<_>>();
```


## Data types

### Structs

```rust
// A struct definition - only fields, no methods
struct SomeStruct {
    field1: u32,
    field2: SomeOtherStruct,
}

// Methods are written separately in an `impl` block
impl SomeStruct {
    // An associated function ("static method" in c++).
    // Called as `SomeStruct::new()`.
    //
    // There is no formal concept of constructor, this is just a regular funciton
    // which creates an instance of the struct.
    //
    // `Self` is a type alias for the type of the impl block.
    // In this case `Self` = `SomeStruct`.
    pub fn new() -> Self {
        SomeStruct {
            field1: 0,
            field2: SomeOtherStruct::new(),
        }
    }

    // Methods take as a first argument one of:
    // `self` - meaning argument named `self` of type `Self`
    // `&self` - meaning argument named `self` of type `&Self`
    // `&mut self` - meaning argument named `self` of type `&mut Self`
    //
    // Also it is valid to have field and method of the same name - it is actually
    // not ambiguous when which one is used.
    pub field1(&self) -> u32 {
        self.field1
    }
}

// Structs without fields
struct NoFieldsV1 {}
struct NoFieldsV2;

// Tuple struct - like a named tuple
struct Color(f32, f32, f32);
```

### Enums

```rust
// C-style enum
enum MyEnum {
    Foo,
    Bar,
}

// Variants can also contain data
// This is like a tagged union or `std::variant<...>`
enum MyEnum {
    Variant1,
    Variant2(String),
    Variant3 { x: u32, y: u32 },
}
```

### Destructuring

Destructuring allows you to unpack an object (struct, tuple, array) into individual variables.
It is done either with `let` or with `match`/`if let`/`while let`.
See here for examples: <https://github.com/nrc/r4cppp/blob/master/destructuring.md>

### Traits

Rust is not an OOP language and there is no inheritance. Traits are the mechanism for expressing interfaces.

```rust
// trait declaration
trait ToJson {
    // required method
    fn to_json(&self) -> String;

    // provided method, but can be overridden
    fn write_json(&self, buffer: &mut String) {
        buffer.push_str(&self.to_json());
    }
}

// implementing the trait for a type
impl ToJson for String {
    fn to_json(&self) -> String {
        format!("\"{:?}\"", escape(self));
    }
}
```

Generic functions must be valid for any possible type parameter `T`. So if they want to use some functionality they must restrict the types they can be called with to only types which implement that functionality. This is done with trait bounds like `T: SomeTrait` (a bit like C++ concepts).

```rust
// must add trait bound on `Debug` to be able to print it with the "{:?}" placeholder
fn print_val<T: std::fmt::Debug>(val: T) {
    println!("{:?}", val);
}

// equivalent to the above - just different syntax
fn print_val<T>(val: T)
where
    T: std::fmt::Debug
{
    println!("{:?}", val);
}
```

Type erasure and dynamic dispatch is also based on traits.

- you can convert `&T` to `&dyn SomeTrait`, which is a type of fat pointer and contains:
  - ptr to the original object
  - ptr to the vtable for `SomeTrait`
- similarily you can convert `Box<T>` to `Box<dyn SomeTrait>`

```rust
fn print_val(val: &dyn std::fmt::Debug) {
    println!("{:?}", val);
}
```


## Iteration

Iterators in Rust are a struct implementing the trait `Iterator`. They have a method `next(&mut self) -> Option<T>` which returns the next element (or `None`) and advances the internal state of the iterator. Thus they can be used only for a single forward pass. This is very different from C++, where iterators are more like a pointer or a possition inside a container.

Iterators have many methods defined on them common for functional programming - ex `map`, `filter`, `zip`. Those methods all return another iterator which wraps the current iterator - an iterator adaptor. (In this regard they act like lazily evaluated lists). Iterators also have some finalizer methods, which consume the iterator and return a single value - ex. `fold`, `collect`.

```rust
// standard simple loops
while cond { /* code */ }
loop { /* code */ }         // same as `while true`

// `for` loops use iterators
// there are usually three ways to iterate a collection:
// - `collection.iter()`      or `&collection`     - iterate over const references to elements
// - `collection.iter_mut()`  or `&mut collection` - iterate over mut references to elements
// - `collection.into_iter()` or `collection`      - consume collection and iterate over values
for item in collection.iter() { /* code */ }
for item in &collection { /* code */ }

// to iterate from 0 to n use ranges
for i in 0..n { /* code */ }

// iterator methods are usually prefered over `if`s and `break`/`continue`
for (index, elem) in collection.iter()
    .enumerate()
    .filter(|(_, elem)| is_odd(elem))
{
}
```


## Error handling

There are no exceptions. Instead errors are encoded in the return value of the function via the `Option` or `Result` types.

### Types

```rust
enum Option<T> {
    Some(T),
    None,
}

enum Result<T, E> {
    Ok(T),
    Err(E),
}
```

### Operator `?`

Used for propagating errors from a function with a `Result<T, E>` return type to the caller.
If the error types are different, some traits need to be implemented to specify the conversion.

```rust
fn something() -> Result<MyVal, MyErr> {
    let result = /*...*/;

    // both are equivalent
    // ================
    let x = result?;
    // ================
    let x = match result {
        Ok(val) => val,
        Err(e) => return Err(e.into())
    };
    // ================

    Ok(make_my_val(x))
}
```

Can also be used for propagating a `None` value from a function with `Option<T>` return type.

```rust
fn something() -> Option<MyVal> {
    let option = /*...*/;

    // both are equivalent
    // ================
    let x = option?;
    // ================
    let x = match option {
        Some(val) => val,
        None => return None,
    };
    // ================

    Some(make_my_val(x))
}
```

Panicing is used for situations which are programmer mistakes and should have never happened and it doesn't make sense to try and recover from them. Usually it is done with the `panic!` or `assert!` macros or by the methods `Option::unwrap()` or `Result::unwrap()`. Panics either kill the program or are handled on very coarse boundaries.


## Lifetimes

References must always be valid and this is enforced at compile time. To do that the compiler tracks object lifetimes. Usually that is invisible, but in some cases special lifetime annotations (like the `'a` in `&'a i32`) must be added.

All references have a lifetime. `&T` is shorthand for `&'a T`. `&mut T` is for `&'a mut T`. But usually the lifetime is not annotated explicitly.

Lifetime annotations in functions associate the lifetime of the outputs with the lifetime of some of the inputs. They are needed only if that is ambiguous.
```rust
// Ex: function returns a slice of the input string after the given pattern.
// We must annotate that the output is associated with the `input` string and not with `pattern`.
fn strip_prefix(input: &'a str, pattern: &str) -> Option<&'a str>;
```

Lifetime annotations in structs indicate that the struct holds a reference.
```rust
// Ex: one way to make an iterator over a slice
pub struct SliceIter<'a, T> {
    slice: &'a [T],
    current_index: usize,
}
```

*When reading code you can mostly ignore lifetimes.*


## Borrow rules

- `&T` is a const reference, also called a shared reference
  - multiple const references to a given value may exists at the same time
  - if a const reference exists, then no mutable reference may exist
- `&mut T` is a mutable reference, also called a unique reference
  - if a mutable reference exists, no other reference may exists at the same time

These rules are enforced at compile time.

This is a big topic, but suffice to say - the rules are very powerful as they prevent many logical bugs and allow building powerful APIs. They can also be limiting and heavily impact the way rust programs are structured.

There are cases when we need to use data that is both shared and (sometimes) mutable. There are special types which allow us to work around these rules:
- `RefCell` - replaces the compile time borrow checks with runtime checks. Single thread only. Frequently used as `Rc<RefCell<T>>`
- `Mutex`, etc. - uses locking to ensure mutable aceess is exclusive. Frequently used as `Arc<Mutex<T>>`

