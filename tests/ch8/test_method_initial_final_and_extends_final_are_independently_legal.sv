/*
:name: test_method_initial_final_and_extends_final_are_independently_legal
:description: Initial final and extends final qualify different methods in the same type
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.20
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_method_initial_final_and_extends_final_are_independently_legal.expected
*/
module test_method_initial_final_and_extends_final_are_independently_legal;
  class parent_type;
    virtual function int value();
      return 1;
    endfunction
  endclass

  class child_type extends parent_type;
    function :initial :final int separate();
      return 4;
    endfunction
    function :extends :final int value();
      return 8;
    endfunction
  endclass

  initial begin
    child_type child;
    parent_type base_ref;
    child = new;
    base_ref = child;
    $display("initial=%0d override=%0d", child.separate(), base_ref.value());
  end
endmodule
