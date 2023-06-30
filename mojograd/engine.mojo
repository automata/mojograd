from String import String
from Vector import DynamicVector
from Random import rand, random_float64

from data import Data

# Utils

fn reverse(vec : DynamicVector[Value]) -> DynamicVector[Value]:
    var reversed : DynamicVector[Value] = DynamicVector[Value](len(vec))
    for i in range(len(vec)-1, -1, -1):
        reversed.push_back(vec[i])
    return reversed

@register_passable
struct Value:
    var _id: Float64
    var data: Data[Float64]
    var grad: Data[Float64]
    var _prev_a: Pointer[NoneType]
    var _prev_b: Pointer[NoneType]
    var _op: StringLiteral

    fn __init__(data: Float64) -> Self:
        let ptr_child_a = Pointer[NoneType].alloc(1)
        let ptr_child_b = Pointer[NoneType].alloc(1)
        let new_data = Data[Float64](data)
        let new_grad = Data[Float64](0.0)
        return Self {
            _id: random_float64(),
            data: new_data,
            grad: new_grad,
            _prev_a: ptr_child_a,
            _prev_b: ptr_child_b,
            _op: ""
        }
    
    fn __init__(data: Float64, op: StringLiteral) -> Self:
        let ptr_child_a = Pointer[NoneType].alloc(1)
        let ptr_child_b = Pointer[NoneType].alloc(1)
        return Self {
            _id: random_float64(),
            data: Data[Float64](data),
            grad: Data[Float64](0.0),
            _prev_a: ptr_child_a,
            _prev_b: ptr_child_b,
            _op: op
        }

    fn __init__(data: Float64, child_a: Value, child_b: Value, op: StringLiteral) -> Self:
        let ptr_child_a = Pointer[Value].alloc(1)
        let ptr_child_b = Pointer[Value].alloc(1)
        ptr_child_a.store(0, child_a)
        ptr_child_b.store(0, child_b)
        return Self {
            _id: random_float64(),
            data: Data[Float64](data),
            grad: Data[Float64](0.0),
            _prev_a: ptr_child_a.bitcast[NoneType](),
            _prev_b: ptr_child_b.bitcast[NoneType](),
            _op: op
        }
    
    fn __copyinit__(other: Self) -> Self:
        return Self {
            # TODO Should we copy id or create a new one _id: random_float64()?
            _id: other._id,
            data: other.data,
            grad: other.grad,
            _prev_a: other._prev_a,
            _prev_b: other._prev_b,
            _op: other._op
        }

    # add
        
    fn __add__(self, other: Self) -> Self:
        let res: Float64 = self.data.get() + other.data.get()
        let out: Value = Value(res, self, other, '+')
        return out
    
    fn __add__(self, other: Float64) -> Self:
        return self + Value(other)
    
    fn __radd__(self, other: Self) -> Self: # other + self
        return self + other
    
    fn __radd__(self, other: Float64) -> Self:
        return self + other
    
    fn _backward_add(self):
        let grad_a = self._prev_a.bitcast[Value]()[0].grad.get()
        let grad_b = self._prev_b.bitcast[Value]()[0].grad.get()
        let grad = self.grad.get()
        self._prev_a.bitcast[Value]()[0].grad.set(grad_a + grad)
        self._prev_b.bitcast[Value]()[0].grad.set(grad_b + grad)

    # mul

    fn __mul__(self, other: Self) -> Self:
        let res: Float64 = self.data.get() * other.data.get()
        let out: Value = Value(res, self, other, '*')
        return out
    
    fn __mul__(self, other: Float64) -> Self:
        return self * Value(other)
    
    fn __rmul__(self, other: Self) -> Self: # other * self
        return self * other
    
    fn _backward_mul(self):
        let grad_a = self._prev_a.bitcast[Value]()[0].grad.get()
        let grad_b = self._prev_b.bitcast[Value]()[0].grad.get()
        let data_a = self._prev_a.bitcast[Value]()[0].data.get()
        let data_b = self._prev_b.bitcast[Value]()[0].data.get()
        let grad = self.grad.get()
        self._prev_a.bitcast[Value]()[0].grad.set(grad_a + data_b * grad)
        self._prev_b.bitcast[Value]()[0].grad.set(grad_b + data_a * grad)

