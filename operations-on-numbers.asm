.model small
.stack 1000h
.data

;Numbers msg

enterMsg db 10,13,10,13,"Enter 6 numbers <between 0 and 9> ",10,13,"then choose an operations to be performed on them ",10h,10,13,'$'

num db 10,13,"Enter the number $"
n   db '1','2','3','4','5','6','$'
space db 3Ah,09h,'$'

tyMsg db 10,13,10,13,"Thank you for entering all the numbers ",03h,10,13,'$'
finishMsg db 10,13,10,13,"Thank you for using this program ",03h,10,13,'$'

;Options msg
selectMsg db 10,13,10,13,"Please select the operation you need",10,13,"<v,x,n,,d,a,e,s,l,q,r or ? for help> ",10h,'$'
optionsMsg db                  10,13,
           db                  "v: for average",10,13,
           db                  "x: for maximum number",10,13,
           db                  "n: for minimum number",10,13,
           db                  "e: for standard deviation",10,13,
           db                  "a: to show numbers in ascending order",10,13,
           db                  "d: to show numbers in descending order",10,13,
           db                  "s: summation of all numbers",10,13,
           db                  "l: for all the above",10,13,
           db                  "q: to quit",10,13,
           db                  "r: to enter 6 new digits",10,13
           db                  "?: for help",10,13,'$'
           
;Error msg
errorChar db 10,13,10,13,"Unrecognized character",10,13,'$'
errorNum db 10,13,10,13 ,"The character you entered is not in the range from 0 to 9",10,13,'$'

;Operations msg
sumMsg db 10,13,"The sum of all numbers is :$"
avgMsg db 10,13,"The average is : $"
maxMsg db 10,13,"the maximum number is : $"
minMsg db 10,13,"The minimum number is : $"
sdMsg db 10,13,"The standard deviation is : $"
ascMsg db 10,13,"Numbers in ascending order : $"
desMsg db 10,13,"Numbers in descending order : $"

allMsg db 's','v','x','n','e','a','d'

;Variables
nums  db 0, 0, 0, 0, 0, 0

avg db  0
max db  0
min db  0
sum db  0
standard db  0

asc  db 0, 0, 0, 0, 0, 0
des  db 0, 0, 0, 0, 0, 0

;Selection register
compareReg db ?  ;for comparing between the operations
input db ? ;for reading from user
result db ? ;for saving the result of mul or div or square
flag db ? ;its value <0:false,1:true>

;registers for the square root
reg db ?
regShift db ?
save db ?

.code 

printC macro character
    pusha
    pushf 
    
    mov dl, character  
    mov ah, 2h
    int 21h
    
    popf
    popa 
    printC endm

printM macro string
    pusha
    pushf 
    
    lea dx, string
    mov ah, 09h
    int 21h
    
    
    popf
    popa 
    printM endm


;result = n1 * n2 = n2 *n1
mulO macro n1,n2
     pusha
     pushf


     mov ax,0;
     mov al,n1
     mul n2 
     mov result,al


     popf
     popa
     mulO endm

;result = n1 / n2
divO macro n1, n2 
    pusha
    pushf
    
    mov ax,0 
    mov al, n1 
    div n2  
    mov result, al 
    
    popf
    popa 
    divO endm


  ;Square root operation
  ;Result = value ^0.5
   root macro value
    pusha
    pushf
              
    mov al, value 

    mov cl, 0
    mov bl, 0ffH
   
  n1: add bl, 02
        cmp al, bl
        jc here
        inc cl
        sub  al, bl
        jnz n1
        
   here: mov result , cl
        
     popf
     popa
     
     root endm
    
    
main proc

mov ax,data
mov ds,ax

repeat:
 printM enterMsg 
 mov cx ,6
 mov di,0
readLoop:
 printM num
 printC n[di]
 printM space

call read
call checkN

cmp flag,0
je cont
printM errorNum
jmp readLoop

cont:
mov dl,input
mov nums[di],dl

inc di
loop readLoop

printM tyMsg
call avgOperation
call sort

mov cx,1

selectLoops:

printM selectMsg
call read
call checkC

cmp flag,0
je continue

printM errorChar
jmp selectLoops

continue:

call selectOperation
inc cx
loop SelectLoops


main endp
jmp toEnd

read proc      
    pusha
    pushf ; to save current status
    mov ah,1h
    int 21h ; ask user to enter a number
    mov input, al  ; move the entered number from al to 'input' variable     
    popf
    popa ; reload latest status
    ret
    read endp 

checkN proc
 pusha
 pushf 

 mov flag, 0

 cmp input, '0'
 jb errorVar 
 
 cmp input, '9'
 ja errorVar

 jmp endCheckN

 errorVar:
 mov flag, 1

 endCheckN:
 popf
 popa

ret
checkN endp 


