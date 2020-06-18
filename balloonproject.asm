.Model Small
.Stack 100h
.Data
new_timer_vec   dw  ?,?
old_timer_vec   dw  ?,?
timer_flag  db  0
vel_x       dw  0
vel_y1      dw  -5 
vel_y2      dw  -5 
vel_y3      dw  -5
T DW 0 
TEMPD DW 0
TEMPC DW 0

H DW 60
W DW 50
H1 DW 85
W1 DW 135
H2 DW 110
W2 DW 235
B1 DB 1
B2 DB 1
B3 DB 1
.Code

            
    
; set graphics mode 
        
    draw_row Macro x,y,z
    Local l1

; pt 1 ****** line drawing ********

; draws a line in row x from col x to col y
    MOV AH, 0CH
    MOV AL, 1
    MOV CX, y
    MOV DX, x
L1: INT 10h
    INC CX
    CMP CX, z
    JL L1
    EndM

draw_col Macro a,b,c
    Local l2
; draws a line col a from row b to row c
    MOV AH, 0CH
    MOV AL, 1
    MOV CX, a
    MOV DX, b
L2: INT 10h
    INC DX
    CMP DX, c
    JL L2
    EndM


 draw_row1 Macro x1
    Local Ll1
; draws a line in row x from col 10 to col 300
    MOV AH, 0CH
    ;MOV AL, 1
    ;MOV CX, 10
    MOV TEMPC,CX
    ADD TEMPC,20
    
    MOV DX, x1
LL1:    INT 10h
    INC CX
    CMP CX, TEMPC
    JL LL1
EndM

draw_col1 Macro y1
    Local Ll2
; draws a line col y from row 10 to row 189
    MOV AH, 0CH
    ;MOV AL, 1
    MOV CX, y1
    ;MOV DX, 10
    MOV TEMPD,DX
    ADD TEMPD,20
LL2:    INT 10h
    INC DX
    CMP DX, TEMPD
    JL LL2

ENDM


; pt 2 ****** display mode handling ********


set_display_mode Proc

; -> sets display mode and draws boundary
    
    MOV AH, 0
    MOV AL, 04h; 320x200 4 color
    INT 10h
    
    
; -> select bck grnd    
    MOV AH, 0BH
    xor BH, BH 
    ;put color in bl
    MOV BL, 1     ; bck grnd 
    INT 10h        
    
;  -> select palette
    MOV BH, 1
    MOV BL, 2; 
    INT 10h
    
            
; -> draw boundary
    
    draw_row 20,20,291
    draw_row 179,20,291
    draw_col 20,20,180
    draw_col 290,20,180 
    
    MOV AX,4
    MOV CX,0
    MOV DX,0
    INT 33H
    
    RET
set_display_mode EndP
    
    
    ; pt 3 ****** 1st ball  spawn ********

display_first_ball Proc
    
    
    PUSH CX
    MOV CX,W
    DRAW_ROW1 H
    MOV CX,W
    ADD H,20
    DRAW_ROW1 H
    SUB H,20
    POP CX
    PUSH DX
    MOV DX,H
    DRAW_COL1 W
    MOV DX,H
    ADD W,20
    DRAW_COL1 W
    SUB W,20
    POP DX 
          
    RET 
display_first_ball EndP
     
     
     ; pt 4 ********  2nd ball drawing  ********


display_second_ball Proc
    
    
    PUSH CX
    MOV CX,W1
    DRAW_ROW1 H1
    MOV CX,W1
    ADD H1,20
    DRAW_ROW1 H1
    SUB H1,20
    POP CX
    PUSH DX
    MOV DX,H1
    DRAW_COL1 W1
    MOV DX,H1
    ADD W1,20
    DRAW_COL1 W1
    SUB W1,20
    POP DX
    RET 
display_second_ball EndP 
          
         
         ; ******** handling time ********
         
         
timer_tick Proc
    PUSH DS
    PUSH AX
    ;
    MOV AX, Seg timer_flag
    MOV DS, AX
    MOV timer_flag, 1
    
    POP AX
    POP DS
    
    IRET
timer_tick EndP
         
         ; ******** ballon movement(- copied from ball bouncer ) *******
move_ballon Proc

    MOV AL, 0
    CALL display_first_ball
    CALL display_second_ball
; get new position

    PUSH CX
    MOV CX,W
    ADD CX, vel_x
    MOV W,CX
    POP CX
    PUSH DX
    MOV DX,H
    ADD DX, vel_y1
    MOV H,DX
    POP DX
    
    PUSH CX
    MOV CX,W1
    ADD CX, vel_x
    MOV W1,CX
    POP CX
    PUSH DX
    MOV DX,H1
    ADD DX, vel_y2
    MOV H1,DX
    POP DX
    
    
; check boundary
    CALL check_boundary 
    CALL MOUSE
; wait for 1 timer tick to display ball
test_timer:
    CMP timer_flag, 1
    JNE test_timer ; it will wait till timer flag is true
    MOV timer_flag, 0                   ; yes,timer flag is true now,make it false
    MOV AL, B1
    CALL display_first_ball 
    MOV AL, B2
    CALL display_second_ball
    
    
    RET 
move_ballon EndP

