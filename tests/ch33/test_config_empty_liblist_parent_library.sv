/*
:name: test_config_empty_liblist_parent_library
:description: An empty liblist selected for an instance makes the library of the parent cell the only library searched, instead of the default liblist (IEEE 1800-2023 Section 33.4.1.5)
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.4.1.5 33.4.1.2 33.4.1.3 33.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_config_empty_liblist_parent_library.expected
*/
// IEEE 1800-2023 §33.4.1.5: when the liblist selected for an instance is
// empty, the list searched for its cell holds one library, the library of the
// cell that contains the instance. The liblist clause may name no library at
// all (A.1.5). §33.4.1.2: the default clause applies only to instances that no
// more specific clause selects. §33.3.1: with no library map file, every cell
// of this test is in the library work.
//
// The library elp_none holds no cell, and the default liblist names only it,
// so an instance that took the default liblist could not be bound. The
// instance clause selects an empty liblist for m, so m is searched for in
// work, the library of the top-level cell that contains it, and is bound to
// work.elp_mid. m.leaf takes its liblist from m (§33.6.4); read either as the
// empty list or as the library work that it stands for, it makes work, which
// is also the library of elp_mid, the library searched, so m.leaf is bound to
// work.elp_leaf.
// %l (§33.7) prints each binding. A tool that read the empty liblist as "search
// no library", or fell back to the default liblist, would find no cell for m
// and could not elaborate the design.

module elp_leaf(output logic [7:0] y);
  assign y = 8'h3c;

  function automatic string binding();
    return $sformatf("%l");
  endfunction
endmodule

module elp_mid(output logic [7:0] y);
  elp_leaf leaf(y);

  function automatic string binding();
    return $sformatf("%l");
  endfunction
endmodule

module test_config_empty_liblist_parent_library;
  logic [7:0] y;

  elp_mid m(y);

  initial begin
    #1;
    $display("m: %s", m.binding());
    $display("m.leaf: %s", m.leaf.binding());
    $display("y=%h", y);
  end
endmodule

config elp_cfg;
  design work.test_config_empty_liblist_parent_library;
  default liblist elp_none;
  instance test_config_empty_liblist_parent_library.m liblist ;
endconfig
