#!/bin/bash
# 
# Test script to run gdb with the tkbindex extension.
# SVP 30AUG2017.
#
# I am getting segfaults in the second G test (removing binding at start)!
# 
gdb wish \
    -ex 'set  disassemble-next-line on' \
    -ex 'set breakpoint pending on' \
    -ex 'break tkbindex.c:166' \
    -ex 'display /3i $pc' \
    -ex 'run tests/tests.tcl ABCDEFG' \
    -ex 'disassemble /m $eip,+100'

# scotty@workshoppc:~/src/tcltk/tkbindex$ debugging/run_gdb.sh 
# GNU gdb (Ubuntu 8.2-0ubuntu1~16.04.1) 8.2
# Copyright (C) 2018 Free Software Foundation, Inc.
# License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.
# Type "show copying" and "show warranty" for details.
# This GDB was configured as "x86_64-linux-gnu".
# Type "show configuration" for configuration details.
# For bug reporting instructions, please see:
# <http://www.gnu.org/software/gdb/bugs/>.
# Find the GDB manual and other documentation resources online at:
#     <http://www.gnu.org/software/gdb/documentation/>.
# 
# For help, type "help".
# Type "apropos word" to search for commands related to "word"...
# Reading symbols from wish...(no debugging symbols found)...done.
# 1: x/3i $pc
# <error: No registers.>
# Starting program: /usr/bin/wish tests/tests.tcl ABCDEFG
# [Thread debugging using libthread_db enabled]
# Using host libthread_db library "/lib/x86_64-linux-gnu/libthread_db.so.1".
# ++++ A. bindex-1 PASSED
# ++++ B. bindex-1 PASSED
# ++++ C. bindex-1 PASSED
# ++++ D. bindex-1 PASSED
# ++++ D. bindex-2 PASSED
# ++++ E. bindex-1 PASSED
# ++++ F. bindex-1 PASSED
# ++++ F. bindex-2 PASSED
# ++++ F. bindex-3 PASSED
# ++++ F. bindex-4 PASSED
# ++++ F. bindex-5 PASSED
# ++++ G. bindex-1 PASSED
# ++++ G. bindex-2 PASSED
# alloc: invalid block: 0x8d8c40: 34 0
# 
# Program received signal SIGABRT, Aborted.
# 0x00007ffff7336438 in __GI_raise (sig=sig@entry=6)
#     at ../sysdeps/unix/sysv/linux/raise.c:54
# 54      ../sysdeps/unix/sysv/linux/raise.c: No such file or directory.
#    0x00007ffff733642b <__GI_raise+43>:  48 63 d7        movslq %edi,%rdx
#    0x00007ffff733642e <__GI_raise+46>:  b8 ea 00 00 00  mov    $0xea,%eax
#    0x00007ffff7336433 <__GI_raise+51>:  48 63 f9        movslq %ecx,%rdi
#    0x00007ffff7336436 <__GI_raise+54>:  0f 05   syscall 
# => 0x00007ffff7336438 <__GI_raise+56>:  48 3d 00 f0 ff ff       cmp    $0xfffffffffffff000,%rax
#    0x00007ffff733643e <__GI_raise+62>:  77 20   ja     0x7ffff7336460 <__GI_raise+96>
# 1: x/3i $pc
# => 0x7ffff7336438 <__GI_raise+56>:      cmp    $0xfffffffffffff000,%rax
#    0x7ffff733643e <__GI_raise+62>:
#     ja     0x7ffff7336460 <__GI_raise+96>
#    0x7ffff7336440 <__GI_raise+64>:      repz retq 
# Value can't be converted to integer.
# (gdb) show stack


#     -ex 'break Tcl_Exit' \
# gdb /c/Tcl/bin/wish86g.exe \
#     -ex 'set  disassemble-next-line on' \
#     -ex 'display /3i $pc' \
#     -ex 'break main' \
#     -ex 'run c:/Threetronics/GAP-USB/TclTkAlarmPanelManager/ui/main.tcl --icanvastest'

#     -ex 'break GdiPhoto' \
#     -ex 'continue' \
#     -ex 'continue'

#     -ex 'continue' \
#     -ex 'disassemble /m $eip,+150' \
#     -ex 'info reg'
     
#     -ex 'break msvcrt!_invalid_parameter' \
#     -ex 'break msvcrt!_ftol2_sse_excpt' \
#     -ex 'break exit' \
#     -ex 'break Tcl_Exit' \
#     -ex 'break __gcc_deregister_frame' \
#     -ex 'continue' \
#     -ex 'disassemble /m $eip,+100'
 

 
 
 
 
 
 
 
 # 
