format PE GUI 4.0
entry start

include 'INCLUDE/WIN32A.INC'

	start:
		push 	0
		call 	[GetModuleHandle]
		mov 	[wc.hInstance], eax
		push 	IDI_APPLICATION
		push 	0
		call 	[LoadIcon]
		mov 	[wc.hIcon], eax
		push 	IDC_ARROW
		push 	0
		call 	[LoadCursor]
		mov 	[wc.hCursor], eax
		push 	wc
		call 	[RegisterClass]
		test 	eax, eax
		jz 		error
		push 	NULL
		push 	[wc.hInstance]
		push 	NULL
		push 	NULL
		push 	200
		push 	275
		push 	0
		push 	0
		push 	WS_VISIBLE+WS_DLGFRAME+WS_SYSMENU
		push 	Title
		push 	Class
		push 	0
		call 	[CreateWindowEx]
		test 	eax, eax
		jz 		error
		mov		[Hwnd], eax

		push 	0
		push 	200
		push 	275
		push 	0
		push 	0
		push 	HWND_TOPMOST
		push 	[Hwnd]
		call 	[SetWindowPos]

		push 	[Hwnd]
		call 	[UpdateWindow]

	MsgLoop:
		push 	0
		push 	0
		push 	NULL
		push 	msg
		call 	[GetMessage]
		cmp 	eax, 1
		jb 		EndLoop
		jne 	MsgLoop
		push 	msg
		call 	[TranslateMessage]
		push 	msg
		call 	[DispatchMessage]

		jmp 	MsgLoop

  error:
		push 	MB_ICONERROR+MB_OK
		push 	NULL
		push 	Error
		push 	NULL
		call 	[MessageBox]

  EndLoop:
		push 	[msg.wParam]
		call 	ExitProcess

proc WndProc uses ebx esi edi, hwnd, wmsg, wparam, lparam
	 cmp 	[wmsg], WM_DESTROY
	 je 	.wmdestroy
	 cmp 	[wmsg], WM_KEYDOWN
	 je 	.wmkey
	 cmp 	[wmsg], WM_CREATE
	 je 	.wmcreate
	 cmp 	[wmsg], WM_COMMAND
	 je 	.wmcommand
	 cmp 	[wmsg], WM_PAINT
	 je 	.update

	.defwndproc:
			push 	[lparam]
			push 	[wparam]
			push 	[wmsg]
			push 	[hwnd]
			call 	[DefWindowProc]
			ret

	.wmcreate:
			;Add Button
			push 	NULL
			push 	[wc.hInstance]
			push 	2
			push 	[hwnd]
			push 	45  ;Height
			push 	100 ;Width
			push 	50  ;Y
			push 	25  ;X
			push 	WS_VISIBLE+WS_CHILD
			push 	Start
			push 	Button
			push 	WS_EX_CLIENTEDGE
			call 	[CreateWindowEx]
			test 	eax, eax
			jz 		error

			push 	NULL
			push 	[wc.hInstance]
			push 	3
			push 	[hwnd]
			push 	45  ;Height
			push 	100 ;Width
			push 	50  ;Y
			push 	150 ;X
			push 	WS_VISIBLE+WS_CHILD
			push 	Stop
			push 	Button
			push 	WS_EX_CLIENTEDGE
			call 	[CreateWindowEx]
			test 	eax, eax
			jz 		error

			ret

	.wmcommand:
			cmp 	[wparam], 1
			je 		.EXIT

			cmp 	[wparam], 2
			je 		.SETTRUE

			cmp 	[wparam], 3
			je 		.SETFALSE

			ret

	.SETTRUE:
			mov 	[Clicked], 1
			jmp 	.START

	.SETFALSE:
			mov 	[Clicked], 0
			ret
					   
	.EXIT:
			push 	0
			call 	[ExitProcess]
			jmp 	.wmdestroy

	.wmkey:
			cmp     [wparam], VK_ESCAPE
			je      .wmdestroy

			cmp     [wparam], VK_F6
			je      .SETTRUE

			cmp     [wparam], VK_F5
			je      .SETFALSE

			ret

	.update:
			cmp 	[Clicked], 1
			je 		.START

			ret

	.START:
			push 	0
			push 	0
			push 	0
			push 	0
			push 	MOUSEEVENTF_LEFTDOWN
			call 	[mouse_event]

			push 	0
			push 	0
			push 	0
			push 	0
			push 	MOUSEEVENTF_LEFTUP
			call 	[mouse_event]

			ret

	.wmdestroy:
			push    0
			call    [PostQuitMessage]
			xor     eax, eax
endp

		Class		db 'Class', 0
		Title		db 'Auto Clicker', 0
		Error		db 'Startup Failed', 0

		Button		db 'BUTTON', 0
		Start		db 'Start', 0
		Stop		db 'Stop', 0

		Clicked		dd 0

		Hwnd 		dd 0

		wc      	WNDCLASS 0, WndProc, 0, 0, NULL, NULL, NULL, COLOR_BTNFACE+1, NULL, Class
		msg 		MSG

Data import
	library kernel32, 'KERNEL32.DLL',\
			user32, 'USER32.DLL'

	include 'INCLUDE/API/KERNEL32.INC'
	include 'INCLUDE/API/USER32.INC'
end Data