# Test Value
var a: Value = Value(1.)
var b: Value = Value(2.)
var c: Value = a + b - 2. * 2
c.backward()
a.show("a")
b.show("b")
c.show("c")

# Test Neuron
var n: Neuron = Neuron(2)
var input: List[Value] = List[Value]()
input.add(Value(2.0))
input.add(Value(3.0))

var act: Value = n(input)
act.show("act")
act.backward()
act.show("act")

# Test MLP
var nouts: List[Int] = List[Int]()
nouts.add(16)
nouts.add(16)
nouts.add(1)

var model: Model = MLP(2, nouts)

var inputs: List[Value] = List[Value]()
inputs.add(Value(2.0))
inputs.add(Value(2.5))

var outputs: List[Value] = model(inputs)
print(outputs[0].data.get())

