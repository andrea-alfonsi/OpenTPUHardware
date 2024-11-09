`ifndef CORE_PROCESSING_ELEMENTS_BASIC_PE
`define CORE_PROCESSING_ELEMENTS_BASIC_PE

typedef struct packed {
  logic [0:0] store_weight;  // 1 bit
} basic_pe_configuration;

/**
 * @brief This is the simplest processing element possible
 *
 *                       |
 *               previous_result
 *                       |
 *                   --------
 * --- data_input ---|  PE  | --- next_input ---
 *                   --------
 *                       |
 *                     result
 *                       |
 */
module basic_pe #(
  parameter DATA_WIDTH = 8
) (
  input  logic                  clk,
  input  logic                  rst_n,
  input  logic [DATA_WIDTH-1:0] data_input,
  input  logic [DATA_WIDTH-1:0] previous_result,
  input  logic                  store_weight,
  output logic [DATA_WIDTH-1:0] result,
  output logic [DATA_WIDTH-1:0] next_input
);

  reg [DATA_WIDTH-1:0] weight;

  always @(posedge clk, negedge rst_n) begin
    if ( !rst_n ) begin
      weight <= 0;
    end else begin
      if ( store_weight ) begin
        weight <= previous_result;
      end else begin
        next_input <= data_input;
        result <= $signed( data_input ) * $signed( weight ) + $signed( previous_result );
      end
    end
  end
  
endmodule

`endif