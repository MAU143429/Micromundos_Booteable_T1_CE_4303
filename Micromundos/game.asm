org  0x8000
bits 16
;-----------------------------------------------------------------------------------------------------------
;                                 Intituto Tecnologico de Costa Rica
;                                  Principios de Sistemas Operativos
;                                         
;                                        Tarea 1 I-S 2024
;                   
;                                   Mauricio Calderon Chavarria 
;                                   Jose Antonio Espinoza Chaves
;
;-----------------------------------------------------------------------------------------------------------

jmp startProgram        ; Salta al inicio del programa

; Variables ------------------------------------------------------------------------------------------------

time           db 00h   ; Tiempo que representa los fps del programa
lastColor      dw 00h   ; Color de la casilla en donde se encuentra
paintMode      dw 00h   ; Flag para indicar si el jugador está en modo de pintura
eraseMode      dw 00h   ; Flag para indicar si el jugador está en modo de borrador
secondsLeft    dw 60    ; Inicializar con el número de segundos deseados (1 minuto)
secondsunit    dw 48    ; Inicializar con las unidades  deseados (1 minuto)
secondsdecs    dw 54    ; Inicializar con las decenas  deseados (1 minuto)
currentColor   dw 0Ah   ; Color actual (por defecto, verde)
clockSeconds   dw 0     ; Variable que maneja los segundos del sistema

; Constantes -----------------------------------------------------------------------------------------------

width          dw 140h  ; El tamano del ancho de la pantalla 320 pixeles
height         dw 0c8H  ; El tamano del alto de la pantalla 200 pixeles
red_color      dw 90h   ; Establece el color del movimiento (NO, SE)
blue_color     dw 70h   ; Establece el color del movimiento (NE, SO)
yellow_color   dw 40h   ; Establece el color del movimiento (left, right)
purple_color   dw 50h   ; EEstablece el color del movimiento (up, down)

gameHeight     dw 46h   ; Define el tamano del alto area de juego 100 pixeles
gameWidth      dw 12ah  ; Define el tamano del ancho area de juego 150 pixeles
timerPosX      dw 19h   ; Posición X para decenas del temporizador
timerPosX2     dw 1ah   ; Posición X para unidades del temporizador
timerPosY      dw 15h   ; Posición Y para el temporizador


textColor      dw 150h  ; Color del texto para los menus
player_x       dw 03h   ; Posicion en x del jugador
player_y       dw 0ah   ; Posicion en y del jugador 
temp_player_x  dw 03h   ; Posicion temporal en x del jugador
temp_player_y  dw 0ah   ; Posicion temporal en y del jugador
color_player_x dw 03h   ; Posicion casilla en x del jugador (para pintar)
color_player_y dw 0ah   ; Posicion casilla en y del jugador (para pintar)
player_speed   dw 06h   ; Velocidad de movimiento del jugador
player_color   dw 0ah   ; Color por defecto del jugador (tortuga)
player_size    dw 05h   ; DImensiones del sprite de la tortuga (5x5)
player_dir     dw 00h   ; Ultima direccion que tuvo el jugador
                                                

; Texto del menu principal del juego ---------------------------------------------------------------------------

menu1    dw '           ----------------         ', 0h
menu2    dw '           - MICRO-MUNDOS -         ', 0h
menu3    dw '           -  BIENVENIDO  -         ', 0h
menu4    dw '           ----------------         ', 0h
menu5    dw '   Presione ENTER para continuar    ', 0h

winner1  dw '          ---------------           ', 0h
winner2  dw '          - FELICIDADES -           ', 0h
winner3  dw '          -   GANASTE   -           ', 0h
winner4  dw '          ---------------           ', 0h
winner5  dw '   Presione ENTER para repetir    ', 0h

loser1   dw '          ---------------           ', 0h
loser2   dw '          -   PERDISTE  -           ', 0h
loser3   dw '          -             -           ', 0h
loser4   dw '          ---------------           ', 0h
loser5   dw '   Presione ENTER para repetir    ', 0h


timeText  dw '  Tiempo restante ->    ', 0h
timeValue dw '  ', 0h
timeUnits dw ' s  ', 0h

; Menu de controles In-Game --------------------------------------------------------------------------------------

inGame1  dw '-------------------------------------', 0h
inGame2  dw '- Lvl.1      Controles              -', 0h
inGame3  dw '- Mover-> Flechas y Q,E,A,D         -', 0h
inGame4  dw '- Reset-> R | Terminar -> ESC       -', 0h
inGame5  dw '- Pintar-> ESPACIO | Borrar -> Z    -', 0h
inGame6  dw '- Habilidad.:', 0h
inGame7  dw 'Pintando       -', 0h
inGame8  dw 'Borrando       -', 0h
inGame9  dw 'Sin accion     -', 0h
inGame10 dw '-------------------------------------', 0h


; Logica del juego  ****************************************************************************************************


startProgram:                       ; FUNCION DE INICIO DEL PROGRAMA


    call    initDisplay             ; Llama al inicializador de la pantalla

    call    clearScreen             ; Llama al limpiador de pantalla

    call    clearCounter            ; Llama al limpiador del contador y las flags de las habilidades

    jmp     menuLoop                ; Salta al bucle del menu principal



startGame:                          ; FUNCION DE INICIO DE JUEGO

    call    setRandomSpawn          ; Llama a la funcion que permite spawnear aleatoriamente al jugador

    call    clearScreen             ; Llama al limpiador de pantalla

    call    drawInGameText          ; Dibuja el menu de controles dentro del juego

    jmp     gameLoop                ; Salta al bucle de juego principal



initDisplay:                        ; FUNCION INICIALIZADORA DEL MODO DE VIDEO

    mov     ah, 00h                 ; Establece el modo de video 
    mov     al, 13h                 ; llamando a la interrupcion 
    int     10h                     ; 10h con el codigo 13h de video VGA

    ret


menuLoop:                           ; BUCLE DEL MENU PRINCIPAL      

    call    checkPlayerMenuAction   ; Revisa si el usuario presiono ENTER para empezar el juego

    call    drawTextMenu            ; Dibuja el menu principal en pantalla

    jmp     menuLoop                ; Se llama asi misma hasta que se detecte el ENTER




