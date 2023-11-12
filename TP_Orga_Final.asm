;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                            
                                    ;TP - OC1;
                                    ;********;
                                    

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


org 100h


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;Se limpian los registros
xor ax,ax
xor bx,bx
xor cx,cx
xor dx,dx

;Se mueve al inicio para dar lugar al juego
jmp inicio

  
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                            
                                    ;DEFINICIONES;
                                    ;************;
                                                  
                                                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;definicion del tablero 

tablero  db "***************************",10,13
         db "** X * X * X * X * X * X **",10,13
         db "***************************",10,13
         db "** X * X * X * X * X * X **",10,13
         db "***************************",10,13
         db "** X * X * X * X * X * X **",10,13
         db "***************************",10,13
         db "** X * X * X * X * X * X **",10,13
         db "***************************",10,13
         db "** X * X * X * X * X * X **",10,13
         db "***************************",'$'

;definicion del tablero solucion

solucion db "AHEKBO"
         db "NCJGID"
         db "GMAEKN"
         db "FMHLCD"
         db "BJILFO",'$'    
         

;definicion del puntaje en pantalla

puntaje_en_pantalla db "puntaje: ","$"


;definicion del msj quiere reiniciar? en pantalla

msjReinicio_en_pantalla  db 10,13
                         db "      Juego Terminado!!!",10,13
                         db 10,13
                         db "      Presione ENTER",10,13
                         db 10,13
                         db "      para reiniciar...",10,13
                         db 10,13
                         db "      Presione ESCAPE",10,13
                         db 10,13
                         db "      para salir...",10,13,'$'
                        
                        

;definicion de teclas

up EQU 'y'
down EQU 'n'
left EQU 'g'
right EQU 'j'
uncover EQU 'h'

escape EQU 27
enter EQU 13 



;definiciones de otras variables

tot_pos_x EQU 6; Total de posiciones licitas por renglon
tot_pos_y EQU 5; Total de posiciones licitas por columna 

posInicialCursor_column db 3  ;se establce la posicion de columna inicial del cursor
posInicialCursor_row db 1     ;se establce la posicion de fila inicial del cursor

pos_actual_solucion dw 0;a medida que se mueve por el tablero, tambien va actualizando
                        ;esta variable para que coincidan las posiciones tablero-solucion
                                                                                 
                                                                                 
cantDesc_JugadaActual db 0; Cantidad de posiciones descubiertas en el juego actual


move_row  db 1          ;aca se guarda la posicion de la fila
move_column  db 1       ;aca se guarda la posicion de la columna
move1_row db 0      ;si es la primer jugada se copia aca move_row
move1_column db 0   ;si es la primer jugada se copia aca move_column
move2_row db 0      ;si es la segunda jugada se copia aca move_row
move2_column db 0   ;si es la segunda jugada se copia aca move_column


valorDesc_mov1 db 0 ;variables para almacenar los valores descubiertos
valorDesc_mov2 db 0 ;en la jugada en curso


points db 000     ;Contador del puntaje del jugador

centena db 0      ;variables utilizadas para transformar a codigo ascii el puntaje
decena db 0
unidad db 0
resto db 0

total_desc db 0 ;usada para contar el total de posiciones descubiertas  

       
       
       
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                            
                                        ;MAIN;
                                        ;****;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



     
reiniciar: 

call printPreReinicio        ;se imprime la pantalla de reinicio-fin

errorTecla:

mov ah, 00h
int 16h

cmp al, enter
je reseteo

cmp al, escape
je fin

jne errorTecla               ;en el caso que no sea enter o escape va a errorTecla
                             ;para ponerse en escucha nuevamente




reseteo:

;se resetean las variables del juego y comienza de nuevo

call reset

jmp inicio



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



inicio:

push bp  ;se guarda el puntero base de la pila para evitar la perdida 
         ;del offset retorno (direccion) 
         

;se establece el tamanio de pantalla

mov ah, 00h ;servicio para establecer el tamanio de pantalla
mov al, 1   ;40x25  (x=40 y=25)
int 10h
 
 
;limpieza de la pantalla

