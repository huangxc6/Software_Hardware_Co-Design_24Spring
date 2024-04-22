module serdiv#(
  parameter WIDTH = 32
)(
  input                     i_clk         ,
  input                     i_rst        ,
  input                     i_flush       , //取消当前计算
  input                     i_start       , //开始计算
  output                    o_busy        , //计算中
  output logic              o_end_valid   , //计算结束
  input                     i_signed      , //有符号数1 无符号数0
  input  logic [WIDTH-1:0]  i_dividend    ,
  input  logic [WIDTH-1:0]  i_divisor     ,
  output logic [WIDTH-1:0]  o_quotient    ,
  output logic [WIDTH-1:0]  o_remainder
);

  // 1. control signal:///////////////////////////////////////////////////////////////////////
  localparam CNT_W = $clog2(WIDTH); 
  
  logic [CNT_W-1:0] cnt;

  wire cntneq0 = |cnt; // cnt != 0
  
  assign o_busy = (cntneq0) | o_end_valid;

  always@(posedge i_clk or negedge i_rst)begin
    if(i_rst)begin
      cnt <= {CNT_W{1'b0}};
    end else if(i_flush) begin
      cnt <= {CNT_W{1'b0}};
    end else if(i_start) begin
      cnt <= {CNT_W{1'b1}}; //  63.
    end else if(cntneq0) begin // cnt != 0
      cnt <= cnt - 1;
    end
  end

  
  always@(posedge i_clk or negedge i_rst)begin
    if(i_rst)begin
      o_end_valid <= 1'b0;
    end else if(i_flush)begin
      o_end_valid <= 1'b0;
    end else if(cnt == {{(CNT_W-1){1'b0}},1'b1}) begin  //1
      o_end_valid <= 1'b1;
    end else if(o_end_valid) begin
      o_end_valid <= 1'b0;
    end
  end

  // 2. deal input signals://///////////////////////////////////////////////////////////////////
  wire [WIDTH-1:0] i_dividend_wrapper =  i_dividend;
  wire [WIDTH-1:0] i_divisor_wrapper  =  i_divisor ;

  wire dividend_positive = i_signed ? ~i_dividend_wrapper[WIDTH-1] : 1;
  wire divisor_positive  = i_signed ? ~i_divisor_wrapper [WIDTH-1] : 1;

  wire [WIDTH-1:0] i_dividend_abs = dividend_positive ? i_dividend_wrapper : ~i_dividend_wrapper + 1'b1;  
  wire [WIDTH-1:0] i_divisor_abs  = divisor_positive  ? i_divisor_wrapper  : ~i_divisor_wrapper  + 1'b1;

  // 3. div:///////////////////////////////////////////////////////////////////////////////////
  logic [WIDTH-1  :0] divisor_r;
  logic [2*WIDTH-1:0] dividend , dividend_r , dividend_r_shift ;
  logic [WIDTH-1  :0] quotient , quotient_r ;

  always@(posedge i_clk or negedge i_rst)begin
    if(i_rst)begin
      dividend_r  <= {2*WIDTH{1'b0}};
      divisor_r   <= {  WIDTH{1'b0}};
      quotient_r  <= {  WIDTH{1'b0}};
    end else if(i_flush) begin
      dividend_r  <= {2*WIDTH{1'b0}};
      divisor_r   <= {  WIDTH{1'b0}};
      quotient_r  <= {  WIDTH{1'b0}};
    end else if(i_start) begin  //初始化
      dividend_r  <= {{WIDTH{1'b0}}, i_dividend_abs};
      divisor_r   <= i_divisor_abs;
      quotient_r  <= {WIDTH{1'b0}};
    end else if(cntneq0) begin
      dividend_r  <= dividend ;
      quotient_r  <= quotient ;
    end
  end

  logic [WIDTH-1:0] div_sub, mask;
  logic sub_positive, sub_negative;

  assign dividend_r_shift = {dividend_r >> cnt};
  assign {sub_negative,div_sub} = dividend_r_shift[WIDTH:0] - {1'b0,divisor_r};
  assign sub_positive = ~sub_negative;

  assign mask = ~({WIDTH{1'b1}} << cnt); // low bit mask.
  assign dividend = sub_negative ? dividend_r : {{WIDTH{1'b0}}, {(div_sub<<cnt) | (dividend_r[WIDTH-1:0] & mask)}};//补全没用到的位

  for(genvar i=0; i<WIDTH; i++)begin
    assign quotient[i]  = (i == cnt) ? sub_positive : quotient_r[i];
  end

  // 4. output: //cnt == 0输出结果
  assign o_quotient  = cntneq0 ? {WIDTH{1'b0}} : (~(dividend_positive^divisor_positive) ? quotient : ~quotient + 1'b1)  ;
  assign o_remainder = cntneq0 ? {WIDTH{1'b0}} : (dividend_positive ? dividend[WIDTH-1:0] : ~dividend[WIDTH-1:0] + 1'b1); 

endmodule