//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module float_discriminant (
    input                     clk,
    input                     rst,

    input                     arg_vld,
    input        [FLEN - 1:0] a,
    input        [FLEN - 1:0] b,
    input        [FLEN - 1:0] c,

    output logic              res_vld,
    output logic [FLEN - 1:0] res,
    output logic              res_negative,
    output logic              err,

    output logic              busy
);

    // Task:
    // Implement a module that accepts three Floating-Point numbers and outputs their discriminant.
    // The resulting value res should be calculated as a discriminant of the quadratic polynomial.
    // That is, res = b^2 - 4ac == b*b - 4*a*c
    //
    // Note:
    // If any argument is not a valid number, that is NaN or Inf, the "err" flag should be set.
    //
    // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
    // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.

    localparam [FLEN - 1:0] four = 64'h4010_0000_0000_0000;

    logic [FLEN - 1:0] mul_a;
    logic [FLEN - 1:0] mul_b;
    logic mul_up_valid;
    logic [FLEN - 1:0] mul_res;
    logic mul_down_valid;
    logic mul_busy;
    logic mul_err;

    f_mult mul(
        .clk (clk),
        .rst (rst),
        .a (mul_a),
        .b (mul_b),
        .up_valid (mul_up_valid),
        .res (mul_res),
        .down_valid (mul_down_valid),
        .busy (mul_busy),
        .error (mul_err)
    );

    logic [FLEN - 1:0] sub_a;
    logic [FLEN - 1:0] sub_b;
    logic sub_up_valid;
    logic [FLEN - 1:0] sub_res;
    logic sub_down_valid;
    logic sub_busy;
    logic sub_err;

    f_sub sub(
        .clk (clk),
        .rst (rst),
        .a (sub_a),
        .b (sub_b),
        .up_valid (sub_up_valid),
        .res (sub_res),
        .down_valid (sub_down_valid),
        .busy (sub_busy),
        .error (sub_err)
    );

    enum logic [1:0]
    {
        IDLE        = 2'd0,
        WAIT_FIRST  = 2'd1,
        WAIT_SECOND = 2'd2,
        WAIT_THIRD  = 2'd3
    } state, new_state;

    // State transition logic
    always_comb
    begin
        new_state = state;

        case (state)
            IDLE:           if (arg_vld)            new_state = WAIT_FIRST;
            WAIT_FIRST:     if (mul_down_valid)     new_state = WAIT_SECOND;
                            else if (mul_err)       new_state = IDLE;
            WAIT_SECOND:    if (mul_down_valid)     new_state = WAIT_THIRD;
                            else if (mul_err)       new_state = IDLE;
            WAIT_THIRD:     if (sub_down_valid)     new_state = IDLE;
                            else if (sub_err)       new_state = IDLE;
        endcase
    end

    // State update
    always_ff @ (posedge clk)
        if (rst)
            state <= IDLE;
        else
            state <= new_state;

    logic [2:0] error;
    logic [FLEN - 1:0] rhs;
    logic [FLEN - 1:0] lhs;

    always_comb
    begin
        mul_up_valid = 0;
        sub_up_valid = 0;

        case (state)
        IDLE: begin
            mul_up_valid = arg_vld;
            mul_a = b;
            mul_b = b;
        end
        WAIT_FIRST: begin
            mul_up_valid = mul_down_valid;
            mul_a = a;
            mul_b = c;
        end
        WAIT_SECOND: begin
            mul_up_valid = mul_down_valid;
            mul_a = rhs;
            mul_b = four;
        end
        WAIT_THIRD: begin
            sub_up_valid = mul_down_valid;
            sub_a = lhs;
            sub_b = rhs;
        end
        endcase

        err = error[0] | error[1] | error[2] | sub_err;
        res_vld = (new_state == IDLE && sub_down_valid);

        busy = state != IDLE;

        res = sub_res;
    end
 
    always_ff @ (clk)
        if (state == IDLE) begin
            rhs     <= 0;
            lhs     <= 0;
            error   <= 0;
            res_vld <= 0;
        end
        else if (state == WAIT_FIRST & mul_down_valid) begin            
            lhs <= mul_res;
            error[0] <= mul_err;
        end
        else if (state == WAIT_SECOND & mul_down_valid) begin
            rhs <= mul_res;
            error[1] <= mul_err;
        end
        else if (state == WAIT_THIRD & mul_down_valid) begin
            rhs <= mul_res;
            error[2] <= mul_err;
        end

endmodule