call limpiarPantalla


;dibujo del tablero

call print_board  


 
 
juegoActivo?:
 
 
;imprime el puntaje
    
call print_puntaje


;se establece la condicion par que el juego este activo 
;(30 posiciones descubiertas)
                
cmp total_desc,30 
je reiniciar  


;se llama al procedimiento encargado de procesar las acciones del
;jugador dentro de cada jugada 
                               
call action_validator
                        
                        
;pregunta al final de cada jugada de 2 movimientos si el juego sigue activo

jmp juegoActivo?
 


;salida del programa

fin:

pop bp  ;se restaura el puntero base de la pila para evitar
        ;la perdida del retorno principal, ya que debe leer de ahi
        ;la direccion offset de retorno
    
;ret final del juego
      
ret
 
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                            
                            ;PROCEDIMIENTOS AUXILIARES;
                            ;*************************;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    
reiniciar_cursor proc
    mov dh, posInicialCursor_row     ;dh: set fila despues de dibujar
	mov dl, posInicialCursor_column  ;dh: set column despues de dibujar
	mov bh, 0                        ;bh: es el numero de pagina
	mov ah, 2                        ;este servicio setea la posicion del cursor
	int 10h
    
    ret
    
reiniciar_cursor endp



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

               
               
limpiarPantalla proc

    mov ah, 02h   ;servicio para posicionar el cursor
    mov dx, 0000h ;coordenadas 0 0 para que ubique el cursor al inicio
    int 10h       ;coloca el cursor en la posicion indicada
    mov ax, 0600h ;servicio de la int 10h para limpiar la pantalla
    mov bh, 5Fh   ;1er digito: color de fondo; 2do digito: color de fuente
    mov cx, 0000  ;coordenada desde donde queremos que limpie
    mov dx, 0A1Ah ;coordenada que indica hasta donde queremos que limpie
    int 10h       ;limpia la pantalla
    
    ret 
    
limpiarPantalla endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



print_board proc 
;Procedimiento encargado de presentar en pantalla el tablero del juego  
    
    mov ax, 0600h ;servicio de int 10h para setear atributos de la pantalla
    mov bh, 1Fh   ;1er digito: color de fondo; 2do digito: color de fuente
    int 10h
    
    
    mov dx,offset tablero
    mov ah,9
    int 21h
    
    mov ch, 0 ;setea el cursor como un cuadro
    mov cl, 7 ;setea el tamanio del cuadro
    mov ah, 1 ;servicio de 10h que le da forma al cursor
    int 10h
    
    
    call reiniciar_cursor
    
    
    ret
    
print_board endp  



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


 
 
calcularPuntaje proc
 
    
    ;se desarma el contenido de la variable points en centena, decena y unidad    
    ;despues se le suma 30 para convertirlo a asscii hexadecimal y se lo imprime en orden
    
    ;centena
    xor ax,ax
    mov al, points  
    mov cl, 100     ;se divide por 100 para separar el digito de centena en al
    div cl
    add al, 30h
    mov centena, al
    mov resto, ah   ;se guarda el resto de la division
    
    ;decena
    xor ax,ax
    mov al, resto   ;copia el resto de la division a al
    mov cl, 10      ;se divide por 10 para separar el digito de decena en al
    div cl
    add al, 30h
    mov decena, al
    mov resto, ah
                  
    ;unidad
    
    mov al, resto  ;copia el resto de la division a al que ya es unidad
    xor ah,ah
    add al, 30h
    mov unidad, al
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;imprime centena
    mov dl,centena
    mov ah,6
    int 21h
    
    ;imprime decena
    mov dl,decena
    mov ah,6
    int 21h
    
    ;imprime unidad
    mov dl,unidad 
    mov ah,6
    int 21h 
    
    ret    

