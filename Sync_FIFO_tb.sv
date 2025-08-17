
`timescale 1ns/1ps

module sync_fifo_tb;

// Parameters
parameter WIDTH = 4;
parameter DEPTH = 8;

// Input clock
logic clk;
bit wr,rd,reset;
bit [WIDTH-1:0] Wdata;

// Clock generation
bit run_clk = 1;

initial begin
  clk = 0;
  while (run_clk) #5 clk = ~clk;
end
// Output Ports
bit full,empty;
bit [WIDTH-1:0] Rdata;

// DUT 
sync_fifo #(WIDTH,DEPTH) DUT (.*);

class transaction;
// Create Random Variables
rand bit reset;
rand bit wr;
rand bit rd;
rand bit [WIDTH-1:0] Wdata;


constraint read_write {
	{wr,rd} != 2'b11; // Write and Read can not be high together
	wr dist {0:= 40, 1:= 60};
	rd dist {0:= 50, 1:= 50};
} 

constraint write_data {Wdata inside{0,2,5,8,10,11,13,15};} 

constraint reset_constraint {
  reset dist { 1 := 1, 0 := 99}; // Most of the reset is de-activated
}
endclass

// Coverage group
covergroup  FIFO_Coverage (ref bit reset, ref bit [WIDTH-1:0] Wdata,ref bit wr,rd) @(posedge clk);

coverpoint reset{bins values = {0,1};}

coverpoint Wdata{
	bins zero = {0};
	bins mid  = {[4'h2:4'hC]};
	bins high = {15};
}

coverpoint wr{bins wr_values = {0,1};}

coverpoint rd{bins rd_values = {0,1};}
endgroup

FIFO_Coverage cov = new(reset,Wdata,wr,rd);

initial
begin
automatic transaction tr = new();

repeat(20) begin
  assert(tr.randomize());

  // Apply random values to testbench/DUT signals
  reset = tr.reset;
  wr    = tr.wr;
  rd    = tr.rd;
  Wdata = tr.Wdata;

  @(posedge clk);
end

// Apply Directed testing
repeat(10) begin // Write more than FIFO can handle till it's full
    wr = 1;
    Wdata = $urandom() % (1 << WIDTH);
    @(posedge clk);
 
end
wr = 0;
#2;

repeat(10) begin // Read until FIFO is empty
    rd = 1;
    @(posedge clk);
    count_vals++;
    $display("Access Number %0d Output Data = %0d", count_vals, Rdata);
    if (empty)
        $display("FIFO is empty");
end
rd = 0;

run_clk = 0;
$stop;
end
endmodule



