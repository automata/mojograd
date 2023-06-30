var a = Value(1.)
var b = Value(2.)
var c = a + b - 2. * 2
c.backward()
a.show("a")
b.show("b")
c.show("c")