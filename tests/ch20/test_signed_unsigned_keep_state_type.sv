/*
:name: test_signed_unsigned_keep_state_type
:description: the result of $signed or $unsigned has the 2-state or 4-state type of its argument with only the signedness changed, as variables declared with type() of the call show (IEEE 1800-2023 Section 20.5)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.5 6.23 6.22.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_signed_unsigned_keep_state_type.expected
*/
// IEEE 1800-2023 §20.5: $signed and $unsigned cast the signedness of an
// expression but not its type, so $signed of a logic vector is a signed
// logic vector and $signed of a bit vector a signed bit vector of the same
// size. §6.23: type() of an expression gives its type, which can declare a
// variable, and two type references compare equal when the types match
// (§6.22.1).
// Variables are declared with the types of $signed and $unsigned of 8-bit
// logic and bit vectors. Assigning x or z leaves x or z in the logic ones
// and 0 in the bit ones; assigning ff gives a negative value only in the
// ones from $signed; all are 8 bits wide. The type references of the calls
// are also compared with logic signed [7:0], bit signed [7:0] and
// logic [7:0] written out.
// Neither simulator follows the clause here: Icarus Verilog 13.0 rejects
// var type(...) declarations, and release 5.052 of the Verilator tool gives
// $signed of a bit vector a logic type (the second and third comparisons
// are 0 and 1, and an x assigned to t_sb does not become 0).

module test_signed_unsigned_keep_state_type;
  logic [7:0] a;
  logic signed [7:0] sa;
  bit [7:0] b8;
  bit signed [7:0] sb8;
  var type($signed(a)) t_sl;
  var type($unsigned(sa)) t_ul;
  var type($signed(b8)) t_sb;
  var type($unsigned(sb8)) t_ub;

  initial begin
    t_sl = 'x;
    t_ul = 'z;
    t_sb = 'x;
    t_ub = 'z;
    $display("x/z: %b %b %b %b", t_sl, t_ul, t_sb, t_ub);
    $display("bits: %0d %0d %0d %0d", $bits(t_sl), $bits(t_ul), $bits(t_sb), $bits(t_ub));
    t_sl = 8'hff;
    t_ul = 8'hff;
    t_sb = 8'hff;
    t_ub = 8'hff;
    $display("negative: %0d %0d %0d %0d", t_sl < 0, t_ul < 0, t_sb < 0, t_ub < 0);
    $display("types: %0d %0d %0d %0d", type($signed(a)) == type(logic signed [7:0]),
             type($signed(b8)) == type(bit signed [7:0]),
             type($signed(b8)) == type(logic signed [7:0]),
             type($unsigned(sa)) == type(logic [7:0]));
  end
endmodule
