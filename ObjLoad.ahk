ObjLoad(addr,objects:=0){
  If addr+0=""{ ; FileRead Mode
    If !FileExist(addr)
      return
    else v:=FileRead(addr,"RAW")
    If ErrorLevel||!FileGetSize(addr)
      return
    else addr:=&v
  }
  obj:=[],end:=addr+8+(sz:=NumGet(addr,"Int64")),addr+=8
  if !objects
    objects:={0:obj}
  else objects.Push(obj)
  While addr<end{ ; 9 = Int64 for size and Char for type
    If NumGet(addr,"Char")=-12
      k:=objects[NumGet(addr+1,"Int64")],addr+=9
    else if NumGet(addr,"Char")=-11
      k:=ObjLoad(addr+1,objects),addr+=9+NumGet(addr+1,"Int64")
    else if NumGet(addr,"Char")=-10
      sz:=NumGet(addr+1,"Int64"),k:=StrGet(addr+9),addr+=sz+9
    else k:=NumGet(addr+1,SubStr("Char  UChar Short UShortInt   UInt  Int64 UInt64Double",(sz:=-NumGet(addr,"Char"))*6-5,6)),addr+=SubStr("112244888",sz,1)+1
    If NumGet(addr,"Char")= 12
      obj[k]:=objects[NumGet(addr+1,"Int64")],addr+=9
    else if NumGet(addr,"Char")= 11
      obj[k]:=ObjLoad(addr+1,objects),addr+=9+NumGet(addr+1,"Int64")
    else if NumGet(addr,"Char")= 10
      obj[k]:=StrGet(addr+9),obj.SetCapacity(k,sz:=NumGet(addr+1,"Int64")),DllCall("RtlMoveMemory","PTR",obj.GetAddress(k),"PTR",addr+9,"PTR",sz),addr+=sz+9
    else obj[k]:=NumGet(addr+1,SubStr("Char  UChar Short UShortInt   UInt  Int64 UInt64Double",(sz:=NumGet(addr,"Char"))*6-5,6)),addr+=SubStr("112244888",sz,1)+1
  }
  return obj
}