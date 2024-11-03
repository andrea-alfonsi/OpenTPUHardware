`include "rtl/core/buffers/sync_fifo.sv"

module sync_fifo_tb;

  bit clk = 0;
  bit rst_n = 1;
  always #100 clk = ~clk;

  logic       write_enable;
  logic [7:0] write_data;
  logic       read_enable;
  logic [7:0] read_data;
  logic       full;
  logic       empty;
  sync_fifo fifo( .* );

  bit done = 0;
  initial begin
    #100 rst_n = 0;
    #100 rst_n = 1;

    assert ( empty ) 
    else   $display("Assertion failed, FIFO is not empty at begin");

    push_data(16);
    wait( done );

    read_enable <= 1;
    for (int i = 0; i < 16; i++) begin
      @(posedge clk);
      assert ( read_data == i) 
      else   $display("ERROR: Expected reading %d , got %d", i, read_data);
    end

    $finish;
  end

  task automatic push_data(int size);
    done <= 0;
    write_enable <= 1;
    for (int i = 0; i < size; i++ ) begin
      write_data <= i;
      @(posedge clk);
    end
    write_enable <= 0;
    done <= 1;
  endtask //automatic

endmodule
