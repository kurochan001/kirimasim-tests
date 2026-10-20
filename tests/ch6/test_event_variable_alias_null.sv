/*
:name: test_event_variable_alias_null
:description: An event variable declared without an initializer gets a new synchronization object, one assigned from another event shares that object, and one assigned null has none (IEEE 1800-2023 Section 6.17)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.17 15.5.5 15.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_event_variable_alias_null.expected
*/
// IEEE 1800-2023 §6.17: an event variable is a handle to a synchronization
// object. Without an initializer it gets a new one; initialized from another
// event variable it refers to the same object, so triggering one (15.5.1)
// wakes processes waiting on the other; assigned null it refers to none.
// Event variables can be compared (15.5.5). e1 and e2 share an object, e3 has
// its own, and e0 is null; later e2 is set to null too.

`timescale 1ns/1ns

module test_event_variable_alias_null;
  event e1;
  event e2 = e1;
  event e3;
  event e0 = null;

  initial begin
    fork
      begin
        @(e2);
        $display("t=%0d: waiting on e2, woken by e1", $time);
      end
      begin
        @(e3);
        $display("t=%0d: e3 triggered", $time);
      end
    join_none
    #1 -> e1;
    #1 $display("e1==e2:%0d e1==e3:%0d e0==null:%0d", e1 == e2, e1 == e3, e0 == null);
    e2 = null;
    $display("after e2 = null: e2==null:%0d e1==null:%0d", e2 == null, e1 == null);
  end
endmodule
