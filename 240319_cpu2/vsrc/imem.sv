module imem(input  logic [31:0] a,
            output logic [31:0] rd);

  logic [31:0] RAM[63:0];

  assign rd = RAM[a[31:2]]; // word aligned

// # 1. Test the RISC-V processor.  
// #  add, sub, and, or, slt, addi, lw, sw, beq, jal
// # If successful, it should write the value 25 to address 100
// 
// #       RISC-V Assembly         Description               Address   Machine Code
// main:   addi x2, x0, 5          # x2 = 5                  0         00500113   
//         addi x3, x0, 12         # x3 = 12                 4         00C00193
//         addi x7, x3, -9         # x7 = (12 - 9) = 3       8         FF718393
//         or   x4, x7, x2         # x4 = (3 OR 5) = 7       C         0023E233
//         and  x5, x3, x4         # x5 = (12 AND 7) = 4     10        0041F2B3
//         add  x5, x5, x4         # x5 = (4 + 7) = 11       14        004282B3
//         beq  x5, x7, end        # shouldn't be taken      18        02728863
//         slt  x4, x3, x4         # x4 = (12 < 7) = 0       1C        0041A233
//         beq  x4, x0, around     # should be taken         20        00020463
//         addi x5, x0, 0          # shouldn't happen        24        00000293
// around: slt  x4, x7, x2         # x4 = (3 < 5)  = 1       28        0023A233
//         add  x7, x4, x5         # x7 = (1 + 11) = 12      2C        005203B3
//         sub  x7, x7, x2         # x7 = (12 - 5) = 7       30        402383B3
//         sw   x7, 84(x3)         # [96] = 7                34        0471AA23 
//         lw   x2, 96(x0)         # x2 = [96] = 7           38        06002103 
//         add  x9, x2, x5         # x9 = (7 + 11) = 18      3C        005104B3
//         jal  x3, end            # jump to end, x3 = 0x44  40        008001EF
//         addi x2, x0, 1          # shouldn't happen        44        00100113
// end:    add  x2, x2, x9         # x2 = (7 + 18)  = 25     48        00910133
//         sw   x2, 0x20(x3)       # mem[100] = 25           4C        0221A023 
// done:   beq  x2, x2, done       # infinite loop           50        00210063

//   assign RAM[0]  = 32'h00500113;
//   assign RAM[1]  = 32'h00C00193;
//   assign RAM[2]  = 32'hFF718393;
//   assign RAM[3]  = 32'h0023E233;
//   assign RAM[4]  = 32'h0041F2B3;
//   assign RAM[5]  = 32'h004282B3;
//   assign RAM[6]  = 32'h02728863;
//   assign RAM[7]  = 32'h0041A233;
//   assign RAM[8]  = 32'h00020463;
//   assign RAM[9]  = 32'h00000293;
//   assign RAM[10] = 32'h0023A233;
//   assign RAM[11] = 32'h005203B3;
//   assign RAM[12] = 32'h402383B3;
//   assign RAM[13] = 32'h0471AA23;
//   assign RAM[14] = 32'h06002103;
//   assign RAM[15] = 32'h005104B3;
//   assign RAM[16] = 32'h008001EF;
//   assign RAM[17] = 32'h00100113;
//   assign RAM[18] = 32'h00910133;
//   assign RAM[19] = 32'h0221A023;
//   assign RAM[20] = 32'h00210063;

