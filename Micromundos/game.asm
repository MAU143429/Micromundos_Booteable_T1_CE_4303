org  0x8000
bits 16

jmp startProgram

; Variables ------------------------------------------------------------------------------------------------

time db  00h                        ; tiempo que representa los FPS del programa
level dw 01h                        ; Nivel del juego
paintMode dw 00h ; Flag para indicar si el jugador está en modo de pintura
eraseMode   dw 00h   ; Estado de borrado (0: No borrar, 1: Borrar)
currentColor dw 0Ah   ; Color actual (por defecto, 0Ah podría ser verde)
lastColor dw 00h   ; Color actual (por defecto, 0Ah podría ser verde)
secondsLeft dw 60     ; Inicializar con el número de segundos deseados (1 minuto)



; Constantes -----------------------------------------------------------------------------------------------

width dw  140h                      ; screen width 320 p
height dw  0c8h                     ; screen height 200 p
purple_color dw 50h    ;; EStablece el color del verde hexadecimal
red_color dw 90h    ;; EStablece el color del verde hexadecimal
blue_color dw 70h    ;; EStablece el color del verde hexadecimal
yellow_color dw 40h    ;; EStablece el color del verde hexadecimal


gameHeight dw 46h ; Board height set to 100p
gameWidth dw 12ah ; Board width set to 150p


gamePaused dw 00h ; Flag to know if the game is paused. 0 not paused. 1 paused

; player

player_x dw      03h   ; x position player 
player_y dw      0ah   ; y position player 
temp_player_x dw 03h   ; temp x position player
temp_player_y dw 0ah   ; temp y position player
color_player_x dw 03h   ; color x position player
color_player_y dw 0ah   ; color y position player
player_speed dw  06h   ; player speed
player_color dw  0ah   ; player color
player_size dw   05h   ; player dimensions 
player_dir dw    00h   ; last direction of player (0 right, 1 down, 2 left, 3 up) 
tortugaSprite db 0b00100, 0b11111, 0b01110, 0b11111, 0b00000


; Texts ---------------------------------------------------------------------------------------------------

menu1 dw '           ----------------         ', 0h
menu2 dw '           - MICRO-MUNDOS -         ', 0h
menu3 dw '           -  BIENVENIDO  -         ', 0h
menu4 dw '           ----------------         ', 0h
menu5 dw '   Presione ENTER para continuar    ', 0h

winner1 dw '          ---------------           ', 0h
winner2 dw '          - FELICIDADES -           ', 0h
winner3 dw '          -   GANASTE   -           ', 0h
winner4 dw '          ---------------           ', 0h
winner5 dw '   Presione ENTER para repetir    ', 0h

looser1 dw '          ---------------           ', 0h
looser2 dw '          -   PERDISTE  -           ', 0h
looser3 dw '          -      :v     -           ', 0h
looser4 dw '          ---------------           ', 0h
looser5 dw '   Presione ENTER para repetir    ', 0h

; In-Game Texts ...........................................................................................

inGame1 dw '-------------------------------------', 0h
inGame2 dw '-            Controles              -', 0h
inGame3 dw '- Mover-> Flechas y Q,E,A,D         -', 0h
inGame4 dw '- Reset-> R | Terminar -> ESC       -', 0h
inGame5 dw '- Pintar-> ESPACIO | Borrar -> Z    -', 0h
inGame6 dw '-      Lvl.:', 0h
inGame7 dw '1              -', 0h
inGame8 dw '2              -', 0h
inGame9 dw '-------------------------------------', 0h


textColor     dw 150h


; GAME LOGIC ****************************************************************************************************
startProgram:
    call initDisplay    ; starts display
    call clearScreen    ; clears display
    jmp  menuLoop       

startGame:                          
    call    setLevel1               ; initialize lvl 1
    call    clearScreen             ; paints the screen black 
    call    drawInGameText          ; function to display the controls in game
    jmp     gameLoop                

initDisplay:                        ;video mode interruption to draw on screen
    mov ah, 00h     
    mov al, 13h     
    int 10h        
    ret

menuLoop:                           ; Menu cycle

    call    checkPlayerMenuAction   ; checks if the player has pressed space

    call    drawTextMenu            ; draws menu on screen

    jmp     menuLoop                ; stays in the cycle if nothing happens

