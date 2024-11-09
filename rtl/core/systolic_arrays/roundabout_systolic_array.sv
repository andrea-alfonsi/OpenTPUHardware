`ifndef CORE_SYSTOLIC_ARRAY_ROUNDABOUT_SYSTOLIC_ARRAY
`define CORE_SYSTOLIC_ARRAY_ROUNDABOUT_SYSTOLIC_ARRAY

`include "rtl/core/processing_elements/redas_pe.sv"

module roundabout_systolic_array #(
  parameter DATA_WIDTH = 8,
  parameter PE_PER_SIDE = 6,
  parameter TOTAL_NUMBER_OF_PE = PE_PER_SIDE * PE_PER_SIDE  // Supports only square systolic arrays
) (
  input   logic                                clk,
  input   logic                                rst_n,
  input   logic [4 * PE_PER_SIDE-1:0]          data_movement_mode, 
  input   logic [5 * PE_PER_SIDE-1:0]          calculation_pattern_mode,
  input   logic [PE_PER_SIDE-1:0]              enable_right_angle_movement,
  input   logic                                store_stationary,
  input   logic [DATA_WIDTH * PE_PER_SIDE-1:0] multi_mode_buffer_left_in,
  input   logic [DATA_WIDTH * PE_PER_SIDE-1:0] multi_mode_buffer_top_in,
  input   logic [DATA_WIDTH * PE_PER_SIDE-1:0] multi_mode_buffer_right_in,
  input   logic [DATA_WIDTH * PE_PER_SIDE-1:0] multi_mode_buffer_bottom_in,
  output  logic [DATA_WIDTH * PE_PER_SIDE-1:0] multi_mode_buffer_left_out,
  output  logic [DATA_WIDTH * PE_PER_SIDE-1:0] multi_mode_buffer_top_out,
  output  logic [DATA_WIDTH * PE_PER_SIDE-1:0] multi_mode_buffer_right_out,
  output  logic [DATA_WIDTH * PE_PER_SIDE-1:0] multi_mode_buffer_bottom_out
);
                                          // row         cols
  wire [DATA_WIDTH-1:0] horizontal_wires [PE_PER_SIDE][PE_PER_SIDE+1][2]; // left right
  wire [DATA_WIDTH-1:0] vertical_wires   [PE_PER_SIDE+1][PE_PER_SIDE][2]; // top bottom

  generate
    for (genvar i = 0; i < PE_PER_SIDE; i++) begin
      assign horizontal_wires[0][0][0] = multi_mode_buffer_left_in;
      // TODO
      // I was working here
    end
  endgenerate

  generate
    for (genvar i = 0; i < PE_PER_SIDE; i++) begin
      if( PE_PER_SIDE % i == 0 ) begin
        // There may be roundabout join here
      end
    end
  endgenerate
  
  // Reshape the roundabout making 4 sub-arrays of shape m*n
  task automatic reshape(int unsigned m, int unsigned n);

    // Check there can be a unused square at the center
    assert ( m + n == PE_PER_SIDE )
    else   $display("Requested shape is not compatible with the systolic array size");

  endtask //automatic

endmodule


`endif