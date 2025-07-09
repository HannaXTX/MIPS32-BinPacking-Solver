# Title: Bin Packing Problem Solver            Filename: Bin_Packing_Solver.asm  
# Author: Hanna Kaibni, Carlos Khamashta       Date: 23/4/2025  

# Description: Implementing First Fit (FF) and Best Fit (BF) 
#              heuristics for the bin packing problem.  

# Input: A file containing a list of floating-point item sizes between 0 and 1.  
# Output: A file displaying the packed bins and the number of bins used.  

############### Data segment ################  
.data
start:  .asciiz "Enter name or path of the file:\n"
err_file:  .asciiz "Error opening file\n"
err_file2: .asciiz "Error reading file\n"
error_in_file: .asciiz "Error in file inputs\n"
reading: .asciiz "Reading file...\n"
newline: .asciiz "\n"
space: .asciiz" "
success_file: .asciiz "File opened successfully\n"
exit: .asciiz "Exiting program...\n"
entries: .asciiz " Entries in the array \n"
input_file:   .space 300
buffer: .space 1000
entry: .space 1
array_input: .float 0:100 
arr_size: .space 10
output_file: .asciiz "output.txt"
first_fit: .asciiz "FF.First Fit\n"
best_fit: .asciiz "BF.Best Fit \n"
exit_msg: .asciiz "Q. Exit\n"
invalidOp: .asciiz "Invalid operation\n"
operation: .asciiz "Please choose an Operation: \n"
adding: .asciiz "Adding to bin... \n"
input_commad: .asciiz ">  "
choice: .space 3
bins: .float 1.0001:10
obuffer: .space 30
oentry: .space 12
init_bin: .float 1.0001
colon: .asciiz ": "
bin_num_str: .space 1
bin_size: .space 1


# macros were used for less repetition of code

.macro initialize 
    la $s0, array_input # Load address of array_input into $s0
    # $s1, file_descriptor
    la $s3, arr_size
    la $s4, bins # Load address of bins into $s4
    la $s5, obuffer # to link index with each item
    la $s6, bin_size
.end_macro

.macro display_menu
    print_string(operation)
    print_string(first_fit)
    print_string(best_fit)
    print_string(exit_msg)
.end_macro

.macro flush
    initialize
    la $t1, init_bin
    lwc1 $f1 , 0($t1)
    lb $t2, 0($s3)
    flush_loop:
        swc1 $f1 , 0($s4)
        sb $zero, 0($s5) 
        addu $s5,$s5,1
        addu $s4,$s4,4
        subu $t2,$t2,1
        bnez $t2 flush_loop
    end_flush_loop:
.end_macro
 
.macro conv(%string,$int) #word is 4 bytes

    la $t5, %string # Load address of string into $t5
    li $t6, 0 # number to divide whole number by to obtain float
    move $t8, $int # move $int to $t8
    move $t7, $t8 # move the final divisor to $t7
    div $t8, $t8, 10
    li $t9, 0
    #print_int($t8) # Print the value of $int
   
    loop_conv:
        lb $t4, 0($t5) # Load byte from string (ex: 1 from the original 0.1 string)
        sub $t4, $t4, 48 # Convert ASCII to integer (0-9)
        mul $t4, $t4, $t8 # Multiply by current value of $int (ex 0.1 becomes 1*1) 
        add $t9, $t9, $t4 # Add to the total value in $t9 (ex 0.12 becomes 12 = 1*10 + 2*1)
        div $t8, $t8, 10 # Divide by 10 to get next digit true value
        addiu $t5, $t5, 1 # Increment string pointer
        blt $t8, 1 end_loop_conv # Check if $t8 the divisor is 1 (meaning we are done)
        j loop_conv # Continue loop if not done
       
    end_loop_conv:
       # print_int($t9) # Print the final value of $t9
       # print_string(newline)
        mtc1 $t9, $f0 # Move integer to float register (ex 1 becomes 1.0 in float)
        mtc1 $t7, $f1 # Move divisor to float register (ex 10 becomes 10.0 in float)
        
        div.s $f12, $f0, $f1 # Divide the integer by the divisor to get the float value (ex: 1.0/10.0 = 0.1)
        
        # li $v0, 2 # Load syscall for print float
        # syscall
        
        # ADD SIZE TO ARRAY
        la $t7, arr_size # Load address of arr_size into $t8
        lb $t6, 0($t7) # Load the current size of the array into $t6
        addiu $t6, $t6, 1 # Increment the size of the array
        sb $t6, 0($t7) # Store the new size of the array into arr_size

        swc1 $f12, 0($s0)
        addiu $s0, $s0, 4
      

