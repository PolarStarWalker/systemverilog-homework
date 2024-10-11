//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module mux
(
  input  d0, d1,
  input  sel,
  output y
);

  assign y = sel ? d1 : d0;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module xor_gate_using_mux
(
    input  a,
    input  b,
    output o
);

  // Task:
  // Implement xor gate using instance(s) of mux,
  // constants 0 and 1, and wire connections

  wire not_a;

  mux not_a_mux(
    .d0 (1),
    .d1 (0),
    .sel (a),
    .y (not_a)
  );

  mux mux0(
    .d0 (a),
    .d1 (not_a),
    .sel (b),
    .y (o)
  );

endmodule
