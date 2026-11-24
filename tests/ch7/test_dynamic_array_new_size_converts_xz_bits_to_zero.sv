/*
:name: test_dynamic_array_new_size_converts_xz_bits_to_zero
:description: The two-state longint extent of a dynamic array converts X and Z bits to zero, including in the sign position
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.5.1 6.11.2
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_dynamic_array_new_size_converts_xz_bits_to_zero.expected
*/
module test_dynamic_array_new_size_converts_xz_bits_to_zero;
  bit data[], cast_control[];

  task automatic allocate(input logic high, sign_bit, input logic [3:0] low);
    logic signed [64:0] requested;
    requested = {high, sign_bit, 59'd0, low};
    data = new[requested];
    cast_control = new[longint'(requested)];
    $display("prefix=%b%b low=%b size=%0d control=%0d",
             high, sign_bit, low, data.size(), cast_control.size());
  endtask

  initial begin
    allocate(1'bx, 1'bz, 4'b01xz);
    allocate(1'bz, 1'bx, 4'bz0x1);
    allocate(1'bx, 1'bz, 4'bxzxz);
  end
endmodule