winnerLoop:                         ; BUCLE DE PANTALLA DE GANADOR

    call    checkPlayerMenuAction   ; Verifica si el jugador presiono el ENTER para jugar de nuevo
    
    call    drawWinnerMenu          ; Dibuja el menu de ganador de la partida

    jmp     winnerLoop              ; Se llama asi misma hasta que se detecte el ENTER




loserLoop:                          ; BUCLE DE PANTALLA DE PERDEDOR

    call    checkPlayerMenuAction   ; Verifica si el jugador presiono el ENTER para jugar de nuevo
    
    call    drawLoserMenu           ; Dibuja el menu de perdedor de la partida

    jmp     loserLoop               ; Se llama asi misma hasta que se detecte el ENTER




gameLoop:                           ; BUCLE PRINCIPAL DEL JUEGO

    call    drawInGameText          ; Dibuja el menu de controles dentro del juego principal

    call    timerLoop               ; Verifica el estado del temporizador

    call    drawInGameTime          ; Permite dibujar todo lo relacionado con el tiempo restante de juego

    call    makeMovements           ; Revisa contanstemente las teclas para detectar cualquier movimiento del jugador en juego 

    call    renderPlayer            ; Permite dibujar al jugador en la posicion donde se encuentre

    jmp     gameLoop                ; Se llama asi misma hasta que ocurra alguna accion por parte del usuario



timerLoop:                           ; FUNCION PARA OBTENER LA HORA DEL SISTEMA

    mov     ah, 02h                  ; Se setea el valor de ah necesario para que la interrupcion devuelva la hora del sistema
    int     0x1A                     ; Se ejecuta la interrupcion que devuelve la hora del sistema

    mov     bx , [clockSeconds]      ; Se da el valor del ultimo segundo al registro bx
    cmp     [clockSeconds], dh       ; Se compara el segundo actual con el ultimo registro para ver si ya paso un segundo 
    jne     delayLoop                ; Si ya paso el segundo entonces llama a la funcion que actualiza las variables y printea en pantalla

    ret                              ; Devuelve al bucle principal



delayLoop:                           ; FUNCION QUE PERMITE CAMBIAR EL VALOR DEL CONTADOR EN PANTALLA
 
    mov     [clockSeconds], dh       ; Se actualiza la variable con el ultimo valor de segundo registrado
    dec     word [secondsLeft]       ; Resta un segundo al valor restante del temporizador  


    cmp     word [secondsunit], 48   ; Se revisa si ya las unidades llegaron a 0
    je      delayLoopAux             ; Si es cero entonces se llama a la funcion que resta decenas y resetea unidades a 9


    dec     word [secondsunit]       ; Si aun no es 0 entonces se resta una unidad indicando que paso un segundo

    cmp     word [secondsLeft], 0    ; Si los segundos restantes son 0 quiere decir que el jugador se ha quedado sin tiempo
    je      lose                     ; Llama a la pantalla de perdedor

    ret                              ; Devuelve al bucle principal



delayLoopAux:                        ; FUNCION COMPLEMENTARIA QUE AYUDA A CAMBIAR EL CONTADOR EN PANTALLA

    mov    word [secondsunit], 57    ; Resetea el valor de unidades en 9
    dec    word [secondsdecs]        ; Decrementa una decena indicando que ya pasaron 10 segundos

    ret                              ; Devuelve al bucle principal




; Funciones de renderizado del jugador y pintado -------------------------------------------------------------------------------

clearScreen:                        ; FUNCION QUE PERMITE ELIMINAR TODOS LOS ELEMENTOS EN PANTALLA

    mov     cx, 00h                 ; Establece la posicion inicial x de la pantalla
    mov     dx, 00h                 ; Establece la posicion inicial y de la pantalla
    jmp     clearScreenAux          


clearScreenAux:                     ; FUNCION COMPLEMENTARIA QUE ELIMINA LOS ELEMENTOS DE LA PANTALLA
    mov     ah, 0ch                 ; Seteo de valores para ejecutar la interrupcion 10h
    mov     al, 00h                 ; Seteo de valores para ejecutar la interrupcion 10h
    mov     bh, 00h                 ; Seteo de valores para ejecutar la interrupcion 10h
    int     10h                     ; Llama a la interrupcion para que se pinte de negro el fondo
    inc     cx                      ; Va incrementando el valor en la horizontal de la pantalla
    cmp     cx, [width]             ; Compara si ya se llego al ancho maximo sino sigue hasta pintar todo
    jng     clearScreenAux          

    jmp     clearScreenAux2         


clearScreenAux2:                    ; FUNCION COMPLEMENTARIA 2 QUE ELIMINA LOS ELEMENTOS DE LA PANTALLA

    mov     cx, 00h                 ; Reinicia la posicion en x
    inc     dx                      ; Incrementa en 1 la y para escribir en la siguiente linea
    cmp     dx, [height]            ; Compara si ya se llego a la altura maxima sino sigue hasta pintar todo
    jng     clearScreenAux          
    ret                             


checkPlayerMenuAction:              ; FUNCION QUE SE ENCARGA DE DETECTAR SI EL JUGADOR ACCIONO ALGUNA TECLA EN EL MENU INICIO
    mov     ah, 01h                
    int     16h                     ; Llama a la interrupcion que detecta movimiento en el teclado
    jz      exitRoutine             ; Si no se presiona nada se retorna al bucle del juego principal
    mov     ah, 00h                 
    int     16h                     ; Llama a la interrupcion de movimiento en el teclado nuevamente
    cmp     al, 0Dh                 ; Verifica si la tecla presionada es ENTER
    je      startGame               ; Si es asi entonces inicia el juego

    ret                             ; Si ningun escenario pasa, devuelve al bucle prinicipal


drawTextMenu:                       ; FUNCION QUE SE ENCARGA DE PRINTEAR EL MENU PRINCIPAL EN PANTALLA

    mov     bx, [textColor]         ; Establece el color del texto para pintar el Menu Principal

    mov     bx, menu1               ; Selecciona el texto que quiere escribir
    mov     dh, 07h                 ; Selecciona la coordenada y en pixeles donde se escribira
    mov     dl, 02h                 ; Selecciona la coordenada x en pixeles donde se escribira
    call    drawText                ; Llama a la funcion que lo coloca en pantalla

    mov     bx, menu2           
    inc     dh                      ; Se aumenta el valor de y para seguir pintando los demas textos en la linea siguiente.
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