// # 2. rotated led.
// #  add, sub, and, or, slt, addi, lw, sw, beq, jal
// # If successful, fpga led is rotated all the time.
//
//  #           RISC-V Assembly         Description                     Address     Machine Code
//  init:       addi t5, x0, 2047       # count_max, t5 = 2047          0           0x7FF00F13  # 0111_1111_1111_00000_000_11110_0010011
//              add  t5, t5, t5         # count_max, t5 = 2047*2        4           0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//              add  t5, t5, t5         # count_max, t5 = 2047*4        8           0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//              add  t5, t5, t5         # count_max, t5 = 2047*8        12          0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//              add  t5, t5, t5         # count_max, t5 = 2047*16       16          0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//              add  t5, t5, t5         # count_max, t5 = 2047*32       20          0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//              add  t5, t5, t5         # count_max, t5 = 2047*64       24          0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//              add  t5, t5, t5         # count_max, t5 = 2047*128      28          0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//              add  t5, t5, t5         # count_max, t5 = 2047*256      32          0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//              add  t5, t5, t5         # count_max, t5 = 2047*512      36          0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//              add  t5, t5, t5         # count_max, t5 = 2047*1024     40          0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//              add  t5, t5, t5         # count_max, t5 = 2047*2048     44          0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//              add  t5, t5, t5         # count_max, t5 = 2047*4096     48          0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//              add  t5, t5, t5         # count_max, t5 = 2047*8192     52          0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//              addi t6, x0, 256        # led_max, t6 = 256             56          0x10000f93  # 0001_0000_0000_00000_000_11111_0010011
//  clean_led:  addi t4, x0, 1          # init led value, t4 = 1        60          0x00100e93  # 0000_0000_0001_00000_000_11101_0010011
//  clean_cnt:  addi t3, x0, 0          # clear count(t3).              64          0x00000e13  # 0000_0000_0000_00000_000_11100_0010011
//  count:      addi t3, t3, 1          # count++                       68          0x001E0E13  # 0000_0000_0001_11100_000_11100_0010011
//              beq  t3, t5, mov_led    # if count==max, jump mov_led   72          0x01EE0463  # 0000_000_11110_11100_000_01000_1100011
//              jal count               #                               76          0xFF9FF06F  # 11111111100111111111_00000_1101111
//  mov_led:    add t4, t4, t4          # led << 1.                     80          0x01DE8EB3  # 0000_000_11101_11101_000_11101_0110011
//              beq t4, t6, clean_led   #                               84          0xFFFE84E3  # 1111_111_11111_11101_000_01001_1100011
//              jal clean_cnt           #                               88          0xFE9FF06F 	# 11111110100111111111_00000_1101111


//   assign RAM[0]  = 32'h7FF00F13;
//   assign RAM[1]  = 32'h01EF0F33;
//   assign RAM[2]  = 32'h01EF0F33;
//   assign RAM[3]  = 32'h01EF0F33;
//   assign RAM[4]  = 32'h01EF0F33;
//   assign RAM[5]  = 32'h01EF0F33;
//   assign RAM[6]  = 32'h01EF0F33;
//   assign RAM[7]  = 32'h01EF0F33;
//   assign RAM[8]  = 32'h01EF0F33;
//   assign RAM[9]  = 32'h01EF0F33;
//   assign RAM[10] = 32'h01EF0F33;
//   assign RAM[11] = 32'h01EF0F33;
//   assign RAM[12] = 32'h01EF0F33;
//   assign RAM[13] = 32'h01EF0F33;
//   assign RAM[14] = 32'h10000f93;
//   assign RAM[15] = 32'h00100e93;
//   assign RAM[16] = 32'h00000e13;
//   assign RAM[17] = 32'h001E0E13;
//   assign RAM[18] = 32'h01EE0463;
//   assign RAM[19] = 32'hFF9FF06F;
//   assign RAM[20] = 32'h01DE8EB3;
//   assign RAM[21] = 32'hFFFE84E3;
//   assign RAM[22] = 32'hFE9FF06F;

// # 2. rotated led. loop
// #  add, sub, and, or, slt, addi, lw, sw, beq, jal
// # If successful, fpga led is rotated all the time.
//
//  #           RISC-V Assembly         Description                     Address     Machine Code
//  init:       addi t5, x0, 2047       # count_max, t5 = 2047          0           0x7FF00F13  # 0111_1111_1111_00000_000_11110_0010011
//              add  t5, t5, t5         # count_max, t5 = 2047*2        4           0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//              add  t5, t5, t5         # count_max, t5 = 2047*4        8           0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//              add  t5, t5, t5         # count_max, t5 = 2047*8        12          0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//              add  t5, t5, t5         # count_max, t5 = 2047*16       16          0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//              add  t5, t5, t5         # count_max, t5 = 2047*32       20          0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//              add  t5, t5, t5         # count_max, t5 = 2047*64       24          0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//              add  t5, t5, t5         # count_max, t5 = 2047*128      28          0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//              add  t5, t5, t5         # count_max, t5 = 2047*256      32          0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//              add  t5, t5, t5         # count_max, t5 = 2047*512      36          0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//              add  t5, t5, t5         # count_max, t5 = 2047*1024     40          0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//              add  t5, t5, t5         # count_max, t5 = 2047*2048     44          0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//              add  t5, t5, t5         # count_max, t5 = 2047*4096     48          0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//              add  t5, t5, t5         # count_max, t5 = 2047*8192     52          0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//              addi t6, x0, 256        # led_max, t6 = 256             56          0x10000f93  # 0001_0000_0000_00000_000_11111_0010011
//  clean_led:  addi t4, x0, 1          # init led value, t4 = 1        60          0x00100e93  # 0000_0000_0001_00000_000_11101_0010011
//  clean_cnt:  addi t3, x0, 0          # clear count(t3).              64          0x00000e13  # 0000_0000_0000_00000_000_11100_0010011
//  count:      addi t3, t3, 1          # count++                       68          0x001E0E13  # 0000_0000_0001_11100_000_11100_0010011
//              beq  t3, t5, mov_led    # if count==max, jump mov_led   72          0x01EE0463  # 0000_000_11110_11100_000_01000_1100011 # 0000_0000_0100 4
//              jal count               #                               76          0xFF9FF06F  # 11111111100111111111_00000_1101111
//  mov_led:    add t4, t4, t4          # led << 1.                     80          0x01DE8EB3  # 0000_000_11101_11101_000_11101_0110011
//              beq t4, t6, clean_led   #                               84          0xFFFE84E3  # 1111_111_11111_11101_000_01001_1100011
//              jal clean_cnt           #                               88          0xFE9FF06F 	# 11111110100111111111_00000_1101111

