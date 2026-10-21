/*
:name: test_sched_wait_true_does_not_block
:description: A wait statement whose condition is already true does not block, so the process goes on before a pending nonblocking update (IEEE 1800-2023 Section 4.4.2.4)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.4 9.4.3 10.4.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_wait_true_does_not_block.expected
*/
// IEEE 1800-2023 §9.4.3: wait blocks only if its condition is not true. Here it
// is true, so the process goes on in the Active region and reads x before the
// NBA region (§4.4.2.4) updates it to 0.

module test_sched_wait_true_does_not_block;
  bit x = 1;
  initial begin
    x <= 0;
    wait (x);
    $display("after wait: x=%0d", x);
  end
endmodule
