/*
:name: test_config_liblist_inherited_order
:description: A liblist is searched in the order written until a library holds the cell, and the instances below the selected instance inherit that liblist instead of taking the default liblist (IEEE 1800-2023 Section 33.4.1.5)
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.4.1.5 33.4.1.2 33.4.1.3 33.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_config_liblist_inherited_order.expected
*/
// IEEE 1800-2023 §33.4.1.5: a liblist is an ordered list of libraries that is
// searched, in that order, for the cell of an instance that no use clause
// binds, and liblists are inherited downward as the instances are bound
// (§33.6.4 shows the descendants of an instance taking the liblist of its
// instance clause rather than the default one). §33.4.1.2: the default clause
// applies only to instances that no more specific clause selects. §33.3.1:
// with no library map file, every cell of this test is in the library work.
//
// The library lio_none holds no cell. The default liblist names only
// lio_none, so an instance that took it could not be bound. The instance
// clause gives m the liblist "lio_none work": lio_none has no cell lio_mid,
// so the search goes on to work and binds m to work.lio_mid. The instance
// m.leaf matches no clause of its own and inherits the liblist of m, so it is
// bound to work.lio_leaf. %l (§33.7) prints each binding. A tool that searched
// only the first library, or gave m.leaf the default liblist, would find no
// cell for the instance and could not elaborate the design.

module lio_leaf(output logic [7:0] y);
  assign y = 8'h5a;

  function automatic string binding();
    return $sformatf("%l");
  endfunction
endmodule

module lio_mid(output logic [7:0] y);
  lio_leaf leaf(y);

  function automatic string binding();
    return $sformatf("%l");
  endfunction
endmodule

module test_config_liblist_inherited_order;
  logic [7:0] y;

  lio_mid m(y);

  initial begin
    #1;
    $display("m: %s", m.binding());
    $display("m.leaf: %s", m.leaf.binding());
    $display("y=%h", y);
  end
endmodule

config lio_cfg;
  design work.test_config_liblist_inherited_order;
  default liblist lio_none;
  instance test_config_liblist_inherited_order.m liblist lio_none work;
endconfig