winnerLoop: 

    call    checkPlayerMenuAction   ; Checks if the player pressed space to play again
    
    call    drawWinnerMenu          ; Draws winning screen

    jmp     winnerLoop              ; stays in the cycle if nothing happens


gameLoop:                           ; game logic loop

    call checkPlayerGameInput       ; function to check whether the keys have been pressed or not  

    call renderPlayer               ; function to draw the player constantly

    jmp     gameLoop                ; stays in the loop

; Render functions **************************************************************************************

clearScreen:                        ; paints black the display
    mov     cx, 00h                 ; starting x
    mov     dx, 00h                 ; starting y
    jmp     clearScreenAux          

clearScreenAux:
    mov     ah, 0ch                 
    mov     al, 00h                 
    mov     bh, 00h
    int     10h                     ; interruption that draws a black pixel
    inc     cx                      ; increases x to draw horizontaly
    cmp     cx, [width]             
    jng     clearScreenAux          
    jmp     clearScreenAux2         

clearScreenAux2:                  
    mov     cx, 00h                 ; restarts x
    inc     dx                      ; increases y to draw in the next line
    cmp     dx, [height]            
    jng     clearScreenAux          
    ret                             


checkPlayerMenuAction:              ; Checks if a key has been pressed in the menu
    mov     ah, 01h                
    int     16h                     ; interruption to get keyboard state
    jz      exitRoutine             ; if nothing is pressed, returns
    mov     ah, 00h                 
    int     16h                     ; interruption to read the key that was pressed
    cmp     al, 0Dh                 ; compares if the key pressed was the enter
    je      startGame               ; starts game if space was pressed

    ret


drawTextMenu:                       ; Draws the text menu
    mov     bx, [textColor]         ; sets the color of the pixel to be drawn

    mov     bx, menu1               ; sets the text to be drawn
    mov     dh, 07h                 ; y coordinate in pixels
    mov     dl, 02h                 ; x coordinate in pixels
    call    drawText                ; calls the function to draw the text

    mov     bx, menu2           
    inc     dh                      ; increases y to draw the next text
    mov     dl, 02h                 
    call    drawText                

    mov     bx, menu3            
    inc     dh                      
    mov     dl, 02h                 
    call    drawText                

    mov     bx, menu4           
    inc     dh                      
    mov     dl, 02h                 
    call    drawText                

    mov     bx, menu5           
    mov     dh, 10h                     
    mov     dl, 02h                 
    call    drawText                

    ret


drawInGameText:
    mov     bx, [textColor]         ; Sets the pixel colors

    mov     bx, inGame1             ;start * box
    mov     dh, 0ch                 ;y text coordinate
    mov     dl, 02h                 ;x text coordinate               
    call    drawText

    mov     bx, inGame2             ;controls text    
    inc     dh            
    mov     dl, 02h               
    call    drawText   

    mov     bx, inGame3             ;movement text       
    inc     dh            
    mov     dl, 02h               
    call    drawText

    mov     bx, inGame4             ;restart text
    inc     dh            
    mov     dl, 02h               
    call    drawText

    mov     bx, inGame5             ;pause text
    inc     dh            
    mov     dl, 02h               
    call    drawText

    mov     bx, inGame6             ;Level text
    inc     dh            
    mov     dl, 02h               
    call    drawText

    mov     bx, inGame9             ;end * box
    mov     dh, 12h          
    mov     dl, 02h               
    call    drawText

    ;checks what lvl is drawing to indicate it to the player
    mov     bx, [level]
    cmp     bx, 1
    je      drawInGameTextAux
    jmp     drawInGameTextAux2


    ret

drawInGameTextAux:
    mov     bx, inGame7                      
    mov     dl, 17h
    mov     dh, 11h               
    call    drawText
    ret

drawInGameTextAux2:
    mov     bx, inGame8                    
    mov     dl, 17h
    mov     dh, 11h              
    call    drawText
    ret


drawWinnerMenu:                     ; Draws the text that is displayed once the player has won
    mov     bx, [textColor]         ; indicates text color
    inc     bx                      ; increases the number of the color to give it a rainbow appearance
    mov     [textColor], bx         ; saves the new color number

    mov     bx, winner1             ; selects the text to display
    mov     dh, 07h                 ; y coordinate
    mov     dl, 02h                 ; x coordinate
    call    drawText                ; draws the text

    mov     bx, winner2             ; changes the text message
    inc     dh                      ; increses y to draw under the previous message
    mov     dl, 02h                 
    call    drawText                

    mov     bx, winner3          
    inc     dh                      
    mov     dl, 02h                 
    call    drawText                

    mov     bx, winner4         
    inc     dh                                        
    mov     dl, 02h                 
    call    drawText                

    mov     bx, winner5         
    mov     dh, 10h                     
    mov     dl, 02h                 
    call    drawText                

    ret

