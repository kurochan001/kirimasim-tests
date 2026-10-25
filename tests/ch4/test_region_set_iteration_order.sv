/*
:name: test_region_set_iteration_order
:description: A time step repeats the regions of the active set until they are all empty before it enters the reactive set, and once in the reactive set it empties the Reactive, Re-Inactive and Re-NBA regions before it returns to active work that the reactive code created (IEEE 1800-2023 Section 4.4.3.10)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.3.10 4.5 24.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_region_set_iteration_order.expected
*/
// IEEE 1800-2023 §4.4.3.10, Figure 4-1, and §4.5: within a time slot the
// scheduler processes the earliest nonempty region from Active to
// Post-Observed again and again, moving its events to Active, until those
// regions are empty; only then does it enter the reactive region set, which
// it in turn empties, Reactive to Post-Re-NBA, before it goes back to the
// active set. §24.3.1: program processes run in the Reactive region.
// At time 1 a module NBA sets a, which starts a chain through the Inactive
// region (#0 b = a + 1), the NBA region (c <= b + 1) and the Active region
// (d = c + 1). The program process main resumes at 1 in the Reactive region
// and sees the whole chain done. It then writes m, which wakes a module
// process (Active work), and executes #0 and pv <= 1: it resumes from
// Re-Inactive, and the program process waiter wakes after the Re-NBA update,
// and both still see m_copy=0, as the reactive set is emptied first. At 2
// the module process has run.
// Icarus Verilog 13.0 resumes the program process at 1 before the module
// chain (a=0 b=0 c=0 d=0), and the release 5.052 of Verilator does not
// support a program declared in a module.

module test_region_set_iteration_order;
  int a = 0, b = 0, c = 0, d = 0, m = 0, m_copy = 0, pv = 0;

  always @(a) #0 b = a + 1;
  always @(b) c <= b + 1;
  always @(c) d = c + 1;
  always @(m) m_copy = m;

  initial #1 a <= 1;

  program p;
    initial begin : waiter
      @(pv);
      $display("waiter: pv=%0d m_copy=%0d", pv, m_copy);
    end

    initial begin : main
      #1;
      $display("program at 1: a=%0d b=%0d c=%0d d=%0d", a, b, c, d);
      m = 1;
      #0;
      $display("after #0: m_copy=%0d", m_copy);
      pv <= 1;
      #1 $display("at 2: m_copy=%0d", m_copy);
    end
  endprogram
endmodule
