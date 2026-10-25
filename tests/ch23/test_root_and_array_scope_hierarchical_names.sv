/*
:name: test_root_and_array_scope_hierarchical_names
:description: A hierarchical name can start at $root and reach a variable through the top-level instance, a foreach loop can name a hierarchical array of an instance and a package-scoped array of a package, and the loops give each index and element (IEEE 1800-2023 Sections 23.6, 23.3.1 and 7.12)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.6 23.3.1 7.12 A.9.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_root_and_array_scope_hierarchical_names.expected
*/
// IEEE 1800-2023 A.9.3: a hierarchical identifier may start with $root and a
// dot; a hierarchical array identifier is a hierarchical identifier, and a
// package-scoped or hierarchical array identifier may have a package scope.
// §23.6: a hierarchical name names an object through instance scopes. §23.3.1:
// $root names the top-level scope, so $root.test_...u.v is the variable v of
// the instance u. §7.12 and foreach: the loop over an array gives the index
// and the element at it.
//
// The instance u has the array mem with 11, 5A, A5 and 44 at 0 to 3, and the
// package hp2 has parr with 4 and 5, so the two loops print four and two
// pairs, and $root names v = 3.
//
// Icarus Verilog 13.0 has no $root and cannot iterate a hierarchical array;
// the 5.052 release of Verilator produces this output.

`timescale 1ns/1ns

package hp2;
  int parr [2] = '{4, 5};
endpackage

module leaf3;
  logic [7:0] mem [0:3];
  logic [3:0] v = 4'h3;

  initial begin
    mem[0] = 8'h11;
    mem[1] = 8'h5A;
    mem[2] = 8'hA5;
    mem[3] = 8'h44;
  end
endmodule

module test_root_and_array_scope_hierarchical_names;
  leaf3 u ();

  initial begin
    #1;
    foreach (u.mem[i]) $display("mem %0d %h", i, u.mem[i]);
    foreach (hp2::parr[j]) $display("parr %0d %0d", j, hp2::parr[j]);
    $display("root %h", $root.test_root_and_array_scope_hierarchical_names.u.v);
  end
endmodule