drawText:                           ; Draws text on screen
    cmp     byte [bx],0             ; checks if the draw is complete
    jz      finishDraw              ; returns when the draw is finished
    jmp     drawChar                ; draws next character

drawChar:                           ; Draws a character on screen
    push    bx                      ; pushes the character on bx
    mov     ah, 02h                 ; indicates that a character is going to be printed on screen
    mov     bh, 00h                 ; indicates that its going to be printed in the current page
    int     10h                     ; calls the interruption
    pop     bx                      ; pops the character into bx

    push    bx                      
    mov     al, [bx]                ; saves the current character
    mov     ah, 0ah                 ; Mueve a ah un 10
    mov     bh, 00h                 
    mov     bl, [textColor]         ; sets the color of the text
    mov     cx, 01h                 ; indicates that only one character will be printed
    int     10h                     ; calls the interruption
    pop     bx                      

    inc     bx                      ; reads the next byte
    inc     dl                      
    jmp     drawText                ; jumps back to the starting cycle

finishDraw:                         ; Returns once the text is written
    ret                             


setLevel1:                          
    mov     ax, 01h                 
    mov     [level], ax                   ; Sets the player in level 1

    mov     ax, 03h                       
    mov     [player_x], ax                ; player x starting coordinate
    mov     [temp_player_x], ax           ; starts the temporal x in the same place so the player wont move unintentionally
    mov     ax, 0ah                       
    mov     [player_y], ax                ; player y starting coordinate
    mov     [temp_player_y], ax           ; starts the temporal y in the same place so the player wont move unintentionally

    mov     ax, 00h                       
    mov     [gamePaused], ax              ; Sets the game to unpaused
    ret

renderPlayer:
    mov     cx, [player_x]            ; current x
    mov     dx, [player_y]            ; current y
    jmp     renderPlayerAux           

renderPlayerAux:
     mov     ah, 0ch                 ; Draw pixel
     mov     al, [player_color]      ; player color 
     mov     bh, 00h                 ; Page
     int     10h                     ; Interrupt
     inc     cx                      ; cx + 1
     mov     ax, cx                  
     sub     ax, [player_x]          ; Substract player width with the current column
     cmp     ax, [player_size]       ; compares if ax is greater than player size
     jng     renderPlayerAux         ; if not greater, draw next column
     jmp     renderPlayerAux2        ; Else, jump to next aux function

renderPlayerAux2:
    mov     cx, [player_x]            ; reset columns
    inc     dx                        ; dx +1
    mov     ax, dx                  
    sub     ax, [player_y]            ; Substract player height with the current row
    cmp     ax, [player_size]         ; compares if ax is greater than player size
    jng     renderPlayerAux           ; if not greater, draw next row
    ret                               ; Else, return


deletePlayer:                       ; Funtion to erase player from screen


    mov     ax, [eraseMode]         ; Obtiene el valor actual de paintMode
    cmp     ax, 01h                 ; Invierte el valor (0 a 1 o 1 a 0)
    je      deletePlayerAux2

    mov     ax, [eraseMode]         ; Obtiene el valor actual de paintMode
    cmp     ax, 01h                 ; Invierte el valor (0 a 1 o 1 a 0)
    jne      deletePlayerAux1
   
    ret


deletePlayerAux1:
    mov     al, [lastColor]         ; Move color black to al
    mov     [player_color], al      ; Updates player color to black 
    call    renderPlayer            ; Render player in color black
    mov     al, 0ah                 ; Set al as the original player color
    mov     [player_color], al      ; Updates player color to black
    ret                             ; return

deletePlayerAux2:
    mov     al, 00h                ; Move color black to al
    mov     [player_color], al      ; Updates player color to black 
    call    renderPlayer            ; Render player in color black
    mov     al, 0ah                 ; Set al as the original player color
    mov     [player_color], al      ; Updates player color to black
    ret                             ; return




