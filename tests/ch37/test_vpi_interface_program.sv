/*
:name: test_vpi_interface_program
:description: a module gives its interface instances; an interface gives its modports, each with its io declarations, and its interface task and function declarations with their access type and task or function; a program instance is a vpiProgram with its processes (IEEE 1800-2023 Sections 37.6, 37.7, 37.8, 37.9)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.6 37.7 37.8 37.9 25.5 25.7.4 24.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_interface_program.c
:expected_stdout: @test_vpi_interface_program.expected
*/
// IEEE 1800-2023 §37.6: a module iterates its interface instances with
// vpiInterface, and an interface its modports with vpiModport (§37.7, §25.5)
// and its interface task and function declarations with vpiInterfaceTfDecl;
// a modport iterates its io declarations with vpiIODecl. §37.8: vpiAccessType
// is vpiForkJoinAcc for an extern forkjoin task and vpiExternAcc for an
// extern function (§25.7.4), and the declaration gives the task or function.
// §37.9: a program instance (§24.3) has vpiType vpiProgram and iterates its
// processes with vpiProcess. Lists, and the io declarations of a modport,
// are sorted.

`timescale 1ns/1ns

interface bus_if;
  logic req = 0, gnt = 0;
  extern forkjoin task ping();
  extern function int peek(input int i);
  modport host(output req, input gnt, import task ping(), import function int peek(input int i));
  modport dev(input req, output gnt, export ping, export peek);
endinterface

module dev_m(bus_if.dev d);
  task d.ping();
  endtask
  function int d.peek(input int i);
    return i;
  endfunction
endmodule

program prog_p;
  initial #5;
  initial #6;
endprogram

module test_vpi_interface_program;
  bus_if bus();
  dev_m d(bus.dev);
  prog_p p();

  initial #1 $vt_instances;
endmodule