.end_macro

.macro reconv(%float)
    la $t9, oentry         # Load address of empty string
    li $t1, 48             # ASCII '0'
    sb $t1, 0($t9)         # Store in String '0'
    addiu $t9, $t9, 1
    li $t1, 46             # ASCII '.'
    sb $t1, 0($t9)         # Add '.'
    addiu $t9, $t9, 1
    mtc1 $zero, $f21       # 0.0 to check
    li $t5, 0              # Counter for digits after decimal

    mov.s $f31, %float     
    mov.s $f13, $f31        # store input float in temp $f13 ex 0.12
    li $t3, 10
   
    mtc1 $t3, $f17
    cvt.s.w $f17, $f17     # $f17 = 10.0

    loop_reconv:
        mul.s $f13, $f13, $f17     # x *= 10 ex obtain 1.2 from 0.12
        cvt.w.s $f15, $f13         # get 1 from 1.2
        mfc1 $t6, $f15             # move int to $t0 to make sure its 1
        cvt.s.w $f15, $f15         # convert back to float so its 1.0
        sub.s $f13, $f13, $f15     # x = x - int, obtain 0.2 for next loop
        addiu $t6, $t6, 48         # convert 1 to ascii to store
        sb $t6, 0($t9)             # store char
        addiu $t9, $t9, 1          # + pointer
        c.eq.s $f13, $f21
        addiu $t5, $t5, 1          # increment digit counter for maximum allowed digits
        beq $t5, 5, end_loop_reconv # if x == 0.0 then no more numbers to get, exit loop
        bc1t end_loop_reconv
        j loop_reconv
        

    end_loop_reconv:
        li $t6, 0
        sb $t6, 0($t9)             # null-terminate
.end_macro

.macro print_string(%string)  
    li $v0, 4  
    la $a0, %string  
    syscall
.end_macro


.macro print_int(%int)  
    li $v0, 1  
    move $a0, %int  
    syscall
.end_macro

.macro read_string(%string, %size)  
    li $v0, 8  
    la $a0, %string  
    li $a1, %size  
    syscall
.end_macro

.macro open_file(%file, %mode)  
    li $v0, 13  
    la $a0, %file  
    li $a1, %mode  
    syscall
.end_macro

.macro read_file(%file)  
    li $v0, 14  
    move $a0, %file
    la $a1, buffer  
    la $a2, 1000
    syscall
.end_macro

.macro write_file(%file,%write,%size)  
    li $v0, 15
    move $a0, %file
    la $a1, %write  
    la $a2, %size
    syscall
.end_macro

.macro close_file(%file)   # macro for close file
    li $v0, 16  
    move $a0, %file  
    syscall
.end_macro

##########حنون###### Code segment ################  
.text  
.globl main  
main:  
initialize # Initialize important addresses 
sb $zero, 0($s3) # Initialize arr_size to 0
print_string(start) # start messege
read_string(input_file, 100) # read string from terminal

la $t0, input_file    # Load address of input_file into $t0

loop_file_string:
    lb $t1, 0($t0)    # Load byte
    beq $t1, 10, newline_found  # If byte is '\n' (ASCII = 10), replace
    beqz $t1, end_loop_file_string  # If byte is null terminator, break
    addi $t0, $t0, 1   # Increment to next byte in String
    j loop_file_string
newline_found:
    sb $zero, 0($t0)   # Replace '\n' with null terminator
end_loop_file_string:


