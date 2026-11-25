/*
:name: test_class_null_instance_access_observation
:description: Observe a null handle used for an instance field or a virtual method
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.4 8.9 8.20
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_null_instance_access_observation.expected
*/
module test_class_null_instance_access_observation;
  class state_base;
    static int shared_value = 47;
    int instance_value = 21;

    virtual function int evaluate();
      return instance_value;
    endfunction
  endclass

  class derived_state extends state_base;
    virtual function int evaluate();
      return instance_value + 7;
    endfunction
  endclass

  initial begin
    state_base handle;
    derived_state instance_handle;
    instance_handle = new;
    handle = instance_handle;
    $display("live field=%0d virtual=%0d", handle.instance_value, handle.evaluate());

    handle = null;
    $display("null handle=%0b static=%0d", handle == null, handle.shared_value);

    // Run each trial separately because either access may stop simulation.
    if ($test$plusargs("observe_null_field")) begin
      $display("before null field");
      $display("null field result=%0d", handle.instance_value);
    end
    if ($test$plusargs("observe_null_virtual")) begin
      $display("before null virtual");
      $display("null virtual result=%0d", handle.evaluate());
    end

    $display("finished");
    $finish(0);
  end
endmodule
