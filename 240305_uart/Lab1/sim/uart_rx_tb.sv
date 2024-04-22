`timescale 1ns/1ns  //定义时间刻度
//模块、接口定义
module uart_rx_tb();

    initial
    begin            
        $dumpfile("uart_rx_tb.vcd");            //生成的vcd文件名称
        $dumpvars(0, uart_rx_tb);               //tb模块名称
    end

    reg sys_clk;
    reg sys_rst_n;
    reg uart_rxd;
    wire uart_rx_done;
    wire [7:0] uart_rx_data;

    parameter       CLK_CYCLE=20;               //时钟周期20ns
    parameter       BPS=115200;                 //波特率115200bps，可更改
    parameter       SYS_CLK_FRE=50_000_000;     //50M系统时钟
    localparam      BPS_CNT=SYS_CLK_FRE/BPS;    //传输一位数据所需要的时钟个数

    //例化被测试的接收模块
    uart_rx #(
        .BPS            (BPS),                  //波特率115200
        .SYS_CLK_FRE    (SYS_CLK_FRE)           //时钟频率50M	
    ) u_uart_rx (
        .sys_clk        (sys_clk),
        .sys_rst_n      (sys_rst_n),
        .uart_rxd       (uart_rxd),
        .uart_rx_done   (uart_rx_done),
        .uart_rx_data   (uart_rx_data)
    );

    reg [7:0] DATA = 8'h55;
    localparam  CNT=BPS_CNT*CLK_CYCLE;  //计算出传输每个时钟所需要的时间
    initial begin   //传输8位数据	8'b01010101
        //初始时刻定义
            sys_clk	<=1'b0;
            sys_rst_n<=1'b0;
            uart_rxd<=1'b1;
        #CLK_CYCLE //系统开始工作
            sys_rst_n<=1'b1;
        #(CNT/2)
            uart_rxd<=1'b0;//开始传输起始位
        #CNT
            uart_rxd<=DATA[0];//传输最低位，第1位
        #CNT
            uart_rxd<=DATA[1];//传输第2位
        #CNT
            uart_rxd<=DATA[2];//传输第3位
        #CNT
            uart_rxd<=DATA[3];//传输第4位
        #CNT
            uart_rxd<=DATA[4];//传输第5位
        #CNT
            uart_rxd<=DATA[5];//传输第6位
        #CNT
            uart_rxd<=DATA[6];//传输第7位
        #CNT
            uart_rxd<=DATA[7];//传输最高位，第8位
        #CNT
            uart_rxd<=1'b1;	//传输终止位
        #CNT
        $finish;
    end

    always begin
        #(CLK_CYCLE/2)  sys_clk=~sys_clk;   //时钟20ns,50M
    end

endmodule 
