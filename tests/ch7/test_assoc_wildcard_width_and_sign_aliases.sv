/*
:name: test_assoc_wildcard_width_and_sign_aliases
:description: Wildcard keys normalize leading zeros and preserve arbitrary-width unsigned values (IEEE 1800-2023 Section 7.8.1)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8.1 7.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_assoc_wildcard_width_and_sign_aliases.expected
*/
// Do not traverse wildcard keys. Preserve bits above 64, and distinguish
// an 8-bit signed -1 treated as unsigned 255 from 32-bit all ones.

module test_assoc_wildcard_width_and_sign_aliases;
  int a[*];
  bit [127:0] wide = 128'h00010000000000000000000000000001;
  initial begin
    a[8'h01] = 10; a[64'h01] = 20; a[128'h01] = 30;
    a[wide] = 44; a[wide + 128'd1] = 55;
    a[8'shff] = 66;
    $display("narrow signed key: num=%0d ff=%0d all32=%0d",
             a.num(), a[8'hff], a.exists(32'hffffffff));
    a[32'hff] = 77; a[32'shffffffff] = 88;
    $display("num=%0d one=%0d wide=%0d neighbor=%0d", a.num(),
             a[8'h01], a[wide], a[wide + 128'd1]);
    $display("unsigned self width: ff8=%0d ff32=%0d all32=%0d",
             a[8'hff], a[32'hff], a[32'hffffffff]);
  end
endmodule
