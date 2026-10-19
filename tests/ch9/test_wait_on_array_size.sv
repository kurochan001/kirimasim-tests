/*
:name: test_wait_on_array_size
:description: wait on the size() of a queue and of a dynamic array resumes when push_back or new[] changes it (IEEE 1800-2023 Section 9.4.3)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.3 7.10.2.7 7.5.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_wait_on_array_size.expected
*/
// IEEE 1800-2023 §9.4.3: wait (expression) blocks until the expression is
// true, and is evaluated again whenever a value it depends on changes. Here
// the expressions call size() on a queue and on a dynamic array, so they
// become true when push_back (7.10.2.7) adds an element and when new[]
// (7.5.1) sizes the array, and a later change of another variable wakes
// nothing.

module test_wait_on_array_size;
  int q[$];
  int d[];
  int unrelated;

  initial begin
    wait (q.size() != 0);
    $display("t=%0d wait (q.size() != 0) resumes, size %0d", $time, q.size());
  end

  initial begin
    wait (d.size() == 2);
    $display("t=%0d wait (d.size() == 2) resumes", $time);
  end

  initial begin
    #1 q.push_back(5);
    #1 d = new[2];
    #1 unrelated = 1;
    #1 $display("t=%0d done", $time);
  end
endmodule
