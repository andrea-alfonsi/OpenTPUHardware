`include "rtl/core/processing_elements/basic_pe.sv"

module basic_pe_tb;
  parameter DATA_WIDTH = 8;
  
  bit clk = 0;
  always #100 clk = ~clk;
  bit rst_n = 1;

  reg store_weight = 0;
  reg [DATA_WIDTH-1:0] data_input;
  reg [DATA_WIDTH-1:0] previous_result;
  reg [DATA_WIDTH-1:0] result;
  reg [DATA_WIDTH-1:0] next_input;

  basic_pe pe ( .* );

  bit test_done  = 0;
  initial begin
    test_int8_multiplication();
    wait( test_done );
    $finish;
  end

  task automatic test_int8_multiplication;
    rst_n <= 0;
    @(posedge clk);

    rst_n <= 1;
    previous_result <= 1;
    store_weight <= 1;
    @(posedge clk);

    store_weight <= 0;
    @(posedge clk);

    for( int n = -10; n < 10; n++) begin
      for( int m = -10; m < 10; m++) begin
        previous_result <= m;
        data_input <= n;
        @(posedge clk);
        @(posedge clk);

        assert ($signed(result) == n * 1 + m) 
        else   $display("Calculation error. Expected %d got %d performing %d * %d  + %d", n * 1 + m, result, n, 1, m);
      end
    end
    test_done <= 1;
  endtask //automatic
endmodule