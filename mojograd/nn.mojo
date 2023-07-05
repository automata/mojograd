from engine import Value
from list import List

@register_passable
struct Neuron:
    var w: List[Value]
    var b: Value
    var nonlin: Bool

    fn __init__(nin: Int, nonlin: Bool=True) -> Neuron:
        let w: List[Value] = List[Value]()
        for i in range(nin):
            w.add(Value(random_float64()))
        return Self {w: w.copy(), b: Value(0.0), nonlin: nonlin}

    fn __call__(self, x: List[Value]) -> Value:
        var act: Value = Value(0.0)
        for i in range(x.size()):
            act = act + self.w[i] * x[i]
        act = act + self.b
        if self.nonlin:
            return act.relu()
        return act

    fn zero_grad(self):
        for pi in range(self.parameters().size()):
            self.parameters()[pi].grad.set(0.0)

    fn parameters(self) -> List[Value]:
        let ret = List[Value]()
        for i in range(self.w.size()):
            ret.add(self.w[i])
        ret.add(self.b)
        return ret.copy()


@register_passable
struct Layer:
    var neurons: List[Neuron]
    
    fn __init__(nin: Int, nout: Int) -> Layer:
        let neurons: List[Neuron] = List[Neuron]()
        for i in range(nout):
            neurons.add(Neuron(nin))
        return Self { neurons: neurons.copy() }
    
    fn __call__(self, x: List[Value]) -> List[Value]:
        let out: List[Value] = List[Value]()
        for i in range(self.neurons.size()):
            out.add(self.neurons[i](x))
        return out.copy()
    
    fn parameters(self) -> List[Value]:
        let ret = List[Value]()
        for i in range(self.neurons.size()):
            for j in range(self.neurons[i].parameters().size()):
                ret.add(self.neurons[i].parameters()[j])
        return ret.copy()


@register_passable
struct MLP:
    var layers: List[Layer]
    
    fn __init__(nin: Int, nouts: List[Int]) -> MLP:
        let sz: List[Int] = List[Int]()
        sz.add(nin)
        for i in range(nouts.size()):
            sz.add(nouts[i])
            
        # TODO Missing nonlin param
        let layers: List[Layer] = List[Layer]()
        for i in range(nouts.size()):
            layers.add(Layer(sz[i], sz[i+1]))
            
        return Self { layers: layers.copy() }
    
    fn __call__(self, x: List[Value]) -> List[Value]:
        var _x: List[Value] = List[Value]()
        _x = x.copy()
        for i in range(self.layers.size()):
            _x = self.layers[i](_x)
        return _x.copy()
    
    fn parameters(self) -> List[Value]:
        let ret = List[Value]()
        for i in range(self.layers.size()):
            for j in range(self.layers[i].parameters().size()):
                ret.add(self.layers[i].parameters()[j])
        return ret.copy()