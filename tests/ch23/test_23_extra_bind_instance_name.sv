/*
:name: test_23_extra_bind_instance_name
:description: A single-instance bind whose name resolves to both an instance and a module binds only to the specified instance (IEEE 1800-2023 Section 23.11)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_23_extra_bind_instance_name.expected
*/
// IEEE 1800-2023 §23.11: the second form of bind names one target instance.
// If the bind_target_instance identifier resolves to both an instance name
// and a module name, binding shall only occur to the specified instance.
// The module sel has an input a whose default is 3. The test has an
// instance also named sel, of module bis_bt, whose a is 7. The bind target
// sel therefore resolves both to that instance and to the module. The rule
// makes the bound probe read the instance, so it prints 7; a tool that
// bound to the module would insert the probe into the implicit top-level
// instance of module sel and print 3.
// Icarus Verilog 13.0 has no bind directive. Verilator 5.052 builds this
// case but binds to the module and prints 3, so this expected output
// follows the standard alone; see the note below.

module bis_sel(input int a = 3);
endmodule

module bis_bt(input int a);
endmodule

module bis_probe(input int x);
  initial #1 $display("x=%0d", x);
endmodule

module test_23_extra_bind_instance_name;
  bis_bt sel(7);

  bind sel bis_probe p(.x(a));

  initial #2 $finish;
endmodule
