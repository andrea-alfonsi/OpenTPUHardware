`ifndef CORE_PROCESSING_ELEMENTS_REDAS_PE
`define CORE_PROCESSING_ELEMENTS_REDAS_PE


// If editing this file edit also `redas_pe_config/redas_pe_simulation.sv` so they are always synced.
`include "macros/annotations.svh"

typedef enum {
  WEIGHT = 0,
  OUTPUT = 1,
  INPUT  = 2
} redas_pe_roundabout_e;

typedef enum {
  FIRST  = 0,
  SECOND = 1,
  THIRD  = 2,
  FOURTH = 3
} redas_pe_subarray_e;

typedef enum {
  ORTHOGONAL = 0, // Data in next pe flows different from current one
  PARALLEL   = 1, // Data in next pe flows the same as the current one
  DIAGONAL   = 2  // The pe rotates the data 45 degrees angle
} redas_pr_role_e;

/**
 * @brief This is the implementation of the processing element proposedin the paper ReDAS available at https://arxiv.org/abs/2302.07520
 *        This pe must be used in combination with a roundabout systolic array or derived
 */
module redas_pe #(
    parameter DATA_WIDTH = 8
) (
  input  logic                  clk,
  input  logic                  rst_n,
  input  logic [DATA_WIDTH-1:0] input_data_from_bottom_pe,
  input  logic [DATA_WIDTH-1:0] input_data_from_top_pe,
  input  logic [DATA_WIDTH-1:0] input_data_from_left_pe,
  input  logic [DATA_WIDTH-1:0] input_data_from_right_pe,
  input  logic [3:0]            data_movement_mode, 
  input  logic [4:0]            calculation_pattern_mode,
  input  logic                  enable_right_angle_movement,
  input  logic                  store_stationary,
  output logic [DATA_WIDTH-1:0] output_data_to_bottom_pe,
  output logic [DATA_WIDTH-1:0] output_data_to_top_pe,
  output logic [DATA_WIDTH-1:0] output_data_to_left_pe,
  output logic [DATA_WIDTH-1:0] output_data_to_right_pe
);
  reg [DATA_WIDTH-1:0] stationary;
  wire [3:0] data_movement_modes;
  wire [4:0] calculation_pattern_modes;

  assign data_movement_modes = data_movement_mode;
  assign calculation_pattern_modes = calculation_pattern_mode;
  
  wire [DATA_WIDTH-1:0] left_input_a;
  wire [DATA_WIDTH-1:0] left_input_b;
  
  redas_pe_crossbar crossbar_left (
    .input_a(input_data_from_left_pe),
    .input_b( input_data_from_right_pe),
    .mode( data_movement_modes[0] ),
    .output_a( left_input_a ),
    .output_b( left_input_b )
  );
  
  wire [DATA_WIDTH-1:0] top_input_a;
  wire [DATA_WIDTH-1:0] top_input_b;
  redas_pe_crossbar crossbar_top ( 
    .input_a(input_data_from_bottom_pe),
    .input_b( input_data_from_top_pe),
    .mode( data_movement_modes[1] ),
    .output_a( top_input_a ),
    .output_b( top_input_b )
  );
  
  reg [DATA_WIDTH-1:0] right_output_a;
  reg [DATA_WIDTH-1:0] right_output_b;
  redas_pe_crossbar crossbar_right (
    .input_a(right_output_a),
    .input_b( right_output_b),
    .mode( data_movement_modes[2] ),
    .output_a( output_data_to_right_pe ),
    .output_b( output_data_to_left_pe )
  );
  
  reg [DATA_WIDTH-1:0] bottom_output_a;
  reg [DATA_WIDTH-1:0] bottom_output_b;
  redas_pe_crossbar crossbar_bottom ( 
    .input_a(bottom_output_a),
    .input_b(bottom_output_b),
    .mode( data_movement_modes[3] ),
    .output_a( output_data_to_top_pe ),
    .output_b( output_data_to_bottom_pe )
  );
  
  wire [DATA_WIDTH-1:0] inner_1_a;
  wire [DATA_WIDTH-1:0] inner_1_b;
  redas_pe_crossbar inner_1 (
    .input_a(left_input_a),
    .input_b(top_input_a),
    .mode( calculation_pattern_modes[0] ),
    .output_a(inner_1_a),
    .output_b(inner_1_b)
  );
  
  wire [DATA_WIDTH-1:0] inner_2_a;
  wire [DATA_WIDTH-1:0] inner_2_b;
  redas_pe_crossbar inner_2 (
    .input_a(inner_1_b),
    .input_b(stationary),
    .mode( calculation_pattern_modes[1] ),
    .output_a(inner_2_a),
    .output_b(inner_2_b)
  );
  
  wire [DATA_WIDTH-1:0] mac;
  assign mac = $signed(inner_1_a) * $signed(inner_2_a) + $signed(inner_2_b);
  
  always @(posedge clk, negedge rst_n) begin 
    if ( !rst_n ) begin 
      stationary <= 0 ;
    end else if ( store_stationary ) begin 
      stationary <= mac;
    end
  end
  
  wire [DATA_WIDTH-1:0] inner_3_a;
  wire [DATA_WIDTH-1:0] inner_3_b;
  redas_pe_crossbar inner_3 (
    .input_a(inner_1_a),
    .input_b(mac),
    .mode( calculation_pattern_modes[2] ),
    .output_a(inner_3_a),
    .output_b(inner_3_b)
  );
  
  redas_pe_crossbar right_movement (
    .input_a(left_input_b),
    .input_b(top_input_b),
    .mode( enable_right_angle_movement ),
    .output_a(bottom_output_b),
    .output_b(right_output_b)
  );
  
  always @(posedge clk) begin
    bottom_output_a <= calculation_pattern_modes[3] ? top_input_a : inner_3_a;
    right_output_a <= calculation_pattern_modes[4] ? left_input_a : inner_3_b;
  end
endmodule

module redas_pe_crossbar # ( parameter DATA_WIDTH = 8 )(
  input logic [DATA_WIDTH-1:0] input_a,
  input logic [DATA_WIDTH-1:0] input_b,
  input logic mode,
  output logic [DATA_WIDTH-1:0] output_a,
  output logic [DATA_WIDTH-1:0] output_b
);
  
  assign output_a = mode ? input_a : input_b;
  assign output_b = mode ? input_b : input_a;
  
endmodule 

`endif