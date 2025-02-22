//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module halve_tokens
(
    input  clk,
    input  rst,
    input  a,
    output b
);
    // Task:
    // Implement a serial module that reduces amount of incoming '1' tokens by half.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // a -> 110_011_101_000_1111
    // b -> 010_001_001_000_0101

    logic cnt;

    assign b = a & (~cnt);

    always_ff @ (posedge clk) begin
        if (rst)
            cnt <= 1'b0;
        else if (a)
            cnt <= ~cnt;
    end


endmodule
