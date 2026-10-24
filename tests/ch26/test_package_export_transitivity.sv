/*
:name: test_package_export_transitivity
:description: a package does not pass on what it imports unless it exports it, and an export may come before its import (IEEE 1800-2023 Section 26.6)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.6 26.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_export_transitivity.expected
*/
// IEEE 1800-2023 §26.6: declarations that a package imports are not made
// visible by later imports of that package, unless the package exports
// them; an export can also be written before the import it refers to.
// §26.3: a name that no import of the module provides is looked up further
// out, here in the compilation unit, which declares its own v and w.
// Package xt_plain imports xt_base::v without exporting it, so a module that
// imports xt_plain::* finds v in the compilation unit (100) and xt_plain's
// own declaration own (11). Package xt_named exports xt_base::v, so through
// it v is xt_base::v (1). Package xt_early has the export xt_base::* before
// its import of xt_base::w, and the explicit import of xt_early::w gives
// xt_base::w (2). The 5.052 release of Verilator gives the w of the
// compilation unit (200) there.

localparam int v = 100;
localparam int w = 200;

package xt_base;
  localparam int v = 1;
  localparam int w = 2;
endpackage

package xt_plain;
  import xt_base::v;
  localparam int own = v + 10;
endpackage

package xt_named;
  import xt_base::v;
  export xt_base::v;
endpackage

package xt_early;
  export xt_base::*;
  import xt_base::w;
endpackage

module xt_use_plain;
  import xt_plain::*;
  initial #1 $display("through xt_plain: v=%0d own=%0d", v, own);
endmodule

module xt_use_named;
  import xt_named::*;
  initial #2 $display("through xt_named: v=%0d", v);
endmodule

module xt_use_early;
  import xt_early::w;
  initial #3 $display("through xt_early: w=%0d", w);
endmodule

module test_package_export_transitivity;
  xt_use_plain u1 ();
  xt_use_named u2 ();
  xt_use_early u3 ();
endmodule
