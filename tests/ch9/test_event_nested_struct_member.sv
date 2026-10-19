/*
:name: test_event_nested_struct_member
:description: Event controls on members of nested packed structures wake only on a change of that member (IEEE 1800-2023 Section 9.4.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.2 7.2.1 6.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_event_nested_struct_member.expected
*/
// IEEE 1800-2023 §9.4.2: the expression of an event control may select a member
// of a structure, at any depth, and the process wakes when the value of that
// expression changes. A write to another member, to a different variable with
// the same name as the member, or of the value the member already has, does not
// wake it. @(s.inner) wakes on a change of any member inside s.inner.
//
// Nothing is written at time 0, so no process wakes then. Verilator 5.052 wakes
// each of these processes once at time 0.

module test_event_nested_struct_member;
  typedef struct packed { logic [7:0] d; logic [7:0] e; } deep_t;
  typedef struct packed { deep_t deep; logic [7:0] f;    } inner_t;
  typedef struct packed { inner_t inner; logic [7:0] h;  } outer_t;
  outer_t   s;
  logic [7:0] f;   // a different variable with the name of a member
  int errors = 0;
  int n_nested = 0;   // @(s.inner.f)
  int n_deep   = 0;   // @(s.inner.deep.d), three levels
  int n_mid    = 0;   // @(s.inner), an intermediate member
  int n_lvl1   = 0;   // @(s.h), one level
  always @(s.inner.f)      n_nested++;
  always @(s.inner.deep.d) n_deep++;
  always @(s.inner)        n_mid++;
  always @(s.h)            n_lvl1++;
  task automatic chk(string what, int got, int want);
    if (got !== want) begin
      $display("CHECK-FAIL: %s = %0d, expected %0d", what, got, want);
      errors++;
    end
  endtask
  initial begin
    #1 f = 8'd9;             // the other variable: no wakeups
    #1 chk("n_nested after unrelated f", n_nested, 0);
    chk("n_deep after unrelated f", n_deep, 0);
    s.inner.deep.e = 8'd2;   // inside deep, but not d: only n_mid
    #1 chk("n_deep after sibling deep.e", n_deep, 0);
    chk("n_mid after deep.e", n_mid, 1);
    s.h = 8'd6;              // outside inner: only n_lvl1
    #1 chk("n_lvl1 after s.h", n_lvl1, 1);
    chk("n_mid after s.h", n_mid, 1);
    chk("n_nested after s.h", n_nested, 0);
    s.inner.deep.d = 8'd3;   // n_deep and n_mid
    #1 chk("n_deep after deep.d", n_deep, 1);
    chk("n_mid after deep.d", n_mid, 2);
    chk("n_nested after deep.d", n_nested, 0);
    s.inner.f = 8'd1;        // n_nested and n_mid
    #1 chk("n_nested after inner.f", n_nested, 1);
    chk("n_mid after inner.f", n_mid, 3);
    chk("n_deep after inner.f", n_deep, 1);
    s.inner.f = 8'd1;        // the same value: no change, no wakeup
    #1 chk("n_nested after rewriting the same value", n_nested, 1);
    s.inner.f = 8'd7;        // a change again
    #1 chk("n_nested after second real change", n_nested, 2);
    if (errors == 0) begin
      $display("n_nested=%0d n_deep=%0d n_mid=%0d n_lvl1=%0d", n_nested, n_deep, n_mid, n_lvl1);
      $display("TEST PASSED: event controls on nested structure members");
    end else begin
      $display("TEST FAILED: %0d errors", errors);
    end
    $finish;
  end
endmodule
