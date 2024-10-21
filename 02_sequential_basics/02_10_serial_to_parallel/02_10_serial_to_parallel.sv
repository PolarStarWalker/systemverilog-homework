//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module serial_to_parallel
# (
    parameter width = 8
)
(
    input                      clk,
    input                      rst,

    input                      serial_valid,
    input                      serial_data,

    output logic               parallel_valid,
    output logic [width - 1:0] parallel_data
);
    // Task:
    // Implement a module that converts serial data to the parallel multibit value.
    //
    // The module should accept one-bit values with valid interface in a serial manner.
    // After accumulating 'width' bits, the module should assert the parallel_valid
    // output and set the data.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.

    logic[width - 1:0] buffer;
    logic[$clog2(width) - 1:0] cnt;

    always_ff @ (posedge clk) begin
        if (rst) begin
            cnt <= 0;
            parallel_data <= 0;
        end 
        else if (serial_valid) begin
            cnt <= cnt + 1;
            parallel_data <= {serial_data, parallel_data[width - 1 : 1]};
        end

        parallel_valid <= (cnt == 'b111) & serial_valid;
    end

endmodule
