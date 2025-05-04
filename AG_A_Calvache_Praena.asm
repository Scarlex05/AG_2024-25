#####################################################################
#
#		ARKANOID EN MIPS32
#  		---------------
# Proyecto de Arquitecturas Graficas - URJC
#
# Autores:
# - Calvache Amador, Carla
# - Pedroso Praena, Rubén
#
# Bitmap Display:
# - Unit width in pixels: 8
# - Unit height in pixels: 8 
# - Display width in pixels: 256 
# - Display height in pixels: 512
# - Base Address for Display: 0x10008000 ($gp)
#
# Maximo objetivo alcanzado en el proyecto:
# - Juego base + 3 ampliaciones
#
# Ampliaciones implementadas 
# - Punto(s) 1/3/4
#
# Instrucciones del juego:
# El jugador controla la barra que hace que la bola rebote, ganara la partida cuando se hayan roto todos los bloques
# Perdera en el caso de que la bola se pierda 3 veces 
# La barra se controla con las teclas a (mover a la izquierda) y d (mover a la derecha)
#####################################################################

.data

frameBuffer:	.space 0x80000				# 256 ancho x 512 alto

# CONSTANTES
maxX:		.word 256				# Se almacenan las variables de las dimensiones
maxY:		.word 512				# para hacer llamadas a ellas directamente
anchoBarra:	.word 4					# Tamano de la barra
movIz:		.word -4				# Movimiento de la barra hacia la izquierda
movDer:		.word 4					# Movimiento de la barra hacia la derecha
limIzq:		.word 7044				# Limite al que puede llegar la plataforma cuando se mueve a la izquierda
limDer:		.word 7148				# Limite al que puede llegar la plataforma cuando se mueve a la izquierda
fraseF:		.asciiz "Tu puntuacion final es: "	# Frase para mostrar al terminar el juego
fraseI:		.asciiz "Desea iniciar el juego: "	# Frase para mostrar al comienzo del juego

# Variables del juego
bar_pos:	.word 7096				# posicion inicial de la barra 
ball_pos:	.word 6976				# posicion inicial de la bola
ball_dir:	.word 124	#124			# direccion inicial de la bola
ball_init_pos:	.word 6976				# variables para manejar el reinicio de la bola
ball_init_dir:	.word 124
puntuacion:	.word 0					# Variable que guarda la puntuacion
vidas:		.word 3					# Variable que va a guardar las vidas

# Colores
colorFondo:	.word 0x003A2A52		# Morado oscuro
colorBarra:	.word 0x00A5F2A5		# Verde claro
colorBorde:	.word 0x00482BD6		# Azul Ocuro
colorBorde2:	.word 0x00EC2C16		# Rojo
colorBall:	.word 0x00E7EBAE		# Amarillo claro
colorRect:	.word 0x00DE35B9		# Rosa			

.text
.globl main

main:
	la $gp, 0x10008000		# Inicializar el $gp para la base address
	lw $t2,ball_pos			#Se almacena la posicion de la bola en una variable fija
	add $s2, $t2, $gp
	add $s0,$gp,$t1	
	lw $s3, ball_dir		#Se almacena la direccion inicial de la bola que se ira modificando con los rebotes

	# Mostrar menu de inicio
	li	$v0,50
	la	$a0, fraseI
	syscall				# Ensena la frase junto a unas opciones

	beq	$a0, $zero, init_game	# Si le da a si, se inicia el juego
	li	$v0, 10			# Si no, no se ejecuta
	syscall


init_game:


	# Dibujar fondo
	jal draw_background
	jal draw_Border
	# Dibujar rectangulos
	jal draw_rectangles
	# Mostrar el juego
	jal loop

	
draw_background:
	# dibujar el fondo
	la $t0, frameBuffer
	subi $t0, $t0, 32768
	li $t1, 32768
	lw $t2, colorFondo

l1:
	sw $t2, 0 ($t0)
	addi $t0, $t0, 4
	addi $t1, $t1, -1
	bnez $t1, l1
	jr $ra


draw_Border:
	# dibujar los bordes	

	# parte de arriba
	la $t0, frameBuffer	
	subi $t0, $t0, 32768
	addi $t1, $zero, 32		# t1 = 32 (256/8)
	lw $t2, colorBorde		# se guarda en color del borde

bordeSuperior:	
	sw $t2, 0($t0)			# color pixel de fondo
	addi $t0, $t0, 4		# nuevo color pixel
	addi $t1, $t1, -1		# reducir contador de pixeles
	bnez $t1, bordeSuperior		# repetir hasta completar el borde
	
	# parte derecha

	la $t0, frameBuffer	
	subi $t0, $t0, 32768
	addi $t0, $t0, 252		# poner el pixel de inicio arriba a la derecha
	addi $t1, $zero, 64		# t1 = 64 (512/8)