drawInGameTime:                     ; FUNCION QUE SE ENCARGA DE PRINTEAR EL TEMPORIZADOR EN PANTALLA


    mov     bx, [textColor]         ; Establece el color del texto para pintar el texto In Game

    mov     bx, timeText            ; Selecciona el texto que quiere escribir
    mov     dh, 15h                 ; Selecciona la coordenada y en pixeles donde se escribira
    mov     dl, 04h                 ; Selecciona la coordenada X en pixeles donde se escribira               
    call    drawText                ; Llama a la funcion que lo coloca en pantalla

    mov     bx, timeUnits           ; Selecciona el texto que quiere escribir
    mov     dh, 15h                 ; Selecciona la coordenada y en pixeles donde se escribira
    mov     dl, 1dh                 ; Selecciona la coordenada X en pixeles donde se escribira               
    call    drawText                ; Llama a la funcion que lo coloca en pantalla

    mov     bx, secondsdecs        ; Obtiene el valor actual del contador
    mov     dh, [timerPosY]         ; Selecciona la coordenada y en pixeles donde se escribira
    mov     dl, [timerPosX]         ; Selecciona la coordenada X en pixeles donde se escribira               
    call    drawText
    
    mov     bx, secondsunit         ; Obtiene el valor actual del contador
    mov     dh, [timerPosY]         ; Selecciona la coordenada y en pixeles donde se escribira
    mov     dl, [timerPosX2]         ; Selecciona la coordenada X en pixeles donde se escribira               
    call    drawText 

    ret


drawInGameText:                     ; FUNCION QUE SE ENCARGA DE PRINTEAR EL MENU DE CONTROLES EN PANTALLA


    mov     bx, [textColor]         ; Establece el color del texto para pintar el texto In Game

    mov     bx, inGame1             ; Selecciona el texto que quiere escribir
    mov     dh, 0ch                 ; Selecciona la coordenada y en pixeles donde se escribira
    mov     dl, 02h                 ; Selecciona la coordenada X en pixeles donde se escribira               
    call    drawText                ; Llama a la funcion que lo coloca en pantalla

    mov     bx, inGame2             ; Texto que indica el nivel y el titulo de controles   
    inc     dh            
    mov     dl, 02h               
    call    drawText   

    mov     bx, inGame3             ; Indica los controles de movimiento del juego      
    inc     dh            
    mov     dl, 02h               
    call    drawText

    mov     bx, inGame4             ; Indica los controles para reiniciar y volver a menu principal
    inc     dh            
    mov     dl, 02h               
    call    drawText

    mov     bx, inGame5             ; Indica los controles para activar las diferentes habilidades (pintar, borrar)
    inc     dh            
    mov     dl, 02h               
    call    drawText

    mov     bx, inGame6             ; Indica en tiempo real cual habilidad esta activada
    inc     dh            
    mov     dl, 02h               
    call    drawText

    mov     bx, inGame10             ; Decoracion para cerrar la caja de controles
    mov     dh, 12h          
    mov     dl, 02h               
    call    drawText


    ;Verifica la habilidad que esta en ejecucion para indicarla en pantalla

    mov     bx, [paintMode]          ; Revisa si esta en modo pintando
    cmp     bx, 1
    je      drawInGameTextAux

    mov     bx, [eraseMode]          ; Revisa si esta en modo pintando
    cmp     bx, 1
    je      drawInGameTextAux2
    
    jmp     drawInGameTextAux3       ; Ejecuta el modo sin habilidad en caso de no estar en ninguna de las mencionadas


    ret


drawInGameTextAux:

    mov     bx, inGame7              ; Dibuja el texto en pantalla indicando que esta pintando     
    mov     dl, 17h
    mov     dh, 11h               
    call    drawText
    ret

drawInGameTextAux2:

    mov     bx, inGame8              ; Dibuja el texto en pantalla indicando que esta borrando   
    mov     dl, 17h
    mov     dh, 11h              
    call    drawText
    ret

drawInGameTextAux3:

    mov     bx, inGame9              ; Dibuja el texto en pantalla indicando que esta sin habilidades        
    mov     dl, 17h
    mov     dh, 11h              
    call    drawText
    ret


drawWinnerMenu:                     ; FUNCION ENCARGADA DE PRINTEAR LA PANTALLA DE GANADOR

    mov     bx, [textColor]         ; Se establece el color del texto 
    inc     bx                      ; Incrementa el color en 1 para que de un efecto de arcoiris y que la animacion sea cambiar de color
    mov     [textColor], bx         ; Guarda el nuevo color

    mov     bx, winner1             ; Selecciona el texto que quiere escribir
    mov     dh, 07h                 ; Selecciona la coordenada y en pixeles donde se escribira
    mov     dl, 02h                 ; Selecciona la coordenada X en pixeles donde se escribira 
    call    drawText                ; Llama a la funcion que lo coloca en pantalla


    mov     bx, winner2             ; Cambia a la siguiente linea de texto
    inc     dh                      ; Incrementa el valor de y para dibujar la nueva linea justo debajo de la otra
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

drawLoserMenu:                      ; FUNCION ENCARGADA DE PRINTEAR LA PANTALLA DE PERDEDOR

    mov     bx, [textColor]         ; Se establece el color del texto 
    inc     bx                      ; Incrementa el color en 1 para que de un efecto de arcoiris y que la animacion sea cambiar de color
    mov     [textColor], bx         ; Guarda el nuevo color

    mov     bx, loser1              ; Selecciona el texto que quiere escribir
    mov     dh, 07h                 ; Selecciona la coordenada y en pixeles donde se escribira
    mov     dl, 02h                 ; Selecciona la coordenada X en pixeles donde se escribira 
    call    drawText                ; Llama a la funcion que lo coloca en pantalla


    mov     bx, loser2              ; Cambia a la siguiente linea de texto
    inc     dh                      ; Incrementa el valor de y para dibujar la nueva linea justo debajo de la otra
    mov     dl, 02h                 
    call    drawText                

    mov     bx, loser3          
    inc     dh                      
    mov     dl, 02h                 
    call    drawText                

    mov     bx, loser4          
    inc     dh                                       
    mov     dl, 02h                 
    call    drawText                

    mov     bx, loser5         
    mov     dh, 10h                     
    mov     dl, 02h                 
    call    drawText                

    ret