#     # pow

#     fn __pow__(self, other: Float64) -> Self:
#         # TODO Do it for Int as well
#         let res: Float64 = self.data.get() ** other
#         let out: Value = Value(res, self, other, '**')
#         return out

#     fn __pow__(self, other: Int) -> Self:
#         # TODO Do it for Int as well
#         let res: Float64 = self.data.get() ** other
#         let out: Value = Value(res, self, other, '**')
#         return out
    
#     fn _backward_pow(self):
#         let prev_a = self._prev_a.bitcast[Value]()[0]
#         let prev_b = self._prev_b.bitcast[Value]()[0]
#         let grad_a = self._prev_a.bitcast[Value]()[0].grad.get()
#         let grad_b = self._prev_b.bitcast[Value]()[0].grad.get()
#         let data_a = self._prev_a.bitcast[Value]()[0].data.get()
#         let data_b = self._prev_b.bitcast[Value]()[0].data.get()
#         let grad = self.grad.get()
#         self._prev_a.bitcast[Value]()[0].grad.set(
#                         grad_a + ((prev_b * data_a**(prev_b-1)) * grad))

    # ReLU

    fn relu(self) -> Self:
        if self.data.get() < 0.0:
            return Value(0.0)
        # TODO How to pass self and other as None?
        return Value(self.data.get(), self, self, 'ReLU')

    fn _backward_relu(self):
        let grad_a = self._prev_a.bitcast[Value]()[0].grad.get()
        let grad = self.grad.get()
        let data = self.data.get()
        if data > 0:
            self._prev_a.bitcast[Value]()[0].grad.set(grad_a + grad)

    fn __neg__(self) -> Self: # -self
        return self * -1.0

    fn __sub__(self, other : Self) -> Self: # self - other
        return self + (-other)
    
    fn __sub__(self, other : Float64) -> Self:
        return self + (-other)

    fn __rsub__(self, other : Self) -> Self: # other - self
        return other + (-self)
    
    fn __rsub__(self, other : Float64) -> Self:
        return other + (-self)

#     fn __truediv__(self, other : Self) -> Self: # self / other
#         return self * other**-1

#     fn __rtruediv__(self, other : Self) -> Self: # other / self
#         return other * self**-1

    fn __eq__(self, other : Value) -> Bool:
        # TODO How to compare structs? For now using a random_float64 value :-)
        if self._id == other._id:
            return True
        return False
    
    fn build_topo(self, v : Int, inout visited : DynamicVector[Value], inout topo : DynamicVector[Value]):
        # Avoid powers
        return
    
    fn build_topo(self, v : Float64, inout visited : DynamicVector[Value], inout topo : DynamicVector[Value]):
        # Avoid powers
        return
    
    fn build_topo(self, v : Value, inout visited : DynamicVector[Value], inout topo : DynamicVector[Value]):
        var is_in_visited = False
        let size = len(visited)
        for i in range(size):
            if v == visited[i]:
                is_in_visited = True
        if not is_in_visited:
            # TODO: Only push if not already there (set)
            visited.push_back(v)
            self.build_topo(self._prev_a.bitcast[Value]()[0], visited, topo)
            self.build_topo(self._prev_b.bitcast[Value]()[0], visited, topo)
            topo.push_back(v)
        
    fn backward(self):
        # Topological sort
        var topo : DynamicVector[Value] = DynamicVector[Value]()
        var visited : DynamicVector[Value] = DynamicVector[Value]()
        self.build_topo(self, visited, topo)
        # Chain rule
        self.grad.set(1.0)
        let reversed_topo = reverse(topo)
        let size : Int = len(reversed_topo)
        for i in range(size):
            let v = reversed_topo[i]
            if v._op == '+':
                v._backward_add()
            if v._op == '*':
                v._backward_mul()
            # if v._op == '**':
            #     v._backward_pow()
            # if v._op == 'ReLU':
            #     v._backward_relu()
    
    fn show(self, label : StringLiteral):
        print("<Value", label, "::", "data:", self.data.get(), "grad:", self.grad.get(), "op:", self._op, "id:", self._id, ">")