/*
:name: test_defparam_positions_and_hierarchy
:description: A defparam may come before or after the instance it changes, anywhere in the design including another file, and a value it sets in a module that passes it to a child instance reaches the child, as the current standard still requires tools to support defparam (IEEE 1800-2023 Section 23.10.1, C.4.1)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.10.1 C.4.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: defparam_positions_override.sv
:expected_stdout: @test_defparam_positions_and_hierarchy.expected
*/
// IEEE 1800-2023 §23.10.1: a defparam changes a parameter through the
// hierarchical name of the parameter, and its place in the text does not
// matter: it may precede the instance, follow it, or stand at the end of the
// module, and it may be in another file, which is why a compiler can resolve
// the final parameter values only after all the design files are compiled. A
// defparam may also change a parameter that the module passes on to an
// instance it contains, so the child sees the new value. C.4.1: the current
// standard still requires tools to support the defparam statement.
//
// Each instance of leaf has the parameters A, B and C, whose defaults are 1,
// 2 and 3. u1 takes A from a defparam before its instance, u2 B from one
// after it, u3 C from one at the end of the module body, and u4 A from one in
// the separate file. u5 is an instance of mid, whose parameter P is the
// default value of A in the leaf it contains; the defparam of u5.P therefore
// changes the nested instance. The top module prints the three parameters of
// every instance at a fixed time, so the order of the instances in the design
// does not enter.

module leaf #(parameter int A = 1, parameter int B = 2, parameter int C = 3);
endmodule

module mid #(parameter int P = 0);
  leaf #(.A(P)) nested();
endmodule

module test_defparam_positions_and_hierarchy;
  defparam u1.A = 10;
  leaf u1();
  leaf u2();
  defparam u2.B = 20;
  mid u5();
  defparam u5.P = 7;
  leaf u4();
  leaf u3();

  initial begin
    #1;
    $display("u1 %0d %0d %0d", u1.A, u1.B, u1.C);
    $display("u2 %0d %0d %0d", u2.A, u2.B, u2.C);
    $display("u3 %0d %0d %0d", u3.A, u3.B, u3.C);
    $display("u4 %0d %0d %0d", u4.A, u4.B, u4.C);
    $display("u5 nested A %0d, mid P %0d", u5.nested.A, u5.P);
    $finish;
  end

  defparam u3.C = 30;
endmodule
