`ifndef CORE_BUFFERS_SYNC_FIFO
`define CORE_BUFFERS_SYNC_FIFO

module sync_fifo #(
  parameter  DEPTH         = 16,
  parameter  WIDTH         = 8,
  localparam POINTER_WIDTH = $clog2( DEPTH )
) (
  input  logic             clk,
  input  logic             rst_n, 
  input  logic             write_enable,
  input  logic [WIDTH-1:0] write_data,
  input  logic             read_enable,
  output logic [WIDTH-1:0] read_data,
  output logic             full,
  output logic             empty  
);

  logic [WIDTH-1:0] memory[DEPTH];
  logic [POINTER_WIDTH:0] write_pointer, write_pointer_next, 
                          read_pointer,  read_pointer_next;
  always_comb begin
    write_pointer_next = write_pointer;
    read_pointer_next  = read_pointer;
    if ( write_enable ) begin
      write_pointer_next = write_pointer + 1;
    end
    if ( read_enable ) begin
      read_pointer_next = read_pointer + 1;
    end
  end

  always_ff @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
      write_pointer <= 0;
      read_pointer <= 0;
    end else begin
      write_pointer <= write_pointer_next;
      read_pointer <= read_pointer_next;
    end

    memory[write_pointer[POINTER_WIDTH-1:0]] <= write_data;
  end

  assign read_data = memory[read_pointer[POINTER_WIDTH-1:0]];
  assign empty = (write_pointer[POINTER_WIDTH] == read_pointer[POINTER_WIDTH]) && 
                 (write_pointer[POINTER_WIDTH-1:0] == read_pointer[POINTER_WIDTH-1:0]);
  assign full  = (write_pointer[POINTER_WIDTH] != read_pointer[POINTER_WIDTH]) && 
                 (write_pointer[POINTER_WIDTH-1:0] == read_pointer[POINTER_WIDTH-1:0]);

endmodule

`endif