/*
:name: test_forward_class_cycle_and_struct_value
:description: Forward class declarations permit cyclic handles while a struct assignment copies its value (IEEE 1800-2023 Section 8.27)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.27 8.28
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_forward_class_cycle_and_struct_value.expected
*/
// IEEE 1800-2023 8.27 8.28: Mutual handles can form a cycle and aliases share
// an object; a copied unpacked struct remains independent after mutation.
// Oracle checks: Icarus Verilog 13.0 does not build this case.

module test_forward_class_cycle_and_struct_value;
  typedef class right_node;
  class left_node;
    right_node link;
    int value;
  endclass
  class right_node;
    left_node back;
  endclass
  typedef struct { int value; } value_t;
  left_node a, alias_node;
  right_node b;
  value_t s, t;
  initial begin
    a = new; b = new; a.link = b; b.back = a; alias_node = a;
    s.value = 4; t = s; s.value = 9;
    alias_node.value = 13;
    $display("cycle=%0d alias=%0d struct=%0d,%0d", a.link.back == a,
             a.value, s.value, t.value);
  end
endmodule
