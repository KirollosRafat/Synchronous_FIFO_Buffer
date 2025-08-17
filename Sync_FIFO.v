
module sync_fifo#(
parameter WIDTH = 8,
parameter DEPTH = 8
)
(
input clk, 
input reset,
input wr,rd, // Write and Read Enables
input [WIDTH-1:0] Wdata, // Data written into the FIFO

output full, empty, // Status Flags
output reg [WIDTH-1:0] Rdata // Data read from the FIFO
);

localparam ADDR = $clog2(DEPTH);

// FIFO memory as 2D array
reg [WIDTH-1:0] FIFO_MEM [0:DEPTH-1];

// Write and Read pointers for accessing FIFO
reg [ADDR-1:0] wr_ptr,rd_ptr;

// Counter for counting reads and written (needed to drive the status flags)
reg [ADDR:0] counter;

always@(posedge clk,posedge reset)
begin
	if(reset)
	begin
	wr_ptr  <=  {ADDR{1'b0}};
	rd_ptr  <=  {ADDR{1'b0}};
	counter <=  {(ADDR+1){1'b0}};
	Rdata   <=  {WIDTH{1'b0}};
	end
	else begin
		if(wr && !full) begin
			FIFO_MEM[wr_ptr] <= Wdata; // Write data into the FIFO buffer
			wr_ptr <= wr_ptr + 1'b1; // Increment the pointer to pint for a new address
			counter <= counter + 1'b1; // Increment the counter indicates a write 
		end
		
		if(rd && !empty) begin
			Rdata <= FIFO_MEM[rd_ptr]; // Read data from the FIFO buffer
			rd_ptr <= rd_ptr + 1'b1; // Increment the pointer to pint for a new address
			counter <= counter - 1'b1; // Decrement the counter indicates a read
		end
	end
end

// Status Flags
assign full  = (counter == DEPTH);
assign empty = (counter == 0);

endmodule

