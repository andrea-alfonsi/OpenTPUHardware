/**
 * @brief This is the implementation of the processing element proposed in the paper ReDAS available at https://arxiv.org/abs/2302.07520
 *        This pe must be used in combination with a roundabout systolic array or derived.
  *       Compared with reas_pe.sv whis one has the stationary reistry value passed input which may result easier to debug and test
 */
module redas_pe #(
    parameter DATA_WIDTH = 8
) (
  input  logic                  clk,
  input  logic [DATA_WIDTH-1:0] input_data_from_bottom_pe,
  input  logic [DATA_WIDTH-1:0] input_data_from_top_pe,
  input  logic [DATA_WIDTH-1:0] input_data_from_left_pe,
  input  logic [DATA_WIDTH-1:0] input_data_from_right_pe,
  input  logic [3:0]            data_movement_mode, 
  input  logic [4:0]            calculation_pattern_mode,
  input  logic                  enable_right_angle_movement,
  input  logic [DATA_WIDTH-1:0] stationary,
  output logic [DATA_WIDTH-1:0] output_data_to_bottom_pe,
  output logic [DATA_WIDTH-1:0] output_data_to_top_pe,
  output logic [DATA_WIDTH-1:0] output_data_to_left_pe,
  output logic [DATA_WIDTH-1:0] output_data_to_right_pe
);
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

module top;
  initial begin
    $display("123456");
    $display("123457");
    $display("123456");
  end
endmodule