/*
:name: test_sdf_scale_type_members
:description: The scale_type argument of $sdf_annotate chooses which member of a min:typ:max triple the scale factors are applied to, FROM_MTM (the default) scaling each member by its own factor, and $sdf_annotate takes all seven of its arguments (IEEE 1800-2023 Section 32.9)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.9 32.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_scale_type_members.expected
*/
// IEEE 1800-2023 §32.9: $sdf_annotate takes the SDF file name and then, each
// optional, the module_instance, config_file, log_file, mtm_spec,
// scale_factors and scale_type arguments, and annotates only the region of
// the design under module_instance (32.6). scale_factors gives one factor
// for the minimum, typical and maximum values, 1.0:1.0:1.0 when it is left
// out. scale_type (Table 32-6) says which values the factors are applied to:
// FROM_MTM, the default, multiplies the minimum, typical and maximum value
// each by its own factor; FROM_MINIMUM, FROM_TYPICAL and FROM_MAXIMUM apply
// the three factors to the minimum, the typical or the maximum value alone,
// so that the scaled triple is made from that one member. mtm_spec (Table
// 32-5) then chooses the member that is annotated.
//
// The SDF file gives the path a => y of the cell the triple (2:3:5), and every
// call but the last uses the factors 2.0:3.0:4.0 and annotates its own
// wrapper. With the default scale_type and with FROM_MTM, MINIMUM, TYPICAL
// and MAXIMUM give 2*2, 3*3 and 5*4; with FROM_MINIMUM they give 2*2, 2*3 and
// 2*4; with FROM_TYPICAL 3*2, 3*3 and 3*4; with FROM_MAXIMUM 5*2, 5*3 and
// 5*4. The call for w13 gives all seven arguments, with an empty config file
// and a log file; the call for w14 leaves the factors out, so MAXIMUM gives 5.
// w0 is not annotated and keeps the delay 1 of its specify block. a rises at
// 100, and the test prints for each wrapper how long its output took to
// follow. Icarus Verilog 13.0 uses only the first two arguments of
// $sdf_annotate, and Verilator 5.052 ignores $sdf_annotate and path delays.

`timescale 1ns/1ns

module sdf_st_cell(output y, input a);
  buf (y, a);
  specify
    (a => y) = 1;
  endspecify
endmodule

module sdf_st_wrap(output y, input a);
  sdf_st_cell c(y, a);
endmodule

module test_sdf_scale_type_members;
  reg a;
  wire [14:0] y;
  time t[15];
  integer f;

  sdf_st_wrap w0(y[0], a);
  sdf_st_wrap w1(y[1], a);
  sdf_st_wrap w2(y[2], a);
  sdf_st_wrap w3(y[3], a);
  sdf_st_wrap w4(y[4], a);
  sdf_st_wrap w5(y[5], a);
  sdf_st_wrap w6(y[6], a);
  sdf_st_wrap w7(y[7], a);
  sdf_st_wrap w8(y[8], a);
  sdf_st_wrap w9(y[9], a);
  sdf_st_wrap w10(y[10], a);
  sdf_st_wrap w11(y[11], a);
  sdf_st_wrap w12(y[12], a);
  sdf_st_wrap w13(y[13], a);
  sdf_st_wrap w14(y[14], a);

  for (genvar i = 0; i < 15; i++) begin : g
    always @(posedge y[i]) t[i] = $time;
  end

  initial begin
    a = 0;
    f = $fopen("test_sdf_scale_type_members.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_st_cell\") (INSTANCE c)");
    $fdisplay(f, "    (DELAY (ABSOLUTE");
    $fdisplay(f, "      (IOPATH a y (2:3:5))))))");
    $fclose(f);
    f = $fopen("test_sdf_scale_type_members.cfg", "w");
    $fclose(f);
    $sdf_annotate("test_sdf_scale_type_members.sdf", w1, , , "MINIMUM", "2.0:3.0:4.0");
    $sdf_annotate("test_sdf_scale_type_members.sdf", w2, , , "TYPICAL", "2.0:3.0:4.0");
    $sdf_annotate("test_sdf_scale_type_members.sdf", w3, , , "MAXIMUM", "2.0:3.0:4.0");
    $sdf_annotate("test_sdf_scale_type_members.sdf", w4, , , "MINIMUM", "2.0:3.0:4.0",
                  "FROM_MTM");
    $sdf_annotate("test_sdf_scale_type_members.sdf", w5, , , "MINIMUM", "2.0:3.0:4.0",
                  "FROM_MINIMUM");
    $sdf_annotate("test_sdf_scale_type_members.sdf", w6, , , "TYPICAL", "2.0:3.0:4.0",
                  "FROM_MINIMUM");
    $sdf_annotate("test_sdf_scale_type_members.sdf", w7, , , "MAXIMUM", "2.0:3.0:4.0",
                  "FROM_MINIMUM");
    $sdf_annotate("test_sdf_scale_type_members.sdf", w8, , , "MINIMUM", "2.0:3.0:4.0",
                  "FROM_TYPICAL");
    $sdf_annotate("test_sdf_scale_type_members.sdf", w9, , , "TYPICAL", "2.0:3.0:4.0",
                  "FROM_TYPICAL");
    $sdf_annotate("test_sdf_scale_type_members.sdf", w10, , , "MAXIMUM", "2.0:3.0:4.0",
                  "FROM_TYPICAL");
    $sdf_annotate("test_sdf_scale_type_members.sdf", w11, , , "MINIMUM", "2.0:3.0:4.0",
                  "FROM_MAXIMUM");
    $sdf_annotate("test_sdf_scale_type_members.sdf", w12, , , "TYPICAL", "2.0:3.0:4.0",
                  "FROM_MAXIMUM");
    $sdf_annotate("test_sdf_scale_type_members.sdf", w13, "test_sdf_scale_type_members.cfg",
                  "test_sdf_scale_type_members.log", "MAXIMUM", "2.0:3.0:4.0", "FROM_MAXIMUM");
    $sdf_annotate("test_sdf_scale_type_members.sdf", w14, , , "MAXIMUM");
    #100 a = 1;
    #50;
    $display("w0, not annotated: %0d", t[0] - 100);
    $display("w1, MINIMUM, default scale_type: %0d", t[1] - 100);
    $display("w2, TYPICAL, default scale_type: %0d", t[2] - 100);
    $display("w3, MAXIMUM, default scale_type: %0d", t[3] - 100);
    $display("w4, MINIMUM, FROM_MTM: %0d", t[4] - 100);
    $display("w5, MINIMUM, FROM_MINIMUM: %0d", t[5] - 100);
    $display("w6, TYPICAL, FROM_MINIMUM: %0d", t[6] - 100);
    $display("w7, MAXIMUM, FROM_MINIMUM: %0d", t[7] - 100);
    $display("w8, MINIMUM, FROM_TYPICAL: %0d", t[8] - 100);
    $display("w9, TYPICAL, FROM_TYPICAL: %0d", t[9] - 100);
    $display("w10, MAXIMUM, FROM_TYPICAL: %0d", t[10] - 100);
    $display("w11, MINIMUM, FROM_MAXIMUM: %0d", t[11] - 100);
    $display("w12, TYPICAL, FROM_MAXIMUM: %0d", t[12] - 100);
    $display("w13, MAXIMUM, FROM_MAXIMUM, all arguments: %0d", t[13] - 100);
    $display("w14, MAXIMUM, default factors: %0d", t[14] - 100);
    $finish;
  end
endmodule
