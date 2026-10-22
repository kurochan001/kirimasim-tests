/*
:name: test_assoc_ref_allocates_before_callee_write
:description: A missing ref actual is allocated before a callee that never writes (IEEE 1800-2023 Section 7.8.7)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8.7 7.8 13.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_assoc_ref_allocates_before_callee_write.expected
*/
// Check allocation before reading the ref formal and never assign it.
// Allocation deferred until a callee write cannot pass.

module test_assoc_ref_allocates_before_callee_write;
  int a[int];
  task automatic inspect(ref int element, ref int container[int]);
    $display("entry before formal read: num=%0d exists=%0d",
             container.num(), container.exists(7));
    $display("formal default=%0d", element);
  endtask
  initial begin
    $display("before: num=%0d exists=%0d", a.num(), a.exists(7));
    inspect(a[7], a);
    $display("after no write: num=%0d exists=%0d value=%0d",
             a.num(), a.exists(7), a[7]);
    a[3] = 9;
    $display("assignment: num=%0d exists=%0d value=%0d",
             a.num(), a.exists(3), a[3]);
  end
endmodule
