//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module sort_floats_using_fsm (
    input                          clk,
    input                          rst,

    input                          valid_in,
    input        [0:2][FLEN - 1:0] unsorted,

    output logic                   valid_out,
    output logic [0:2][FLEN - 1:0] sorted,
    output logic                   err,
    output                         busy,

    // f_less_or_equal interface
    output logic      [FLEN - 1:0] f_le_a,
    output logic      [FLEN - 1:0] f_le_b,
    input                          f_le_res,
    input                          f_le_err
);

    // Task:
    // Implement a module that accepts three Floating-Point numbers and outputs them in the increasing order using FSM.
    //
    // Requirements:
    // The solution must have latency equal to the three clock cycles.
    // The solution should use the inputs and outputs to the single "f_less_or_equal" module.
    // The solution should NOT create instances of any modules.
    //
    // Notes:
    // res0 must be less or equal to the res1
    // res1 must be less or equal to the res2
    //
    // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
    // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.



    // student note
    // please sync this task with readme.md task, beacause they are different


    enum logic [1:0]
    {
        IDLE      = 2'd0,
        WAIT_A    = 2'd1,
        WAIT_B    = 2'd2,
        WAIT_C    = 2'd3
    } state, new_state;

    // State transition logic
    always_comb
    begin
        new_state = state;

        case (state)
            IDLE:   if (valid_in)   new_state = WAIT_A;
            WAIT_A: if (f_le_err)   new_state = IDLE;
                    else            new_state = WAIT_B;
            WAIT_B: if (f_le_err)   new_state = IDLE;
                    else            new_state = WAIT_C;
            WAIT_C:                 new_state = IDLE;
        endcase
    end

    // State update
    always_ff @ (posedge clk)
        if (rst)
            state <= IDLE;
        else
            state <= new_state;

    // Output logic (depends only on the current state)
    assign busy = (state != IDLE);
    assign valid_out = (new_state == IDLE);

    // order position
    // order[0] is 0 leq 2
    // order[1] is 1 leq 2
    // order[2] is 0 leq 1
    enum logic [2:0]
    {
        st_a        = 3'b000, // 0 >  1 1 >  2 0 >  2: {2 < 1 < 0}
        st_b        = 3'b001, // 0 >  1 1 >  2 0 <= 2: {error}
        st_c        = 3'b010, // 0 >  1 1 <= 2 0 >  2: {1 < 2 < 0}
        st_d        = 3'b011, // 0 >  1 1 <= 2 0 <= 2: {1 < 0 < 2}
        st_e        = 3'b100, // 0 <= 1 1 >  2 0 >  2: {2 < 0 < 1}
        st_f        = 3'b101, // 0 <= 1 1 >  2 0 <= 2: {0 < 2 < 1}
        st_g        = 3'b110, // 0 <= 1 1 <= 2 0 >  2: {error}
        st_h        = 3'b111  // 0 <= 1 1 <= 2 0 <= 2: {0 < 1 < 2}
    } order;

    logic [2:0] error;
    logic [1:0] compare_error;

    always_ff @ (clk) 
        if (rst) begin
            order <= 0;
            error <= 0;
        end
        else if (state == WAIT_A) begin
            f_le_a      <= unsorted[0];
            f_le_b      <= unsorted[2];
        end
        else if (state == WAIT_B) begin
            f_le_a      <= unsorted[1];
            f_le_b      <= unsorted[2];
        end
        else if (state == WAIT_C) begin
            f_le_a      <= unsorted[0];
            f_le_b      <= unsorted[1];
        end

    always_comb begin
        compare_error = 2'b00;

        if (state == WAIT_A) begin
            order[0]    = f_le_res;
            error[0]    = f_le_err;
        end
        else if (state == WAIT_B) begin
            order[1]    = f_le_res;
            error[1]    = f_le_err;
        end
        else if (state == WAIT_C) begin
            order[2]    = f_le_res;
            error[2]    = f_le_err;

            case (order)
                st_a: sorted = { unsorted [2], unsorted [1], unsorted [0] };
                st_b: compare_error[0] = 1'b1; 
                st_c: sorted = { unsorted [1], unsorted [2], unsorted [0] };
                st_d: sorted = { unsorted [1], unsorted [0], unsorted [2] };
                st_e: sorted = { unsorted [2], unsorted [0], unsorted [1] };
                st_f: sorted = { unsorted [0], unsorted [2], unsorted [1] };
                st_g: compare_error[1] = 1'b1;
                st_h: sorted = { unsorted [0], unsorted [1], unsorted [2] };
            endcase
        end

        err = error[0] | error[1] | error[2] | compare_error[0] | compare_error[1];
    end
endmodule