checkPlayerGameInput:
    mov     ax, 00h                 ; Reset reg ax
    cmp     ax, [gamePaused]        ; move the gamePaused Flag to ax
    je      makeMovements           ; If the game is not paused, player can move 

makeMovements:
    mov     ah, 01h                 ; gets keyboard status
    int     16h                     ; interrupt 

    jz      exitRoutine             ; if not pushed key, exit

    mov     ah, 00h                 ; Read key
    int     16h                     ; interrupt

    cmp     ah, 48h                 ; If the key pushed is arrow up
    je      playerUp                ; Moves player up

    
    cmp     ah, 50h                 ; If the key pushed is arrow down
    je      playerDown              ; Moves player down

    cmp     ah, 4dh                 ; If the key pushed is arrow right 
    je      playerRight             ; Moves player right

    cmp     ah, 4bh                 ; If the key pushed is arrow left 
    je      playerLeft              ; Moves player left

    cmp     al, 'q'                 ; If the key pushed is q
    je      playerSE               ; Pause the game

    cmp     al, 'a'                 ; If the key pushed is a
    je      playerNE                ; Pause the game

    cmp     al, 'e'                 ; If the key pushed is e
    je      playerSO               ; Pause the game

    cmp     al, 'd'                 ; If the key pushed is d
    je      playerNO               ; Pause the game

    cmp     al, 'z'                 ; If the key pushed is z
    je      toggleEraseMode               ; Pause the game

    cmp     al, 20h                 ; If the key pushed is space
    je      togglePaintMode         ; Change the paintmode flag

    cmp     ah, 13h                 ; If the key pushed is r
    je      resetGame               ; Resets game

    cmp     al, 1Bh                 ; If the key pushed is esc
    je      startProgram             


    ret

playerUp:                           ; Moves player up

    ; Apenas entra actualiza el color al que deberia printear segun el movimiento
    mov     al, [purple_color]               ; Guarda el hexa del color verde en el registro al
    mov     [currentColor], al    ; Establece el color como el actual
    xor     al, al
    mov     ax, [player_x] 
    mov     [color_player_x], ax
    xor     ax, ax
    mov     ax, [player_y] 
    mov     [color_player_y], ax
    xor     ax, ax


    mov     ax, 06h                 ; Moves 6 to ax
    cmp     [player_y], ax          ; compares the player_y to the up border
    jle      exitRoutine             ; if equal, return. Dont move

    call    deletePlayer            ; Deletes player from screen

    mov     ax, [player_y]          
    sub     ax, [player_speed]      ; substracts the speed to the player position in y to move up
    mov     [temp_player_y], ax     ; stores the new position in the temp y
    
    call    checkPlayerColision     ; checks if the movement causes a colition

    mov     [player_y], ax          ; Updates pos y of player

    jmp verifyMode


playerNO:                           ; Moves player NO

    mov     al, [red_color]               ; Guarda el hexa del color verde en el registro al
    mov     [currentColor], al    ; Establece el color como el actual
    xor     al, al
    mov     ax, [player_x] 
    mov     [color_player_x], ax
    xor     ax, ax
    mov     ax, [player_y] 
    mov     [color_player_y], ax
    xor     ax, ax

    mov     ax, 06h                 ; Moves 6 to ax
    cmp     [player_y], ax          ; compares the player_y to the up border
    jle      exitRoutine             ; if equal, return. Dont move

    xor     ax,ax

    mov     ax, 06h                 ; Moves 6 to ax
    cmp     [player_y], ax          ; compares the player_y to the up border
    jle      exitRoutine             ; if equal, return. Dont move

    call    deletePlayer            ; Deletes player from screen

    mov     ax, [player_y]          
    sub     ax, [player_speed]      ; substracts the speed to the player position in y to move up
    mov     [temp_player_y], ax     ; stores the new position in the temp y
    
    call    checkPlayerColision     ; checks if the movement causes a colition

    mov     [player_y], ax          ; Updates pos y of player


    mov     ax, [player_x]          
    sub     ax, [player_speed]      ; substracts the speed to the player position in y to move up
    mov     [temp_player_x], ax     ; stores the new position in the temp y

    call    checkPlayerColision     ; checks if the movement causes a colition

    mov     [player_x], ax          ; Updates pos y of player

   
    jmp verifyMode


    
playerDown:                         ; Moves player down


