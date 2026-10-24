/*
:name: test_package_export_same_declaration
:description: a declaration imported through several exporting packages is the original declaration, so the paths do not conflict and share one variable (IEEE 1800-2023 Section 26.6)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.6
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_export_same_declaration.expected
*/
// IEEE 1800-2023 §26.6: importing a declaration that a package exports is
// the same as importing the original declaration. Importing it, directly or
// by a wildcard, through several exported paths therefore causes no
// conflict, and a package may export the same declaration more than once.
// Packages xi_p1 and xi_p2 both export xi_base::x, one by name and one by
// xi_base::*; package xi_p3 imports x by two paths and exports it both as
// xi_base::x and as xi_p1::x. Module xi_writer imports x by wildcards from
// xi_p1 and xi_p2 and sets it to 9 at time 1; module xi_reader imports x
// explicitly from xi_p3 and from xi_base and reads it at time 2. Since all
// paths lead to the one variable xi_base::x, the reader sees 9, also in
// the functions touch and seen, whose bodies reference x in xi_p2 and xi_p3.

package xi_base;
  int x = 5;
endpackage

package xi_p1;
  import xi_base::x;
  export xi_base::x;
endpackage

package xi_p2;
  import xi_base::*;
  export xi_base::*;
  function automatic int touch();
    return x;
  endfunction
endpackage

package xi_p3;
  import xi_p1::*;
  import xi_base::*;
  function automatic int seen();
    return x;
  endfunction
  export xi_base::x;
  export xi_p1::x;
endpackage

module xi_writer;
  import xi_p1::*;
  import xi_p2::*;
  initial begin
    $display("t=0 writer: x=%0d touch=%0d", x, touch());
    #1 x = 9;
  end
endmodule

module xi_reader;
  import xi_p3::x;
  import xi_base::x;
  initial #2 $display("t=2 reader: x=%0d xi_base::x=%0d seen=%0d", x, xi_base::x, xi_p3::seen());
endmodule

module test_package_export_same_declaration;
  xi_writer w ();
  xi_reader r ();
endmodule
