//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module add
(
  input  [3:0] a, b,
  output [3:0] sum
);

  assign sum = a + b;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

parameter POSITIVE_MAX = 4'b0111;
parameter NEGATIVE_MAX = 4'b1000;

module signed_add_with_saturation
(
  input [3:0] a, b,
  output [3:0] sum
);

  // Task:
  //
  // Implement a module that adds two signed numbers with saturation.
  //
  // "Adding with saturation" means:
  //
  // When the result does not fit into 4 bits,
  // and the arguments are positive,
  // the sum should be set to the maximum positive number.
  //
  // When the result does not fit into 4 bits,
  // and the arguments are negative,
  // the sum should be set to the minimum negative number.

  logic [3:0] tmp;
  assign tmp = a + b;

  logic [3:0] mask;
  assign mask = {a[3], b[3], tmp[3]};

  logic [3:0] out;

  always_comb begin
    case(mask)
      3'b110:   out = NEGATIVE_MAX; // negative overflow
      3'b001:   out = POSITIVE_MAX; // positive overflow
      default:  out = tmp;
    endcase
  end

  assign sum = out;

  
endmodule
