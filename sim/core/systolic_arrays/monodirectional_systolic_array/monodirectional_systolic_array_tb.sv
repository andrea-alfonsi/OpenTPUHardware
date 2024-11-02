`include "rtl/core/systolic_arrays/monodirectional_systolic_array.sv"

module monodirectional_systolic_array_tb;
    parameter DATA_WIDTH = 8;
    parameter COLUMNS = 2;
    parameter ROWS = 2;

    bit clk = 0;
    always #100 clk = ~clk;
    bit rst_n = 1;

    reg [DATA_WIDTH * ROWS-1:0] data;
    reg [DATA_WIDTH * COLUMNS-1:0] weight;
    reg [DATA_WIDTH * COLUMNS-1:0] result;
    reg store_weight;

    monodirectional_systolic_array #( .DATA_WIDTH(DATA_WIDTH), .COLUMNS(COLUMNS), .ROWS(ROWS)) sa ( .* );

    bit test_done = 0;
    initial begin
      test_int8_2x2_matrix();
      wait( test_done );
      $finish;
    end

    task automatic test_int8_2x2_matrix;
      test_done <= 1;
    endtask //automatic
  
endmodule