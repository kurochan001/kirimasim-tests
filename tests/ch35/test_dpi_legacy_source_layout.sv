/*
:name: test_dpi_legacy_source_layout
:description: Deprecated DPI passes opaque packed values through a header independent application
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.4 H.14.3
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:dpi_c: @test_dpi_legacy_source_layout.c
:files: legacy_source_layout/words/svdpi_src.h legacy_source_layout/bytes/svdpi_src.h legacy_source_layout/host.c
:expected_stdout: @test_dpi_legacy_source_layout.expected
*/
module test_dpi_legacy_source_layout;
  import "DPI" function void legacy_layout_transfer(input bit [64:0] sent_bits,
                                                     input logic [64:0] sent_logic,
                                                     output bit [64:0] received_bits,
                                                     output logic [64:0] received_logic);

  bit [64:0] sent_bits, received_bits;
  logic [64:0] sent_logic, received_logic;

  task automatic observe(input int pass_number);
    legacy_layout_transfer(sent_bits, sent_logic, received_bits, received_logic);
    $display("pass=%0d bit=%0d logic=%0d", pass_number,
             received_bits == sent_bits, received_logic === sent_logic);
  endtask

  initial begin
    sent_bits = 65'h1_23456789_abcdef00;
    sent_logic = 65'h1_fedcba98_765x3z10;
    observe(1);
    sent_bits = 65'h0_84091280_0192e43f;
    sent_logic = 65'h0_0033x23f_90z78x34;
    observe(2);
    $finish(0);
  end
endmodule
