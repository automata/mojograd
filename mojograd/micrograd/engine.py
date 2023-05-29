# Just like micrograd but without too much Python magic to make it
# easier to port to Mojo
#
# For instance, topological sort function and backward functions do
# not rely anymore of injection of variables by side effect. It's
# explicit now.

class Value:

    def __init__(self, data, _children=[], _op=''):
        self.data = data
        self.grad = 0
        self._prev = _children
        self._op = _op

    def __add__(self, other):
        other = other if isinstance(other, Value) else Value(other)
        return Value(self.data + other.data, [self, other], '+')

    def __radd__(self, other): # other + self
        return self + other

    def _backward_add(self):
        self._prev[0].grad += self.grad
        self._prev[1].grad += self.grad

    def __mul__(self, other):
        other = other if isinstance(other, Value) else Value(other)
        return Value(self.data * other.data, [self, other], '*')

    def __rmul__(self, other): # other * self
        return self * other

    def _backward_mul(self):
        self._prev[0].grad += self._prev[1].data * self.grad
        self._prev[1].grad += self._prev[0].data * self.grad

    def __pow__(self, other):
        assert isinstance(other, (int, float)), "only supporting int/float powers for now"
        return Value(self.data**other, [self, other], '**')

    def _backward_pow(self):
        self._prev[0].grad += (self._prev[1] * self._prev[0].data**(self._prev[1]-1)) * self.grad

    def relu(self):
        return Value(0 if self.data < 0 else self.data, [self,], 'ReLU')

    def _backward_relu(self):
        self._prev[0].grad += (self.data > 0) * self.grad

    def __neg__(self): # -self
        return self * -1

    def __sub__(self, other): # self - other
        return self + (-other)

    def __rsub__(self, other): # other - self
        return other + (-self)

    def __truediv__(self, other): # self / other
        return self * other**-1

    def __rtruediv__(self, other): # other / self
        return other * self**-1

    def build_topo(self, v, visited, topo):
        # Avoid powers
        if isinstance(v, (int, float)):
            return
        if v not in visited:
            visited.add(v)
            for child in v._prev:
                self.build_topo(child, visited, topo)
            topo.append(v)

    def backward(self):
        # Topological sort
        topo = []
        visited = set()
        self.build_topo(self, visited, topo)
        # Chain rule
        self.grad = 1
        for v in reversed(topo):
            if v._op == '+':
                v._backward_add()
            if v._op == '*':
                v._backward_mul()
            if v._op == '**':
                v._backward_pow()
            if v._op == 'ReLU':
                v._backward_relu()

    def __repr__(self):
        return f"Value(data={self.data}, grad={self.grad})"