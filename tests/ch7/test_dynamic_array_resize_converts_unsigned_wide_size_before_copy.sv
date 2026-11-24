/*
:name: test_dynamic_array_resize_converts_unsigned_wide_size_before_copy
:description: Resize with self-copy converts an unsigned wide operand to longint before truncating, padding, or emptying the array
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.5.1 6.11.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_dynamic_array_resize_converts_unsigned_wide_size_before_copy.expected
*/
module test_dynamic_array_resize_converts_unsigned_wide_size_before_copy;
  int data[], cast_control[];

  function automatic string contents(input int values[]);
    string text = "";
    foreach (values[i]) text = {text, $sformatf(" %0d", values[i])};
    return text;
  endfunction

  task automatic resize(input bit [31:0] upper, input bit [2:0] low);
    bit [95:0] requested;
    requested = {upper, 61'd0, low};
    data = new[requested](data);
    cast_control = new[longint'(requested)](cast_control);
    $display("low=%0d implicit=%0d:%s explicit=%0d:%s",
             low, data.size(), contents(data), cast_control.size(), contents(cast_control));
  endtask

  initial begin
    data = new[2];
    data[0] = 31;
    data[1] = 47;
    cast_control = data;
    resize(32'h1, 4);
    resize(32'hfedc_ba98, 1);
    resize(32'h8000_0000, 0);
    resize(32'h8000_0001, 2);
  end
endmodule
