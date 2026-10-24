/*
:name: test_cast_size_sign_keep_state_domain
:description: a size cast and a signing cast give a [n-1:0] vector of bit for a 2-state operand and of logic for a 4-state operand, so x and z survive only the 4-state casts (IEEE 1800-2023 Section 6.24.1)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.1 20.6.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_cast_size_sign_keep_state_domain.expected
*/
// IEEE 1800-2023 §6.24.1: a size cast n'(e) gives the value of a packed
// [n-1:0] array assigned e, keeping the signedness of e; a signing cast
// gives a [$bits(e)-1:0] array with the signedness of the cast. In both, the
// elements are bit when e is 2-state and logic when e is 4-state. The test
// compares $typename of each cast (§20.6.1) with that of the expected type,
// which avoids depending on the spelling of the name, and prints the values:
// the 4-state casts keep their x and z bits, a signed 4-bit result is
// sign-extended when it is printed or assigned in 8 bits, and an unsigned
// one is zero-extended.
// Icarus Verilog 13.0 has no $typename with a data type argument
// ("Type names are not valid expressions here"). As a 2-state
// simulator, Verilator 5.052 loses the x and z bits, and its $typename
// gives the signing casts signed'(b) and unsigned'(bs) of 2-state operands
// the type logic[3:0] instead of a vector of bit.

module test_cast_size_sign_keep_state_domain;
  bit [3:0] b = 4'b1010;
  bit signed [3:0] bs = 4'b1101;
  logic [3:0] l = 4'b1x0z;
  logic signed [3:0] ls = 4'b1z01;
  logic [7:0] r8;
  logic signed [7:0] s8;

  initial begin
    $display("size of bit: bit=%0d logic=%0d value=%b",
             $typename(8'(b)) == $typename(bit [7:0]),
             $typename(8'(b)) == $typename(logic [7:0]), 8'(b));
    $display("size of signed bit: bit signed=%0d value=%b",
             $typename(8'(bs)) == $typename(bit signed [7:0]), 8'(bs));
    $display("size of logic: logic=%0d bit=%0d value=%b",
             $typename(8'(l)) == $typename(logic [7:0]),
             $typename(8'(l)) == $typename(bit [7:0]), 8'(l));
    $display("size of signed logic: logic signed=%0d value=%b narrow=%b",
             $typename(8'(ls)) == $typename(logic signed [7:0]), 8'(ls), 2'(l));
    $display("signed of bit: bit signed=%0d logic signed=%0d value=%0d",
             $typename(signed'(b)) == $typename(bit signed [3:0]),
             $typename(signed'(b)) == $typename(logic signed [3:0]), signed'(b));
    $display("unsigned of signed bit: bit=%0d value=%0d",
             $typename(unsigned'(bs)) == $typename(bit [3:0]), unsigned'(bs));
    s8 = signed'(l);
    $display("signed of logic: logic signed=%0d bit signed=%0d extended=%b",
             $typename(signed'(l)) == $typename(logic signed [3:0]),
             $typename(signed'(l)) == $typename(bit signed [3:0]), s8);
    r8 = unsigned'(ls);
    $display("unsigned of signed logic: logic=%0d extended=%b",
             $typename(unsigned'(ls)) == $typename(logic [3:0]), r8);
  end
endmodule
