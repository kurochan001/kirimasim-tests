/*
:name: test_assoc_class_key_order_is_stable
:description: Class key traversal repeats for a fixed set without prescribing address order (IEEE 1800-2023 Section 7.8.3)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_assoc_class_key_order_is_stable.expected
*/
// Compare two whole traversals by handle identity and check membership.
// No specific ordering of class handles, including null, is prescribed.

module test_assoc_class_key_order_is_stable;
  class key_t; endclass
  key_t x, y;
  int a[key_t];
  key_t first_order[$], second_order[$];
  bit same_order;
  bit [2:0] members;
  initial begin
    x = new; y = new;
    a[y] = 22; a[null] = 33; a[x] = 11;
    foreach (a[k]) first_order.push_back(k);
    foreach (a[k]) second_order.push_back(k);
    same_order = first_order.size() == 3 && second_order.size() == 3;
    members = 0;
    foreach (first_order[i]) begin
      if (first_order[i] != second_order[i]) same_order = 0;
      if (first_order[i] == x) members[0] = 1;
      if (first_order[i] == y) members[1] = 1;
      if (first_order[i] == null) members[2] = 1;
    end
    $display("size=%0d scans=%0d,%0d stable=%0d members=%03b",
             a.num(), first_order.size(), second_order.size(), same_order, members);
    $display("values=%0d,%0d,%0d", a[x], a[y], a[null]);
  end
endmodule
