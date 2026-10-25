/*
:name: test_vpi_property_kinds_access_routines
:description: Integer and Boolean properties of the diagrams are read with vpi_get as PLI_INT32, string properties with vpi_get_str as PLI_BYTE8 *, and the complex properties for a logic value and a delay with the routines the diagrams name, vpi_get_value and vpi_get_delays (IEEE 1800-2023 Section 37.4.2)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.4.2 37.16 37.17 37.39 38.6 38.10 38.11 38.15
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_property_kinds_access_routines.c
:expected_stdout: @test_vpi_property_kinds_access_routines.expected
*/
// IEEE 1800-2023 §37.4.2: the diagrams mark how each property is read. An
// integer ("int:") or Boolean ("bool:") property is read with vpi_get and is
// of type PLI_INT32 (38.6: a Boolean is 1 for TRUE and 0 for FALSE); a string
// ("str:") property is read with vpi_get_str, which returns PLI_BYTE8 *
// (38.11); a complex property of time or logic value is read with the
// routine that the diagram names.
//
// The application assigns vpi_get and vpi_get_str to pointers of those
// types, which a C++ compiler rejects when the routines have other types,
// and reads, from the variables vec (6 bits) and one (1 bit) and the net bus
// (4 bits) of 37.16 and 37.17: vpiSize (int), vpiVector and vpiScalar
// (bool), vpiName and vpiFullName (str), and the value (vpi_get_value) of
// vec, 101100, and of bus, which the continuous assignment gives the 4 low
// bits of vec, 1100. The delay of the module path a => y of the instance c
// (37.39) is read with vpi_get_delays: the path has a rise delay of 3 and a
// fall delay of 5, in the time unit of the module, 1 ns. The values are read
// at time 10.

`timescale 1ns/1ns

module test_vpi_property_kinds_access_routines_cell(input wire a, output wire y);
  buf b(y, a);

  specify
    (a => y) = (3, 5);
  endspecify
endmodule

module test_vpi_property_kinds_access_routines;
  logic [5:0] vec = 6'b101100;
  logic one = 1'b1;
  wire [3:0] bus;
  wire o;

  assign bus = vec[3:0];

  test_vpi_property_kinds_access_routines_cell c(.a(one), .y(o));

  initial #10 $vt_props;
endmodule
