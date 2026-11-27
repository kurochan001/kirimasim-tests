/*
:name: test_vpi_class_reclaim_lifetimes
:description: Class reclaim callbacks select a type or instance and retire handles after delivery
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.1 37.2.2 37.3.7 37.3.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @vpi_class_reclaim/native.c
:expected_stdout: @test_vpi_class_reclaim_lifetimes.expected
:files: vpi_class_reclaim/client.h vpi_class_reclaim/driver.cpp vpi_class_reclaim/reference.expected vpi_class_reclaim/held.expected
*/
`timescale 1ns/1ps

class reclaim_record;
  int serial;
  int values[2];

  function new(int serial);
    this.serial = serial;
    values[1] = serial + 3;
  endfunction

  function int read_slot();
    return values[1];
  endfunction
endclass

class reclaim_peer;
  int serial;

  function new(int serial);
    this.serial = serial;
  endfunction
endclass

module test_vpi_class_reclaim_lifetimes;
  reclaim_record first /* verilator public_flat_rw */;
  reclaim_record second /* verilator public_flat_rw */;
  reclaim_peer other /* verilator public_flat_rw */;

  initial begin
`ifndef REFERENCE_RECLAIM
    $vt_reclaim_setup;
`endif
    first = new(29);
    second = new(47);
    other = new(63);
    $display("live slots=%0d,%0d other=%0d", first.read_slot(), second.read_slot(), other.serial);
    #1 first = null;
    #1 other = null;
    #1 second = null;
    #1;
`ifndef REFERENCE_RECLAIM
    $vt_reclaim_report;
`endif
    $finish(0);
  end
endmodule
