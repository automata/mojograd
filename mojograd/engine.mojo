from String import String
from BuiltinList import FloatLiteral

from list import List
from data import Data

@register_passable
struct Value:
    var data: Data[Int]
    var grad: Data[Float64]
    var _prev_a: Pointer[NoneType]
    var _prev_b: Pointer[NoneType]
    var _op: StringLiteral

    fn __init__(data: Int) -> Self:
        let ptr_child_a = Pointer[NoneType].alloc(1)
        let ptr_child_b = Pointer[NoneType].alloc(1)
        let new_data = Data[Int](data)
        let new_grad = Data[Float64](0.0)
        return Self {
            data: new_data,
            grad: new_grad,
            _prev_a: ptr_child_a,
            _prev_b: ptr_child_b,
            _op: ""
        }
    
    fn __init__(data: Int, op: StringLiteral) -> Self:
        let ptr_child_a = Pointer[NoneType].alloc(1)
        let ptr_child_b = Pointer[NoneType].alloc(1)
        return Self {
            data: Data[Int](data),
            grad: Data[Float64](0.0),
            _prev_a: ptr_child_a,
            _prev_b: ptr_child_b,
            _op: op
        } 

    fn __init__(data: Int, child_a: Value, child_b: Value, op: StringLiteral) -> Self:
        let ptr_child_a = Pointer[Value].alloc(1)
        let ptr_child_b = Pointer[Value].alloc(1)
        ptr_child_a.store(0, child_a)
        ptr_child_b.store(0, child_b)
        return Self {
            data: Data[Int](data),
            grad: Data[Float64](0.0),
            _prev_a: ptr_child_a.bitcast[NoneType](),
            _prev_b: ptr_child_b.bitcast[NoneType](),
            _op: op
        }
    
    fn __copyinit__(other: Self) -> Self:
        return Self {
            data: other.data,
            grad: other.grad,
            _prev_a: other._prev_a,
            _prev_b: other._prev_b,
            _op: other._op
        }

    fn __add__(self, other: Self) -> Self:
        let res: Int = self.data.get() + other.data.get()
        let out: Value = Value(res, self, other, '+')
        return out
    
    fn _backward_add(self):
        let grad_a = self._prev_a.bitcast[Value]()[0].grad.get()
        let grad_b = self._prev_b.bitcast[Value]()[0].grad.get()
        let grad = self.grad.get()
        self._prev_a.bitcast[Value]()[0].grad.set(grad_a + grad)
        self._prev_b.bitcast[Value]()[0].grad.set(grad_b + grad)

    fn build_topo(self, v : Value, visited : List[Value], topo : List[Value]):
        # Avoid powers
        # if isinstance(v, (Int, Float64)):
        #     return
        let is_in_visited = False
        let size = visited.size()
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
        let topo : List[Value] = List[Value]()
        let visited : List[Value] = List[Value]()
        self.build_topo(self, visited, topo)
        # Chain rule
        self.grad.set(1.0)
        # TODO: Reverse topo
        let size : Int = topo.size()
        for i in range(size):
            let v = topo[i]
            if v._op == '+':
                v._backward_add()
            # if v._op == '*':
            #     v._backward_mul()
            # if v._op == '**':
            #     v._backward_pow()
            # if v._op == 'ReLU':
            #     v._backward_relu()