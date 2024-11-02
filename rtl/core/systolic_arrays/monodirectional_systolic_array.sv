`include "rtl/core/processing_elements/basic_pe.sv"

module monodirectional_systolic_array #(
  parameter DATA_WIDTH = 8,
  parameter COLUMNS  = 8,
  parameter ROWS = COLUMNS
) (
  input  logic                            clk,
  input  logic                            rst_n,
  input  logic [DATA_WIDTH * ROWS-1:0]    data,
  input  logic [DATA_WIDTH * COLUMNS-1:0] weight,
  input  logic                            store_weight,
  output logic [DATA_WIDTH * COLUMNS-1:0] result
);

  wire [DATA_WIDTH-1:0] data_wires        [ROWS][COLUMNS + 1];
  wire [DATA_WIDTH-1:0] computation_wires [ROWS + 1][COLUMNS];
  wire [0:0]            pe_store_weight   [ROWS][COLUMNS];

  generate
    for (genvar col = 0; col < COLUMNS; col++) begin
      for (genvar row = 0; row < ROWS; row++) begin
        assign pe_store_weight[row][col] = store_weight;
      end      
    end
  endgenerate

  generate
    for (genvar col = 0; col < COLUMNS ; col++) begin
      assign computation_wires[0][col] = weight[col * DATA_WIDTH +: DATA_WIDTH];
      assign result[col * DATA_WIDTH +: DATA_WIDTH] = computation_wires[ROWS][col];
    end
  endgenerate

  generate
    for (genvar row = 0; row < ROWS; row++) begin
      assign data_wires[row][0] = data[row * DATA_WIDTH +: DATA_WIDTH];
    end
  endgenerate

  generate
    for (genvar col = 0; col < COLUMNS; col++) begin
      for (genvar row = 0; row < ROWS; row++) begin
        basic_pe #( .DATA_WIDTH( DATA_WIDTH ) ) pe ( .*, 
                              .data_input( data_wires[row][col] ),
                              .previous_result( computation_wires[row][col] ),
                              .result( computation_wires[row + 1][col] ),
                              .next_input( data_wires[row][col + 1] ),
                              .store_weight( pe_store_weight[row][col] ) );
      end
    end
  endgenerate
  
endmodule