bordeDerecha:
	sw $t2, 0($t0)			# color pixel de fondo
	addi $t0, $t0, 128		
	addi $t1, $t1, -1		# reducir contador de pixeles
	bnez $t1, bordeDerecha		# repetir hasta completar el borde
	
	# parte izquierda
	la $t0, frameBuffer		# cargar la direccion del frame buffer
	subi $t0, $t0, 32768
	addi $t1, $zero, 64		# t1 = 64 (512/8)

bordeIzquierda:
	sw $t2, 0($t0)			# color pixel de fondo
	addi $t0, $t0, 128		
	addi $t1, $t1, -1		# reducir contador de pixeles
	bnez $t1, bordeIzquierda	# repetir hasta completar el borde

	# parte de abajo
	la $t0, frameBuffer		# cargar la direccion del frame buffer
	subi $t0, $t0, 32768
	addi $t0, $t0, 8064		# poner pixel para que este cerca del borde de la izquierda
	addi $t1, $zero, 32		# t1 = 32 (256/8)
	lw $t2, colorBorde2		#cambia de color ya que si la pelota toca esta parte terminaria el juego	

bordeAbajo:
	sw $t2, 0($t0)			# color pixel de fondo
	addi $t0, $t0, 4		# nuevo color pixel
	addi $t1, $t1, -1		# reducir contador de pixeles
	bnez $t1, bordeAbajo		# repetir hasta completar el borde
jr $ra

#Dibujar los rectangulos en una fila
draw_rectangles:
	la $t0, frameBuffer
	subi $t0, $t0, 32768
	addi $t0, $t0, 2584		# poner los rectangulos en la parte superior
	lw $t1, colorRect
	li $t2, 10			# numero de rectangulos a dibujar (2 pixeles de ancho cada uno)
	
draw_rect_loop:
	beqz $t2, draw_rect_end		# Si se ha dibujado la fila completa, terminar
	
	sw $t1, 0($t0)			# dibujar el primer pixel del rectangulo
	addi $t0, $t0, 4		# moverse al siguiente pixel
	sw $t1, 0 ($t0)			# dibujar el segundo pixel del rectangulo
	addi $t0, $t0, 4        	# Moverse al siguiente píxel
	addi $t2, $t2, -1		# reducir el contador de rectangulos
	
	j draw_rect_loop			# desactivar el flag para evitar dibujar mas filas
	
draw_rect_end:
	jr $ra
	

#game_loop:
#bucle principal del juego
loop:
	lw	$t9, 0xffff0004		# pillar keypress del input del teclado
	### parar por 90 ms asi el radio de frecuancia es sobre 10
	addi	$v0, $zero, 32	# syscall parado
	addi	$a0, $zero, 250	# 250 ms
	syscall
	
	jal draw_Border
	jal draw_ball
	beq	$t9, 100, movimientoDer	# si la tecla pulsada = 'd' se mueve a la derecha
	beq	$t9, 97, movimientoIzq	# si la tecla pulsada = 'a' se mueve a la izquierda
	jal draw_bar
	
	j loop
	
#Movimiento hacia la derecha
movimientoDer:
	jal clear_bar			#limpia la barra en su posici�n actual
	lw $t0, bar_pos			#carga la posicion de la barra
	lw $t2, limDer			#carga el limite derecho
	beq $t0,$t2,end_movDer		#Si coinciden la plataforma no se mueve mas
	lw $t1, movDer			#carga el desplazamiento que se quiere sumar a la barra
	add $t0, $t0, $t1		#Suma el movimiento a bar_pos
	sw $t0, bar_pos			#guarda el valor
	jal draw_bar			#dibuja la plataforma
	jal loop			#se vuelve a ejecutar el loop

#Si llega al limite derecho
end_movDer:
	jal draw_bar
	j loop
	
#Movimiento hacia la izquierda
movimientoIzq:
	jal clear_bar			#limpia la barra en su posici�n actual
	lw $t0, bar_pos			#carga la posicion de la barra en la x
	lw $t2, limIzq			#carga el limite izquierdo
	beq $t0,$t2,end_movIzq		#Si coinciden la plataforma no se mueve mas
	lw $t1, movIz			#carga el desplazamiento que se quiere sumar a la barra
	add $t0, $t0, $t1		#Suma el movimiento a bar_pos
	sw $t0, bar_pos			#guarda el valor
	jal draw_bar			#dibujamos la plataforma
	jal loop			#volvemos e ejecutar el loop
	