; Apenas entra actualiza el color al que deberia printear segun el movimiento
    mov     al, [purple_color]               ; Guarda el hexa del color verde en el registro al
    mov     [currentColor], al    ; Establece el color como el actual
    xor     al, al
    mov     ax, [player_x] 
    mov     [color_player_x], ax
    xor     ax, ax
    mov     ax, [player_y] 
    mov     [color_player_y], ax
    xor     ax, ax

    mov     ax, [gameHeight]                 ; Moves the game height to ax
    add     ax, 06h                 ; add 6 to ax 
    cmp     [player_y], ax          ; compares the player_y to the up border
    jge      exitRoutine            ; if equal, return. Dont move

    call    deletePlayer            ; Deletes player from screen

    mov     ax, [player_y]          
    add     ax, [player_speed]      ; adds the speed to the player position in y to move down
    mov     [temp_player_y], ax     
    call    checkPlayerColision     

    mov     [player_y], ax          ; Updates pos y of player

    jmp verifyMode


playerSE:                           ; Moves player up

    ; Apenas entra actualiza el color al que deberia printear segun el movimiento
    mov     al, [red_color]               ; Guarda el hexa del color verde en el registro al
    mov     [currentColor], al    ; Establece el color como el actual
    xor     al, al
    mov     ax, [player_x] 
    mov     [color_player_x], ax
    xor     ax, ax
    mov     ax, [player_y] 
    mov     [color_player_y], ax
    xor     ax, ax

    mov     ax, 06h                 ; Moves 6 to ax
    cmp     [player_y], ax          ; compares the player_y to the up border
    jle      exitRoutine             ; if equal, return. Dont move

    call    deletePlayer            ; Deletes player from screen

    mov     ax, [player_y]          
    add     ax, [player_speed]      ; substracts the speed to the player position in y to move up
    mov     [temp_player_y], ax     ; stores the new position in the temp y
    
    call    checkPlayerColision     ; checks if the movement causes a colition

    mov     [player_y], ax          ; Updates pos y of player

    mov     ax, [player_x]          
    add     ax, [player_speed]      ; substracts the speed to the player position in y to move up
    mov     [temp_player_x], ax     ; stores the new position in the temp y

    call    checkPlayerColision     ; checks if the movement causes a colition

    mov     [player_x], ax          ; Updates pos y of player

    jmp     verifyMode  

playerRight:                        ; Moves player right

    ; Apenas entra actualiza el color al que deberia printear segun el movimiento
    mov     al, [yellow_color]               ; Guarda el hexa del color verde en el registro al
    mov     [currentColor], al    ; Establece el color como el actual
    xor     al, al
    mov     ax, [player_x] 
    mov     [color_player_x], ax
    xor     ax, ax
    mov     ax, [player_y] 
    mov     [color_player_y], ax
    xor     ax, ax


    mov     ax, [gameWidth]         ; Moves the game height to ax
    add     ax, 06h                 
    cmp     [player_x], ax          ; compares the player_y to the right border
    jge      exitRoutine            ; if equal, return. Dont move

    call    deletePlayer            ; Deletes player from screen

    mov     ax, [player_x]          ; gets x position
    add     ax, [player_speed]      ; adds speed to x position
    mov     [temp_player_x], ax     ; stores the new position in temp variable
    call    checkPlayerColision     ; checks for colision

    mov     [player_x], ax          ; Updates pos x of player

    jmp     verifyMode

playerSO:                           ; Moves player up

    mov     al, [blue_color]               ; Guarda el hexa del color verde en el registro al
    mov     [currentColor], al    ; Establece el color como el actual
    xor     al, al
    mov     ax, [player_x] 
    mov     [color_player_x], ax
    xor     ax, ax
    mov     ax, [player_y] 
    mov     [color_player_y], ax
    xor     ax, ax

    mov     ax, 06h                 ; Moves 6 to ax
    cmp     [player_y], ax          ; compares the player_y to the up border
    jle      exitRoutine             ; if equal, return. Dont move

    call    deletePlayer            ; Deletes player from screen

    mov     ax, [player_y]          
    add     ax, [player_speed]      ; substracts the speed to the player position in y to move up
    mov     [temp_player_y], ax     ; stores the new position in the temp y
    
    call    checkPlayerColision     ; checks if the movement causes a colition

    mov     [player_y], ax          ; Updates pos y of player

    mov     ax, [player_x]          
    sub     ax, [player_speed]      ; substracts the speed to the player position in y to move up
    mov     [temp_player_x], ax     ; stores the new position in the temp y

    call    checkPlayerColision     ; checks if the movement causes a colition

    mov     [player_x], ax          ; Updates pos y of player

    jmp     verifyMode  