drawText:                           ; FUNCION QUE SE ENCARGA DE DIBUJAR CADENAS DE CARACTERES EN PANTALLA

    cmp     byte [bx],0             ; Verifica si el texto ya se termino de dibujar en pantalla
    jz      exitRoutine             ; Vuelve al bucle principal si ya termino
    jmp     drawChar                ; Sino sigue al siguiente caracter


drawChar:                           ; FUNCION QUE SE ENCARGA DE DIBUJAR CARACTERES EN PANTALLA

    push    bx                      ; Agrega el valor del caracter a la pila de dibujo
    mov     ah, 02h                 ; Indica que se va a pintar un caracter en pantalla
    mov     bh, 00h                 ; Indica que el caracter se va a pintar en la pantalla actual
    int     10h                     ; Llama a la interrupcion de pintar en pantalla
    pop     bx                      ; Saca al caracter de la pila

    push    bx                      
    mov     al, [bx]                ; Guarda el caracter actual que se va a pintar
    mov     ah, 0ah                 ; Se mueve 10 unidades 
    mov     bh, 00h                 
    mov     bl, [textColor]         ; Establece el color que va a tener el caracter que se dibujara
    mov     cx, 01h                 ; Indica que solo un caracter va a ser dibujado
    int     10h                     ; Llama a la interrupcion de dibujo en pantalla
    pop     bx                      

    inc     bx                      ; Incrementa en 1 para leer el siguiente caracter
    inc     dl                      
    jmp     drawText                ; Devuelve al ciclo de dibujado principal
                        


setRandomSpawn:                     ; FUNCION QUE PERMITE SPAWNEAR AL JUGADOR EN UNA POSICION ALEATORIA  

    mov ah, 02h                     ; Se setea el valor de ah necesario para que la interrupcion devuelva la hora del sistema
    int 0x1A                        ; Se ejecuta la interrupcion que devuelve la hora del sistema

    movsx ax, ch                    ; Se almacenan los minutos en un registro
    movsx bx, dh                    ; Se almacenan los segundos en un registro

    mul bx                          ; Se multiplican segundos x minutos para obtener un posicion aleatoria
    
    mov [player_y], bx              ; Asigna el valor calculado  a y
    mov [temp_player_y], bx         ; Guarda la misma coordenada en el temp y
    mov [player_x], bx              ; Asigna el valor calculado a x
    mov [temp_player_x], bx         ; Guarda la misma coordenada en el temp x

    ret                             ; Se devuelve al bucle principal



renderPlayer:                        ; FUNCION QUE PERMITE DIBUJAR AL JUGADOR EN PANTALLA.

    mov     cx, [player_x]           ; Posicion x donde sera dibujado
    mov     dx, [player_y]           ; Posicion y donde sera dibujado
    jmp     renderPlayerAux           

renderPlayerAux:                     ; FUNCION COMPLEMENTARIA QUE PERMITE DIBUJAR AL JUGADOR EN PANTALLA.

    mov    ah, 0ch                   ; Indica que se va a dibujar un pixel en pantalla
    mov    al, [player_color]        ; Indica el color del pixel (color del jugador)
    mov    bh, 00h                   ; Indica en que pagina lo va a dibujar (predeterminada)
    int    10h                       ; Llama a la interrupcion para dibujar en pantalla
    inc    cx                        ; Incremente en 1 el cx
    mov    ax, cx                   
    sub    ax, [player_x]            ; Resta 1 a la posicion del jugador para dibujar el siguiente pixel del sprite (dibujando anchura)
    cmp    ax, [player_size]         ; Verifica si el ax es mas grande que el tamano del jugador
    jng    renderPlayerAux           ; Si aun no es mas grande sigue dibujando la siguiente columna
    jmp    renderPlayerAux2          ; Sino salta a la siguiente funcion de dibujo (dibujar altura del sprite)

renderPlayerAux2:                    ; FUNCION COMPLEMENTARIA QUE PERMITE DIBUJAR AL JUGADOR EN PANTALLA.

    mov     cx, [player_x]           ; Restablece el valor de las columnas
    inc     dx                       ; Aumenta en la fila
    mov     ax, dx                  
    sub     ax, [player_y]           ; Resta 1 a la posicion del jugador para dibujar el siguiente pixel del sprite (dibujando altura)
    cmp     ax, [player_size]        ; Verifica si el ax es mas grande que el tamano del jugador
    jng     renderPlayerAux          ; Si aun no es mas grande sigue dibujando la siguiente fila
    ret                              ; Sino vuelve al bucle principal


deletePlayer:                        ; FUNCION  QUE PERMITE ELIMINAR AL JUGADOR EN PANTALLA.


    mov     ax, [eraseMode]          ; Obtiene el valor actual de paintMode
    cmp     ax, 01h                  ; Invierte el valor (0 a 1 o 1 a 0)
    je      deletePlayerAux2

    jmp      deletePlayerAux1
   
    ret                              ; Vuelve al bucle principal


deletePlayerAux1:                   ; FUNCION COMPLEMENTARIA QUE PERMITE DIBUJAR AL JUGADOR EN PANTALLA.(SI PASO POR UNA CASILLA PINTADA)

    mov     al, [lastColor]         ; Establece el color que a casilla tenia antes de llegar ahi el jugador
    mov     [player_color], al      ; Actualiza el color del jugador con el de la casilla
    call    renderPlayer            ; Llama a renderizar al jugador con ese color, para dejar la casilla como estaba
    mov     al, 0ah                 ; Se devuelve al color original del jugador
    mov     [player_color], al      ; Lo actualiza en la variable
    ret                             ; Vuelve al ciclo principal

