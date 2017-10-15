Unit fpc_jemalloc;

Interface

{$LINKLIB jemalloc}

const
	LibName = 'libjemalloc';

Function je_malloc(Size: ptruint): Pointer; cdecl; external LibName name 'je_malloc';
Procedure je_free(P: Pointer); cdecl; external LibName name 'je_free';
Function je_realloc(P: Pointer; Size: ptruint): Pointer; cdecl; external LibName name 'je_realloc';

Implementation

type pptruint = ^ptruint;

Function JEGetMem(Size: ptruint): Pointer;
begin
	JEGetMem := je_malloc(Size + sizeof(ptruint));

	if JEGetMem <> nil then
	begin
		pptrint(JEGetMem)^ := Size;
		Inc(JEGetMem, sizeof(ptruint));
	end;
end;

Function JEFreeMem(P: Pointer): ptruint;
begin
	if P <> nil then
		Dec(P, sizeof(ptruint));

	je_free(P);
	JEFreeMem := 0;
end;

Function JEFreeMemSize(P: Pointer; Size: ptruint): ptruint;
begin
	if Size <= 0 then
	begin
		if Size = 0 then
			exit;
		runerror(204);
	end;

	if P <> nil then
	begin
		if Size <> pptruint(P - sizeof(ptruint))^ then
			runerror(204);
	end;

	JEFreeMemSize := JEFreeMem(P);
end;

Function JEAllocMem(Size: ptruint): Pointer;
var
	TotalSize: ptruint;
begin
	TotalSize := Size + sizeof(ptruint);

	JEAllocMem := je_malloc(TotalSize);

	if JEAllocMem <> nil then
	begin
		FillByte(JEAllocMem, TotalSize, 0);

		pptruint(JEAllocMem)^ := Size;
		Inc(JEAllocMem, sizeof(ptruint));
	end;
end;

Function JEReAllocMem(var P: Pointer; Size: ptruint): Pointer;
begin
	if Size = 0 then
	begin
		if P <> Nil then
		begin
			Dec(P, sizeof(ptruint));

			je_free(P);

			P := nil;
		end;
	end
	else
	begin
		Inc(Size, sizeof(ptruint));
		if P = nil then
			P := je_malloc(Size)
		else
		begin
			Dec(P, sizeof(ptruint));
			P := je_realloc(P, Size);
		end;

		if P <> nil then
		begin
			pptruint(P)^ := Size - sizeof(ptruint);
			Inc(P, sizeof(ptruint));
		end;
	end;

	JEReAllocMem := P;
end;

Function JEMemSize(P: Pointer): ptruint;
begin
	JEMemSize := pptruint(P - sizeof(ptruint))^;
end;

{ TODO }
Function JEGetHeapStatus: THeapStatus;
begin
	FillChar(JEGetHeapStatus, sizeof(JEGetHeapStatus), 0);
end;

Function JEGetFPCHeapStatus: TFPCHeapStatus;
begin
	FillChar(JEGetFPCHeapStatus, sizeof(JEGetHeapStatus), 0);
end;

const JEMemoryManager: TMemoryManager =
(
	NeedLock: false (* TODO: verify *);
	GetMem: @JEGetMem;
	FreeMem: @JEFreeMem;
	FreeMemSize: @JEFreeMemSize;
	AllocMem: @JEAllocMem;
	ReAllocMem: @JEReAllocMem;
	MemSize: @JEMemSize;
	InitThread: Nil;
	DoneThread: Nil;
	RelocateHeap: Nil;
	GetHeapStatus: @JEGetHeapStatus;
	GetFPCHeapStatus: @JEGetFPCHeapStatus;
);

var PreviousMemoryManager: TMemoryManager;

Initialization
	GetMemoryManager(PreviousMemoryManager);
	SetMemoryManager(JEMemoryManager);

Finalization
	SetMemoryManager(PreviousMemoryManager);

end.