//    assign RAM[0]  = 32'h7FF00F13;
//    assign RAM[1]  = 32'h01EF0F33;
//    assign RAM[2]  = 32'h01EF0F33;
//    assign RAM[3]  = 32'h01EF0F33;
//    assign RAM[4]  = 32'h01EF0F33;
//    assign RAM[5]  = 32'h01EF0F33;
//    assign RAM[6]  = 32'h01EF0F33;
//    assign RAM[7]  = 32'h01EF0F33;
//    assign RAM[8]  = 32'h01EF0F33;
//    assign RAM[9]  = 32'h01EF0F33;
//    assign RAM[10] = 32'h01EF0F33;
//    assign RAM[11] = 32'h01EF0F33;
//    assign RAM[12] = 32'h01EF0F33;
//    assign RAM[13] = 32'h01EF0F33;
//    assign RAM[14] = 32'h10000f93;
//    assign RAM[15] = 32'h00100393;
//    assign RAM[16] = 32'h00100e93;
//    assign RAM[17] = 32'h00100e13;
//    assign RAM[18] = 32'h001E0E13;
//    assign RAM[19] = 32'h01EE0463;
//    assign RAM[20] = 32'hFF9FF06F;
//    assign RAM[21] = 32'h01DE8EB3;
//    assign RAM[22] = 32'h01FE8C63;
//    assign RAM[23] = 32'hFE9FF06F;
//    assign RAM[24] = 32'h00100e13;
//    assign RAM[25] = 32'h001E0E13;
//    assign RAM[26] = 32'h01EE0463;
//    assign RAM[27] = 32'hFF9FF06F;
//    assign RAM[28] = 32'hF80E8E93;  // -128
//    assign RAM[29] = 32'hFFD380E3;
//    assign RAM[30] = 32'hFE9FF06F;


