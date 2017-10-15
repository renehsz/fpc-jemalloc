program test;

uses fpc_jemalloc;

var t: PChar;

begin 
	t := GetMem(14);
	t := PChar('Hello, world' + chr(10));
	Write(String(t));
end.

