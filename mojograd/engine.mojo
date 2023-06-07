from String import String
from BuiltinList import FloatLiteral

@register_passable
struct Value:
    var data: Int
    var grad: FloatLiteral
    var _prev_a: Pointer[NoneType]
    var _prev_b: Pointer[NoneType]
    var _op: StringLiteral

    fn __init__(data: Int) -> Self:
        let ptr_child_a = Pointer[NoneType].alloc(1)
        let ptr_child_b = Pointer[NoneType].alloc(1)
        return Self {
            data: data,
            grad: 0.0,
            _prev_a: ptr_child_a,
            _prev_b: ptr_child_b,
            _op: ""
        }

    fn __init__(data: Int, op: StringLiteral) -> Self:
        let ptr_child_a = Pointer[NoneType].alloc(1)
        let ptr_child_b = Pointer[NoneType].alloc(1)
        return Self {
            data: data,
            grad: 0.0,
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
            data: data,
            grad: 0.0,
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

    fn __add__(self, owned other: Self) -> Self:
        let out: Value = Value(self.data + other.data, self, other, '+')
        return out

    fn _backward_add(inout self, inout other: Self):
        let ptr_a = self._prev_a.bitcast[Value]()
        let lptr_a = ptr_a.load().set_grad(2.0)
        # let grad_a = ptr_a.load().grad
        # grad_a + other.grad
        # .grad += self.grad
        # self._prev_b.bitcast[Value]().grad += self.grad

    fn set_grad(inout self, value: ):
        self.grad = value
