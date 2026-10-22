/*
:name: test_assoc_composite_empty_null_key_order
:description: Empty strings and null handles in composite keys are valid with stable order (IEEE 1800-2023 Section 7.8.5)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_assoc_composite_empty_null_key_order.expected
*/
// Unpacked struct keys have no relational ordering. Compare repeated
// traversals instead of prescribing field order; check all keys and values.

module test_assoc_composite_empty_null_key_order;
  class object_t; endclass
  typedef struct { int tag; string label; object_t obj; } key_t;
  int a[key_t];
  key_t empty_key, full_key, first_order[$], second_order[$];
  object_t object_handle;
  bit same_order;
  bit [1:0] members;
  initial begin
    object_handle = new;
    empty_key = '{0, "", null};
    full_key = '{1, "filled", object_handle};
    a[full_key] = 34; a[empty_key] = 12;
    foreach (a[k]) first_order.push_back(k);
    foreach (a[k]) second_order.push_back(k);
    same_order = first_order.size() == 2 && second_order.size() == 2;
    members = 0;
    foreach (first_order[i]) begin
      if (first_order[i] != second_order[i]) same_order = 0;
      if (first_order[i] == empty_key) members[0] = 1;
      if (first_order[i] == full_key) members[1] = 1;
    end
    $display("size=%0d stable=%0d members=%02b empty=%0d full=%0d",
             a.num(), same_order, members, a[empty_key], a[full_key]);
  end
endmodule
