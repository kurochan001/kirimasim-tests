/*
:name: test_net_decl_assign_resolution
:description: The assignment in a net declaration is one more driver of the net and is resolved with the other drivers (IEEE 1800-2023 Section 10.3.1)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3.1 6.6.1 28.12.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_net_decl_assign_resolution.expected
*/
// IEEE 1800-2023 §10.3.1: wire w = expr; declares the net and a continuous
// assignment to it, with the drive strength written in the declaration. With
// another continuous assignment to the same net, the two drivers are resolved
// as usual (6.6.1, 28.12.1): equal strengths with different values give x, and
// otherwise the stronger driver wins, bit by bit.

module test_net_decl_assign_resolution;
  int errors = 0;

  // 1. declaration assignment and assign, equal strengths, different values -> x
  wire w = 1'b0;
  assign w = 1'b1;

  // 2. control: two plain assigns
  wire u;
  assign u = 1'b0;
  assign u = 1'b1;

  // 3. (strong1, weak0) declaration drives a weak 0; the strong 1 wins
  wire (strong1, weak0) s1 = 1'b0;
  assign s1 = 1'b1;

  // 4. (weak1, weak0) declaration drives a weak 1; the strong 0 wins
  wire (weak1, weak0) s2 = 1'b1;
  assign s2 = 1'b0;

  // 5. a strong declaration assignment beats a weak assign
  wire v = 1'b1;
  assign (weak1, weak0) v = 1'b0;

  // 6. declaration assignment alone
  wire alone = 1'b0;

  // 7. two drivers of the same value
  wire same = 1'b0;
  assign same = 1'b0;

  // 8. the drivers follow their right-hand sides
  reg a, b;
  wire dyn = a;
  assign dyn = b;

  // 9. vectors are resolved bit by bit
  wire [3:0] vec = 4'b0011;
  assign vec = 4'b0101;

  // 10. three drivers
  wire t3 = 1'b0;
  assign t3 = 1'b0;
  assign t3 = 1'b0;

  task automatic check(string label, logic [3:0] got, logic [3:0] exp);
    if (got !== exp) begin
      $display("MISMATCH %s: got %b expected %b", label, got, exp);
      errors++;
    end
  endtask

  initial begin
    a = 1'b1; b = 1'b1;
    #1;
    check("decl_vs_assign_conflict", w, 1'bx);
    check("two_assigns_control", u, 1'bx);
    check("decl_weak0_loses", s1, 1'b1);
    check("decl_weak1_loses", s2, 1'b0);
    check("assign_weak_loses", v, 1'b1);
    check("decl_alone", alone, 1'b0);
    check("same_value", same, 1'b0);
    check("dyn_11", dyn, 1'b1);
    check("vector_perbit", vec, 4'b0xx1);
    check("triple_driver", t3, 1'b0);
    a = 1'b0;
    #1;
    check("dyn_01_conflict", dyn, 1'bx);
    a = 1'b1; b = 1'bz;
    #1;
    check("dyn_1z", dyn, 1'b1);

    if (errors == 0) $display("TEST PASSED");
    else $display("TEST FAILED: %0d mismatches", errors);
    $finish;
  end
endmodule
