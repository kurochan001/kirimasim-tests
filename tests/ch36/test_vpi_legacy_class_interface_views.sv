/*
:name: test_vpi_legacy_class_interface_views
:description: Class definition and typespec views of two virtual interface members
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.12.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_vpi_legacy_class_interface_views
:vpi_c: @test_vpi_legacy_class_interface_views.c
:expected_stdout: @test_vpi_legacy_class_interface_views.expected
*/
`timescale 1ns/1ns

module legacy_plain_vpi_scope;
  reg marker;
  initial marker = 1'b1;
endmodule

interface legacy_view_link;
  logic flag;
endinterface

module test_vpi_legacy_class_interface_views;
  legacy_plain_vpi_scope plain();
  legacy_view_link left(), right();
  class dual_view;
    virtual legacy_view_link main_link;
    virtual legacy_view_link backup_link;
    int ordinary;
  endclass
  dual_view holder;

  initial begin
    holder = new;
    holder.main_link = left;
    holder.backup_link = right;
    left.flag = 1;
    right.flag = 0;
    #1 $display("interface connections=%0b,%0b", holder.main_link.flag, holder.backup_link.flag);
    $finish;
  end
endmodule