deletePlayerAux2:                   ; FUNCION COMPLEMENTARIA QUE PERMITE DIBUJAR AL JUGADOR EN PANTALLA.(SI ESTA BORRANDO)

    mov     al, 00h                 ; Guarda el color del fondo (negro)
    mov     [player_color], al      ; Establece el color negro como el del jugador
    call    renderPlayer            ; Dibuja la casilla del color del fondo
    mov     al, 0ah                 ; SSe devuelve al color original del jugador
    mov     [player_color], al      ; Lo actualiza en la variable

    ret                             ; Vuelve al ciclo principal


makeMovements:                      ; FUNCION QUE SE ENCARGA DE DETECTAR LOS INPUTS DE TECLADO Y EJECUTAR LAS ACCIONES QUE CORRESPONDAN

    mov     ah, 01h                 ; Indica que se va a leer una entrada de teclado
    int     16h                     ; Ejecuta la interrupcion de teclado

    jz      exitRoutine             ; Si no se detecta ninguna tecla vuelve al bucle principal

    mov     ah, 00h                 ; Detecta que se presiono una tecla
    int     16h                     ; Ejecuta la interrupcion para saber el valor de la tecla presionada

    cmp     ah, 48h                 ; Si la tecla es : Flecha arriba
    je      playerUp                ; Mueve al jugador hacia arriba

    
    cmp     ah, 50h                 ; Si la tecla es : Flecha abajo
    je      playerDown              ; Mueve al jugador hacia abajo

    cmp     ah, 4dh                 ; Si la tecla es : Flecha derecha
    je      playerRight             ; Mueve al jugador hacia derecha

    cmp     ah, 4bh                 ; Si la tecla es : Flecha izquierda
    je      playerLeft              ; Mueve al jugador hacia izquierda

    cmp     al, 'q'                 ; Si la tecla es : q
    je      playerSE                ; Mueve al jugador hacia el Sur-Este

    cmp     al, 'a'                 ; Si la tecla es : a
    je      playerNE                ; Mueve al jugador hacia el Nor-Este

    cmp     al, 'e'                 ; Si la tecla es : e
    je      playerSO                ; Mueve al jugador hacia el Sur-Oeste

    cmp     al, 'd'                 ; Si la tecla es : d
    je      playerNO                ; Mueve al jugador hacia el Nor-Oeste

    cmp     al, 'z'                 ; Si la tecla es :z
    je      toggleEraseMode         ; Activa/Desactiva el modo de borrado

    cmp     al, 20h                 ; Si la tecla es : Space
    je      togglePaintMode         ; Activa/Desactiva el modo de pintado

    cmp     ah, 13h                 ; Si la tecla es : r
    je      resetGame               ; Reinicia el juego

    cmp     al, 1Bh                 ; Si la tecla es : esc
    je      startProgram            ; EL juego termina y vuelve al menu principa


    ret

playerUp:                           ; FUNCION QUE SE ENCARGA DE MOVER EL JUGADOR HACIA ARRIBA

    mov     al, [purple_color]      ; Guarda el color del cual se debe pintar el movimiento
    mov     [currentColor], al      ; Establece el color como el actual para luego colorear si es necesario
    xor     al, al
    mov     ax, [player_x] 
    mov     [color_player_x], ax    ; Guarda las posiones de x de la casilla para pintar en ella
    xor     ax, ax
    mov     ax, [player_y] 
    mov     [color_player_y], ax    ; Guarda las posiones de y de la casilla para pintar en ella
    xor     ax, ax

    mov     ax, 06h                 ; Mueve en 6 al registro ax
    cmp     [player_y], ax          ; Compara si la posicion y esta por tocar un borde con el movimiento
    jle      exitRoutine            ; Si lo tocaria entonces no lo mueve

    call    deletePlayer            ; Sino elimina al jugador de la posicion para moverlo

    mov     ax, [player_y]          
    sub     ax, [player_speed]      ; Resta la velocidad del jugador para poder moverlo arriba
    mov     [temp_player_y], ax     ; Guarda el nuevo valor de y en la variable temporal
    
    call    checkPlayerColision     ; Verifica si ocasiona colision el nuevo movimiento                                                         MODIFICAR (REVISA SI GANA)

    mov     [player_y], ax          ; Actualiza la posicion del jugador en y

    jmp     verifyMode              ; Revisa el modo de movimiento (Normal,Pintando,Borrando)


playerNO:                           ; FUNCION QUE SE ENCARGA DE MOVER EL JUGADOR HACIA NOR-OESTE

    mov     al, [red_color]         ; Guarda el color del cual se debe pintar el movimiento     
    mov     [currentColor], al      ; Establece el color como el actual para luego colorear si es necesario
    xor     al, al
    mov     ax, [player_x] 
    mov     [color_player_x], ax    ; Guarda las posiones de x de la casilla para pintar en ella
    xor     ax, ax
    mov     ax, [player_y] 
    mov     [color_player_y], ax    ; Guarda las posiones de y de la casilla para pintar en ella
    xor     ax, ax

    mov     ax, 06h                 ; Mueve en 6 al registro ax
    cmp     [player_y], ax          ; Compara si la posicion y esta por tocar un borde con el movimiento
    jle      exitRoutine            ; Si lo tocaria entonces no lo mueve

    xor     ax,ax

    mov     ax, 06h                 ; Mueve en 6 al registro ax
    cmp     [player_y], ax          ; Compara si la posicion y esta por tocar un borde con el movimiento
    jle      exitRoutine            ; Si lo tocaria entonces no lo mueve

    call    deletePlayer            ; Sino elimina al jugador de la posicion para moverlo

    mov     ax, [player_y]          
    sub     ax, [player_speed]      ; Resta la velocidad del jugador para poder moverlo arriba
    mov     [temp_player_y], ax     ; Guarda el nuevo valor de y en la variable temporal
    
    call    checkPlayerColision     ; Verifica si ocasiona colision el nuevo movimiento   

    mov     [player_y], ax          ; Actualiza la posicion del jugador en y

    mov     ax, [player_x]          
    sub     ax, [player_speed]      ; Resta la velocidad del jugador para poder moverlo izquierda
    mov     [temp_player_x], ax     ; Guarda el nuevo valor de x en la variable temporal

    call    checkPlayerColision     ; Verifica si ocasiona colision el nuevo movimiento

    mov     [player_x], ax          ; Actualiza la posicion del jugador en x

   
    jmp     verifyMode              ; Revisa el modo de movimiento (Normal,Pintando,Borrando)


    