open_file(input_file, 0)  
move $s1, $v0  # Store file descriptor in $s1
bltz $s1, error_opening_file
j continue
continue:
    print_string(success_file)
    read_file($s1) # read file to store string in buffer
    close_file($s1) # close file as there is no more use for the file
    print_string(reading)
    print_string(buffer)
    la $t2, buffer       # Load address of buffer into $t2

    loop_read_content: #start
        #print_string(newline)
        lb $t0, 0($t2)       # Load byte from buffer
        lb $t1, 1($t2)       # Load next byte from buffer
        beq $t0, 32, end_loop_read_content # Check if byte is " "
        bne $t0, 48 err_in_file    # Check if first byte is 0
        bne $t1, 46 err_in_file    # Check if second byte is .
        
        addi $t2, $t2, 2 # Increment buffer pointer

        li $t3, 1 # Initialize counter for decimal digits
        la $t1, entry   # Load address of entry (the one used for storing the number)
        loop_entry:

            lb $t0, 0($t2)   # Load next byte from buffer after "0."

            sb $t0,($t1) # Store byte in entry

            addi $t2, $t2, 1 # Increment buffer pointer
            addi $t1, $t1, 1 # Increment entry pointer
            lb $t0, 0($t2)  # Load next byte from buffer

      
            mul $t3, $t3, 10 # Increment counter for decimal digits
            bne $t0, 32 loop_entry 
            j next_entry
            next_entry:
                conv(entry, $t3) # Convert entry to float
                addi $t2, $t2, 1 # Increment buffer pointer
                j loop_read_content

        end_loop_entry:
            
    end_loop_read_content:
        la $s0, array_input
        la $t2, arr_size
        lb $t2, 0($t2) # Load the current size of the array into $t2

        print_int($t2)
        print_string(entries)
        loop_array:
            lwc1 $f12, 0($s0) # Load float from array_input  
            
            addiu $s0, $s0, 4 # Increment array_input pointer
            subu $t2, $t2, 1 # Decrement size of array
            
            beqz $t2, end_loop_array # Check if size is 0

            j loop_array

        end_loop_array:
        
        open_file(output_file,1)
        move $s1, $v0  # Store file descriptor in $s1
        bltz $s1, error_opening_file

        menu_loop:
            flush
            initialize
            display_menu
            
            print_string(input_commad)
            li $t3, 32  # To convert to uppercase
            read_string(choice, 3) # Read user choice
            la $t0, choice

            lb $t1, 0($t0) # Load first byte of user choice into $t0
            lb $t2, 1($t0) # Load second byte

            blt $t1, 96 is_upper1
            sub $t1, $t1, $t3 # Convert to uppercase
            is_upper1:
                blt $t2, 96 is_upper2
                sub $t2, $t2, $t3 # Convert to uppercase
            is_upper2:
                sb $t1, 0($t0) # Store back to choice
                sb $t2, 1($t0) # Store back to choice

                # for Q or q
                addu $t0,$t1,$t2 # Add the two bytes together
                beq $t0, 91, exit_program   # ASCII value for 'Q + \n'
                
                # for FF or ff
                bne $t2, 70, invalid # ASCII value for 'F'
                beq $t1, 70, ff # ASCII value for 'F'
                beq $t1, 66, bf # ASCII value for 'B'


                invalid:
                    print_string(invalidOp)        # Print invalid choice message
                    j menu_loop                    # Jump back to menu_loop to try again
                ff:
                    write_file($s1,first_fit,13) # write that the chosen heurstic is ff
              
                    lb $t0, 0($s3) # load size of array
                    lw $t2, 0($s3)   # Load the current size of the array into $t2
                    
                    loop_ff:
                        li $t3, 1
                        lwc1 $f3, 0($s0) # Load float from array_input
                        la $s4, bins # Load address of bins into $s4
                    bins_ff:
                        lwc1 $f5,0($s4) # load bin
                        c.le.s $f3,$f5 # check if item is less than bin
                        bc1f skip_it # skip
                        sub.s $f5,$f5,$f3 # get leftover after subtracting item from bin
                        sb $t3, 0($s5)  #store index
                        swc1 $f5, 0($s4) # store new value
                        addu $s5, $s5, 1 # increment index pointer to make sure all items are linked to an index
                        j end_bins_ff
                    skip_it:
                        addiu $s4, $s4, 4 # Increment bin pointer 
                        addu $t3,$t3,1 # increment bin index
                        bgt $t3,$t0 end_bins_ff # Check if size = 0
                        j bins_ff
                    end_bins_ff:
                    addiu $s0, $s0, 4 # Increment array pointer     
                    subu $t2, $t2, 1 # Decrement size of array
                    beqz $t2 end_loop_ff # Check if size is 0
                    j loop_ff # Continue loop if not done
                    end_loop_ff:
                    j check
                bf:

                    write_file($s1,best_fit,13) # write that the chosen heurstic is bf
                    initialize
                    lb $t3, 0($s3) # Load the current size of the array into $t3
                    lb $t2, 0($s3) # Load the current size of the array into $t2
                    lb $t4, 0($s3)
                    li $t7, 101 # Initialize smallest bin size
                    li $t6, 100
                    mtc1 $t7, $f3
                    mtc1 $t6, $f7
                    div.s $f8, $f3, $f7 # obtain an initial smallest bin
                    
                    loop_bf:

                        li $t3, 1 # Copy size of array to $t3 to monitor bin index
                        lwc1 $f3, 0($s0) # Load float from array_input                        
                        la $s4, bins # Load address of bins into $s4
                        move $t0, $s4   # move bin address
                        mov.s $f9, $f8
                        bins_bf:

                            lwc1 $f5, 0($s4) # load a bin to $f1 (begin)
                            c.le.s $f3, $f5 # check if the item fits the bin 0.3 < 0.6 ?
                            bc1f skip # if it does not fit, skip

                            sub.s $f6, $f5, $f3 # subtract the bin from the item  ex 1 - 0.7 = 0.3
                            c.lt.s $f6, $f9 # check if leftover is the smallest              
                            bc1f skip # if its not less, skip
                            mov.s $f9 , $f6 # new smallest bin size after leftover

                            # mov.s $f12 ,$f9
                            # li $v0, 2 # Load syscall for print float
                            # syscall
                            # print_string(newline)
                            move $t0, $s4 # save address of smallest bin
                            skip:
                                addiu $s4, $s4, 4 # Increment bin pointer 
                                addu $t3,$t3,1 # increment bin index
                                bgt $t3,$t4 end_bins_bf # Check if index = arraysize
                                j bins_bf
                        end_bins_bf:
                            lwc1 $f5, 0($t0) # Load the smallest bin
                            c.le.s $f3, $f5 # check if the item fits the bin 0.3 < 0.6 ?
                            bc1f skip2 # if it does not fit, skip
                            sub.s $f6, $f5, $f3 # subtract the bin from the item  ex 1 - 0.7 = 0.3
                            swc1 $f6, 0($t0) # store the subtraction in the bin

                            # to obtain index
                            la $s4 , bins # get address of bin
                            sub $t0 , $t0 , $s4 # remove difference
                            div $t0,$t0,4 # div by 4 to obtain true index as they move by 4 not 1

                            addu $t0,$t0,1 # add one incase the the division causes issues
                            
                            
                            sb $t0, 0($s5)  # store in obuffer
                            addu $s5,$s5,1 # increment the address for next entry to store

                            skip2:
                            addiu $s0, $s0, 4 # Increment array pointer     
                            subu $t2, $t2, 1 # Decrement size of array
                            beqz $t2, end_loop_bf # Check if size is 0
                            j loop_bf # Continue loop if not done

                    end_loop_bf:
                    j check
                    after_choice:
                    # printing to file algorithm
                    #initialization
                    initialize
                    lb $t0, 0($s6)
                    addu $t0,$t0,1  # add +1 to array to loop from each index starting with 1
                    li $t4, 1  # begin index

                    
                    size_loop:
                        la $t9, bin_num_str
                        addu $t4,$t4,48
                        sb $t4, 0($t9)
                        subu $t4,$t4,48
                        write_file($s1,bin_num_str,1)
                        write_file($s1,colon,2)
                        la $s0, array_input # Load address of array_input into $s0
                        la $s5, obuffer # to link index with each item
                        lb $t2, 0($s3)
                    item_to_bin_loop:
                        
                        lwc1 $f12,0($s0) # get each item value
                        lb $t7, 0($s5)  # load obuffer value
                        bne $t4,$t7 skip_bin  # if index != buffer skip_bin

                        reconv($f12)
                        write_file($s1,oentry,4)
                        write_file($s1,space,1)

                        skip_bin:
                        addu $s0,$s0,4
                        addu $s5,$s5,1
                        subu $t2,$t2,1
                        
                       
                        beqz $t2 end_item_to_bin_loop
                        j item_to_bin_loop
                    end_item_to_bin_loop:
                 

                   
                    write_file($s1,newline,1)

                    addu $t4,$t4,1
                    bne $t4,$t0 size_loop
                    end_size_loop:
       

                    j menu_loop

    err_in_file:
        print_string(error_in_file)
        close_file($s1)
        j main

error_opening_file:  
    print_string(err_file)
    j main


exit_program:
    print_string(exit)
    close_file($s1)
    li $v0, 10   # Exit program  
    syscall

check:
    la $s0, bins
    la $t2, arr_size
    lb $t2, 0($t2) # Load the current size of the array into $t2
    la $s6, bin_size
    li $t6, 0
    la $t7, init_bin
    lwc1 $f13, 0($t7)


    print_int($t2)
    print_string(newline)
    check_bins:
        lwc1 $f12, 0($s0) # Load float from array_input  
        c.lt.s $f12,$f13
        bc1f con
        addu $t6,$t6,1

        li $v0, 2 # Load syscall for print float
        syscall

        print_string(space)
        con:
        addiu $s0, $s0, 4 # Increment array_input pointer
        subu $t2, $t2, 1 # Decrement size of array
        beqz $t2, end_check_bins # Check if size is 0
        j check_bins
       
    end_check_bins:
    print_string(newline)
    sb $t6,0($s6)       # store how many bins were used
    j after_choice      # continue program execution