calcularPuntaje endp  



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


 
print_puntaje proc 
;Procedimiento encargado de presentar en pantalla el puntaje 
    
    push dx       ;se salva la posicion del cursor       
           
                  ;se setea el cursor para que imprima el puntaje debajo del tablero
    mov dh, 12    ;dh: set fila despues de dibujar
	mov dl, 3     ;dl: set columna despues dibujar
	
	mov ah, 2     ;este servicio setea la posicion del cursor
	int 10h
    
    mov dx,offset puntaje_en_pantalla ;se imprime la palabra puntaje: 
    mov ah,9
    int 21h
    
    call calcularPuntaje  ;proc que convierte a hexa los digitos de puntaje y
                          ;los imprime en pantalla
    
    pop dx                ; se restaura la posicion del cursor
    call SetCursor
    
    
	 
    ret
    
      
    
print_puntaje endp




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



action_validator proc 
;Procedimiento encargado de validar si las teclas oprimidas por el usuario
;son las definidas en el programa. Tambien se encarga de invocar los procedimientos
;correspondientes a la accion que debe llevarse a cabo de acuerdo con el tipo de 
;tecla presionada por el usuario. Si se presiona enter, se invoca el procedimiento 
;enter_actions y si se presiona cualquier tecla de movimiento se invoca mov_actions
 
  teclas:   mov ah,00h         ;servicio de la int 16h para escuchar 
                               ;ingresos de teclado
            int 16h
            
            cmp al, up
            je mov_actions
            
            cmp al, down
            je mov_actions
            
            cmp al, left
            je mov_actions
            
            cmp al, right
            je mov_actions
            
            cmp al, uncover
            je enter_actions
            
            cmp al, escape     ;en todo momento se puede salir del juego
            je reiniciar       ;reiniciarlo o salir directamente si se presiona escape   
            
            jmp teclas          ;si no se presiona nada vuelve a teclas para ponerse
                                ;nuevamente a la escucha
            
            ret
            
action_validator endp  
 
 
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



mov_actions proc 
;Procedimiento encargado de implementar la logica necesaria para determinar las
;acciones a llevar a cabo cada vez que se oprime una tecla de movimiento.. 

        cmp al, up
        je ARRIBA
            
        cmp al, down
        je ABAJO
            
        cmp al, left
        je IZQUIERDA
            
        cmp al, right
        je DERECHA
            
        ;;;;;;;;;;;;;
        ;;;;;;;;;;;;;
        ;;;;;;;;;;;;;
        
        ARRIBA:    
        mov ch,move_column  ;se copia la posicion y del primer movimiento
        cmp ch,1            ;se compara con 1 ya que es el limite superior
        je preMovDown       ;si esta en 1 solo se puede mover para abajo
        
        cmp al, up          ;si no esta en un limite proseguira para moverse para arriba
        je movUp   
        
        ;;;;;;;;;;;;;;
        
        ABAJO:
        mov ch,move_column  ;se copia la posicion y del primer movimiento
        cmp ch,tot_pos_y    ;se compara con el limite inferior de la columna que es 5
        je teclas           ;si es igual vuelve a teclas, ya que no se puede mover fuera  
        
        preMovDown:         ;si llegaron a un limite superior se fija aca para permitir
                            ;moverse en la otra direccion si se presiona n
        cmp al, down
        je movDown  
        jne teclas
        
        ;;;;;;;;;;;;;;
        
        IZQUIERDA: 
        mov cl,move_row   ;se copia la posicion x del primer movimiento
        cmp cl,1          ;se compara con 1 ya que es el limite izquierdo
        je preMovRight    ;si esta en 1 solo se puede mover a la derecha
        
        cmp al, left      ;si no esta en un limite proseguira para moverse a la izquierda
        je movLeft   
        
        ;;;;;;;;;;;;;;
        
        DERECHA:
        mov cl,move_row   ;se copia la posicion x del primer movimiento
        cmp cl,tot_pos_x  ;se compara con el limite de la linea que es 6
        je teclas         ;si es igual vuelve a teclas, ya que no se puede mover fuera
        
                          ;si no esta en un limite proseguira para moverse a la derecha
        preMovRight:      ;si llegaron a un limite a la izquierda se fija aca para permitir
                          ;moverse en la otra direccion si se presiona j  
        cmp al, right     
        je movRight
        jne teclas
        
        
        ;;;;;;;;;;;;;
        ;;;;;;;;;;;;;
        ;;;;;;;;;;;;;
        
        
        movUp: sub dh, 2                    ;para reposicionar el cursor columna
               dec move_column              ;se decrementa ya que sube
               sub pos_actual_solucion,6    ;actualiza eso en la posicion solucion
               call SetCursor               ;llamo al procedimiento para setear cursor
               jmp teclas
               ret
        
        
        movDown: add dh, 2                  ;para reposicionar el cursor columna 
                 inc move_column            ;se incrementa ya que baja
                 add pos_actual_solucion,6  ;actualiza eso en la posicion solucion
                 call SetCursor             ;llamo al procedimiento para setear cursor
                 jmp teclas
                 ret
         
        
        movLeft: sub dl, 4                  ;para reposicionar el cursor fila
                 dec move_row               ;se decrementa ya que va a izquierda
                 dec pos_actual_solucion    ;actualiza eso en la posicion solucion    
                 call SetCursor             ;llamo al procedimiento para setear cursor
                 jmp teclas
                 ret
        
        
        movRight: inc move_row              ;se incrementa ya que va a la derecha 
                  inc pos_actual_solucion   ;actualiza eso en la posicion solucion
                  add dl, 4                 ;para reposicionar el cursor fila
                  call SetCursor            ;llamo al procedimiento para setear cursor
                  jmp teclas
                  ret
       
        ret
        
