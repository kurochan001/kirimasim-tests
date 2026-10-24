/*
:name: test_vpi_compare_objects_current_object
:description: vpi_compare_objects gives 1 for two handles to selects with variable indices only while they name the same existing array element, and 0 when the indices differ or name no element, even for a handle compared with itself (IEEE 1800-2023 Section 38.3)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.3 37.2.3 38.19 7.4.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_compare_objects_current_object.c
:expected_stdout: @test_vpi_compare_objects_current_object.expected
*/
// IEEE 1800-2023 §38.3, §37.2.3: vpi_compare_objects returns 1 when its two
// handles refer to the same simulation object at the time of the call and
// that object exists, and 0 otherwise; comparing the handles with == does not
// decide it. The arguments mem[j] and mem[k] of $vt_compare are two distinct
// select expressions, and each names the element that its index selects when
// the call is made. With j = k = 9 neither names an element, since mem has
// the indices 0 to 3 (7.4.6). The application compares the two arguments with
// each other, the first with itself, and the first with mem[0] obtained with
// vpi_handle_by_index (38.19).
// Icarus Verilog 13.0 gives 1 only for a handle compared with itself, also
// for mem[9], and 0 for all the other comparisons.

module test_vpi_compare_objects_current_object;
  logic [7:0] mem [0:3];
  int j, k;

  initial begin
    j = 0;
    k = 0;
    $vt_compare(mem[j], mem[k]);
    k = 1;
    $vt_compare(mem[j], mem[k]);
    j = 1;
    $vt_compare(mem[j], mem[k]);
    j = 9;
    k = 9;
    $vt_compare(mem[j], mem[k]);
  end
endmodule
