# Testing...

var a = Value(1)
var b = Value(2)
var c = Value(3, a, b, "+")
print(a.data.get(), a.grad.get(), b.data.get(), b.grad.get())
var d = a + b
print(d.data.get())
d._backward_add()
print(d.data.get(), d._prev_a.bitcast[Value]()[0].grad.get(), d._prev_b.bitcast[Value]()[0].grad.get())
# print(a.data.get(), b.data.get(), c.data.get(), c._op, d.data.get(), a.grad.get(), d.grad.get())