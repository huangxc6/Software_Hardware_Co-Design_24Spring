`timescale 1ns/1ns  //定义时间刻度
//模块、接口定义
module uart_tx_tb();

    initial
    begin            
        $dumpfile("uart_tx_tb.vcd"); //生成的vcd文件名称
        $dumpvars(0, uart_tx_tb);    //tb模块名称
    end

    reg         sys_clk;
    reg         sys_rst_n;
    reg [7:0]   uart_data;
    reg         uart_tx_en;    
    wire        uart_txd;

    parameter       CLK_CYCLE=20;               //时钟周期20ns
    parameter       BPS=115200;                 //波特率115200bps，可更改
    parameter       SYS_CLK_FRE=50_000_000;     //50M系统时钟
    localparam      BPS_CNT=SYS_CLK_FRE/BPS;    //传输一位数据所需要的时钟个数

    //例化被测试的接收模块
    uart_tx #(
        .BPS            (BPS),       //波特率115200
        .SYS_CLK_FRE    (SYS_CLK_FRE)    //时钟频率50M	
    ) u_uart_tx (
        .sys_clk        (sys_clk),
        .sys_rst_n      (sys_rst_n),
        .uart_data      (uart_data),
        .uart_tx_en     (uart_tx_en),
        .uart_txd       (uart_txd)
    );

    reg [7:0] DATA = 8'hAB;
    localparam  CNT=BPS_CNT*CLK_CYCLE;  //计算出传输每个时钟所需要的时间
    initial begin   //传输8位数据   8'b01010101
        //初始时刻定义
            sys_clk     <= 1'b0;
            sys_rst_n   <= 1'b0;
            uart_tx_en  <= 1'b0;
            uart_data   <= DATA;//发送数据 01010101
        #CLK_CYCLE //系统开始工作
            sys_rst_n   <=1'b1;
        #(CNT/2)
            uart_tx_en  <=1'b1;
        #CLK_CYCLE
            uart_tx_en  <=1'b0;
        #(CNT*10)
        $finish;
    end

    always begin
        #(CLK_CYCLE/2)  sys_clk=~sys_clk;   //时钟20ns,50M
    end
 
endmodule 