playerLeft:                         ; Moves player left

    ; Apenas entra actualiza el color al que deberia printear segun el movimiento
    mov     al, [yellow_color]               ; Guarda el hexa del color verde en el registro al
    mov     [currentColor], al    ; Establece el color como el actual
    xor     al, al
    mov     ax, [player_x] 
    mov     [color_player_x], ax
    xor     ax, ax
    mov     ax, [player_y] 
    mov     [color_player_y], ax
    xor     ax, ax


    mov     ax, 06h                 ; Moves the game height to ax
    cmp     [player_x], ax          ; compares the player_y to the right border
    jle      exitRoutine             ; if equal, return. Dont move

    call    deletePlayer            ; Deletes player from screen

    mov     ax, [player_x]          
    sub     ax, [player_speed]      
    mov     [temp_player_x], ax     
    call    checkPlayerColision     

    mov     [player_x], ax          
    
    jmp     verifyMode 
    
playerNE:                           ; Moves player up

    mov     al, [blue_color]               ; Guarda el hexa del color verde en el registro al
    mov     [currentColor], al    ; Establece el color como el actual
    xor     al, al
    mov     ax, [player_x] 
    mov     [color_player_x], ax
    xor     ax, ax
    mov     ax, [player_y] 
    mov     [color_player_y], ax
    xor     ax, ax
    mov     ax, 06h                 ; Moves 6 to ax
    cmp     [player_y], ax          ; compares the player_y to the up border
    jle      exitRoutine             ; if equal, return. Dont move

    call    deletePlayer            ; Deletes player from screen

    mov     ax, [player_y]          
    sub     ax, [player_speed]      ; substracts the speed to the player position in y to move up
    mov     [temp_player_y], ax     ; stores the new position in the temp y
    
    call    checkPlayerColision     ; checks if the movement causes a colition

    mov     [player_y], ax          ; Updates pos y of player

    mov     ax, [player_x]          
    add     ax, [player_speed]      ; substracts the speed to the player position in y to move up
    mov     [temp_player_x], ax     ; stores the new position in the temp y

    call    checkPlayerColision     ; checks if the movement causes a colition

    mov     [player_x], ax          ; Updates pos y of player

    jmp     verifyMode  


verifyMode:

    xor     ax,ax
    mov     ax, [paintMode]         ; Verifica el estado de pintura
    cmp     ax, 01h
    je      paintInGame             ; Si estamos en modo de pintura, salta a la rutina correspondiente

    mov     ax, [eraseMode]         ; Verifica el estado de borrado
    cmp     ax, 01h
    je      eraseInGame            ; Si estamos en modo de borrado, salta a la rutina correspondiente

    ; Si no estamos en modo de pintura ni de borrado, simplemente movemos al jugador
    ret

togglePaintMode:

    mov     ax, [eraseMode]         ; Obtiene el valor actual de paintMode
    cmp     ax, 01h                 ; Invierte el valor (0 a 1 o 1 a 0)
    jne      togglePaintModeAux

    ret

togglePaintModeAux:

    mov     ax, [paintMode]         ; Obtiene el valor actual de paintMode
    xor     ax, 01h                 ; Invierte el valor (0 a 1 o 1 a 0)
    mov     [paintMode], ax         ; Actualiza paintMode

    ret    

toggleEraseMode:

    mov     ax, [paintMode]         ; Obtiene el valor actual de paintMode
    cmp     ax, 01h                 ; Invierte el valor (0 a 1 o 1 a 0)
    jne      toggleEraseModeAux

    ret

toggleEraseModeAux:

    mov     ax, [eraseMode]         ; Obtiene el valor actual de paintMode
    xor     ax, 01h                 ; Invierte el valor (0 a 1 o 1 a 0)
    mov     [eraseMode], ax         ; Actualiza paintMode

    ret 


paintInGame:

    mov     cx, [color_player_x]       ; Obtén el tamaño del jugador (ancho o alto, asumiendo que es cuadrado)
    mov     dx, [color_player_y]                  ; Establece el contador de bucle para el tamaño del jugador
    jmp     paintLoop