#Si llega al limite izquierdo	
end_movIzq:
	jal draw_bar
	j loop

draw_bar:
	# dibujar la barra en su posicion actual
	lw $t0, bar_pos
	add $t0, $t0, $gp
	lw $t2, anchoBarra
	lw $t3, colorBarra
	
draw_bar_loop:
	beqz $t2, draw_bar_end	# Si se ha dibujado el ancho completo, terminar
	sw $t3, 0($t0)		# Dibujar el pixel de la barra
	addi $t0, $t0, 4	# Moverse al siguiente pixel en la linea
	addi $t2, $t2, -1	# Incrementar el contador del ancho
	j draw_bar_loop

draw_bar_end:
	jr $ra
clear_bar:
    # limpiar la barra en su posicion actual
    lw $t0, bar_pos
    add $t0, $t0, $gp
    lw $t2, anchoBarra
    lw $t3, colorFondo      # usar el color de fondo para limpiar

clear_bar_loop:
    beqz $t2, clear_bar_end  # Si se ha limpiado el ancho completo, terminar
    sw $t3, 0($t0)           # Limpiar el pixel de la barra (poner el color de fondo)
    addi $t0, $t0, 4         # Moverse al siguiente pixel en la linea
    addi $t2, $t2, -1        # Decrementar el contador del ancho
    j clear_bar_loop

clear_bar_end:
    jr $ra
   


draw_ball:

	lw $t0, colorFondo        # se guarda el color del fondo para comprobar las colisiones
    	lw $t1, colorBall         # se guarda el color de la bola
    	lw $t6, 0($s2)            # se guarda la posicion actual de la pelota para limpiarla despues
	
	
    	lw $t2, 4($s2)            # variable que comprueba la posicion a la derecha de la pelota
    	lw $t3, -128($s2)         # variable que comprueba la posicion encima de la pelota
    	lw $t4, -4($s2)           # variable que comprueba la posicion a la izquierda de la pelota
    	lw $t5, 128($s2)          # variable que comprueba la posicion debajo de la pelota
	
	# Verificar colision con la barra
    	lw $t7, bar_pos
    	add $t7, $t7, $gp
    	lw $t8, anchoBarra
    	add $t8, $t7, $t8         # calcular el extremo derecho de la barra

    	# Detectar colision con la barra y cambiar la direccion de la pelota
    	ble $s2, $t7, no_bar_collision
    	bge $s2, $t8, no_bar_collision
    	
    	# Si la pelota esta dentro de la barra, rebotar hacia arriba y cambiar direccion
	beq $t5, $t0, no_bar_collision	# si no hay colision con la parte superior de la barra, continuar

	# Detectar la parte de la barra tocada
    	sub $t9, $s2, $t7         # Calcular la posicion relativa en la barra
    	sra $t9, $t9, 2           # Dividir por 4 para obtener la posicion en terminos de pixeles de barra

   	blt $t9, 2, movIzqArriba_Ball   # Si esta en la parte izquierda de la barra, moverse a la izquierda y arriba
    	bgt $t9, 2, movDerArriba_Ball   # Si esta en la parte derecha de la barra, moverse a la derecha y arriba

    	# Si esta en el centro de la barra, moverse hacia arriba
    	j movArriba_Ball
    	
no_bar_collision:

	# verificar colision con los rectangulos rosas
	lw $t6, colorRect
	beq $t2, $t6, clear_rectangle_right
	beq $t3, $t6, clear_rectangle_top
	beq $t4, $t6, clear_rectangle_left
	beq $t5, $t6, clear_rectangle_bottom
	
	# Colisiones con los bordes
	lw $t7, colorBorde
    	bne $t2,$t0, check_borde_right
    	bne $t3,$t0, check_borde_top
    	bne $t4,$t0, check_borde_left
    	bne $t5, $t0, check_borde_bottom
    	    	
	# Limpiar la posicion anterior de la pelota
	sw $t0, 0 ($s2)			# limpia el color en la posicion anterior del pixel
	
	sub $s2,$s2,$s3			#Se guarda la nueva posicion de la pelota sino sucede nada de lo anterior
	sw $t1, 0($s2)			#guarda el color en la posicion del pixel
	jr $ra				#vuelve al loop

clear_rectangle_right:
	sw $t0, 4($s2)
	j movDer_Ball
	
clear_rectangle_top:
	sw $t0, -128($s2)
	j movAbajo_Ball
	
clear_rectangle_left:
	sw $t0, -4($s2)
	j movIzq_Ball

