# :fire:grad

**Note: It's still a WIP with some ops missing but getting there ;-)**

A Mojo implementation of [micrograd](https://github.com/karpathy/micrograd).

# Using

For now, it's only possible to use it on Mojo Playground. Make sure
you request your access to it on Modular's website and then
copy and paste the contents of `mojograd/data.mojo` and
`mojograd/engine.mojo` files in a new notebook.

Then test it (some examples on `mojograd/test.mojo`):

```python
var a = Value(1.)
var b = Value(2.)
var c = a + b - 2. * 2
c.backward()

a.show("a")
b.show("b")
c.show("c")
```

```
<Value a :: data: 1.0 grad: 1.0 op:  id: 0.13153778773876068 >
<Value b :: data: 2.0 grad: 1.0 op:  id: 0.4586501320232198 >
<Value c :: data: -1.0 grad: 1.0 op: + id: 0.93469289622673868 >
```

# Changelog

- 2023.06.30
  - Finally got it working! Only missing pow ops and review it

# Author

Vilson Vieira <vilson@void.cc>