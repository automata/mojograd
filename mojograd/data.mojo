@register_passable
struct Data[Type: AnyType]:
    # Changeable data (while we don't have let on struct?)
    # From: https://github.com/yakupc55/mojo-example/blob/main/changeable%20data%20for%20struct.md
    var __data : Pointer[Type]

    fn __init__() -> Self:
        return Self {__data : Pointer[Type].alloc(1)}

    fn __init__(value : Type) -> Self:
        let data = Pointer[Type].alloc(1)
        data.store(0, value)
        return Self {__data:data}
    
    fn __copyinit__(self) -> Self:
        return Self {__data:self.__data}
    
    fn set(self, value : Type):
        self.__data.store(0, value)
    
    fn get(self) -> Type:
        return self.__data.load(0)
    
    # fn __del__(owned self):
    #     self.__data.free()