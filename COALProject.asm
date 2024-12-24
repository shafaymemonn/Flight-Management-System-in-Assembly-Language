.model small

.stack 100h

.data

title1 db 10, 13, '                          Flight Management System$'
b1 db 13, 10, '                        ****************************$', 0

; Menu options
op1 db 10, 13, '                            1. Show Flight Schedule$', 0
op2 db 10, 13, '                            2. Book Flight$', 0
op3 db 10, 13, '                            3. Cancel Flight$', 0
op4 db 10, 13, '                            4. Exit$', 0
prompt1 db 10, 13, 10, 13, '                          Type the desired option number:$', 0

; Flight data
flight1 db 'F101 - Karachi to Islamabad', 10, 13, '$'
flight2 db 'F202 - Islamabad to Karachi', 10, 13, '$'
flight3 db 'F303 - Islamabad to Peshawar', 10, 13, '$'
flight4 db 'F404 - Karachi to Lahore', 10, 13, '$'
flight5 db 'F505 - Lahore to Karachi', 10, 13, '$'
flight6 db 'F606 - Islamabad to Lahore', 10, 13, '$'

; Prompts
book_prompt1 db 'Enter your name (max 10 chars):$', 10, 13, '$'
book_prompt2 db 'Select Flight ID (1-6):$', 10, 13, '$'
book_confirm db 'Booking Confirmed : $',0
cancel_prompt_id db 'Enter your id to cancel a booking: $',10,13,'$'
cancel_no_bookings db 'No bookings found for that name.$',10,13,'$'
cancel_done db 'Booking canceled successfully.$',10,13,'$'

; Receipt details
receipt_header db '--- Flight Booking Receipt ---$',0
passenger_ticket_label db 'Passenger Ticket ID: $',0
total_cost_label db 'Total Cost: $',0
total_cost db '100$',0

; Filenames
fname dw 'records2.txt', 0
fhandle dw ?       

; line buffer for file operations
line_buffer db 14 dup('$') 
ticketCount db '0'
readbuffer db 5000 dup('$')

.code

print_newline macro ; macro to print newline efficiently
    mov dl, 0Ah   ; hexa for newline character / line feed
    mov ah, 2
    int 21h
    mov dl, 0Dh   ; hexa for enter char / carriage return 
    mov ah, 2
    int 21h
endm

display macro str   ; macro to print a string through Load Effective Addressing
    lea dx, str
    mov ah, 9
    int 21h
    
    print_newline   ; nested macro - macro called inside a macro
endm
                                    
show_flight_schedule proc ; procedure beginning 
    
    print_newline         ; call newline macro
    
    display flight1       ; print ' F101 - Karachi to Islamabad ' along a new line 
    
    display flight2       ; print ' F202 - Islamabad to Karachi ' along a new line 
    
    display flight3       ; print ' F303 - Islamabad to Peshawar ' along a new line 
    
    display flight4       ; print ' F404 - Karachi to Lahore ' along a new line 
    
    display flight5       ; print ' F101 - Lahore to Karachi ' along a new line 
    
    display flight6       ; print ' F606 - Islamabad to Lahore ' along a new line
      
    ret                   ; return control to proc
    
show_flight_schedule endp  ; procedure ending


generate_receipt proc      ; procedure beginning
    
    print_newline          ; call newline macro
    
    display book_confirm   ; print Booking Confirmed : 
    
    display receipt_header ; print --- Flight Booking Receipt ---

    display passenger_ticket_label ; print Passenger Ticket ID:
    
    mov dl, ticketCount  ; move the value of ticketCount to dl register to display the value on screen
    mov ah, 2            ; set AH to 2 - the DOS function number for write character
    int 21h              ; call interrupt 21h to execute the function in AH, which outputs the character in dl register to the console,
    
    print_newline        ; call newline macro
    
    display total_cost_label ; print Total Cost: 
    
    display total_cost ; print on screen 100

    ret 
    
generate_receipt endp   ; procedure ending


book_flight proc         ; procedure beginning
    
resetBuffer:
    lea di, line_buffer ; Point DI to the start of the buffer
    mov cx, 14           ; Length of the buffer
resetLoop:
    mov al, ' '          ; Fill with spaces
    mov [di], al         ; Store the space in the buffer
    inc di               ; Move to the next position
    loop resetLoop       ; Repeat until the entire buffer is filled
    
    print_newline
   
    lea di, line_buffer ; Point DI to ticketBuffer
                                                       
    inc ticketCount                                                   
    ; write ticket count as first char
    mov al, ticketCount 
    mov [di], al        ; Store character in buffer
    inc di              ; Move pointer to next location
    
    mov al, ' '         ; add space 
    mov [di], al        ; Store character in buffer
    inc di              ; Move pointer to next location
    
    ; Prompt for Name
    display book_prompt1

    ; Accept Name (max 10 chars)
    mov cx, 11          ; Up to 10 characters