playerDown:                         ; FUNCION QUE SE ENCARGA DE MOVER EL JUGADOR HACIA ABAJO

    mov     al, [purple_color]      ; Guarda el color del cual se debe pintar el movimiento  
    mov     [currentColor], al      ; Establece el color como el actual para luego colorear si es necesario
    xor     al, al
    mov     ax, [player_x] 
    mov     [color_player_x], ax    ; Guarda las posiones de x de la casilla para pintar en ella
    xor     ax, ax
    mov     ax, [player_y] 
    mov     [color_player_y], ax    ; Guarda las posiones de y de la casilla para pintar en ella
    xor     ax, ax



    mov     ax, [gameHeight]        ; Mueve la altura del juego a ax
    add     ax, 06h                 ; Mueve en 6 al registro ax
    cmp     [player_y], ax          ; Compara si la posicion y esta por tocar un borde con el movimiento
    jge      exitRoutine            ; Si lo tocaria entonces no lo mueve


    call    deletePlayer            ; Sino elimina al jugador de la posicion para moverlo

    mov     ax, [player_y]          
    add     ax, [player_speed]      ; Suma la velocidad del jugador para poder moverlo abajo
    mov     [temp_player_y], ax     ; Guarda el nuevo valor de y en la variable temporal 


    call    checkPlayerColision     ; Verifica si ocasiona colision el nuevo movimiento  

    mov     [player_y], ax          ; Actualiza la posicion del jugador en y

    jmp     verifyMode              ; Revisa el modo de movimiento (Normal,Pintando,Borrando)



playerSE:                           ; FUNCION QUE SE ENCARGA DE MOVER EL JUGADOR HACIA EL SUR-ESTE

    mov     al, [red_color]         ; Guarda el color del cual se debe pintar el movimiento 
    mov     [currentColor], al      ; Establece el color como el actual
    xor     al, al
    mov     ax, [player_x]          
    mov     [color_player_x], ax    ; Guarda las posiones de x de la casilla para pintar en ella
    xor     ax, ax
    mov     ax, [player_y]          ;
    mov     [color_player_y], ax    ; Guarda las posiones de y de la casilla para pintar en ella
    xor     ax, ax

    mov     ax, 06h                 ; Mueve en 6 al registro ax
    cmp     [player_y], ax          ; Compara si la posicion y esta por tocar un borde con el movimiento
    jle      exitRoutine            ; Si lo tocaria entonces no lo mueve


    call    deletePlayer            ; Sino elimina al jugador de la posicion para moverlo

    mov     ax, [player_y]          
    add     ax, [player_speed]      ; Suma la velocidad del jugador para poder moverlo abajo
    mov     [temp_player_y], ax     ; Guarda el nuevo valor de y en la variable temporal  
    
    call    checkPlayerColision     ; Verifica si ocasiona colision el nuevo movimiento 

    mov     [player_y], ax          ; Actualiza la posicion del jugador en y

    mov     ax, [player_x]          
    add     ax, [player_speed]      ; Suma la velocidad del jugador para poder moverlo derecha
    mov     [temp_player_x], ax     ; Guarda el nuevo valor de x en la variable temporal  

    call    checkPlayerColision     ; Verifica si ocasiona colision el nuevo movimiento 

    mov     [player_x], ax          ; Actualiza la posicion del jugador en x

    jmp     verifyMode              ; Revisa el modo de movimiento (Normal,Pintando,Borrando)



playerRight:                        ; FUNCION QUE SE ENCARGA DE MOVER EL JUGADOR HACIA LA DERECHA

    mov     al, [yellow_color]      ; Guarda el color del cual se debe pintar el movimiento 
    mov     [currentColor], al      ; Establece el color como el actual para luego colorear si es necesario
    xor     al, al
    mov     ax, [player_x]          
    mov     [color_player_x], ax    ; Guarda las posiones de x de la casilla para pintar en ella
    xor     ax, ax
    mov     ax, [player_y] 
    mov     [color_player_y], ax    ; Guarda las posiones de y de la casilla para pintar en ella
    xor     ax, ax


    mov     ax, [gameWidth]         ; Mueve el valor del ancho a ax
    add     ax, 06h                 ; Mueve en 6 al registro ax
    cmp     [player_x], ax          ; Compara si la posicion x esta por tocar un borde con el movimiento
    jge      exitRoutine            ; Si lo tocaria entonces no lo mueve


    call    deletePlayer            ; Sino elimina al jugador de la posicion para moverlo

    mov     ax, [player_x]          
    add     ax, [player_speed]      ; Suma la velocidad del jugador para poder moverlo derecha
    mov     [temp_player_x], ax     ; Guarda el nuevo valor de x en la variable temporal


    call    checkPlayerColision     ; Verifica si ocasiona colision el nuevo movimiento   

    mov     [player_x], ax          ; Actualiza la posicion del jugador en y

    jmp     verifyMode              ; Revisa el modo de movimiento (Normal,Pintando,Borrando)



playerSO:                           ; FUNCION QUE SE ENCARGA DE MOVER EL JUGADOR HACIA EL SUR-OESTE

    mov     al, [blue_color]        ; Guarda el color del cual se debe pintar el movimiento 
    mov     [currentColor], al      ; Establece el color como el actual para luego colorear si es necesario
    xor     al, al
    mov     ax, [player_x] 
    mov     [color_player_x], ax    ; Guarda las posiones de x de la casilla para pintar en ella
    xor     ax, ax
    mov     ax, [player_y] 
    mov     [color_player_y], ax    ; Guarda las posiones de y de la casilla para pintar en ella
    xor     ax, ax


    mov     ax, 06h                 ; Mueve en 6 al registro ax
    cmp     [player_y], ax          ; Compara si la posicion y esta por tocar un borde con el movimiento
    jle      exitRoutine            ; Si lo tocaria entonces no lo mueve

    call    deletePlayer            ; Sino elimina al jugador de la posicion para moverlo

    mov     ax, [player_y]          
    add     ax, [player_speed]      ; Suma la velocidad del jugador para poder moverlo arriba
    mov     [temp_player_y], ax     ; Guarda el nuevo valor de y en la variable temporal  
    
    call    checkPlayerColision     ; Verifica si ocasiona colision el nuevo movimiento 

    mov     [player_y], ax          ; Actualiza la posicion del jugador en y

    mov     ax, [player_x]          
    sub     ax, [player_speed]      ; Resta la velocidad del jugador para poder moverlo izquierda
    mov     [temp_player_x], ax     ; Guarda el nuevo valor de x en la variable temporal  

    call    checkPlayerColision     ; Verifica si ocasiona colision el nuevo movimiento 

    mov     [player_x], ax          ; Actualiza la posicion del jugador en x

    jmp     verifyMode              ; Revisa el modo de movimiento (Normal,Pintando,Borrando)


