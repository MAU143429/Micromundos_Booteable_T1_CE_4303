ORG 0x8000                ;; Establece la direccion de memoria del juego


jmp setup_game            ;; Ejecuta un salto al metodo setup 
;; CONSTANTS
VIDMEM		      equ 0B800h    ;; EStableciendo memoria 
SCREENW		      equ 80        ;; Establece el ancho de pantalla 
SCREENH		      equ 25        ;; Establece el largo de la pantalla
WINCOND		      equ 5         ;; Condiciones de Victoria 
BGCOLOR		      equ 0ffffh    ;; Etablece el color del fondo en Hexadecimal
APPLECOLOR        equ 4020h     ;; EStablcer el color de la manzana
TURTLECOLOR       equ 2040h     ;; Establece el color de la tortuga
TIMER             equ 046Ch     ;; Establece una direccion de memoria para el timer 
SNAKEXARRAY       equ 1000h     ;; EStablece la direccion de memoria que guarda las coordenadas X
SNAKEYARRAY       equ 2000h     ;; EStablece la direccion de memoria que guarda las coordenadas Y
UP			      equ 0         ;; Establece el vqlor de una constante que representa direccion.
DOWN		      equ 1         ;; Establece el vqlor de una constante que representa direccion.
LEFT		      equ 2         ;; Establece el vqlor de una constante que representa direccion.
RIGHT		      equ 3         ;; Establece el vqlor de una constante que representa direccion.
SO			      equ 4         ;; Establece el vqlor de una constante que representa direccion.
SE		          equ 5         ;; Establece el vqlor de una constante que representa direccion.
NO		          equ 6         ;; Establece el vqlor de una constante que representa direccion.
NE		          equ 7         ;; Establece el vqlor de una constante que representa direccion.
UP_DOWN_COLOR     equ 0A000h    ;; EStablece el color del verde hexadecimal
LEFT_RIGHT_COLOR  equ 0C000h    ;; EStablece el color del rojo hexadecimal
SO_NE_COLOR		  equ 0010h     ;; EStablece el color del azul hexadecimal
SE_NO		      equ 0E000h    ;; EStablece el color del amarillo hexadecimall


;; VARIABLES
playerX:	 dw 40        ;;Variable de tamaño de palabra (16 bits) que almacena la coordenada X del jugador
playerY:	 dw 12        ;;Variable de tamaño de palabra (12 bits) que almacena la coordenada Y del jugador
appleX:		 dw 16        ;;Variable de tamaño de palabra (16 bits) que almacena la coordenada X de la manzana
appleY:		 dw 8         ;;Variable de tamaño de palabra (8 bits) que almacena la coordenada Y de la manzana
direction:	 db 8         ;;Variable de tamaño de palabra (4 bits) que almacena ldireccion actual
snakeLength: dw 1         ;;Variable de tamaño de palabra (1 bits) que almacena la longitud de la serpiente
printRoad:   db 0         ;;Variable de tamaño de palabra (1 bits) que almacena la flag para pintar el camino

;; LOGIC --------------------
setup_game:
	;; Set video mode - VGA mode 03h (80x25 text mode, 16 colors)
	mov ax, 0003h
	int 10h

	;; Set up video memory
	mov ax, VIDMEM
	mov es, ax		; ES:DI <- video memory (0B800:0000 or B8000)

	;; Set 1st snake segment "head"
	mov ax, [playerX]
	mov word [SNAKEXARRAY], ax
	mov ax, [playerY]
	mov word [SNAKEYARRAY], ax
	
	;; Hide cursor
	mov ah, 02h
	mov dx, 2600h	; DH = row, DL = col, cursor is off the visible screen
	int 10h

