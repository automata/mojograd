from String import String
from BuiltinList import FloatLiteral

struct Value:
    var data: Int
    var grad: FloatLiteral
    var _prev_a: Self
    var _prev_b: Self
    var _op: String

    fn __init__(inout self, data: Int, _child_a: Self, _child_b: Self, _op: String):
        self.data = data
        self.grad = 0.0
        self._prev_a = _child_a
        self._prev_b = _child_b
        self._op = _op

    fn __copyinit__(inout self, other: Self):
        self.data = other.data
        self.grad = other.grad
        self._prev_a = other._prev_a
        self._prev_b = other._prev_b
        self._op = other._op

    fn __add__(self, owned other: Self) -> Self:
        let out: Value = Value(self.data + other.data, self, other, '+')
        return out

    fn _backward_add(inout self, inout other: Self):
        self._prev_a.grad += self.grad
        self._prev_b.grad += self.grad