fillName:
    mov ah, 1           ; Input a character
    int 21h
    cmp al, 0Dh         ; If Enter is pressed before 10 chars
    je addSpaces
    mov [di], al        ; Store character in buffer
    inc di              ; Move pointer to next location
    loop fillName

addSpaces:
    mov al, ' '         ; Fill remaining spaces with ' '
    cmp cx, 0
    jg fillSpace
    
fillSpace:
    mov [di], al        ; Store space in buffer
    inc di              ; Move pointer to next location
    loop fillSpace

    ; Add the $ terminator to buffer
    mov al, '$'
    mov [di], al   ; store $ in buffer  
    
    ; open file
    mov ah, 3dh    ; DOS inteerupt to open file
    lea dx, fname
    mov al, 2    ; 0 for read-only, 1 for write-only, 2 for both
    int 21h
    mov fhandle, ax           
     
    ;Appending File
    mov bx,ax    ; Move the file handle 
    mov cx,0     ; Clear CX 
    mov ah,42h   ; file pointer repositioning
    mov al,02h   ; AL=2 for end of file
    int 21h    

    ;Writing File
    mov cx,13;   Set the count of bytes to write 
    mov dx, offset line_buffer
    mov ah,40h   ; to write to file
    int 21h
   
    ; 6. Close the file
    mov ah, 3Eh     ; to close file
    mov bx, fhandle ; Load the file handle into BX to specify which file to close. 
    int 21h                           
    
    call generate_receipt
    
    print_newline
    
    ret
    
book_flight endp         ; procedure ending

cancel_booking proc      ; procedure beginning
        
        print_newline         
        display cancel_prompt_id 
        print_newline
        
        ; open file
        mov ah, 3dh   ; DOS inteerupt to open file
        lea dx, fname
        mov al, 2
        int 21h
        mov fhandle, ax           
        
        ; read file        
        mov ah, 3fh    ; DOS inteerupt to read file
        lea dx, readbuffer
        mov cx, 2000   ; the number of bytes to store in specified buffer
        mov bx, fhandle ; store the file handle
        int 21h 
        
        ; Close the file
        mov ah, 3Eh     ; to close file
        mov bx, fhandle ; Load the file handle into BX to specify which file to close. 
        int 21h           
        
        ; prompt user for ticket id              
        mov ah, 01h
        int 21h  
        
        xor bl, bl   ; clear bl register
        mov bl, al   ; save user input in bl register for comparison purposes
         
        lea si, readbuffer 
        xor cx, cx   ; clear cx register
          
; search the ticket id in buffer
search:
        mov al, [si]      ; use the value in readbuffer string pointed out by [si] location and store in al register
        cmp al, bl        ; compare string character with user input in bl register
        je cancel_success ; if value matched, jump to cancel_success label, print message and return.
        
        inc cx             ; increment cx variable value to chekc if it reached 5000 value - the max char search value
        cmp cx, 5000
        je not_found       ; jump to another label, inform user ticket id not found and return
        
        inc si             ; incremment si pointer to point to the next char in readbuffer string
        jmp search         ; jump to search label

not_found:
         display cancel_no_bookings 
         ret

cancel_success:
        display cancel_done
        ret
        
        ret 
cancel_booking endp    ; procedure ending

main proc              ; main procedure beginning
    mov ax,@data       ; Initialize the data segment by loading its address into AX
    mov ds,ax          ; Move the value in AX to DS to set up the data segment 
    
    ; Create new file
    mov ah, 3ch    ; DOS inteerupt to create file
    lea dx, fname ; Load the address of the filename into the DX register.
    mov cl, 0    ; attribute value 0 for read only
    int 21h
    mov fhandle, ax ; Store the returned file handle in the variable
    
    ; Close the file
    mov ah, 3Eh     ; to close file
    mov bx, fhandle ; Load the file handle into BX to specify which file to close. 
    int 21h     

menu_loop:
    
    display b1   ; display the border of stars above title

    display title1  ; display the title

    display b1   ; display the border of stars below title
    
    ;display 4 main menu options
    
    display op1
    display op2
    display op3
    display op4

    display prompt1 ; display the prompt to user

    mov ah,1  ; ask user input
    int 21h    
    ; check the user input and jump to the relevant label otherwise display main menu
    cmp al,'1' 
    je show_schedule_call
    cmp al,'2'
    je book_flight_call
    cmp al,'3'
    je cancel_flight_call
    cmp al,'4'
    je exit_program
    jmp menu_loop

show_schedule_call:
    call show_flight_schedule
    jmp menu_loop

book_flight_call:
    call book_flight
    jmp menu_loop

cancel_flight_call:
    call cancel_booking
    jmp menu_loop

exit_program:
    mov ah,4Ch  ; set AH to 4ch, which is the DOS function to terminate the program
    int 21h     ; call DOS interrupt 21H to exit and return control to the operating system
    
main endp    ; procedure ending
end main     ; indicates the end of the assembly code and specifies the entry point 