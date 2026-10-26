/*
:name: test_nested_module_implicit_instance
:description: A nested module without ports that nothing instantiates gets one implicit instance named after the module, while a nested module with ports is not instantiated implicitly (IEEE 1800-2023 Section 23.4)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nested_module_implicit_instance.expected
*/
// IEEE 1800-2023 §23.4: a module declared inside another module is not
// instantiated by its declaration; if it has no ports and is not instantiated
// otherwise, one implicit instance named after the module is created. A nested
// module that has ports is not instantiated implicitly. The nested module
// nmi_leaf has no ports and sets its variable and the outer counter in its
// initial procedure, so its values show that the implicit instance nmi_leaf
// ran; the nested module nmi_ported has a port and prints nothing, so its line
// must not appear.

// The 5.052 release of Verilator does not support a module declaration
// inside a module, so the
// expected output is recorded from the standard and Icarus Verilog 13.0 alone.

module test_nested_module_implicit_instance;
  int seen = 0;

  initial begin
    #1;
    $display("leaf got %0d seen %0d", nmi_leaf.got, seen);
  end

  module nmi_leaf;
    int got = 0;

    initial begin
      got = 7;
      seen++;
    end
  endmodule

  module nmi_ported(input int p);
    initial $display("ported module ran with %0d", p);
  endmodule
endmodule