mov_actions endp



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



    
enter_actions proc 
;Procedimiento encargado de implementar la logica necesaria para determinar las
;acciones a llevar a cabo cada vez que el usuario presiona la tecla uncover. Su comportamiento
;depende de los valores de las variables de estado del programa (cantDesc_JugadaAcual,
;estadoActual,valorDesc_mov1, valorDesc_mov2).
    

   
    mov ah, 08h ;servicio para leer un caracter desde la pantalla 
    int 10h     ;cuando lo lee lo guarda por defecto en al
    
    cmp al, "X" ;lo compara con la posicion tapada "X"
    jne teclas  ;si no esta tapada, "X", no hace nada y vuelve a esperar otro ingreso de tecla
    
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;
     
    call uncover_pos            ;procedimiento encargado de descubrir las posiciones
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    cmp cantDesc_JugadaActual,1
    je guardarValor1
    
    cmp cantDesc_JugadaActual,2
    je guardarValor2
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    guardarValor1:      
    mov valorDesc_mov1,al
    jmp finCantDesc
    
    guardarValor2:        
    mov valorDesc_mov2, al 
    
    ;;;;;;;;;;;;;;;;;;;;;;;
    
    ;una vez que termina el 2do movimiento se comparan los valores de ambos
    ;(letras descubiertas de ambos) usando el procedimiento val_positions
    
    call val_positions 
    
    
    finCantDesc:
    
    ret

enter_actions endp        



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    
uncover_pos proc 
;Procedimiento encargado de reemplazar en la pantalla la X del tablero por su
;correspondiente valor en la estructura de datos ocultos (solucion) 
       
       
       
       call juegoActual             ;se fija el numero de movimiento dentro de la jugada
                                    ;y ademas guarda la posicion x e y donde se apreto h
                                    ;para despues poder taparla si no es igual a la otra
                                    ;destapada
       
       
       push dx                      ;se salva la posicion del cursor
       
       mov bx, offset solucion      ;se para al principio de solucion
       add bx,pos_actual_solucion   ;se le suma la posicion actual del tablero
       mov dl,[bx]                  ;su contenido se carga a dl para ser mostrado  
       mov ah, 6
       int 21h
       
       
       pop dx                       ;se restaura la posicion del cursor
       call SetCursor
        
       ret 
       
uncover_pos endp
  
  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    

