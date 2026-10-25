/*
:name: test_sscanf_m_hierarchical_path
:description: %m in the format of $sscanf stores the hierarchical path of the calling module instance as a string and reads nothing from the input, so the conversion after it still reads the next field (IEEE 1800-2023 Section 21.3.4.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sscanf_m_hierarchical_path.expected
*/
// IEEE 1800-2023 §21.3.4.3, Table 21-7: %m returns the current hierarchical
// path as a string and does not read data from the input. The top-level
// module and its instance u1 of sub call $sscanf with "%m%d", and u1 also
// with "%d %m%s" on "43 x"; the paths are those of the top-level module and
// of its instance, the numbers are read whole and %s still reads the x after
// %m. The values are printed from the top-level module at time 1.

module sub;
  string path_first, path_last, w_last;
  int v_first, v_last;

  initial begin
    void'($sscanf("42", "%m%d", path_first, v_first));
    void'($sscanf("43 x", "%d %m%s", v_last, path_last, w_last));
  end
endmodule

module test_sscanf_m_hierarchical_path;
  string path;
  int v;

  sub u1();

  initial begin
    void'($sscanf("41", "%m%d", path, v));
    #1;
    $display("top: %s v=%0d", path, v);
    $display("u1 first: %s v=%0d", u1.path_first, u1.v_first);
    $display("u1 middle: %s v=%0d w=%s", u1.path_last, u1.v_last, u1.w_last);
  end
endmodule
