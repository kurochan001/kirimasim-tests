/*
:name: test_modport_access_unlisted_type_parameter_and_enum
:description: Through a port with a selected modport, a module reaches the variable the modport lists, and also a type, a localparam and an enumeration constant of the interface, which cannot be listed in a modport; an unlisted variable is reached by its hierarchical name (IEEE 1800-2023 Section 25.10)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.10 25.5 6.18
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_modport_access_unlisted_type_parameter_and_enum.expected
*/
// IEEE 1800-2023 §25.10: the objects of an interface can always be reached by
// their hierarchical names. Through a port connection or a virtual interface
// with a selected modport, the modport restricts access to the objects it
// lists, but objects that cannot be listed in a modport remain accessible.
// The modport mp of mau_bus lists only the variable Q.
// - mau_sub reaches through its port i the type choice (typedef i.choice,
//   6.18), the localparam True and the enumeration constant N, none of which
//   can be listed in a modport, and the listed variable Q.
// - It writes the unlisted variable I by its hierarchical name, not through
//   i, and Q by its hierarchical name too, with the value of True cast to the
//   enumeration type, that is N (1).
// At 1 it prints P, which follows i.Q through a continuous assignment, the
// comparison of P with i.N, i.True, the width of its own type yes_no (an
// enumeration with the base type int: 32) and I.
// Icarus Verilog 13.0 does not support interface ports, and Verilator 5.052
// does not find the enumeration constant N through the port.

`timescale 1ns/1ns

interface mau_bus;
  integer I;
  typedef enum {Y, N} choice;
  choice Q;
  localparam True = 1;
  modport mp (input Q);
endinterface

module mau_sub (mau_bus.mp i);
  typedef i.choice yes_no;
  yes_no P;
  assign P = i.Q;

  initial begin
    test_modport_access_unlisted_type_parameter_and_enum.ebus.Q = yes_no'(i.True);
    test_modport_access_unlisted_type_parameter_and_enum.ebus.I = 5;
    #1 $display("P=%0d P==N:%0d True=%0d bits=%0d I=%0d", P, P == i.N, i.True, $bits(yes_no),
                test_modport_access_unlisted_type_parameter_and_enum.ebus.I);
  end
endmodule

module test_modport_access_unlisted_type_parameter_and_enum;
  mau_bus ebus ();
  mau_sub s1 (ebus.mp);
endmodule
