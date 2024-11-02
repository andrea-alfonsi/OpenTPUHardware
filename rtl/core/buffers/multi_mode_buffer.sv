// todo

module multi_mode_buffer #(
  parameter DATA_WIDTH = 8,
  parameter NUMBER_OF_BUFFERS = 1,
  parameter BUFFER_DEPTH = NUMBER_OF_BUFFERS
) (
  input  logic [DATA_WIDTH * NUMBER_OF_BUFFERS-1:0] input_data,
  input  logic [DATA_WIDTH * NUMBER_OF_BUFFERS-1:0] systolic_array_links_in,
  output logic [DATA_WIDTH * NUMBER_OF_BUFFERS-1:0] systolic_array_links_out,
  input  logic                                      mode
);
  
endmodule