match: 
		push ebp; 
		mov ebp, esp ; stack frame
		sub esp, 4   ; local variable

		push esi     ; save the reg (no change)
		push edi     ; save the reg (no change)

		mov esi, [ebp+8]  ; load address string
		mov edi, [ebp+12] ; load address pattern 

.again:
		cmp byte [edi], 0 ; pattern ran out?
		jne .not_end	  ; if not, then jump
		cmp byte [esi], 0 ; if the pattern is over, check if the string is over?
		jne near .false	  ; if not over, then return false
		jmp .true		  ; if everything ended at the same time, then return true

.not_end: 
		cmp byte [edi], '*' ; checking for an asterisk in the pattern
		jne .not_star		; if not, jump to a local label

		mov dword [ebp-4], 0 ; variable := 0

.star_loop:
		mov eax, edi	  ; move edi to eax, for recurs
		inc eax			  ; start the pattern with the next character
		push eax		  ; save the reg 
		mov eax, esi   
		add eax, [ebp-4]  ; first arg variable
		push eax		  ; save the reg
		call match		  ; recurs with new param

		add esp, 8		 ; stack cleanup
		test eax, eax	 ; checking what is ret?
		jnz .true		 ; if not zero, then ret true (the remainder of the pattern is matched with the remainder of the string)
		add eax, [ebp-4] ; if zero is ret, then write off more characters to the asterisk

		cmp byte [esi+eax], 0 ; line ended?
		je .false			  ; if ended, ret false
		inc dword [ebp-4]	  ; if not, then inc the variable
		jmp .star_loop		  ; jump to the beginning of the loop by variable

.not_star:					  ; if the sample is not empty
		mov al, [edi]
		cmp al, '?'			  ; check for a question mark
		je .quest			  ; if yes, jmp to local label
		cmp al, [esi]		  ; if not, the characters at the beginning of the string and pattern must match; if the string ends, this check will also fail
		jne .false			  ; if they do not match, or if the string is over, ret false
		jmp .goon			  ; if they match, jmp to local mark

.quest:						  ; if the sample starts with a question
		cmp byte [esi], 0	  ; checking if a line has ended 
		jz .false			  ; if it's over ret false
		
.goon:						  ; if characters are matched
		inc esi				  ; move along the line
		inc edi				  ; move in a pattern
		jmp .again			  ; jmp local mark

.true:						  ; ret true
		mov eax, 1
		jmp .quit 

.false:						  ; ret false
		xor eax, eax

.quit:						  ; end 
		pop edi
		pop esi
		mov esp, ebp
		pop ebp
		ret