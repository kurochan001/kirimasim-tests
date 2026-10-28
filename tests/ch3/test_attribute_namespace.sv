/*
:name: test_attribute_namespace
:description: Attribute names belong to the namespace of their attribute instance delimiters, so the same attribute name can be used on a module, a variable and a net without a name conflict, and the attributes change no value (IEEE 1800-2023 Sections 3.13 and 5.12)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.13 5.12
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_attribute_namespace.expected
*/
// IEEE 1800-2023 §3.13: attribute identifiers belong only to the namespace of
// their attribute instance delimiters, not to the design's definition or
// declaration namespaces. The same attribute name marker is therefore legal on
// the module, a variable and a net, and each attribute instance is independent.
// §5.12: attributes do not change the behavior, so x starts at 1 and the task's
// call of the function makes it 2.

(* marker = "module" *)
module test_attribute_namespace;
  (* marker = "variable" *) int x = 1;
  (* marker = "net" *) wire w;
  assign w = x[0];

  function automatic int inc(int v);
    return v + 1;
  endfunction

  task automatic bump();
    x = inc(x);
  endtask

  initial begin
    bump();
    $display("x=%0d", x);
  end
endmodule