check_boundary Proc

    CMP H, 21
    JG P1
    MOV H, 158
    ADD W,50
    CMP W,200
    JL P1
    SUB W,100
  P1:  
    CMP H1, 21
    JG P2
    MOV H1, 158
    ADD W1,20
    CMP W1,200
    JL P2
    SUB W1,50
  P2:
    CMP H2, 21
    JG DONE
    MOV H2, 158
    ADD W2,30
    CMP W2,200
    JL DONE
    SUB W2,80

    
DONE:   
    RET 
check_boundary EndP
        
        ; i dont know what it does
        
setup_int Proc
    MOV AH, 35h ; get vector
    INT 21h
    MOV [DI], BX    ; save offset
    MOV [DI+2], ES  ; save segment
; setup new vector
    MOV DX, [SI]    ; dx has offset
    PUSH DS     ; save ds
    MOV DS, [SI+2]  ; ds has the segment number
    MOV AH, 25h ; set vector
    INT 21h
    POP DS
    RET
setup_int EndP
       
     ;  ******** mouse action *********
       
MOUSE PROC
    
    PUSH AX  
    PUSH W
    PUSH H 
    PUSH W1
    PUSH H1
                  
      ; turns on  mouse show 
     MOV AX,1     
     INT 33H
     MOV AX,3
     INT 33H
     SHR CX,1 ;  divide CX by 2
     
     CMP CX,W
     JL NAI1
     
     ADD W,20
     
     CMP CX,W
     JG NAI1      
     
     CMP DX,H
     JL NAI1
     
     ADD  H,20 
     
     CMP DX,H
     JG NAI1
     MOV B1,0   ; mouse is inside AT this step
   
  NAI1:
     MOV AX,3
     INT 33H
     SHR CX,1 ; divide CX by 2
    
     CMP CX,W1
     ;JL NAI2 
     JL EXIT
     
     ADD W1,20
     
     CMP CX,W1
     ;JG NAI2
     JG EXIT
     
     CMP DX,H1
     ;JL NAI2
     JL EXIT
     
     ADD  H1,20 
     
     CMP DX,H1
     ;JG NAI2
     JG EXIT
     
     MOV B2,0  
     
   
  EXIT:
   POP H1
   POP W1  
   POP H
   POP W
   POP AX
    RET
    MOUSE ENDP



ROLL PROC   
           
       
        MOV AH,2    ; CURSOR MOVE
        MOV BH,0
        MOV DL,27
        MOV DH, 1
       
        INT 10H
        MOV AH,9
        MOV AL,'1'
                    ; SHOW ROLL
        MOV BL,2
        MOV CX,1
        INT 10H   
        
        
        MOV AH,2    ; CURSOR MOVE
        MOV BH,0
        MOV DL,28
        MOV DH, 1
       
        INT 10H
        MOV AH,9
        MOV AL,'2'
                    ; SHOW ROLL
        MOV BL,2
        MOV CX,1
        INT 10H  
        
        MOV AH,2    ; CURSOR MOVE
        MOV BH,0
        MOV DL,29
        MOV DH, 1
       
        INT 10H
        MOV AH,9
        MOV AL,'0'
                    ; SHOW ROLL
        MOV BL,2
        MOV CX,1
        INT 10H  
        
        MOV AH,2    ; CURSOR MOVE
        MOV BH,0
        MOV DL,30
        MOV DH, 1
       
        INT 10H
        MOV AH,9
        MOV AL,'5'
                    ; SHOW ROLL
        MOV BL,2
        MOV CX,1
        INT 10H  
        
       MOV AH,2    ; CURSOR MOVE
       MOV BH,0
       MOV DL,31
       MOV DH, 1
       
        INT 10H
        MOV AH,9
        MOV AL,'0'
                    ; SHOW ROLL
        MOV BL,2
        MOV CX,1
        INT 10H  
               
        MOV AH,2    ; CURSOR MOVE
        MOV BH,0
        MOV DL,32
        MOV DH, 1
       
        INT 10H
        MOV AH,9
        MOV AL,'3'
                    ; SHOW ROLL
        MOV BL,2
        MOV CX,1
        INT 10H       
                
        MOV AH,2    ; CURSOR MOVE
        MOV BH,0
        MOV DL,33
        MOV DH, 1
        
        INT 10H
        MOV AH,9
        MOV AL,'6'
                    ; SHOW ROLL
        MOV BL,2
        MOV CX,1
        INT 10H          
    ret

ROLL ENDP



main Proc
    MOV AX, @data
    MOV DS, AX
    
; set graphics display mode & draw border
    CALL set_display_mode
    CALL ROLL
    
; set up timer interrupt vector
    MOV new_timer_vec, offset timer_tick
    MOV new_timer_vec+2, CS
    MOV AL, 1CH; interrupt type
    LEA DI, old_timer_vec
    LEA SI, new_timer_vec
    CALL setup_int
    
    CALL display_first_ball 
    CALL display_second_ball
    
; wait for timer tick before moving the ball
tt:
    CMP timer_flag, 1
    JNE tt
    MOV timer_flag, 0
    CALL move_ballon
tt2:
    CMP timer_flag, 1
    JNE tt2
    MOV timer_flag, 0
    CMP B1,0
    JNE tt
    CMP B2,0
    JNE tt
    INC T
    CMP T,70                                                            
    
    JL tt

        
        MOV AH, 0
        INT 16h
; return to text mode
        MOV AX, 3
        INT 10h
        
; return to dos
        MOV AH, 4CH
        INT 21h
main EndP
     End main