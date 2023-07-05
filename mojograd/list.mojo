@register_passable
struct List[Type: AnyType]:
    # From: https://github.com/yakupc55/mojo-example/
    var data:Pointer[Pointer[Type]]
    var data_back:Pointer[Pointer[Type]]
    var _size:Data[Int]
    var _cap:Data[Int]

    fn __init__()->Self:
        let size = Data[Int](0)
        let cap = Data[Int](2)
        let data = Pointer[Pointer[Type]].alloc(1)
        let data_back = Pointer[Pointer[Type]].alloc(1)
        data.store(0, Pointer[Type].alloc(2))
        data_back.store(0,data.load(0))
        return Self{_size:size,_cap:cap,data:data,data_back:data_back}

    fn copy(self)->Self:
        let size = Data[Int](self.size())
        let cap = Data[Int](self.capacity())
        let data = Pointer[Pointer[Type]].alloc(1)
        let data_back = Pointer[Pointer[Type]].alloc(1)
        data.store(0, Pointer[Type].alloc(cap.get()))
        data_back.store(0,data.load(0))
        for i in range(size.get()):
            data.load(0).store(i,self.data.load(0).load(i))
        return Self{_size:size,_cap:cap,data:data,data_back:data_back}
        
    fn size(self)->Int:
        return self._size.get()
        
    fn capacity(self)->Int:
        return self._cap.get()
    
    fn add(self,_index:Int,value:Type):
        var index =_index
        var size = self.size()
        if index<0:
            index = size+index
        var cap = self.capacity()
        size = size + 1
        self._size.set(size)
        if(size == cap):
            cap = cap * 2
            self.data.store(0, Pointer[Type].alloc(cap))
            self._cap.set(cap)
            for i in range(size-1):#previous size
                self.data.load(0).store(i,self.data_back.load(0).load(i))
            self.__add_Index(index,value)
            self.data_back.store(0,self.data.load(0))
        else:
            self.__add_Index(index,value)
    
    fn __add_Index(self,index:Int,value:Type):

        for i in range(self.size()-1,index,-1):
            self.data.load(0).store(i,self.data.load(0).load(i-1))
        self.data.load(0).store(index,value)
                       
    fn __add_Index(self,index:Int,data:Pointer[Type],size:Int):
        for i in range(self.size()-1,index+size-1,-1):
            self.data.load(0).store(i,self.data.load(0).load(i-size))
        for i in range(size):
            self.data.load(0).store(i+index,data.load(i))
            
    fn add(self,_index:Int,other:Self):
        self.add(_index,other.data.load(0).bitcast[Type](),other.size())
    
    
    fn add(self,_index:Int,data:Pointer[Type],_size:Int):
        var index =_index
        var size = self.size()
        if index<0:
            index = size+index
        var newCap = self.capacity()
        size = size + _size
        self._size.set(size)
        while(size>newCap):
            newCap = newCap * 2
            
        if newCap>self.capacity():
            self.data.store(0, Pointer[Type].alloc(newCap))
            self._cap.set(newCap)
            for i in range(size-1):#previous size
                self.data.load(0).store(i,self.data_back.load(0).load(i))
            self.__add_Index(index,data,_size)
            self.data_back.store(0,self.data.load(0))
        else:
            self.__add_Index(index,data,_size)
            
    fn add(self,value:Type):
        var size = self.size()
        var cap = self.capacity()
        size = size + 1
        self._size.set(size)
        if(size == cap):
            cap = cap * 2
            self.data.store(0, Pointer[Type].alloc(cap))
            self._cap.set(cap)
            
            for i in range(size-1):#previous size
                self.data.load(0).store(i,self.data_back.load(0).load(i))
            self.data.load(0).store(size-1,value)
            self.data_back.store(0,self.data.load(0))
        else:
            self.data.load(0).store(size-1,value)
    
    fn add(self,other:Self):
        self.add(other.data.load(0),other.size())
        
    fn add(self,data:Pointer[Type],size:Int):
        for i in range(size):
            self.add(data[i])
            
    fn addMany(self,size:Int,value:Type):
        let data= Pointer[Type].alloc(size)
        for i in range(size):
            data.store(i, value)
        self.add(data,size)
        
    fn addEmpty(self,addSize:Int):
        var size = self.size()
        var newCap = self.capacity()
        size = size + addSize
        self._size.set(size)
        while(size>newCap):
            newCap = newCap * 2
            
        if newCap>self.capacity():
            self.data.store(0, Pointer[Type].alloc(newCap))
            self._cap.set(newCap)
            for i in range(size-1):#previous size
                self.data.load(0).store(i,self.data_back.load(0).load(i))
            self.data_back.store(0,self.data.load(0))
            
    fn addMany(self,index:Int,size:Int,value:Type):
        let data= Pointer[Type].alloc(size)
        for i in range(size):
            data.store(i, value)
        self.add(index,data,size)
        
    fn remove(self):
        var size = self.size()
        if(size>0):
            size = size - 1
            self._size.set(size)
            
    fn remove(self,_index:Int):
        let size = self.size()
        if(size==0):
            return None
        var index =_index
        if index<0:
            index = self.size()+index
        for i in range(index,size-1):
            self.data.load(0).store(i,self.data.load(0).load(i+1))
        self.remove()
        
    fn remove(self,_index:Int,length:Int):
        var size = self.size()
        if(size-length<0):
            return None
        size = size - length
        self._size.set(size)
        var index =_index
        if index<0:
            index = self.size()+index
        for i in range(index,size):
            self.data.load(0).store(i,self.data.load(0).load(i+length))

    
    fn __setitem__(self,i:slice,data:Pointer[Type]):
        for j in range(0,i.end - i.start):
            self.data.load(0).store(j+i.start,data.load(j))
    
    fn __setitem__(self, i: Int,value:Type):
        return self.data.load(0).store(i,value)
            
    fn __getitem__(self, x: Int) -> Type:
        var i = x
        if i<0:
            i = self.size()+i
        return self.data.load(0).load(i)
    
    fn __getitem__(self, s:slice) -> Pointer[Type]:
        let total:Int = (s.end - s.start)
        let newList = Pointer[Type].alloc(total)
        for j in range(total):
            newList.store(j,self.data.load(0).load(j+s.start))
        return newList
    
    # fn printArray(self):
    #     #1d lists
    #     if Type==Int:
    #         PrintService.printArray(self.data.load(0).bitcast[Int](),self.size())
    #     if Type==Float64:
    #         PrintService.printArray(self.data.load(0).bitcast[Float64](),self.size())