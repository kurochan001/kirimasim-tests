/*
:name: test_param_override_three_ways_module_interface_program
:description: parameters of module, interface and program instances are overridden by an ordered list, by name and by defparam, each changing exactly the parameters it names (IEEE 1800-2023 Section 6.20)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20 23.10.1 23.10.2.1 23.10.2.2 24.3 25.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_param_override_three_ways_module_interface_program.expected
*/
// IEEE 1800-2023 §6.20: the parameters of a module, interface or program
// instance can be overridden by an ordered list (§23.10.2.1), by name
// (§23.10.2.2) or by a defparam with the hierarchical name of the parameter
// (§23.10.1). Each kind of design element has three parameters, 1, 2 and 3
// by default, and three instances: the ordered list #(10, 20) sets P1 and P2
// in declaration order; the named list gives P3 and P1 in the other order and
// leaves out P2; the defparam changes only P2. The top module prints the
// module and interface parameters at time 1; each program prints its own at
// time 100 + P1, so the three programs print at different times.

module pov_m #(int P1 = 1, int P2 = 2, int P3 = 3) ();
endmodule

interface pov_if #(int P1 = 1, int P2 = 2, int P3 = 3) ();
endinterface

program pov_p #(int P1 = 1, int P2 = 2, int P3 = 3) ();
  initial #(100 + P1) $display("program %m: %0d %0d %0d", P1, P2, P3);
endprogram

module test_param_override_three_ways_module_interface_program;
  pov_m #(10, 20) m_ord ();
  pov_m #(.P3(30), .P1(11)) m_named ();
  pov_m m_def ();
  defparam m_def.P2 = 22;

  pov_if #(10, 20) i_ord ();
  pov_if #(.P3(30), .P1(11)) i_named ();
  pov_if i_def ();
  defparam i_def.P2 = 22;

  pov_p #(10, 20) p_ord ();
  pov_p #(.P3(30), .P1(11)) p_named ();
  pov_p p_def ();
  defparam p_def.P2 = 22;

  initial begin
    #1;
    $display("module ordered: %0d %0d %0d", m_ord.P1, m_ord.P2, m_ord.P3);
    $display("module named: %0d %0d %0d", m_named.P1, m_named.P2, m_named.P3);
    $display("module defparam: %0d %0d %0d", m_def.P1, m_def.P2, m_def.P3);
    $display("interface ordered: %0d %0d %0d", i_ord.P1, i_ord.P2, i_ord.P3);
    $display("interface named: %0d %0d %0d", i_named.P1, i_named.P2, i_named.P3);
    $display("interface defparam: %0d %0d %0d", i_def.P1, i_def.P2, i_def.P3);
  end
endmodule
