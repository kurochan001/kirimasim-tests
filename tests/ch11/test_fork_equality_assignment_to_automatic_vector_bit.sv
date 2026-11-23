/*
:name: test_fork_equality_assignment_to_automatic_vector_bit
:description: A fork branch stores its true comparison in an automatic vector bit (IEEE 1800-2023 Section 11.4.5)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.5 11.5.1 9.3.2
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_fork_equality_assignment_to_automatic_vector_bit.expected
:expected_exit: 0
*/
// The only writer assigns 72 == 72 to bit zero. The peer only waits. Both the
// immediate read and the read after join must observe one.

module test_fork_equality_assignment_to_automatic_vector_bit;
  initial begin
    automatic int left = 72, right = 72;
    automatic bit [1:0] mask = 0;
    fork
      begin
        mask[0] = (left == right);
        $display("CHECK equality=%0d stored=%0d", left == right, mask[0]);
      end
      #2;
    join
    $display("CHECK joined=%0d", mask[0]);
    $finish;
  end
endmodule