// init:       addi t5, x0, 2047       # count_max, t5 = 2047          0           0x7FF00F13  # 0111_1111_1111_00000_000_11110_0010011
//             add  t5, t5, t5         # count_max, t5 = 2047*2        4           0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//             add  t5, t5, t5         # count_max, t5 = 2047*4        8           0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//             add  t5, t5, t5         # count_max, t5 = 2047*8        12          0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//             add  t5, t5, t5         # count_max, t5 = 2047*16       16          0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//             add  t5, t5, t5         # count_max, t5 = 2047*32       20          0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//             add  t5, t5, t5         # count_max, t5 = 2047*64       24          0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//             add  t5, t5, t5         # count_max, t5 = 2047*128      28          0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//             add  t5, t5, t5         # count_max, t5 = 2047*256      32          0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//             add  t5, t5, t5         # count_max, t5 = 2047*512      36          0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//             add  t5, t5, t5         # count_max, t5 = 2047*1024     40          0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//             add  t5, t5, t5         # count_max, t5 = 2047*2048     44          0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//             add  t5, t5, t5         # count_max, t5 = 2047*4096     48          0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//             add  t5, t5, t5         # count_max, t5 = 2047*8192     52          0x01EF0F33  # 0000_000_11110_11110_000_11110_0110011
//             addi t6, x0, 256        # led_max, t6 = 256             56          0x10000f93  # 0001_0000_0000_00000_000_11111_0010011
//             addi t2, x0, 0          # led_min, t2 = 1               60          0x00000393  # 0000_0000_0000_00000_000_00111_0010011
//             addi t1, x0, 1          # led, t1 = 0                   64          0x00100313  # 0000_0000_0001_00000_000_00110_0010011
// clean_led:  addi t4, x0, 1          # init led value, t4 = 1        68          0x00100e93  # 0000_0000_0001_00000_000_11101_0010011
// clean_cnt:  addi t3, x0, 1          # clear count(t3).              72          0x00100e13  # 0000_0000_0001_00000_000_11100_0010011
// count:      addi t3, t3, 1          # count++                       76          0x001E0E13  # 0000_0000_0001_11100_000_11100_0010011
//             beq  t3, t5, mov_led    # if count==max, jump mov_led   80          0x01EE0463  # 0000_000_11110_11100_000_01000_1100011 # 0000_0000_0100
//             jal count               #                               84          0xFF9FF06F  # 11111111100111111111_00000_1101111
// mov_led:    add t4, t4, t4          # led << 1.                     88          0x01DE8EB3  # 0000_000_11101_11101_000_11101_0110011
//             beq t4, t6, rev_mov     #                               92          0x01FE8C63  # 0000_000_11111_11101_000_11000_1100011
//             jal clean_cnt           #                               96          0xFE9FF06F 	# 11111110100111111111_00000_1101111
// rev_clr_cnt addi t3, x0, 1          # clear count(t3).              100         0x00100e13  # 0000_0000_0001_00000_000_11100_0010011         
// rev_count:  addi t3, t3, 1          # count++                       104         0x001E0E13  # 0000_0000_0001_11100_000_11100_0010011
//             beq  t3, t5, rev_mov    # if count==max, jump rev_mov   108         0x01EE0463  # 0000_000_11110_11100_000_01000_1100011
//             jal rev_count           #                               112         0xFF9FF06F  # 11111111100111111111_00000_1101111
// rev_mov:    srl  t4, t4, t1         # led >> 1.                     116         0x006EDEB3  # 0000_000_00110_11101_101_11101_0110011
//             beq  t2, t4, clean_led  # if led==min, jump clean_led   120         0xFDD386E3  # 1111_110_11101_00111_000_01101_1100011
//             jal rev_clr_cnt         #                               124         0xFE9FF06F  # 11111110100111111111_00000_1101111

   assign RAM[0]  = 32'h7FF00F13;
   assign RAM[1]  = 32'h01EF0F33;
   assign RAM[2]  = 32'h01EF0F33;
   assign RAM[3]  = 32'h01EF0F33;
   assign RAM[4]  = 32'h01EF0F33;
   assign RAM[5]  = 32'h01EF0F33;
   assign RAM[6]  = 32'h01EF0F33;
   assign RAM[7]  = 32'h01EF0F33;
   assign RAM[8]  = 32'h01EF0F33;
   assign RAM[9]  = 32'h01EF0F33;
   assign RAM[10] = 32'h01EF0F33;
   assign RAM[11] = 32'h01EF0F33;
   assign RAM[12] = 32'h01EF0F33;
   assign RAM[13] = 32'h01EF0F33;
   assign RAM[14] = 32'h10000f93;
   assign RAM[15] = 32'h00000393;
   // 00100313
   assign RAM[16] = 32'h00100313;
   assign RAM[17] = 32'h00100e93;
   assign RAM[18] = 32'h00100e13;
   assign RAM[19] = 32'h001E0E13;
   assign RAM[20] = 32'h01EE0463;
   assign RAM[21] = 32'hFF9FF06F;
   assign RAM[22] = 32'h01DE8EB3;
   assign RAM[23] = 32'h01FE8C63;
   assign RAM[24] = 32'hFE9FF06F;
   assign RAM[25] = 32'h00100e13;
   assign RAM[26] = 32'h001E0E13;
   assign RAM[27] = 32'h01EE0463;
//    assign RAM[28] = 32'hFFFE8E93; -1
//    srl 0x007EDEB3
   assign RAM[28] = 32'hFF9FF06F;
   assign RAM[29] = 32'h006EDEB3;
   assign RAM[30] = 32'hFDD386E3;
   assign RAM[31] = 32'hFE9FF06F;  

endmodule