checkC proc
    pusha
    pushf 
    
    mov flag,0
    
    cmp input,'v'
    je endCheckC 
    
    cmp input,'x'
    je endCheckC
     
    cmp input,'n'
    je endCheckC
      
    cmp input,'d'
    je endCheckC 
    
    cmp input,'a'
    je endCheckC
    
    cmp input,'e'
    je endCheckC
     
    cmp input,'s'
    je endCheckC 
    
    cmp input,'l'
    je endCheckC 
    
    cmp input,'q'
    je endCheckC 
    
    cmp input,'r'
    je endCheckC 
    
    cmp input,'?'
    je endCheckC 
    
    errorExist:
    mov flag,1
    
    endCheckC:
    
    popf
    popa
    
    ret
    checkC endp


clear proc    
    
mov ax, 0     
mov bx, 0   
mov dx, 0
mov cx, 0
mov si, 0 
mov di, 0
mov flag, 0 
    
    
     ret
    clear endp


SelectOperation proc
pusha
 pushf
 
    mov dl, input
    mov compareReg,dl

    L0:
    cmp compareReg ,'?'
    jne L1
    
    printM optionsMsg 
    jmp finishSelect
    
    
    L1:
    cmp compareReg ,'r'
    jne L2
    
    jmp repeat
    
    L2:
    cmp compareReg ,'q'
    jne L3
         
    jmp toEnd
    
    L3:
    cmp compareReg ,'v'
    jne L4
    
    printM avgMsg
    printC avg
    jmp finishSelect
    
    
    L4: 
    cmp compareReg ,'x'
    jne L5
    
    printM maxMsg
    printc max
    jmp finishSelect
    
     
    L5: 
    cmp compareReg ,'n'
    jne L6
    
    printM minMsg
    printc min
    jmp finishSelect 
    
    
    L6:
    cmp compareReg ,'e'
    jne L7
    
    printM sdMsg
    printc standard
    jmp finishSelect
    
    
    L7: 
    cmp compareReg ,'s'
    jne L8
    
    printM sumMsg
    
    mov ax, 0
    mov al, sum
    
    aam
    or ax,3030h
    
    printC ah
    printC al
    
    jmp finishSelect
    
    L8:
    cmp compareReg ,'a'
    jne L9
    
    printM ascMsg
    
    mov cx ,6
    mov si,0
    
    printAsc:
    
    printc asc[si]
    inc si
    
    loop printAsc
    
    jmp finishSelect

    L9:  
    cmp compareReg ,'d'
    jne L10
    
     printM desMsg
    
    mov cx ,6
    mov si,0
    
    printDes:
    
    printc des[si]
    inc si
    
    loop printDes
    jmp finishSelect
    
    
    L10:
    cmp compareReg ,'l'
    jne finishSelect
    
    mov cx,7
    mov di,0
    
    printAll:
    push cx
    push di
    
   mov dl,allMsg[di]
   mov input,dl
   
   call selectOperation 

    pop di
    pop cx
    inc di
    loop printAll
    
 finishSelect:
 popf
 popa
  ret
  SelectOperation endp

StandardOperation proc           

 pusha
 pushf
 
 mov standard, 0
 
 mov cx,6
 mov si,0
 
 rootSum:
 
 mov dl, nums[si]
 cmp avg,dl
 ja aOp
 
 mov al,avg
 sub al,30h
 sub dl,30h
 sub dl,al
 
 mov bl,dl
 
 jmp toPower

 aOp:
 
 mov al,avg
 sub al,30h
 sub dl,30h
 sub al,dl
 
 mov bl,al
 
 toPower: 

 mulO bl,bl
 mov bl,result
 add standard,bl
 
 inc si
 loop rootSum
 
 mov bh,standard
 mov bl,6  
 
 divO bh,bl   
 
 mov al,result
 root al
 
 mov bl,result
 add bl,30h
 mov standard,bl
 
 popf
 popa
 ret
 StandardOperation endp

avgOperation proc
 pusha
 pushf
 mov sum,0  
 mov avg,0          
 mov cx ,6
 mov si ,0
 
 sumLoop:
 mov dl, nums[si] 
 sub dl,30h
 add sum,dl
 inc si
 loop sumLoop
 mov dl,6
 divO sum,dl
 mov al , result
 add al,30h
 mov avg, al  
 popf
 popa
    ret
    avgOperation endp

Sort proc
 pusha
 pushf
 mov cx,6
 mov si,0
 
 addTo:
 mov dl, nums[si]
 mov asc[si],dl
 inc si
 
 loop addTo

; Selection sort 
  mov si,0
  mov cx,5
  
  p1:
  push cx
  mov cx,5
  sub cx,si
  mov di, si ;si =0
  inc di    ;di =1
  mov bx, si ;bx= 0
  
  p2:
  mov dl, asc[bx]
  cmp asc[di],dl
  jnb fp2
  mov bx,di
 
  fp2:
  inc di
  
  loop p2 
  
  mov dl,asc[bx]
  mov al,asc[si]
  mov asc[si],dl
  mov asc[bx],al
  pop cx 
  inc si
  
  loop p1  

  mov di,0
  mov si,5
  mov cx,6

 insert:  
  mov dl,asc[si]
  mov des[di],dl
  inc di
  dec si
  loop insert

mov al,des[5]
mov min,al
mov al,des[0]
mov max,al  
 
 popf
 popa
    ret
    Sort endp

toEnd:
    end main  