#  The segault is at the call to Tk_FindPhoto().
# tkStubsPtr is empty!
#  
#  
#  (gdb) si
# 0x6b542e81      1106      if ( photoname == 0 ) {
# (gdb) nexti
# 1114      if ((photo_handle = Tk_FindPhoto (interp, photoname)) == 0) {
# (gdb) disassemble /m $eip,+150
# Dump of assembler code from 0x6b542eb8 to 0x6b542f4e:
# 1114      if ((photo_handle = Tk_FindPhoto (interp, photoname)) == 0) {
# => 0x6b542eb8 <GdiPhoto+836>:   mov    0x6b559520,%eax
#    0x6b542ebd <GdiPhoto+841>:   mov    0x108(%eax),%eax
#    0x6b542ec3 <GdiPhoto+847>:   mov    -0x1c(%ebp),%edx
#    0x6b542ec6 <GdiPhoto+850>:   mov    %edx,0x4(%esp)
#    0x6b542eca <GdiPhoto+854>:   mov    0xc(%ebp),%edx
#    0x6b542ecd <GdiPhoto+857>:   mov    %edx,(%esp)
#    0x6b542ed0 <GdiPhoto+860>:   call   *%eax
#    0x6b542ed2 <GdiPhoto+862>:   mov    %eax,-0x3c(%ebp)
#    0x6b542ed5 <GdiPhoto+865>:   cmpl   $0x0,-0x3c(%ebp)
#    0x6b542ed9 <GdiPhoto+869>:   jne    0x6b542f1f <GdiPhoto+939>

# 1115        Tcl_AppendResult(interp, "gdi photo: Photo name ", photoname, " can't be located\n", usage_message, 0);
#    0x6b542edb <GdiPhoto+871>:   mov    0x6b55950c,%eax
#    0x6b542ee0 <GdiPhoto+876>:   mov    0x120(%eax),%eax
#    0x6b542ee6 <GdiPhoto+882>:   movl   $0x0,0x14(%esp)
#    0x6b542eee <GdiPhoto+890>:   movl   $0x6b551b00,0x10(%esp)
#    0x6b542ef6 <GdiPhoto+898>:   movl   $0x6b5533d1,0xc(%esp)
#    0x6b542efe <GdiPhoto+906>:   mov    -0x1c(%ebp),%edx
#    0x6b542f01 <GdiPhoto+909>:   mov    %edx,0x8(%esp)
#    0x6b542f05 <GdiPhoto+913>:   movl   $0x6b5533e4,0x4(%esp)
#    0x6b542f0d <GdiPhoto+921>:   mov    0xc(%ebp),%edx
#    0x6b542f10 <GdiPhoto+924>:   mov    %edx,(%esp)
#    0x6b542f13 <GdiPhoto+927>:   call   *%eax

# 1116        return TCL_ERROR;
#    0x6b542f15 <GdiPhoto+929>:   mov    $0x1,%eax
#    0x6b542f1a <GdiPhoto+934>:   jmp    0x6b543301 <GdiPhoto+1933>

# 1117      }
# 1118      Tk_PhotoGetImage (photo_handle, &img_block);
#    0x6b542f1f <GdiPhoto+939>:   mov    0x6b559520,%eax
#    0x6b542f24 <GdiPhoto+944>:   mov    0x250(%eax),%eax
#    0x6b542f2a <GdiPhoto+950>:   lea    -0x74(%ebp),%edx
#    0x6b542f2d <GdiPhoto+953>:   mov    %edx,0x4(%esp)
#    0x6b542f31 <GdiPhoto+957>:   mov    -0x3c(%ebp),%edx
#    0x6b542f34 <GdiPhoto+960>:   mov    %edx,(%esp)
#    0x6b542f37 <GdiPhoto+963>:   call   *%eax

# 1119
# 1120      nx  = img_block.width;
#    0x6b542f39 <GdiPhoto+965>:   mov    -0x70(%ebp),%eax
#    0x6b542f3c <GdiPhoto+968>:   mov    %eax,-0x40(%ebp)

# 1121      ny  = img_block.height;
#    0x6b542f3f <GdiPhoto+971>:   mov    -0x6c(%ebp),%eax
#    0x6b542f42 <GdiPhoto+974>:   mov    %eax,-0x44(%ebp)

# 1122      sll = ((3*nx + 3) / 4)*4; /* must be multiple of 4 */
#    0x6b542f45 <GdiPhoto+977>:   mov    -0x40(%ebp),%eax
#    0x6b542f48 <GdiPhoto+980>:   lea    0x1(%eax),%edx
#    0x6b542f4b <GdiPhoto+983>:   mov    %edx,%eax
#    0x6b542f4d <GdiPhoto+985>:   add    %eax,%eax
#    0x6b542f4f <GdiPhoto+987>:   add    %edx,%eax
#    0x6b542f51 <GdiPhoto+989>:   lea    0x3(%eax),%edx
#    0x6b542f54 <GdiPhoto+992>:   test   %eax,%eax
#    0x6b542f56 <GdiPhoto+994>:   cmovs  %edx,%eax
#    0x6b542f59 <GdiPhoto+997>:   sar    $0x2,%eax
#    0x6b542f5c <GdiPhoto+1000>:  shl    $0x2,%eax
#    0x6b542f5f <GdiPhoto+1003>:  mov    %eax,-0x48(%ebp)

# End of assembler dump.
# (gdb)