juegoActual proc
;Procedimiento que setea el movimiento en cada jugada, entre 1er mov y 2do mov 
   
       cmp cantDesc_JugadaActual,0
       je jugada1
        
       cmp cantDesc_JugadaActual,1
       je jugada2 
       
       jugada1:
              
       mov move1_column, dh  ;como es la jugada uno se carga move_column en move_column1
       mov move1_row, dl     ;como es la jugada uno se carga move_row en move_row1
                             ;se usaran en clean_up si no son son iguales los val desc
                             
       inc cantDesc_JugadaActual
       jmp  finJuegoActual
       
       jugada2:
       
       mov move2_column, dh  ;como es la jugada dos se carga move_column en move_column2
       mov move2_row, dl     ;como es la jugada dos se carga move_row en move_row2 
                             ;se usaran en clean_up si no son son iguales los val desc
       
       mov cantDesc_JugadaActual, 2 
       jmp  finJuegoActual 
       
       finJuegoActual:
       
       ret
       
juegoActual endp




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



val_positions proc 
;Procedimiento encargado de verificar si las dos ultimas posiciones descubiertas
;corresponden a un acierto o a un fallo.  

    mov al, valorDesc_mov1
    cmp al, valorDesc_mov2  
    
    ;si no son iguales que salte a limpiar
    jne limpiar
    
    ;si son iguales que sume 1 punto
    je correctas
    
    correctas:           
    mov cantDesc_JugadaActual,0;se pone en 0 para que empiece una nueva jugada
    add total_desc,2 ;se suma las dos descubiertas (cuando esto llegue a 30 termina el juego) 
    add points, 10
    jmp finVal_positions
    
    limpiar:
    cmp points,0
    je sinResta
    
    sub points, 2
    
    sinResta:
    mov cantDesc_JugadaActual,0 ;se pone en 0 para que empiece una nueva jugada
    call clean_up  ;llama a clean_up para que oculte las pos y de lugar a una nueva jugada
    
    finVal_positions:
    ret
    
val_positions endp



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


               
clean_up proc 
;Procedimiento encargado de volver a cubrir las posiciones descubiertas 
;en caso de que las dos ultimas movidas correspondan a una jugada fallida.
;Tambien se encarga de inicializar las variables de estado para definir el
;comienzo de una nueva jugada.
  
       
    mov dh, move1_column
    mov dl, move1_row
    
    mov bh, 0
    mov ah, 2           ;este servicio setea la posicion del cursor
	int 10h
	
    ;reemplaza el valor donde este parado el cursor
    mov dl,"X"                   
    mov ah, 6
    int 21h
    
    
     
    mov dh, move2_column
    mov dl, move2_row
    
    
    mov ah, 2            ;este servicio setea la posicion del cursor
	int 10h
    
    push dx              ;se salva la posicion del cursor
    
    ;reemplaza el valor donde este parado el cursor
    mov dl,"X"                   
    mov ah, 6
    int 21h
    
    pop dx               ;se restaura la posicion del cursor
    call SetCursor   
    
    ret
    
clean_up endp



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



SetCursor proc 
;Setea la forma del cursor y lo muestra titilando en la posicion establecida
             
        mov ch, 0 ;setea el cursor como un cuadro
     	mov cl, 7 ;setea el tamanio del cuadro
     	mov ah, 1 ;servicio de 10h que le da forma al cursor
     	int 10h
     	
     	;;;;;;;;;;;
     	
        mov ah, 02h ;muestra el cursor titilando
        mov bh, 00
        int 10h             
        ret

SetCursor endp  


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

   
    
printPreReinicio proc

    call limpiarPantalla
       
    mov dx, offset msjReinicio_en_pantalla 
    mov ah,9
    int 21h
   
    
    ret 

printPreReinicio endp



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 


reset proc
    
    ;Se limpian los registros
    xor ax,ax
    xor bx,bx
    xor cx,cx
    xor dx,dx
    
    call limpiarPantalla
    
    mov total_desc,0             ;se reinicia el total de descubiertos
    mov points,0                 ;se reinician los puntos
    
    mov move_row,1               ;se reinicia la posicion x
    mov move_column,1            ;se reinicia la posicion y
    
    call reiniciar_cursor        ;se reinicia la posicion del cursor
    
    mov pos_actual_solucion,0    ;se reinicia la posicion de solucion    
    
    ret
    
reset endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;