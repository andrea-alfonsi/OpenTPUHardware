`include "rtl/core/processing_elements/redas_pe.sv"

module redas_pe_tb;

  parameter DATA_WIDTH = 8;

  reg clk = 0;
  reg rst_n = 1;
  always #100 clk = ~clk;

  logic [DATA_WIDTH-1:0] input_data_from_bottom_pe, input_data_from_top_pe,
                        input_data_from_left_pe  , input_data_from_right_pe;

  // Configure the pe to store the input value and nothing else
  logic [3:0]            data_movement_mode;
  logic [4:0]            calculation_pattern_mode;
  logic                  enable_right_angle_movement;
  logic                  store_stationary;

  logic [DATA_WIDTH-1:0] output_data_to_bottom_pe, output_data_to_top_pe,
                        output_data_to_left_pe  , output_data_to_right_pe;

  redas_pe pe ( .* );

  bit test_done = 0;
  initial begin
    test_int8_multiplication();
    wait( test_done );
    $finish;
  end

  task automatic test_int8_multiplication;
    data_movement_mode <= 0;
    calculation_pattern_mode <= 0;
    enable_right_angle_movement <= 0;
    store_stationary <= 0;
    rst_n <= 1;
    @(posedge clk);

    rst_n <= 0;
    @(posedge clk);

    // Store 1 in the stationary register
    rst_n <= 1;
    input_data_from_right_pe <= 1;
    input_data_from_top_pe <= 0;
    store_stationary <= 1;
    @(posedge clk);
    
    store_stationary <= 0;
    @(posedge clk);

    for ( int n = -10; n < 10; n++ ) begin
      for (int m = -10; m < 10; m++) begin
        // Compute top * stationary + right and store result in bottom 
        input_data_from_right_pe <= m;
        input_data_from_top_pe <= n;
        @(posedge clk);
        @(posedge clk);    

        assert ($signed(output_data_to_bottom_pe) == n * 1 + m) 
        else $display("Calculation error. Exteced %d got %d. Computation was %d * %d + %d", n * 1 + m, output_data_to_bottom_pe, n, 1, m);
      end
    end

    @(posedge clk);
    test_done <= 1;
  endtask //automatic
  
endmodule