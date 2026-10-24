/*
:name: test_virtual_interface_type_forms
:description: A virtual interface variable type can be written with or without the keyword interface, with parameter values for the interface and with a modport, and each variable then refers to an instance of that parameterization (IEEE 1800-2023 Section 6.8)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.8 25.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_virtual_interface_type_forms.expected
*/
// IEEE 1800-2023 §6.8, Syntax 6-3: the data type of a variable can be virtual,
// an optional keyword interface, the interface name, optional parameter
// values, and an optional modport after a dot. Such a variable refers to an
// interface instance of the same parameterization (25.9).
// v_plain and v_mp refer to i4, the instance with W = 4, and v_kw and v_kw_mp
// to i8, with W = 8. The value written through the wr modport of v_mp is read
// from i4 and through v_plain; the value written through v_kw is read through
// the rd modport of v_kw_mp. $bits shows the width that W gives.

interface test_virtual_interface_type_forms_if #(parameter int W = 2);
  logic [W-1:0] data;
  modport rd (input data);
  modport wr (output data);
endinterface

module test_virtual_interface_type_forms;
  test_virtual_interface_type_forms_if #(.W(4)) i4();
  test_virtual_interface_type_forms_if #(.W(8)) i8();

  virtual test_virtual_interface_type_forms_if #(.W(4)) v_plain;
  virtual interface test_virtual_interface_type_forms_if #(.W(8)) v_kw;
  virtual test_virtual_interface_type_forms_if #(.W(4)).wr v_mp;
  virtual interface test_virtual_interface_type_forms_if #(8).rd v_kw_mp;

  initial begin
    v_plain = i4;
    v_kw = i8;
    v_mp = i4;
    v_kw_mp = i8;
    v_mp.data = 4'h9;
    v_kw.data = 8'h5a;
    #1 $display("i4.data=%h v_plain.data=%h i8.data=%h v_kw_mp.data=%h widths %0d %0d", i4.data,
                v_plain.data, i8.data, v_kw_mp.data, $bits(v_plain.data), $bits(v_kw.data));
  end
endmodule
