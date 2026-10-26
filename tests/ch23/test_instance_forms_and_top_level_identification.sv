/*
:name: test_instance_forms_and_top_level_identification
:description: A module is a top-level module only if no module instantiation statement names it, even one in a generate block that is not instantiated, and each top-level module is instantiated once under its module name, while a module can also be instantiated explicitly in the hierarchy or implicitly as a nested module (IEEE 1800-2023 Section 23.3 and 23.3.1)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3 23.3.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_instance_forms_and_top_level_identification.expected
*/
// IEEE 1800-2023 §23.3 and §23.3.1: a module can be instantiated at the top
// level, implicitly, or explicitly in the hierarchy, or implicitly as a
// nested module. A module is top-level only if it does not appear in any
// module instantiation statement, including one in a generate block that is
// not itself instantiated, and a design shall contain at least one
// top-level module. A top-level module is instantiated once, under the same
// name as the module. In this design tli_top is the only module that no
// instantiation names: tli_child is instantiated explicitly as u_child,
// tli_gen_only is named only by an instantiation in the generate block g_off
// whose condition is false, so it is not top-level and has no instance, and
// tli_nested is a nested module without ports, so it is instantiated
// implicitly under its own name. Each instance prints %m, its hierarchical
// name, at a time of its own: the explicit instance prints tli_top.u_child,
// the nested one tli_top.tli_nested, and the top-level one tli_top, which
// shows that the top-level instance name is the module name. A tool that
// made tli_gen_only or tli_child a top-level module would print one more
// line, or a line with the wrong path.

module tli_child;
  initial begin
    #1 $display("child %m");
  end
endmodule

module tli_gen_only;
  initial begin
    #2 $display("gen_only %m");
  end
endmodule

module tli_top;
  tli_child u_child ();

  module tli_nested;
    int v = 11;
    initial begin
      #3 $display("nested %m v=%0d", v);
    end
  endmodule

  generate
    if (0) begin : g_off
      tli_gen_only u_off ();
    end
  endgenerate

  initial begin
    #10 $display("top %m");
  end
endmodule
