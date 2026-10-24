/*
:name: test_packed_union_whole_vector_sign_select
:description: a packed union used as a primary is one vector whose arithmetic follows its signedness (unsigned by default), and its bits can be selected as a [n-1:0] vector (IEEE 1800-2023 Section 7.3.1)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.3.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_packed_union_whole_vector_sign_select.expected
*/
// IEEE 1800-2023 §7.3.1: a packed union that appears as a primary is treated
// as a single vector; used as a whole with arithmetic and logical operators it
// behaves according to its signedness, which is unsigned unless the union is
// declared signed. Its bits can be selected as if it were a packed array with
// the range [n-1:0], n being its number of bits.
// u_t (no signing) and su_t (signed) hold the same 8 bits f6. Widened to int,
// compared with 0, shifted with >>> and added to a signed constant, the
// unsigned one acts as 246 and the signed one as -10. Bit-selects and
// part-selects of u read and write the bits [7:0] of the whole union, the
// same bits that the members b and n hold.

module test_packed_union_whole_vector_sign_select;
  typedef union packed {
    logic [7:0] b;
    logic [1:0][3:0] n;
  } u_t;
  typedef union packed signed {
    logic [7:0] b;
    logic [1:0][3:0] n;
  } su_t;

  u_t u;
  su_t s;
  int i, j;
  int sel;

  initial begin
    u.b = 8'hf6;
    s.b = 8'hf6;
    i = u;
    j = s;
    $display("widened: u=%0d s=%0d", i, j);
    $display("less than 0: u=%0d s=%0d", u < 0, s < 0);
    $display("shift >>> 4: u=%h s=%h", u >>> 4, s >>> 4);
    i = u + 8'sd10;
    j = s + 8'sd10;
    $display("plus 8'sd10 into int: u=%0d s=%0d", i, j);
    $display("8-bit u + 10 = %h, ~u = %h, !u = %0d, {u, 4'h3} = %h",
             u + 8'd10, ~u, !u, {u, 4'h3});
    $display("u[7]=%b u[0]=%b u[7:4]=%h u[3:0]=%h n[1]=%h n[0]=%h",
             u[7], u[0], u[7:4], u[3:0], u.n[1], u.n[0]);
    u[3:0] = 4'h1;
    sel = 6;
    u[sel] = 1'b0;
    $display("after writes: b=%h n[1]=%h n[0]=%h u[sel]=%b", u.b, u.n[1], u.n[0], u[sel]);
  end
endmodule
