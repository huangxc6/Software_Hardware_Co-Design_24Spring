module imem(input  logic [31:0] a,
            output logic [31:0] rd);

  logic [31:0] RAM[63:0];

 // initial
 //     $readmemh("/project/users/PKUSOC-18/work/cpu_for_fpga_class/riscv_sources/riscvtest.txt",RAM);
/* # riscvtest.s
# Sarah.Harris@unlv.edu
# David_Harris@hmc.edu
# 27 Oct 2020
#
# Test the RISC-V processor.  
#  add, sub, and, or, slt, addi, lw, sw, beq, jal
# If successful, it should write the value 25 to address 100

#       RISC-V Assembly         Description               Address   Machine Code   binary
main:   addi x2, x0, 5          # x2 = 5                  0         00500113   
        addi x3, x0, 12         # x3 = 12                 4         00C00193
        mul  x7, x3, x2         # x7 = (12 * 5) = 60      8         023103B3      0000001 00010 00011 000 00111 01100 11 
        div  x4, x7, x2         # x4 = (60 / 5) = 12      C         0223C233      0000001 00010 00111 100 00100 01100 11
        addi x2, x0, 5          # x2=5                    10        00500113      0000001 00100 00010 110 00101 01100 11
        add  x5, x5, x4         # x5 = (2 + 12) = 14      14        004282B3
        beq  x5, x7, end        # shouldn't be taken      18        02728863
        slt  x4, x3, x4         # x4 = (12 < 12) = 0      1C        0041A233
        beq  x4, x0, around     # should be taken         20        00020463
        addi x5, x0, 0          # shouldn't happen        24        00000293
around: slt  x4, x7, x2         # x4 = (3 < 5)  = 1       28        0023A233
        add  x7, x4, x5         # x7 = (1 + 11) = 12      2C        005203B3
        sub  x7, x7, x2         # x7 = (12 - 5) = 7       30        402383B3
        sw   x7, 84(x3)         # [96] = 7                34        0471AA23 
        lw   x2, 96(x0)         # x2 = [96] = 7           38        06002103 
        add  x9, x2, x5         # x9 = (7 + 11) = 18      3C        005104B3
        jal  x3, end            # jump to end, x3 = 0x44  40        008001EF
        addi x2, x0, 1          # shouldn't happen        44        00100113
end:    add  x2, x2, x9         # x2 = (7 + 18)  = 25     48        00910133
        sw   x2, 0x20(x3)       # mem[100] = 25           4C        0221A023 
done:   beq  x2, x2, done       # infinite loop           50        00210063
*/		
		

  assign rd = RAM[a[31:2]]; // word aligned

  assign RAM[0]  = 32'h00500113;
  assign RAM[1]  = 32'h00C00193;
  assign RAM[2]  = 32'h023103B3;
  assign RAM[3]  = 32'h0223C233;
  assign RAM[4]  = 32'h00500113;
  assign RAM[5]  = 32'h004282B3;
  assign RAM[6]  = 32'h02728863;
  assign RAM[7]  = 32'h0041A233;
  assign RAM[8]  = 32'h00020463;
  assign RAM[9]  = 32'h00000293;
  //assign RAM[10] = 32'h01EF0F33;
  //assign RAM[11] = 32'h01EF0F33;
  //assign RAM[12] = 32'h01EF0F33;
  //assign RAM[13] = 32'h01EF0F33;
  //assign RAM[14] = 32'h10000f93;
  //assign RAM[15] = 32'h00100e93;
  //assign RAM[16] = 32'h00000e13;
  //assign RAM[17] = 32'h001E0E13;
  //assign RAM[18] = 32'h01EE0463;
  //assign RAM[19] = 32'hFF9FF06F;
  //assign RAM[20] = 32'h01DE8EB3;
  //assign RAM[21] = 32'hFFFE84E3;
  //assign RAM[22] = 32'hFE9FF06F;

endmodule