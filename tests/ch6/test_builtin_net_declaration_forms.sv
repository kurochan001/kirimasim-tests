/*
:name: test_builtin_net_declaration_forms
:description: built-in net declarations with a drive strength or a charge strength, scalared or vectored, an implicit or explicit data type, a delay, a list of net declaration assignments and an unpacked dimension, observed through values, strengths and change times (IEEE 1800-2023 Sections 6.7.1, A.2.1.3, A.2.3, A.2.4)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.7.1 6.9.2 10.3.1 10.3.3 10.3.4 6.6.4 A.2.1.3 A.2.3 A.2.4 21.2.1.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_builtin_net_declaration_forms.expected
*/
// IEEE 1800-2023 A.2.1.3: a net declaration with a built-in net type is the
// net type, an optional drive strength or charge strength, an optional
// vectored or scalared, a data type or an implicit type, an optional delay3
// and a list of net declaration assignments (A.2.3: one or more, separated by
// commas); A.2.4: each is a name, optional unpacked dimensions and an optional
// = expression. A.10 note 16: a charge strength goes only with trireg, and
// vectored or scalared needs a packed dimension.
// - w_and and w_or are declared together with the drive strength (pull0,
//   weak1), scalared, the implicit type [3:0] and the delays #(2, 4, 6);
//   each has a continuous assignment (§10.3.1). §10.3.3: for a vector, a
//   change from nonzero to zero takes the fall delay 4, a change to z the
//   turn-off delay 6, any other change the rise delay 2. §10.3.4: a 1 bit
//   then has weak strength and a 0 bit pull strength, shown by %v
//   (§21.2.1.4) on bit-selects, which scalared permits (§6.9.2).
// - w_cat is tri vectored logic [7:0] with the single delay #7; it is only
//   read as a whole, since vectored may forbid selects (§6.9.2).
// - t_hold is trireg (small) scalared [1:0]: bit 0 is driven by a bufif1
//   until en goes to 0 at time 30 and then keeps its 1 with small strength,
//   bit 1 is never driven and stays at x with small strength (§6.6.4,
//   §6.7.1).
// - w_pair has the unpacked dimension [2] and no assignment in the
//   declaration; continuous assignments drive its elements.
// Inputs change at 10, 20 and 30; values are printed at times where nothing
// changes. Neither release takes the test: Icarus Verilog 13.0 has no trireg
// nets and no drive strength or delay after it on a vector net declaration,
// and the other release has no trireg nets and no delay after an explicit data
// type in a net declaration.

`timescale 1ns/1ns

module test_builtin_net_declaration_forms;
  logic [3:0] a = 4'h3, b = 4'h5;
  logic en = 1'b1;

  wire (pull0, weak1) scalared [3:0] #(2, 4, 6) w_and = a & b, w_or = en ? (a | b) : 4'bz;
  tri vectored logic [7:0] #7 w_cat = {a, b};
  trireg (small) scalared [1:0] t_hold;
  wire [3:0] w_pair [2];

  bufif1 (t_hold[0], 1'b1, en);
  assign w_pair[0] = a;
  assign w_pair[1] = b;

  initial begin
    #10 a = 4'h0;
    #1 $display("t=%0t w_and=%b w_or=%b w_cat=%h", $time, w_and, w_or, w_cat);
    #2 $display("t=%0t w_and=%b w_or=%b", $time, w_and, w_or);
    #2 $display("t=%0t w_and=%b w_or=%b w_cat=%h", $time, w_and, w_or, w_cat);
    #5 a = 4'hf;
    #3 $display("t=%0t w_and=%b w_or=%b w_cat=%h w_pair=%h,%h", $time, w_and, w_or, w_cat,
                w_pair[0], w_pair[1]);
    $display("t=%0t w_and[0]=%v w_and[1]=%v t_hold[0]=%v", $time, w_and[0], w_and[1],
             t_hold[0]);
    #7 en = 1'b0;
    #3 $display("t=%0t w_or=%b w_cat=%h t_hold[0]=%v t_hold[1]=%v", $time, w_or, w_cat,
                t_hold[0], t_hold[1]);
    #4 $display("t=%0t w_or=%b", $time, w_or);
  end
endmodule