playerLeft:                         ; FUNCION QUE SE ENCARGA DE MOVER EL JUGADOR HACIA LA IZQUIERDA

    mov     al, [yellow_color]      ; Guarda el color del cual se debe pintar el movimiento 
    mov     [currentColor], al      ; Establece el color como el actual para luego colorear si es necesario
    xor     al, al
    mov     ax, [player_x] 
    mov     [color_player_x], ax    ; Guarda las posiones de x de la casilla para pintar en ella
    xor     ax, ax
    mov     ax, [player_y] 
    mov     [color_player_y], ax    ; Guarda las posiones de y de la casilla para pintar en ella
    xor     ax, ax

    mov     ax, 06h                 ; Mueve en 6 al registro ax
    cmp     [player_x], ax          ; Compara si la posicion x esta por tocar un borde con el movimiento
    jle      exitRoutine            ; Si lo tocaria entonces no lo mueve

    call    deletePlayer            ; Sino elimina al jugador de la posicion para moverlo

    mov     ax, [player_x]          
    sub     ax, [player_speed]      ; Resta la velocidad del jugador para poder moverlo izquierda
    mov     [temp_player_x], ax     ; Guarda el nuevo valor de x en la variable temporal 

    call    checkPlayerColision     ; Verifica si ocasiona colision el nuevo movimiento   

    mov     [player_x], ax          ; Actualiza la posicion del jugador en x
    
    jmp     verifyMode              ; Revisa el modo de movimiento (Normal,Pintando,Borrando)

    
playerNE:                           ; FUNCION QUE SE ENCARGA DE MOVER EL JUGADOR HACIA EL NOR-ESTE

    mov     al, [blue_color]        ; Guarda el color del cual se debe pintar el movimiento 
    mov     [currentColor], al      ; Establece el color como el actual para luego colorear si es necesario
    xor     al, al
    mov     ax, [player_x] 
    mov     [color_player_x], ax    ; Guarda las posiones de x de la casilla para pintar en ella
    xor     ax, ax
    mov     ax, [player_y] 
    mov     [color_player_y], ax    ; Guarda las posiones de y de la casilla para pintar en ella

    xor     ax, ax


    mov     ax, 06h                 ; Mueve en 6 al registro ax
    cmp     [player_y], ax          ; Compara si la posicion y esta por tocar un borde con el movimiento
    jle      exitRoutine            ; Si lo tocaria entonces no lo mueve


    call    deletePlayer            ; Sino elimina al jugador de la posicion para moverlo

    mov     ax, [player_y]          
    sub     ax, [player_speed]      ; Resta la velocidad del jugador para poder moverlo arriba
    mov     [temp_player_y], ax     ; Guarda el nuevo valor de y en la variable temporal  
    
    call    checkPlayerColision     ; Verifica si ocasiona colision el nuevo movimiento 

    mov     [player_y], ax          ; Actualiza la posicion del jugador en y

    mov     ax, [player_x]          
    add     ax, [player_speed]      ; Suma la velocidad del jugador para poder moverlo derecha
    mov     [temp_player_x], ax     ; Guarda el nuevo valor de x en la variable temporal  

    call    checkPlayerColision     ; Verifica si ocasiona colision el nuevo movimiento 

    mov     [player_x], ax          ; Actualiza la posicion del jugador en x

    jmp     verifyMode              ; Revisa el modo de movimiento (Normal,Pintando,Borrando) 



verifyMode:                         ; FUNCION QUE SE ENCARGA DE DETERMINAR QUE ACCION HACE SEGUN EL MODO ESTABLECIDO

    xor     ax,ax
    mov     ax, [paintMode]         ; Verifica el estado de pintura
    cmp     ax, 01h
    je      paintInGame             ; Si estamos en modo de pintura, salta a la rutina correspondiente

    mov     ax, [eraseMode]         ; Verifica el estado de borrado
    cmp     ax, 01h
    je      eraseInGame             ; Si estamos en modo de borrado, salta a la rutina correspondiente

    ; Si no estamos en modo de pintura ni de borrado, simplemente movemos al jugador

    ret                             ; Vuelve al bucle principal


togglePaintMode:                    ; FUNCION QUE SE ENCARGA DE CAMBIAR EL ESTADO DE PINTADO

    mov     ax, [eraseMode]         ; Obtiene el valor actual de eraseMode
    cmp     ax, 01h                 ; Verifica si esta en modo borrar 
    jne     togglePaintModeAux      ; Sino lo esta entonces activa modo pintar

    ret                             ; Vuelve al ciclo principal

togglePaintModeAux:                 ; FUNCION COMPLEMENTARIA QUE SE ENCARGA DE CAMBIAR EL ESTADO DE PINTADO

    mov     ax, [paintMode]         ; Obtiene el valor actual de paintMode
    xor     ax, 01h                 ; Invierte el valor (0 a 1 o 1 a 0)
    mov     [paintMode], ax         ; Actualiza paintMode

    ret                             ; Vuelve al ciclo principal

toggleEraseMode:                    ; FUNCION QUE SE ENCARGA DE CAMBIAR EL ESTADO DE BORRADO

    mov     ax, [paintMode]         ; Obtiene el valor actual de paintMode
    cmp     ax, 01h                 ; Verifica si esta en modo pintar 
    jne      toggleEraseModeAux     ; Sino lo esta entonces activa modo pintar

    ret                             ; Vuelve al ciclo principal

