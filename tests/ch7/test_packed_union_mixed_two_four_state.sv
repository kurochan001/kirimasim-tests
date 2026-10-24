/*
:name: test_packed_union_mixed_two_four_state
:description: a packed union with a 2-state and a 4-state member is 4-state as a whole; reading the 2-state member turns x and z into 0, and writing it stores known bits (IEEE 1800-2023 Section 7.3.1)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.3.1 6.11.2 6.8
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_packed_union_mixed_two_four_state.expected
*/
// IEEE 1800-2023 §7.3.1: when a packed union has both a 2-state and a 4-state
// member, the whole union is 4-state. Reading the 2-state member converts the
// stored 4-state bits to 2-state, where x and z become 0 (§6.11.2), and
// writing the 2-state member converts its 2-state value to 4-state bits.
// m starts with the default of a 4-state variable, all x (§6.8), which the
// 2-state member reads as zeros. After the 4-state member stores a value with
// x and z, the whole union and l4 still show them, while b2 reads 0 in their
// places, also inside an expression. Writing b2 leaves no unknown bit.
// Icarus Verilog 13.0 reads the x and z bits through b2 unchanged. Verilator
// is a 2-state simulator and cannot hold them.

module test_packed_union_mixed_two_four_state;
  typedef union packed {
    bit [7:0] b2;
    logic [7:0] l4;
  } m_t;

  m_t m;

  initial begin
    $display("initial: whole=%b b2=%b", m, m.b2);
    m.l4 = 8'b1x0z_10x1;
    $display("after l4 write: l4=%b whole=%b b2=%b", m.l4, m, m.b2);
    $display("unknown bits: whole=%0d l4=%0d b2=%0d", $isunknown(m), $isunknown(m.l4),
             $isunknown(m.b2));
    $display("plus 1: b2+1=%b l4+1=%b", m.b2 + 8'd1, m.l4 + 8'd1);
    m.b2 = 8'ha5;
    $display("after b2 write: l4=%b whole=%b unknown=%0d", m.l4, m, $isunknown(m));
  end
endmodule