clear_rectangle_bottom:
	sw $t0, 128($s2)
	j movArriba_Ball

check_borde_right:
	beq $t2, $t7, movDer_Ball	# Si el pixel es azul del borde, moverse a la izquierda
	j movDer_Ball

check_borde_top:
	beq $t3, $t7, movAbajo_Ball	# Si el pixel es azul del borde, moverse abajo
	j movAbajo_Ball
	
check_borde_left:
	beq $t4, $t7, movIzq_Ball	# Si el pixel es azul del borde, moverse a la derecha
	j movIzq_Ball

check_borde_bottom:
	beq $t5, $t7, movArriba_Ball	# Si el pixel es azul del borde, moverse arriba
	j movArriba_Ball


movDer_Ball:
	addi $s3,$s3, 8			#Suma al movimiento de la pelota 8 para que se mueva hacia la izquierda ahora
	# Limpiar la posición anterior de la pelota
	sw $t0, 0 ($s2)			#limpia el color de la posición anterior del pixel
	sub $s2,$s2,$s3			#Se guarda la nueva posicion de la pelota
	sw $t1, 0($s2)			#guarda el color en la posicion del pixel
	jr $ra				#vuelve al loop
	
movIzq_Ball:
	addi $s3,$s3, -8		#Resta al movimiento de la pelota 8 para que se mueva hacia la derecha ahora
	# Limpiar la posición anterior de la pelota
	sw $t0, 0 ($s2)			#limpia el color de la posición anterior del pixel
	sub $s2,$s2,$s3			#Se guarda la nueva posicion de la pelota
	sw $t1, 0($s2)			#guarda el color en la posicion del pixel
	jr $ra				#vuelve al loop
	
movAbajo_Ball:
	subi $s3,$s3, 128		#Suma al movimiento de la pelota 1288 para que se mueva hacia abajo ahora
	# Limpiar la posición anterior de la pelota
	sw $t0, 0 ($s2)			#limpia el color de la posición anterior del pixel
	sub $s2,$s2,$s3			#Se guarda la nueva posicion de la pelota
	sw $t1, 0($s2)			#guarda el color en la posicion del pixel
	jr $ra				#vuelve al loop
	
movArriba_Ball:
	# verificar colision con el borde rojo
    	lw $t9, colorBorde2
    	beq $t5, $t9, reset_ball_position # Si el pixel que esta debajo de la pelota es del color del borde rojo, reiniciar posicion
    	
	subi $s3,$s3, -128
	# Limpiar la posición anterior de la pelota
	sw $t0, 0 ($s2)			#limpia el color de la posición anterior del pixel
	sub $s2,$s2,$s3
	sw $t1, 0($s2)
	jr $ra
	
movIzqArriba_Ball:
	subi $s3, $s3, 128		# y hacia arriba
	addi $s3, $s3, -8		# Cambiar direccion a la izquierda	
	# Limpiar la posición anterior de la pelota
	sw $t0, 0 ($s2)			#limpia el color de la posición anterior del pixel
	sub $s2,$s2,$s3			#Se guarda la nueva posicion de la pelota
	sw $t1, 0($s2)			#guarda el color en la posicion del pixel
	jr $ra
	
movDerArriba_Ball:
	subi $s3, $s3, 128		# y hacia arriba 
	addi $s3, $s3, 8		# Cambiar direccion a la derecha	
	# Limpiar la posición anterior de la pelota
	sw $t0, 0 ($s2)			#limpia el color de la posición anterior del pixel
	sub $s2,$s2,$s3			#Se guarda la nueva posicion de la pelota
	sw $t1, 0($s2)			#guarda el color en la posicion del pixel
	jr $ra
	
reset_ball_position:
	# limpiar la posicion anterior de la pelota
	sw $t0, 0($s2)			# limpia el color en la posicion anterior del pixel
	
	# restablecer la posicion y direccion de la pelota
	la $t0, ball_init_pos
	lw $t0, 0 ($t0)			# cargar la posicion inicial de la pelota
	la $t1, ball_init_dir
	lw $t1, 0($t1)			# cargar la direccion inicial de la pelota
	
	add $s2, $t0, $gp		# ajustar la posicion con el $gp
	move $s3, $t1			# ajustar la direccion inicial
	
	lw $t1, colorBall
	sw $t1, 0 ($s2)			#dibujar la pelota en la posicion inicial
	
	jr $ra				# volver al loop

clear_ball:
	lw $t4, colorFondo
	lw $t3, 0($s2)
	sub $t3, $t3, $s3
	sw $t4, 0($s2)
	jr $ra
	
	