toggleEraseModeAux:                 ; FUNCION COMPLEMENTARIA QUE SE ENCARGA DE CAMBIAR EL ESTADO DE PINTADO

    mov     ax, [eraseMode]         ; Obtiene el valor actual de eraseMode
    xor     ax, 01h                 ; Invierte el valor (0 a 1 o 1 a 0)
    mov     [eraseMode], ax         ; Actualiza eraseMode

    ret                             ; Vuelve al ciclo principal


paintInGame:                        ; FUNCION QUE SE ENCARGA DE PINTAR ESTABLECER LAS COORDENADAS PARA PINTAR EN PANTALLA

    mov     cx, [color_player_x]    ; Obtiene el valor de x de la casilla que se va a pintar
    mov     dx, [color_player_y]    ; Obtiene el valor de y de la casilla que se va a pintar
    jmp     paintLoop               ; Llama al paintloop que pintara la casilla


paintLoop:                          ; BUCLE QUE SE ENCARGA DE PINTAR LA CASILLA DEL COLOR CORRESPONDIENTE (FILAS)

    mov     ah, 0ch                 ; Indica que se va a dibujar un pixel en pantalla
    mov     al, [currentColor]      ; Indica el color del pixel (color segun movimiento) 
    mov     bh, 00h                 ; Indica en que pagina lo va a dibujar (predeterminada)
    int     10h                     ; Llama a la interrupcion para dibujar en pantalla
    inc     cx                      ; Incrementa en 1 el cx 
    mov     ax, cx                  
    sub     ax, [color_player_x]    ; Resta 1 a la posicion del jugador para dibujar el siguiente pixel del sprite (dibujando anchura)
    cmp     ax, [player_size]       ; Verifica si el ax es mas grande que el tamano del jugador
    jng     paintLoop               ; Si aun no es mas grande sigue dibujando la siguiente columna
    jmp     paintLoop2              ; Sino salta a la siguiente funcion de dibujo (dibujar altura del sprite)



paintLoop2:                         ; BUCLE QUE SE ENCARGA DE PINTAR LA CASILLA DEL COLOR CORRESPONDIENTE (COLUMNAS)

    mov     cx, [color_player_x]    ; Restablece el valor de las columnas
    inc     dx                      ; Aumenta en la fila
    mov     ax, dx                  
    sub     ax, [color_player_y]    ; Resta 1 a la posicion del jugador para dibujar el siguiente pixel del sprite (dibujando altura)
    cmp     ax, [player_size]       ; Verifica si el ax es mas grande que el tamano del jugador
    jng     paintLoop               ; Si aun no es mas grande sigue dibujando la siguiente fila

    ret                             ; Sino vuelve al bucle principal 

    
eraseInGame:                        ; BUCLE QUE SE ENCARGA DE BORRAR LA CASILLA DE LA PANTALLA

    mov     al, 00h                 ; Guarda el hexa del color verde en el registro al
    mov     [currentColor], al      ; Establece el color como el actual
    xor     al, al
    mov     cx, [color_player_x]    ; Obtén el tamaño del jugador (ancho o alto, asumiendo que es cuadrado)
    mov     dx, [color_player_y]    ; Establece el contador de bucle para el tamaño del jugador
    jmp     paintLoop
    

    ret                             ; Sino vuelve al bucle principal 

checkPlayerColision:                ; FUNCION DE VERIFICAR LA WIN CODITION SI SE DETECTA LA COLISION CON LA PARED

    push    ax
    mov     cx, [temp_player_x]
    mov     dx, [temp_player_y]     ; Se setean los valores necesarios para ejecutar la interrupcion 10h
    mov     ah, 0dh
    mov     bh, 00h
    int     10h

    mov     [lastColor], al         ; Establece el color de la casilla siguiente

    
    cmp     al, [currentColor]      ; Verifica si el color al que me mueve es igual al color que voy a pintar 
    je      skipWin                 ; Si es asu entonces no puede ganar por lo que sale de la verificacion


    
    mov     bl, [paintMode]         ; Carga el valor de paintMode en bl 
    cmp     bl, 01h                 ; Verifica si el modo de pintura esta activado
    je      skipAdditionalComparison; Si paintMode es 1 y por ende esta activo, entonces salta a la comparación adicional de color

    
skipAdditionalComparison:           ; FUNCION QUE VERIFICA EL COLOR CON EL CUAL CHOCA PARA DAR LA CONDICION DE GANADOR
    
    mov     al, [lastColor]         ; Vuelve a cargar el color de la casilla destino

    cmp     al, [purple_color]      ; Compara el color de la castilla destino con los de pintado
    je      win      
   

skipWin:                            ; FUNCION QUE SALTA LA PANTALLA DE WIN

    pop    ax

    ret
      

resetGame:                          ; FUNCION QUE REINICIA EL JUEGO 

    call    clearCounter            ; Llama al reiniciador del temporizador y flags

    call    clearScreen             ; Llama al limpiador de pantalla 

    jmp     startGame               ; Vuelve a llamar al inicio de juego

win:                                ; FUNCION QUE SE ENCARGA DEL MENU DE GANADOR

    call    clearCounter            ; Llama al reiniciador del temporizador y flags

    call    clearScreen             ; Llama al limpiador de pantalla

    jmp     winnerLoop              ; Llamar a la animacion de ganador


lose:                               ; FUNCION QUE SE ENCARGA DEL MENU DE PERDEDOR

    call    clearCounter            ; Llama al reiniciador del temporizador y flags

    call    clearScreen             ; Llama al limpiador de pantalla

    jmp     loserLoop               ; Llamar a la animacion de perdedor


clearCounter:                       ; FUNCION QUE SE ENCARGA DE REINICIAR EL TEMPORIZADOR Y LAS FLAGS

    mov     word [secondsLeft], 60  ; Reinicia los segundos restantes a 60 (1 mins)
    mov     word [secondsdecs], 54  ; Reinicia las decenas  restantes a 6 
    mov     word [secondsunit], 48  ; Reinicia las unidades restantes a 0 
    mov     word [paintMode], 00h   ; Reinicia el valor de la flag de pintar a 0
    mov     word [eraseMode], 00h   ; Reinicia el valor de la flag de borrar a 0


exitRoutine:                        ; FUNCION QUE SE VOLVER A LOS CICLOS PRINCIPALES

    ret                             ; Permite salir de una rutina y vuelve al ciclo principal


