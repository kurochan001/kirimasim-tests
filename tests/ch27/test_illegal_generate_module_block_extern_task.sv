/*
:name: test_illegal_generate_module_block_extern_task
:description: Inside a module a generate block can hold only module items, so an extern task prototype, which is an interface item, is illegal there, while a task declaration is legal (IEEE 1800-2023 Section 27.3)
:tags: ch27
:type: elaboration
:lrm: 1800-2023 27.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the generate block of the module declares an extern task prototype
:expected_stderr_regex: test_illegal_generate_module_block_extern_task\.sv:27:
*/
// IEEE 1800-2023 §27.3, footnote 35 of Syntax 27-1: within a module
// declaration that is not also within an interface, a generate_item shall
// only be a module_or_generate_item. An extern task prototype is an
// extern_tf_declaration, which only an interface_or_generate_item can be.
// The generate block declares and calls an ordinary task, which is legal.
// Both releases reject the line as a syntax error, which is the right
// diagnosis here: the item is not in the grammar of a module generate block.

module test_illegal_generate_module_block_extern_task #(parameter bit ON = 1'b1);
  if (ON) begin : g
    task automatic show();
      $display("show");
    endtask
    extern task remote();   // illegal: an extern subroutine in a module generate block
    initial show();
  end
endmodule
