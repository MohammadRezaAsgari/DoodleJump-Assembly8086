	.MODEL SMALL
	.STACK 64
	.DATA
	
	PLAYER_POINTS DW 0 
	
    WINDOW_WIDTH EQU 320
    WINDOW_HEIGHT EQU 200                

	JUMPING DW 0
	JUMP_VELOCITY DW 15
	COUNTER DW 0
	
	BALL_X DW 160                      
	BALL_Y DW 5                        
	BALL_SIZE DW 6 
	BALL_HALF_SIZE DW 3
	BALL_VELOCITY_X DW 10            
	BALL_VELOCITY_Y DW 3                 
	  
   	PLATFORM_X DW 250           	  
	PLATFORM_Y DW 180             
	PLATFORM_WIDTH DW 36                  
	PLATFORM_HEIGHT DW 1               
      
	NUM DW 100
.CODE 
MAIN PROC FAR
    MOV AX, @DATA
    MOV DS, AX
                         
    CALL SET_GRAPHIC_MODE
    
    PROGRAM_LOOP:
    
        CALL CLEAR_SCREEN
		CALL DRAW_PLATFORM
        CALL MOVE_BALL
        CALL DRAW_BALL	
		CALL DRAW_POINT
        CALL DELAY               
        JMP PROGRAM_LOOP
		
