;David Benson
;5 May 2024
;A snake game displayed in the console that the player is able to control.
;Revised: 29 April 2024 Added background color so the snake segments weren't just characters repeating.
;Revised: 30 April 2024 Figured out how to add bounds to RandomRange indirectly. Target kept appearing in opening messages.
;Revised: 1 May 2024 Tried to add an exit key sequence for the player. Unsure why it won't work.

;Register Names: EAX, EDX, DL, DH, AL
;Commands used: mov, jmp, add, je, jne, cmp, push, pop


INCLUDE Irvine32.inc

.data

strTop BYTE "-------------------------------------------------------------------",0
strHello BYTE "| Welcome to AssemblySnake. To begin, press one of the WASD keys. |",0
strBottom BYTE "-------------------------------------------------------------------",0
strGoodbye BYTE "You have selected to exit the game. Thank you for playing!",0

inputChar BYTE ?

xPosition BYTE ?
yPosition BYTE ?

xTarget BYTE ?
yTarget BYTE ?

isColliding BYTE 'F'
right BYTE 'F'
left BYTE 'F'
up BYTE 'F'
down BYTE 'F'

adder DWORD 2


.code
main PROC

	; Starting Messages:

	;Displays top line of the welcome message box.
	mov  dl,1
	mov  dh,0
	call Gotoxy
	mov edx,OFFSET strTop
	call WriteString

	;Displays the welcome message itself.
	mov  dl,1
	mov  dh,1
	call Gotoxy
	mov edx,OFFSET strHello
	call WriteString

	;Displays the bottom line of the welcome message box.
	mov  dl,1
	mov  dh,2
	call Gotoxy
	mov edx,0
	mov edx,OFFSET strBottom
	call WriteString


	call DrawRandomTarget

	; Sets initial player position:
	mov xPosition,10
	mov yPosition,10

	call ReadChar
	mov inputChar,al


	; Starts game
	gameLoop:
		call DrawTarget
		; delay for 80ms
		mov eax,40
		call Delay


		; Reads buffer into al:
		call ReadKey


		;Checks for valid character inputs for buffer
		cmp al,"w"
		jne checkS
		mov inputChar,al

		checkS:
		cmp al,"s"
		jne checkA
		mov inputChar,al

		checkA:
		cmp al,"a"
		jne checkD
		mov inputChar,al

		checkD:
		cmp al,"d"
		jne skip
		mov inputChar,al

		checkN:
		cmp al, "n"
		jne skip
		mov inputChar,al

		skip:

		; check for 'n' (game exit):
		cmp inputChar,"n"
		je exitGame

		; check for 'w' (up):
		cmp inputChar,"w"
		je moveUp
		
		; check for 's' (down):
		cmp inputChar,"s"
		je moveDown

		; check for 'd' (right):
		cmp inputChar,"d"
		je moveRight

		; check for 'a' (left):
		cmp inputChar,"a"
		je moveLeft
		jmp gameLoop


		; move the player up:
		moveUp:

			; decrement yPosition (moving up) and draw Player:
			dec yPosition
			call DrawPlayer
			
			; check for target collision:
			call checkCollision
			cmp isColliding,'T'
			jne noCollide1

			; if collision occurs:
			call DrawRandomTarget
			noCollide1:

			mov right,'F'
			mov left,'F'
			mov down,'F'
			mov up,'T'

			; reset input and repeat loop:
			jmp gameLoop


		; move the player down:
		moveDown:

			; increment yPosition (moving down) and draw Player:
			inc yPosition
			call DrawPlayer

			; check target collision:
			call checkCollision
			cmp isColliding,'T'
			jne noCollide2
			; if collision occurs:

			call DrawRandomTarget
			noCollide2:

			mov right,'F'
			mov left,'F'
			mov down,'T'
			mov up,'F'

			;Repeat loop:
			jmp gameLoop


		; Move player right:
		moveRight:

			; increment xPosition (moving right) and draw Player:
			inc xPosition
			call DrawPlayer

			; check target collision:
			call checkCollision
			cmp isColliding,'T'
			jne noCollide3
			; if collision occurs:

			call DrawRandomTarget
			noCollide3:

			mov right,'T'
			mov left,'F'
			mov down,'F'
			mov up,'F'

			; Repeat loop:
			jmp gameLoop


		; Move player left:
		moveLeft:

			; increment xPosition (moving left) and draw Player:
			dec xPosition
			call DrawPlayer

			; check target collision:
			call checkCollision
			cmp isColliding,'T'
			jne noCollide4
			; if collision occurs:

			call DrawRandomTarget
			noCollide4:

			mov right,'F'
			mov left,'T'
			mov down,'F'
			mov up,'F'

			;Repeats loop
			jmp gameLoop
			
		exitGame:
			mov eax,1

main ENDP



;Identifies random location for target
DrawRandomTarget PROC
	push edx
	; Generate random x position 0-30:
	mov eax,30
	call RandomRange
	mov dl,al
	add dl, 5		;Important, functionally sets the lower bound of x=5 so target doesn't go too far left in screen.
	; Generate random y position 0-30:
	mov eax,25
	call RandomRange
	mov dh,al
	add dh, 5		;VERY important, functionally sets the lower bound of y=5 so target doesn't enter top message.
	call Gotoxy

	; Logs target position:
	mov xTarget,dl
	mov yTarget,dh
	pop edx
	ret
DrawRandomTarget ENDP


;Draws the target with the appropriate color
DrawTarget PROC
	push eax
	mov eax,red  (red * 16)
	call SetTextColor
	pop eax
	push edx
	mov dl,xTarget
	mov dh,yTarget
	call Gotoxy
	pop edx
	mov al," "	;Sets the appearance of the character that the snake's pieces are made of.
	call WriteChar
	ret
DrawTarget ENDP


; Draw player with appropriate color:
DrawPlayer PROC
	push eax
	mov eax,blue  (blue * 16)
	call SetTextColor
	pop eax

	mov  dl,xPosition
	mov  dh,yPosition
	call Gotoxy
	mov al," "	;Sets the appearance of the character that the snake's pieces are made of.
	call WriteChar
	ret
DrawPlayer ENDP


;Checks for target player collision
checkCollision PROC
	; Set isColliding to 'T' if player and target coordinates collide
	mov bl,xPosition
	cmp xTarget,bl
	jne notColliding

	mov bl,yPosition
	cmp yTarget,bl
	jne notColliding
	mov isColliding,'T'
	jmp exitCheck

	; Otherwise set isColliding to 'F'
	notColliding:
	mov isColliding,'F'

	exitCheck:
	ret
checkCollision ENDP



END main

