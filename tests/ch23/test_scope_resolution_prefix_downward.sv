/*
:name: test_scope_resolution_prefix_downward
:description: A name with a package or class scope resolution prefix resolves downwards only, and a prefix that resolves by the normal scope rules denotes a class rather than a package (IEEE 1800-2023 Section 23.7.1)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.7.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_scope_resolution_prefix_downward.expected
*/
// IEEE 1800-2023 §23.7.1: a name whose prefix is followed by the scope
// resolution operator :: resolves in a downwards manner and is never subject
// to the upwards rules of §23.8. If the prefix resolves by the normal scope
// rules it denotes a class, otherwise it denotes a package. Package sp has a
// variable v = 11 and package both has v = 51, and module spref declares its
// own v = 31, so an upwards search from a prefix could find 31. The name
// sp::v must be the package variable 11; the class spref::C holds a static v
// = 21 and C::v must be 21; the class both, declared in module spref, hides
// the package both of the same name, so both::v must be the class member 61
// and not the package's 51. A tool that searched upwards, or that preferred
// the package to the class that normal scope resolution finds first, would
// print 31, 31 or 51 on the corresponding field. Icarus Verilog 13.0 does
// not accept a class declaration in a module, so the expected output is
// recorded with Verilator 5.052.

package sp;
  int v = 11;
endpackage

package both;
  int v = 51;
endpackage

module spref;
  int v = 31;

  class C;
    static int v = 21;
  endclass

  class both;
    static int v = 61;
  endclass

  initial begin
    #1 $display("package=%0d class=%0d shadowing=%0d local=%0d", sp::v, C::v, both::v, v);
  end
endmodule
