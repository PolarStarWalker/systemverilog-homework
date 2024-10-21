//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module round_robin_arbiter_with_2_requests
(
    input        clk,
    input        rst,
    input  [1:0] requests,
    output [1:0] grants
);
    // Task:
    // Implement a "arbiter" module that accepts up to two requests
    // and grants one of them to operate in a round-robin manner.
    //
    // The module should maintain an internal register
    // to keep track of which requester is next in line for a grant.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // requests -> 01 00 10 11 11 00 11 00 11 11
    // grants   -> 01 00 10 01 10 00 01 00 10 01

    // 0 for 01
    // 1 for 10
    logic prev_req;

    logic [1:0] out;

    always_comb begin
        case (requests)
            2'b00 : out = 2'b00; 
            2'b01 : out = 2'b01; 
            2'b10 : out = 2'b10; 
            2'b11 : if (prev_req) out = 2'b01;
                    else out = 2'b10; 
        endcase
    end

    always_ff @ (posedge clk) begin
        if (rst)
            prev_req <= 0;
        else if (requests == 'b11)
            prev_req <= prev_req;
        else if (requests)
            prev_req <= requests[1];       
    end

    assign grants = out; 


endmodule
