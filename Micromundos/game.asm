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
TURTLEXARRAY       equ 1000h     ;; EStablece la direccion de memoria que guarda las coordenadas X
TURTLEYARRAY       equ 2000h     ;; EStablece la direccion de memoria que guarda las coordenadas Y
UP			      equ 0         ;; Establece el vqlor de una constante que representa direccion.
DOWN		      equ 1         ;; Establece el vqlor de una constante que representa direccion.
LEFT		      equ 2         ;; Establece el vqlor de una constante que representa direccion.
RIGHT		      equ 3         ;; Establece el vqlor de una constante que representa direccion.
SO			      equ 4         ;; Establece el vqlor de una constante que representa direccion.
SE		          equ 5         ;; Establece el vqlor de una constante que representa direccion.
NO		          equ 6         ;; Establece el vqlor de una constante que representa direccion.
NE		          equ 7         ;; Establece el vqlor de una constante que representa direccion.
GREEN             equ 0A000h    ;; EStablece el color del verde hexadecimal
RED               equ 0C000h    ;; EStablece el color del rojo hexadecimal
BLUE		      equ 0010h     ;; EStablece el color del azul hexadecimal
YELLOW		      equ 0E000h    ;; EStablece el color del amarillo hexadecimal


;; VARIABLES
playerX:	 dw 40        ;;Variable de tamaño de palabra (16 bits) que almacena la coordenada X del jugador
playerY:	 dw 12        ;;Variable de tamaño de palabra (12 bits) que almacena la coordenada Y del jugador
appleX:		 dw 16        ;;Variable de tamaño de palabra (16 bits) que almacena la coordenada X de la manzana
appleY:		 dw 8         ;;Variable de tamaño de palabra (8 bits) que almacena la coordenada Y de la manzana
direction:	 db 8         ;;Variable de tamaño de palabra (8 bits) que almacena ldireccion actual
snakeLength: dw 1         ;;Variable de tamaño de palabra (1 bits) que almacena la longitud de la serpiente
printRoad:   db 0         ;;Variable de tamaño de palabra (1 bits) que almacena la flag para pintar el camino
eraseRoad:   db 0         ;;Variable de tamaño de palabra (1 bits) que almacena la flag para borrar el camino

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
	mov word [TURTLEXARRAY], ax
	mov ax, [playerY]
	mov word [TURTLEYARRAY], ax
	
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
		imul di, [TURTLEYARRAY+bx], SCREENW*2	; Y position of snake segment, 2 bytes per character
		imul dx, [TURTLEXARRAY+bx], 2			; X position of snake segment, 2 bytes per character
		add di, dx
        mov word [es:di], ax    ; Coloca el color de la tortuga en la posición de la memoria de video

		inc bx
		inc bx
	loop .turtle_loop


	;; Move turtle in current direction
	mov al, [direction]
    mov si, [playerX]
    mov di, [playerY]

	
	; Verifica si la flag de borrar esta activa sino se sale del metodo
	;mov al, [eraseRoad]
	;cmp al, 1
	;je set_default_color

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
		; Verifica si la flag de pintar esta activa sino se sale del metodo
		mov al, [printRoad]
		cmp al, 1
		je set_up_down_color
		dec di		; Move up 1 row on the screen
		jmp update_snake

	move_down:
		; Verifica si la flag de pintar esta activa sino se sale del metodo
		mov al, [printRoad]
		cmp al, 1
		je set_up_down_color
		inc di		; Move down 1 row on the screen
		jmp update_snake
		

	move_left:
		; Verifica si la flag de pintar esta activa sino se sale del metodo
		mov al, [printRoad]
		cmp al, 1
		je set_left_right_color
		dec si		; Move left 1 column on the screen
		jmp update_snake
		

	move_right:
		; Verifica si la flag de pintar esta activa sino se sale del metodo
		mov al, [printRoad]
		cmp al, 1
		je set_left_right_color
		inc si		; Move right 1 column on the screen
		jmp update_snake
		
    
    move_NO:
		; Verifica si la flag de pintar esta activa sino se sale del metodo
		mov al, [printRoad]
		cmp al, 1
		je set_NO_SE_color
        dec si
        dec di
		jmp update_snake
		

    move_SO:
		; Verifica si la flag de pintar esta activa sino se sale del metodo
		mov al, [printRoad]
		cmp al, 1
		je set_NE_SO_color
        dec si
        inc di
		jmp update_snake
		

    move_SE:
		; Verifica si la flag de pintar esta activa sino se sale del metodo
		mov al, [printRoad]
		cmp al, 1
		je set_NO_SE_color
        inc si
        inc di
		jmp update_snake
		

    move_NE:
		; Verifica si la flag de pintar esta activa sino se sale del metodo
		mov al, [printRoad]
		cmp al, 1
		je set_NE_SO_color
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
	mov word [TURTLEXARRAY], si
	mov word [TURTLEYARRAY], di
	
	;; Lose conditions
	;; 1) Hit borders of screen
	;cmp di, -1		; Top of screen
	;je game_lost
	;cmp di, SCREENH	; Bottom of screen
	;je game_lost
	;cmp si, -1		; Left of screen
	;je game_lost
	;cmp si, SCREENW ; Right of screen
	;je game_lost

	; 2) WIN CONDITION 
	;cmp word [snakeLength], 1	; Only have starting segment
	;je get_player_input

	;mov bx, 2					; Array indexes, start at 2nd array element
	;mov cx, [snakeLength]		; Loop counter
	;check_hit_snake_loop:
	;		cmp si, [TURTLEXARRAY+bx]
	;	jne .increment

	;	cmp di, [TURTLEYARRAY+bx]
	;	je game_lost				; Hit snake body, lose game :'(

	;	.increment:
	;		inc bx
	;		inc bx
	;loop check_hit_snake_loop

	get_player_input:

		mov bl, [direction]		
		
		; Reset a 0 de ah y interrupcion de teclado
		xor ah, ah
		int 16h					

        
		cmp ah, 48h      
        je arrow_up_pressed
        cmp ah, 50h     
        je arrow_down_pressed
        cmp ah, 4Bh    
        je arrow_left_pressed
        cmp ah, 4Dh      
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
		cmp al, 'z'
        je z_pressed
		cmp ah, 32  
        je space_pressed
     

		jmp update_snake

        space_pressed:
            ;; Change printRoad status flag
			mov ax, [printRoad]
            xor ax, 1  
            mov [printRoad], ax
			jmp update_position
			

		z_pressed:
            ;; Change eraseRoad status flag
			mov ax, [eraseRoad]
            xor ax, 1  
            mov [eraseRoad], ax
			jmp update_position

		arrow_up_pressed:
            ;; Move up
			mov bl, UP
			jmp update_position

		arrow_down_pressed:
            ;; Move down
			mov bl, DOWN
			jmp update_position

		arrow_left_pressed:
            ;; Move left
			mov bl, LEFT
			jmp update_position

		arrow_right_pressed:
            ;; Move right
			mov bl, RIGHT
			jmp update_position

        a_pressed:
            ;; Move NO
			mov bl, NO
			jmp update_position

		d_pressed:
            ;; Move NE
			mov bl, NE
			jmp update_position

		q_pressed:
            ;; Move SO
			mov bl, SO
			jmp update_position

		e_pressed:
            ;; Move SE
			mov bl, SE
		    jmp update_position

		r_pressed:
            ;; Reset
			int 19h     ; Reload bootsector

	
	update_position:
		mov byte [direction], bl		; Update direction
		

jmp game_loop

color_draw:
	; Dibujar el color en la posición actual de la tortuga (playerX, playerY)
	imul di, [playerY], SCREENW*2
	imul dx, [playerX], 2
	add di, dx
	stosw
	jmp update_position

set_up_down_color:
	mov ax, GREEN  
	jmp color_draw

set_left_right_color:
	mov ax, RED  
	jmp color_draw

set_NE_SO_color:
	mov ax, BLUE  
	jmp color_draw

set_NO_SE_color:
	mov ax, YELLOW  
	jmp color_draw

set_default_color:
	mov ax, BGCOLOR  
	jmp color_draw

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