;; Game loop
game_loop:
	;; Clear screen every loop iteration
	mov ax, BGCOLOR
	xor di, di
	mov cx, SCREENW*SCREENH
	rep stosw				; mov [ES:DI], AX & inc di

	;; Draw turtle
	xor bx, bx				; Array index
	mov cx, [snakeLength]	; Loop counter
	mov ax, TURTLECOLOR
	.turtle_loop:
		imul di, [SNAKEYARRAY+bx], SCREENW*2	; Y position of snake segment, 2 bytes per character
		imul dx, [SNAKEXARRAY+bx], 2			; X position of snake segment, 2 bytes per character
		add di, dx
        mov word [es:di], ax    ; Coloca el color de la tortuga en la posición de la memoria de video

		inc bx
		inc bx
	loop .turtle_loop

	;; Draw apple
	;;imul di, [appleY], SCREENW*2
	;;imul dx, [appleX], 2
	;;add di, dx
	;;mov ax, APPLECOLOR
	;;stosw

	;; Move snake in current direction
	mov al, [direction]
    mov si, [playerX]
    mov di, [playerY]

	cmp al, UP
	je move_up
	cmp al, DOWN
	je move_down
	cmp al, LEFT
	je move_left
	cmp al, RIGHT
	je move_right
    cmp al, SO
	je move_SO
	cmp al, SE
	je move_SE
	cmp al, NO
	je move_NO
	cmp al, NE
	je move_NE

	jmp update_snake

	move_up:
		dec di		; Move up 1 row on the screen
		jmp update_snake

	move_down:
		inc di		; Move down 1 row on the screen
		jmp update_snake

	move_left:
		dec si		; Move left 1 column on the screen
		jmp update_snake

	move_right:
		inc si		; Move right 1 column on the screen
    
    move_NO:
        dec si
        dec di
        jmp update_snake

    move_SO:
        dec si
        inc di
        jmp update_snake

    move_SE:
        inc si
        inc di
        jmp update_snake

    move_NE:
        inc si
        dec di
        jmp update_snake
    

	;; Update snake position from playerX/Y changes
	update_snake:
        mov word [playerX], si  ;; Update snake/player X,Y position
        mov word [playerY], di

		;; Update all snake segments past the "head", iterate back to front
		;;imul bx, [snakeLength], 2	; each array element = 2 bytes
		;;.turtle_loop:
		;;	mov ax, [SNAKEXARRAY-2+bx]			; X value
		;;	mov word [SNAKEXARRAY+bx], ax
		;;	mov ax, [SNAKEYARRAY-2+bx]			; Y value
		;;	mov word [SNAKEYARRAY+bx], ax
			
		;;	dec bx								; Get previous array elem
		;;	dec bx
		;;jnz .turtle_loop							; Stop at first element, "head"

	;; Store updated values to head of snake in arrays
	mov word [SNAKEXARRAY], si
	mov word [SNAKEYARRAY], di
	
	;; Lose conditions
	;; 1) Hit borders of screen
	cmp di, -1		; Top of screen
	je game_lost
	cmp di, SCREENH	; Bottom of screen
	je game_lost
	cmp si, -1		; Left of screen
	je game_lost
	cmp si, SCREENW ; Right of screen
	je game_lost

	;; 2) Hit part of snake
	cmp word [snakeLength], 1	; Only have starting segment
	je get_player_input

	mov bx, 2					; Array indexes, start at 2nd array element
	mov cx, [snakeLength]		; Loop counter
	check_hit_snake_loop:
		cmp si, [SNAKEXARRAY+bx]
		jne .increment

		cmp di, [SNAKEYARRAY+bx]
		je game_lost				; Hit snake body, lose game :'(

		.increment:
			inc bx
			inc bx
	loop check_hit_snake_loop

	get_player_input:


		mov bl, [direction]		; Save current direction
		
		mov ah, 1
		int 16h					; Get keyboard status
		;;jz check_apple			; If no key was pressed, move on

		xor ah, ah
		int 16h					; Get keystroke, AH = scancode, AL = ascii char entered

        cmp ah, 32  
        je space_pressed
		cmp ah, 48h      ; Compara con la tecla de flecha arriba
        je arrow_up_pressed
        cmp ah, 50h      ; Compara con la tecla de flecha abajo
        je arrow_down_pressed
        cmp ah, 4Bh      ; Compara con la tecla de flecha izquierda
        je arrow_left_pressed
        cmp ah, 4Dh      ; Compara con la tecla de flecha derecha
        je arrow_right_pressed
        cmp al, 'q'
        je q_pressed
        cmp al, 'a'
        je a_pressed
        cmp al, 'e'
        je e_pressed
        cmp al, 'd'
        je d_pressed
        cmp al, 'r'
        je r_pressed
     

		jmp check_apple

        space_pressed:
            ;; Change printRoad status flag
			mov al, [printRoad]
            xor al, 1  ; Alternar entre 0 y 1
            mov [printRoad], al

		arrow_up_pressed:
            ;; Move up
			mov bl, UP
			jmp check_apple

		arrow_down_pressed:
            ;; Move down
			mov bl, DOWN
			jmp check_apple

		arrow_left_pressed:
            ;; Move left
			mov bl, LEFT
			jmp check_apple

		arrow_right_pressed:
            ;; Move right
			mov bl, RIGHT
			jmp check_apple

        a_pressed:
            ;; Move NO
			mov bl, NO
			jmp check_apple

		d_pressed:
            ;; Move NE
			mov bl, NE
			jmp check_apple

		q_pressed:
            ;; Move SO
			mov bl, SO
			jmp check_apple

		e_pressed:
            ;; Move SE
			mov bl, SE
		    	jmp check_apple

		r_pressed:
            ;; Reset
			int 19h     ; Reload bootsector

	;; Did player hit apple?
	check_apple:
		mov byte [direction], bl		; Update direction
		
		mov ax, si
		cmp ax, [appleX]
		jne delay_loop

		mov ax, di
		cmp ax, [appleY]
		jne delay_loop

		; Hit apple, increase snake length
		inc word [snakeLength]
		cmp word [snakeLength], WINCOND
		je game_won

	
	delay_loop:
		mov bx, [TIMER]
		inc bx
		inc bx
		.delay:
			cmp [TIMER], bx
			jl .delay

jmp game_loop

;; End conditions
game_won:
	mov dword [ES:0000], 1F491F57h	; WI
	mov dword [ES:0004], 1F211F4Eh	; N!
	jmp reset
	
game_lost:
	mov dword [ES:0000], 1F4F1F4Ch	; LO
	mov dword [ES:0004], 1F451F53h	; SE
	
;; Reset the game
reset:
	xor ah, ah
	int 16h
    int 19h     ; Reload bootsector







