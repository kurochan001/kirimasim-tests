/*
:name: test_constructor_default_argument
:description: The default keyword in the argument list of a derived class constructor stands for the arguments of the superclass constructor in their order, types and default values, and may appear once; a call with no arguments then takes the superclass defaults and a call with arguments gives them in that order (IEEE 1800-2023 Sections 8.15 and 8.16 and footnote 9 of A.10)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.15 8.16 A.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constructor_default_argument.expected
*/
// IEEE 1800-2023 footnote 9 of A.10: the default keyword appears at most once
// in a class constructor argument list. §8.15: the default keyword in the
// constructor of a derived class expands to the argument list of the
// superclass constructor, with the same order, direction, type and default
// values, and the call to super.new(default) may then be left out. §8.16: the
// arguments of the derived constructor follow the expanded list.
//
// The constructor of sup_c has the argument x with the default 1, and the
// constructor of sub_c has default and the argument y with the default 2. The
// call new of s0 therefore has x = 1 and y = 2, and new(5, 7) of s1 has x = 5
// and y = 7.
//
// Neither Icarus Verilog 13.0 nor Verilator 5.052 supports the default
// keyword in a constructor, so this expected output follows the standard.

module test_constructor_default_argument;
  class sup_c;
    int x;

    function new(int x = 1);
      this.x = x;
    endfunction
  endclass

  class sub_c extends sup_c;
    int y;

    function new(default, int y = 2);
      this.y = y;
    endfunction
  endclass

  sub_c s0, s1;

  initial begin
    s0 = new;
    s1 = new(5, 7);
    $display("ctor %0d %0d %0d %0d", s0.x, s0.y, s1.x, s1.y);
  end
endmodule
