/*
:name: test_repeated_task_output_into_caller_property
:description: A task output copied to a caller property survives every enclosing task return (IEEE 1800-2023 Section 13.5.1)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5.1 8.6
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_repeated_task_output_into_caller_property.expected
:expected_exit: 0
*/
// On each call transfer sets its property to one and the device returns zero
// through output. The owner must still read zero after each invocation.

module test_repeated_task_output_into_caller_property;
  class device;
    task read_status(output int result);
      result = 0;
    endtask
  endclass
  class route;
    device dev = new;
    int status = 1;
    task transfer();
      status = 1;
      dev.read_status(status);
      $display("CHECK inside=%0d", status);
    endtask
  endclass

  initial begin
    automatic route target = new;
    repeat (3) begin
      target.transfer();
      $display("CHECK outside=%0d", target.status);
    end
    $finish;
  end
endmodule
