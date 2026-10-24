/*
:name: test_variable_default_values_nonintegral
:description: Without an initializer, real, shortreal and realtime variables start at 0.0, a string is empty, chandle, class and interface class handles are null, and each event variable has a new event of its own that can be triggered and waited for (IEEE 1800-2023 Section 6.8)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.8 6.12 6.16 6.14 8.4 8.26 15.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_variable_default_values_nonintegral.expected
*/
// IEEE 1800-2023 §6.8, Table 6-7: a variable declared without an initial value
// starts with the default of its type: 0.0 for real and shortreal (realtime is
// real, 6.12), "" for string (6.16), null for chandle (6.14), class (8.4) and
// interface class (8.26) handles, and a new event for event. A new event is a
// synchronization object of its own for each variable: a process waiting on e1
// wakes when e1 is triggered (15.5), and e2, a separate event, stays
// untriggered.

interface class test_variable_default_values_nonintegral_ifc;
  pure virtual function int id();
endclass

class test_variable_default_values_nonintegral_obj;
  int k;
endclass

module test_variable_default_values_nonintegral;
  real r;
  shortreal sr;
  realtime rt;
  string s;
  chandle h;
  test_variable_default_values_nonintegral_obj obj;
  test_variable_default_values_nonintegral_ifc ic;
  event e1, e2;

  initial begin
    $display("real=%f shortreal=%f realtime=%f", r, sr, rt);
    $display("string=\"%s\" len=%0d", s, s.len());
    $display("null: chandle %0d class %0d interface class %0d", h == null, obj == null,
             ic == null);
    fork
      begin
        @e1;
        $display("woke on e1");
      end
      #1 ->e1;
    join
    $display("triggered: e1 %0d e2 %0d", e1.triggered, e2.triggered);
  end
endmodule
