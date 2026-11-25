/*
:name: test_dpi_unpacked_struct_native_layout
:description: The native C compiler lays out the unpacked struct while packed values use canonical words
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6 H.7.3 H.7.8
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:dpi_c: @test_dpi_unpacked_struct_native_layout.c
:expected_stdout: @test_dpi_unpacked_struct_native_layout.expected
*/
module test_dpi_unpacked_struct_native_layout;
  typedef struct {
    byte marker;
    longint serial;
    shortint short_field;
    real ratio;
    int last;
  } native_t;
  typedef struct packed {
    logic [1:0] tag;
    logic [31:0] data;
  } packet_t;
  typedef logic [1:0][16:0] grid_t;

  import "DPI-C" function void native_transfer(input native_t src, output native_t dst);
  import "DPI-C" function void packet_transfer(input packet_t src, output packet_t dst);
  import "DPI-C" function void grid_transfer(input grid_t src, output grid_t dst);

  native_t unpacked_input, unpacked_output;
  packet_t packet_input, packet_output;
  grid_t grid_input, grid_output;

  initial begin
    unpacked_input = '{9, -64'sd6000000003, -16'sd1234, 3.25, -314159};
    native_transfer(unpacked_input, unpacked_output);
    $display("native reply=%0d",
             unpacked_output.marker == 13 && unpacked_output.serial == 64'sd6000000003 &&
             unpacked_output.short_field == -16'sd1231 && unpacked_output.ratio == 6.50 &&
             unpacked_output.last == -314166);

    packet_input = {2'bxz, 32'h02x3_456z};
    grid_input = {2'bxz, 32'h02x3_456z};
    packet_transfer(packet_input, packet_output);
    grid_transfer(grid_input, grid_output);
    $display("canonical reply packet=%0d grid=%0d",
             packet_output === {2'bzx, 32'h02x3_457z}, grid_output === {2'bzx, 32'h02x3_457z});
  end
endmodule
