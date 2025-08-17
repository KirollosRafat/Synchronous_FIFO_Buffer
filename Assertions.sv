`timescale 1ns/1ps

interface sync_fifo_assertions #(
    parameter WIDTH = 8,
    parameter DEPTH = 8
)(
    input logic clk,
    input logic reset,
    input logic wr,
    input logic rd,
    input logic [WIDTH-1:0] Wdata,
    input logic full,
    input logic empty,
    input logic [WIDTH-1:0] Rdata
);

    // Local parameters
    localparam ADDR = $clog2(DEPTH);
    
    // Internal signals for tracking FIFO state
    logic [ADDR:0] expected_count;
    logic [WIDTH-1:0] expected_data_queue[$];
    
    
    // Reset makes FIFO empty
    property reset_makes_empty;
        @(posedge clk) reset |-> empty;
    endproperty
    assert_reset_empty: assert property (reset_makes_empty)
        else $error("RESET BEHAVIOR: FIFO should be empty after reset");
    
    // Reset makes FIFO not full
    property reset_makes_not_full;
        @(posedge clk) reset |-> !full;
    endproperty
    assert_reset_not_full: assert property (reset_makes_not_full)
        else $error("RESET BEHAVIOR: FIFO should not be full after reset");
    
    
    // No write when FIFO is full
    property no_write_when_full;
        @(posedge clk) disable iff (reset) 
        (full && wr) |-> ##1 (expected_count == $past(expected_count));
    endproperty
    assert_no_write_when_full: assert property (no_write_when_full)
        else $error("WRITE PROTECTION: Write should be ignored when FIFO is full");
    
    
    // No read when FIFO is empty - Rdata remains stable
    property no_read_when_empty;
        @(posedge clk) disable iff (reset) 
        (empty && rd && !wr) |=> ##1 (Rdata == $past(Rdata));
    endproperty
    assert_no_read_when_empty: assert property (no_read_when_empty)
        else $error("READ PROTECTION: Read should be ignored when FIFO is empty");
    
    // Read from single-entry FIFO sets empty flag
    property read_sets_empty;
        @(posedge clk) disable iff (reset) 
        ((expected_count == 1) && rd) |=> empty;
    endproperty
    assert_read_sets_empty: assert property (read_sets_empty)
        else $error("READ PROTECTION: Empty flag should be set when FIFO becomes empty");
    
    property write_clears_empty;
        @(posedge clk) disable iff (reset) 
        (empty && wr) |=> !empty;
    endproperty
    assert_write_clears_empty: assert property (write_clears_empty)
        else $error("STATUS FLAG: Empty flag should be cleared after write to empty FIFO");
    
    // Read from full FIFO clears full flag
    property read_clears_full;
        @(posedge clk) disable iff (reset) 
        (full && rd) |-> ##1 !full;
    endproperty
    assert_read_clears_full: assert property (read_clears_full)
        else $error("STATUS FLAG: Full flag should be cleared after read from full FIFO");
    
    
    // Empty flag should be set within one clock cycle of read that empties FIFO
    property read_response_timing;
        @(posedge clk) disable iff (reset)
        (rd && (expected_count == 1) && !wr && !empty) |=> empty;
    endproperty
    assert_read_timing: assert property (read_response_timing)
        else $error("TEMPORAL PROPERTIES: Empty flag should be set within one clock cycle");

    
    // Track expected count for assertion checking
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            expected_count <= 0;
        end else begin
            case ({wr && !full, rd && !empty})
                2'b10: expected_count <= expected_count + 1;  // Write only
                2'b01: expected_count <= expected_count - 1;  // Read only  
                2'b11: expected_count <= expected_count;      // Simultaneous ----> Not Applicable but for simulation reasons
                2'b00: expected_count <= expected_count;      // No operation
            endcase
        end
    end
    
    // Track expected data queue for data integrity checking
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            expected_data_queue.delete();
        end else begin
            // Push data on write
            if (wr && !full && !(rd && !empty))
                expected_data_queue.push_back(Wdata);
            // Pop data on read
            else if (rd && !empty && !(wr && !full))
                void'(expected_data_queue.pop_front());
            // Simultaneous read/write - pop then push
            else if (wr && !full && rd && !empty) begin
                void'(expected_data_queue.pop_front());
                expected_data_queue.push_back(Wdata);
            end
        end
    end

endinterface


/*
bind sync_fifo sync_fifo_assertions #(
    .WIDTH(WIDTH),
    .DEPTH(DEPTH)
) fifo_assert (
    .clk(clk),
    .reset(reset),
    .wr(wr),
    .rd(rd),
    .Wdata(Wdata),
    .full(full),
    .empty(empty),
    .Rdata(Rdata)
);
*/

