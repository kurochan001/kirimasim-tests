/*
:name: test_package_export_wildcard_forms
:description: export p::* passes on only what the package actually imported from p, export *::* passes on everything it imported, and an export can list several items (IEEE 1800-2023 Section 26.6)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.6 26.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_export_wildcard_forms.expected
*/
// IEEE 1800-2023 §26.6, Syntax 26-4: an export is either *::* or a
// comma-separated list of items p::name and p::*. An item p::* passes on the
// declarations that the package actually imported from p, by an explicit
// import or because a wildcard import was used, but not the candidates of a
// wildcard import that were never referenced. *::* passes on all imported
// declarations from all packages.
// §26.3: a name that the imports of a module do not provide is looked up in
// the compilation unit, which declares b, c and d with values of its own.
// Package xw_pkgwild references only a of xw_base::*, so b stays in the
// compilation unit. Package xw_all imports xw_other::c and xw_base::b and
// exports *::*, which gives b and c but not d. Package xw_list exports
// xw_base::a and xw_other::*, where it referenced d but not c.
// The 5.052 release of Verilator also passes on the unreferenced candidates
// b of xw_pkgwild (b=2) and c of xw_list (c=3).

localparam int b = 500;
localparam int c = 700;
localparam int d = 600;

package xw_base;
  localparam int a = 1;
  localparam int b = 2;
endpackage

package xw_other;
  localparam int c = 3;
  localparam int d = 4;
endpackage

package xw_pkgwild;
  import xw_base::*;
  export xw_base::*;
  localparam int sum = a + 10;
endpackage

package xw_all;
  import xw_other::c;
  import xw_base::b;
  export *::*;
endpackage

package xw_list;
  import xw_base::a;
  import xw_other::*;
  localparam int e = d;
  export xw_base::a, xw_other::*;
endpackage

module xw_use_pkgwild;
  import xw_pkgwild::*;
  initial #1 $display("xw_pkgwild: a=%0d b=%0d sum=%0d", a, b, sum);
endmodule

module xw_use_all;
  import xw_all::*;
  initial #2 $display("xw_all: b=%0d c=%0d d=%0d", b, c, d);
endmodule

module xw_use_list;
  import xw_list::*;
  initial #3 $display("xw_list: a=%0d c=%0d d=%0d e=%0d", a, c, d, e);
endmodule

module test_package_export_wildcard_forms;
  xw_use_pkgwild u1 ();
  xw_use_all u2 ();
  xw_use_list u3 ();
endmodule
