//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module detect_4_bit_sequence_using_fsm
(
  input  clk,
  input  rst,
  input  a,
  output detected
);

  // Detection of the "1010" sequence

  // States (F — First, S — Second)
  enum logic[2:0]
  {
     IDLE = 3'b000,
     F1   = 3'b001,
     F0   = 3'b010,
     S1   = 3'b011,
     S0   = 3'b100
  }
  state, new_state;

  // State transition logic
  always_comb
  begin
    new_state = state;

    // This lint warning is bogus because we assign the default value above
    // verilator lint_off CASEINCOMPLETE

    case (state)
      IDLE: if (  a) new_state = F1; // 0000 -> 0001
      F1:   if (~ a) new_state = F0; // 0001 -> 0010
      F0:   if (  a) new_state = S1; // 0010 -> 0101
            else     new_state = IDLE; // 0010 -> 0100 -> IDLE
      S1:   if (~ a) new_state = S0;
            else     new_state = F1;
      S0:   if (  a) new_state = S1;
            else     new_state = IDLE;
    endcase

    // verilator lint_on CASEINCOMPLETE

  end

  // Output logic (depends only on the current state)
  assign detected = (state == S0);

  // State update
  always_ff @ (posedge clk)
    if (rst)
      state <= IDLE;
    else
      state <= new_state;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module detect_6_bit_sequence_using_fsm
(
  input  clk,
  input  rst,
  input  a,
  output detected
);

  // Task:
  // Implement a module that detects the "110011" input sequence
  //
  // Hint: See Lecture 3 for details




  // Studend note:
  // The task is "Implement a module that detects the "110011" input sequence"
  // And there do not specified will current sequence be part of new sequence or not
  // I decided that it should be, beccause thats it's how example implemented
  // but in my opinion task description have to be more detailed, because othe implementation is accetable





  enum logic[2:0]
  {
     IDLE       = 3'd1,
     S_xxxxx1   = 3'd2,
     S_xxxx11   = 3'd3,
     S_xxx110   = 3'd4,
     S_xx1100   = 3'd5,
     S_x11001   = 3'd6,
     S_110011   = 3'd7
  }
  state, new_state;

  // State transition logic
  always_comb
  begin
    new_state = state;

    // This lint warning is bogus because we assign the default value above
    // verilator lint_off CASEINCOMPLETE

    case (state)
      IDLE:       if (  a) new_state = S_xxxxx1;
      S_xxxxx1:   if (  a) new_state = S_xxxx11;
                  else     new_state = IDLE;
      S_xxxx11:   if ( ~a) new_state = S_xxx110; 
      S_xxx110:   if ( ~a) new_state = S_xx1100;
                  else     new_state = S_xxxxx1;   
      S_xx1100:   if (  a) new_state = S_x11001;
                  else     new_state = IDLE;  
      S_x11001:   if (  a) new_state = S_110011;
                  else     new_state = IDLE; 
      S_110011:   if (  a) new_state = S_xxxx11; 
                  else new_state = S_xxx110; 
    endcase

    // verilator lint_on CASEINCOMPLETE

  end

  // Output logic (depends only on the current state)
  assign detected = (state == S_110011);

  // State update
  always_ff @ (posedge clk)
    if (rst)
      state <= IDLE;
    else
      state <= new_state;


endmodule
