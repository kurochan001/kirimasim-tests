/*
:name: test_param_class_package_vs_module_instance_specializations
:description: matching specializations of a generic class declared in a package are one type everywhere, while each instance of a module that declares a generic class has its own class and so its own specializations (IEEE 1800-2023 Section 8.25)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.25
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_param_class_package_vs_module_instance_specializations.expected
*/
// IEEE 1800-2023 §8.25: all matching specializations of a generic class are
// the same type. For a generic class declared in a package, which is visible
// throughout the design, this holds everywhere. For a generic class declared
// in a module, each instance of the module creates a unique generic class,
// with its own set of specializations.
// holder declares lc_c and uses pk::pc_c; both classes count their
// constructor calls in a static variable. The two instances of holder have
// no parameters, so they differ only as instances. Each creates one object of
// lc_c#(1) and one of pk::pc_c#(1), at the time its input d gives (1 and 2),
// after waiting for d to arrive, so that the output order is fixed: the
// package class counts both objects, the class of each instance only its own.
// Icarus Verilog 13.0 does not support parameterized classes. The C++ code
// that Verilator 5.052 generates for two instances of holder does not compile.

package pk;
  class pc_c #(int P = 1);
    static int n = 0;
    function new();
      n++;
    endfunction
  endclass
endpackage

module holder (input var int d);
  class lc_c #(int P = 1);
    static int n = 0;
    function new();
      n++;
    endfunction
  endclass

  lc_c #(1) l;
  pk::pc_c #(1) p;

  initial begin
    wait (d != 0);
    #(d);
    l = new;
    p = new;
    $display("instance %0d: module class count=%0d package class count=%0d", d, l.n, p.n);
  end
endmodule

module test_param_class_package_vs_module_instance_specializations;
  holder h1 (.d(1));
  holder h2 (.d(2));
endmodule