paintLoop:

    mov     ah, 0ch                 ; Draw pixel
    mov     al, [currentColor]      ; player color 
    mov     bh, 00h                 ; Page
    int     10h                     ; Interrupt
    inc     cx                      ; cx + 1
    mov     ax, cx                  
    sub     ax, [color_player_x]          ; Substract player width with the current column
    cmp     ax, [player_size]       ; compares if ax is greater than player size
    jng     paintLoop         ; if not greater, draw next column
    jmp     paintLoop2       ; Else, jump to next aux function



paintLoop2:

    mov     cx, [color_player_x]            ; reset columns
    inc     dx                        ; dx +1
    mov     ax, dx                  
    sub     ax, [color_player_y]            ; Substract player height with the current row
    cmp     ax, [player_size]         ; compares if ax is greater than player size
    jng     paintLoop           ; if not greater, draw next row

    ret                             ; Retorna de la función
    
eraseInGame:
    mov     al, 00h               ; Guarda el hexa del color verde en el registro al
    mov     [currentColor], al    ; Establece el color como el actual
    xor     al, al
    mov     cx, [color_player_x]       ; Obtén el tamaño del jugador (ancho o alto, asumiendo que es cuadrado)
    mov     dx, [color_player_y]                  ; Establece el contador de bucle para el tamaño del jugador
    jmp     paintLoop
    

    ret                             ; return

; ;-----------------------Render Goal-----------------------

; renderGoal:
;     mov    ax, 01h
;     cmp    ax, [level]
;     je     renderGoalLevel1
;     jmp    renderGoalLevel2

; renderGoalLevel1: 
;     mov ax, [goal_level_1_x]
;     mov [goal_x], ax
;     mov ax, [goal_level_1_y]
;     mov [goal_y], ax
;     jmp renderGoalAux

; renderGoalLevel2: 
;     mov ax, [goal_level_2_x]
;     mov [goal_x], ax
;     mov ax, [goal_level_2_y]
;     mov [goal_y], ax
;     jmp renderGoalAux

; renderGoalAux:
;     mov     cx, [goal_x]            
;     mov     dx, [goal_y]            
;     jmp     renderGoalAux1         

; renderGoalAux1:
;     mov     ah, 0ch                 ; Draw pixel
;     mov     al, [goal_color]        ; player color 
;     mov     bh, 00h                 ; Page
;     int     10h                     ; Interrupt 
;     inc     cx                      ; cx +1
;     mov     ax, cx                  
;     sub     ax, [goal_x]          ; Substract player width with the current column
;     cmp     ax, [player_size]       ; compares if ax is greater than player size
;     jng     renderGoalAux1         ; if not greater, draw next column
;     jmp     renderGoalAux2        ; Else, jump to next aux function

; renderGoalAux2:
;     mov     cx, [goal_x]            ; reset columns
;     inc     dx                        ; dx +1
;     mov     ax, dx                  
;     sub     ax, [goal_y]            ; Substract player height with the current row
;     cmp     ax, [player_size]         ; compares if ax is greater than player size
;     jng     renderGoalAux1           ; if not greater, draw next row
;     ret                               ; Else, return

;-----------------------Check colisions-----------------------

;compares if the pixel in the position of the temp x and y of the player, matches the color of a wall
;if that happens it means the player movement made him collide with a wall
;But if the color of the pixel is red, it means the player reached the goal


checkPlayerColision:
     push ax

     mov cx, [temp_player_x]
     mov dx, [temp_player_y]
     mov ah, 0dh
     mov bh, 00h
     int 10h

    mov [lastColor], al  ; Establece el color como el actual

     ;cmp al, [purple_color]
     ;je  exitRoutine

     ;cmp al, [blue_color]
     ;je exitRoutine
     
     ;cmp al, [red_color]
     ;je exitRoutine

     ;cmp al, [yellow_color]
     ;je exitRoutine

     ;cmp al, [goal_color]
     ;je goalReached

     pop ax

     ret



;goalReached:
;     mov    ax, 01h
;     cmp    ax, [level]
;     je     startLevel2
;     call   clearScreen
;     jmp    winnerLoop

win:
    call   clearScreen
    jmp    winnerLoop



exitPlayerMovement:
    mov     ax, [player_x]            
    mov     [temp_player_x], ax           
    mov     ax, [player_y]            
    mov     [temp_player_y], ax          

    call resetGame 

resetGame:
    call clearScreen
    jmp startGame

exitRoutine:                       
    ret                      