MAIN    ENDP
;---------------------
DRAW_BALL   PROC   
	MOV CX,BALL_X                    ;SET THE INITIAL COLUMN (X)
	MOV DX,BALL_Y                    ;SET THE INITIAL LINE (Y)
		
	DRAW_BALL_HORIZONTAL:
		MOV AH,0CH                   ;SET THE CONFIGURATION TO WRITING A PIXEL
		MOV AL,0CH 					 ;CHOOSE RED AS COLOR
		MOV BH,00H 					 ;SET THE PAGE NUMBER 
		INT 10H    					 ;EXECUTE THE CONFIGURATION
			
		INC CX     					 ;CX = CX + 1
		MOV AX,CX          	  		 ;CX - BALL_X > BALL_SIZE (Y -> WE GO TO THE NEXT LINE,N -> WE CONTINUE TO THE NEXT COLUMN
		SUB AX,BALL_X
		CMP AX,BALL_SIZE
		JNG DRAW_BALL_HORIZONTAL
			
		MOV CX,BALL_X 				 ;THE CX REGISTER GOES BACK TO THE INITIAL COLUMN
		INC DX       				 ;WE ADVANCE ONE LINE
			
		MOV AX,DX             		 ;DX - BALL_Y > BALL_SIZE (Y -> WE EXIT THIS PROCEDURE,N -> WE CONTINUE TO THE NEXT LINE
		SUB AX,BALL_Y
		CMP AX,BALL_SIZE
		JNG DRAW_BALL_HORIZONTAL  	
	CALL FIX_BALL
	RET          
DRAW_BALL   ENDP      
;---------------------
DRAW_PLATFORM PROC NEAR	
    MOV CX,PLATFORM_X 			 ;set the initial column (X)
    MOV DX,PLATFORM_Y 			 ;set the initial line (Y)
    
    DRAW_PLATFORM_HORIZONTAL:
        MOV AH,0Ch 					 ;set the configuration to writing a pixel
        MOV AL,0Fh 					 ;choose white as color
        MOV BH,00h 					 ;set the page number 
        INT 10h    					 ;execute the configuration
        
        INC CX     				 	 ;CX = CX + 1
        MOV AX,CX         			 ;CX - PADDLE_LEFT_X > PADDLE_WIDTH (Y -> We go to the next line,N -> We continue to the next column
        SUB AX,PLATFORM_X
        CMP AX,PLATFORM_WIDTH
        JNG DRAW_PLATFORM_HORIZONTAL		
        
        MOV CX,PLATFORM_X 		 	 ;the CX register goes back to the initial column
        INC DX       				 ;we advance one line
        
        MOV AX,DX            	     ;DX - PADDLE_LEFT_Y > PADDLE_HEIGHT (Y -> we exit this procedure,N -> we continue to the next line
        SUB AX,PLATFORM_Y
        CMP AX,PLATFORM_HEIGHT
        JNG DRAW_PLATFORM_HORIZONTAL
    
    RET
DRAW_PLATFORM ENDP
;---------------------
MOVE_BALL   PROC          
    ;check if any key is being pressed
    MOV AH,01h
    INT 16h
    JZ NO_INT 

    ;check which key is being pressed (AL = ASCII character)
    MOV AH,00h
    INT 16h
   
    CMP AL,'j'
    JE MOVE_LEFT
    CMP AL,'k' 
    JE MOVE_RIGHT

    CMP AL,'J'
    JE MOVE_LEFT
    CMP AL,'K' 
    JE MOVE_RIGHT

    JMP NO_INT

    MOVE_LEFT:
        MOV AX,BALL_VELOCITY_X
        SUB BALL_X,AX
        JMP NO_INT
            
    MOVE_RIGHT:
        MOV AX,BALL_VELOCITY_X
        ADD BALL_X,AX
        

    NO_INT:
     
    ;Check if the ball is colliding with the  PLATFORM

    ; BALL_X + BALL_SIZE > PLATFORM_X 
	;&& BALL_X < PLATFORM_X + PLATFORM_WIDTH 
    ;&& BALL_Y + BALL_SIZE > PLATFORM_Y 
	;&& BALL_Y < PLATFORM_Y + PLATFORM_HEIGHT

    MOV AX,BALL_X
    ADD AX,BALL_SIZE
    CMP AX,PLATFORM_X
    JNG NO_COLLISION  

    MOV AX,PLATFORM_X
    ADD AX,PLATFORM_WIDTH
    CMP BALL_X,AX
    JNL NO_COLLISION  

    MOV AX,BALL_Y
    ADD AX,BALL_SIZE
    CMP AX,PLATFORM_Y
    JNG NO_COLLISION 

    MOV AX,PLATFORM_Y
    ADD AX,PLATFORM_HEIGHT
    CMP BALL_Y,AX
    JNL NO_COLLISION 

    ;If it reaches this point, the ball is colliding with the PLATFORM

	MOV JUMPING,1
	ADD PLAYER_POINTS,1
	
    ;CHANGE_PLATFORM:	
	MOV AX,PLATFORM_X
	ADD AX,NUM
	MOV BX,280
	XOR DX,DX
	DIV BX
	ADD DX,10
	MOV PLATFORM_X,DX


	MOV AX,PLATFORM_Y
	ADD AX,NUM
	MOV BX,150
	XOR DX,DX
	DIV BX
	ADD DX,50
	MOV PLATFORM_Y,DX
	
	ADD NUM,100
    RET

	NO_COLLISION: 
	
    ;Check if the ball has passed the bottom boundarie (BALL_Y > WINDOW_HEIGHT - BALL_SIZE)		
	MOV AX,WINDOW_HEIGHT	
	SUB AX,BALL_SIZE
	CMP BALL_Y,AX                    ;BALL_Y is compared with the bottom boundarie of the screen (BALL_Y > WINDOW_HEIGHT - BALL_SIZE - WINDOW_BOUNDS)
	JNG CHECK_LEFT		         ;if is greater reverve the velocity in Y
	MOV BALL_X,160
    MOV BALL_Y,5
	MOV PLAYER_POINTS,0
	
	CHECK_LEFT:
	;Check if the ball has passed the LEFT boundarie (BALL_X < 0)		
	CMP BALL_X,0                    
	JNL CHECK_RIGHT		        
	MOV BALL_X,0
	
	CHECK_RIGHT:
	;Check if the ball has passed the RIGHT boundarie (BALL_X + BALL_SIZE > WINDOW_WIDTH)	
	MOV AX,BALL_X
	ADD AX,BALL_SIZE
	CMP AX,WINDOW_WIDTH                    
	JNG NO_COLLISION2	
	MOV AX,WINDOW_WIDTH
	SUB AX,BALL_SIZE
	DEC AX
	MOV BALL_X,AX
		

	
	NO_COLLISION2:
	MOV AX,JUMPING
	CMP AX,1
	JE JUMP
	
	MOV AX, BALL_VELOCITY_Y
    ADD BALL_Y, AX
    RET

JUMP:

	ADD COUNTER,1
	MOV CX,COUNTER
	CMP CX,JUMP_VELOCITY
	JE STOP_JUMP
	
    MOV BX,JUMP_VELOCITY
	SUB BX,CX ;//
	MOV AX,BALL_Y
	SUB AX,BX
	MOV BALL_Y,AX
    RET   

STOP_JUMP:
	MOV COUNTER,0
	MOV JUMPING,0
	RET
    
MOVE_BALL   ENDP
;---------------------
DELAY PROC              
    MOV AH, 86H
    MOV CX, 0H
    MOV DX, 0A028H  ;WAIT FOR 41 MILISECONDS (FOR 24 FPS)
    INT 15H
    
    RET   
DELAY ENDP
;---------------------
CLEAR_SCREEN    PROC    
    MOV AH, 06H     ;SCROLL UP
    MOV AL, 00H     ;CLEAR ENTIRE WINDOW
    MOV BH, 00H     ;COLOR    
    MOV CX, 0000    ;START ROW, COLUMN
    MOV DX, 184FH   ;END  ROW, COLUMN
    INT 10H
      
    RET    
CLEAR_SCREEN    ENDP
;---------------------
SET_GRAPHIC_MODE    PROC       
    MOV AH, 00H     ;SETTING VIDEO MODE
    MOV AL, 13H     ;320X200 256 COLORS 
    INT 10H         ;CALL INTERRUPTION
    
    MOV AX, 1003H
    MOV BL, 00H
    MOV BH, 00H
    INT 10H         ;DISABLE BLINKING FOR BACKGROUND      
    
    RET   
SET_GRAPHIC_MODE    ENDP    
;---------------------
DRAW_POINT PROC NEAR
	MOV AH,02h                       ;set cursor position
	MOV BH,00h                       ;set page number
	MOV DH,1                       	 ;set row 
	MOV DL,37						 ;set column
	INT 10h							 
	
	MOV AX,PLAYER_POINTS
	XOR CX,CX
	MOV BX,10
	BEGIN_:
		INC CX
		
		XOR DX, DX
		DIV BX
		ADD DX,48
		PUSH DX  
		
		CMP AX,0
		JNZ BEGIN_
	PRINT_:
		POP DX 		
		MOV AX, 0200H
		INT 21H
		LOOP PRINT_		
	RET
DRAW_POINT ENDP
;---------------------
FIX_BALL    PROC      	
	MOV CX,BALL_X                
	MOV DX,BALL_Y               
	MOV AH,0CH                   
	MOV AL,0 					
	MOV BH,00H 					
	INT 10H 
	
	MOV CX,BALL_X      
	INC CX
	MOV DX,BALL_Y               
	MOV AH,0CH                   
	MOV AL,0 					
	MOV BH,00H 					
	INT 10H  
	
	MOV CX,BALL_X      	
	MOV DX,BALL_Y
	INC DX	
	MOV AH,0CH                   
	MOV AL,0 					
	MOV BH,00H 					
	INT 10H  
	
	MOV CX,BALL_X                
	MOV DX,BALL_Y                    	
	ADD DX,BALL_SIZE
	MOV AH,0CH                   
	MOV AL,0 					
	MOV BH,00H 					 
	INT 10H
	
	MOV CX,BALL_X    
	INC CX
	MOV DX,BALL_Y                    	
	ADD DX,BALL_SIZE
	MOV AH,0CH                   
	MOV AL,0 					
	MOV BH,00H 					 
	INT 10H
	
	MOV CX,BALL_X    
	MOV DX,BALL_Y                    	
	ADD DX,BALL_SIZE
	DEC DX
	MOV AH,0CH                   
	MOV AL,0 					
	MOV BH,00H 					 
	INT 10H
	
	MOV CX,BALL_X                 
	ADD CX,BALL_SIZE
	MOV DX,BALL_Y                  
	MOV AH,0CH                  
	MOV AL,0 					
	MOV BH,00H 					
	INT 10H  

	MOV CX,BALL_X                 
	ADD CX,BALL_SIZE
	DEC CX
	MOV DX,BALL_Y                  
	MOV AH,0CH                  
	MOV AL,0 					
	MOV BH,00H 					
	INT 10H   	
	
	MOV CX,BALL_X                 
	ADD CX,BALL_SIZE
	MOV DX,BALL_Y 
	INC DX
	MOV AH,0CH                  
	MOV AL,0 					
	MOV BH,00H 					
	INT 10H   	
	
	MOV CX,BALL_X                    
	MOV DX,BALL_Y                    
	ADD CX,BALL_SIZE
	ADD DX,BALL_SIZE	
	MOV AH,0CH                   
	MOV AL,0				 
	MOV BH,00H 					
	INT 10H  
	
	MOV CX,BALL_X                    
	MOV DX,BALL_Y                    
	ADD CX,BALL_SIZE
	ADD DX,BALL_SIZE	
	DEC CX
	MOV AH,0CH                   
	MOV AL,0				 
	MOV BH,00H 					
	INT 10H  

	MOV CX,BALL_X                    
	MOV DX,BALL_Y                    
	ADD CX,BALL_SIZE
	ADD DX,BALL_SIZE	
	DEC DX
	MOV AH,0CH                   
	MOV AL,0				 
	MOV BH,00H 					
	INT 10H 
      
    RET    
FIX_BALL    ENDP
;---------------------
END MAIN
RET
