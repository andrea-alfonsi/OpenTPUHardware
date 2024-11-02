module instruction_decoder #(
  parameter OPCODE_WIDTH = 8,
  parameter FLAG_WIDTH = 8,
  parameter LENGTH_WIDTH = 8,
  parameter HOST_MEMORY_ADDRESS_WIDTH = 64,
  parameter LOCAL_MEMORY_ADDRESS_WIDTH = 24,
  parameter INSTRUCTION_WIDTH = OPCODE_WIDTH + FLAG_WIDTH + LENGTH_WIDTH + HOST_MEMORY_ADDRESS_WIDTH + LOCAL_MEMORY_ADDRESS_WIDTH
) (
  input logic                         clk,
  input logic                         rst_n,
  input logic [INSTRUCTION_WIDTH-1:0] instruction,
);
endmodule
