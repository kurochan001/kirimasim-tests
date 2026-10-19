/*
:name: test_vpi_instance_arrays
:description: an array of module instances and an array of gate instances are instance array objects with a name, size and range; vpi_handle_by_index gives an element, the module array iterates its modules and the gate array its primitives (IEEE 1800-2023 Section 37.11)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.11 38.19 23.3.3.5 28.3.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_instance_arrays.c
:expected_stdout: @test_vpi_instance_arrays.expected
*/
// IEEE 1800-2023 §37.11: an array of instances (§23.3.3.5, §28.3.6) is an
// instance array object: a module array or, for gates, a gate array. It has
// vpiName, vpiFullName and vpiSize, vpiLeftRange and vpiRightRange give the
// bounds of its range, vpi_iterate(vpiRange, array) its ranges (detail 2),
// and vpi_handle_by_index (§38.19) an element; a module array iterates its
// modules with vpiModule and a primitive array its primitives with
// vpiPrimitive.

module leaf(input a, output y);
  assign y = a;
endmodule

module test_vpi_instance_arrays;
  wire [3:0] in = 4'b1010, out;
  wire [1:0] gy;

  leaf u [3:0] (.a(in), .y(out));
  and g [0:1] (gy, in[1:0], in[3:2]);

  initial #1 $vt_arrays;
endmodule
