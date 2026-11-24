/*
:name: test_readmem_stops_at_address_outside_selected_slice_without_resuming
:description: Explicit memory addresses outside the requested ascending or descending slice terminate loading even when the file later returns to the slice
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_readmem_stops_at_address_outside_selected_slice_without_resuming.expected
:expected_stderr_regex: \A(?=[\s\S]*(?im:^[^\n]*ascending_slice\.mem[^\n]*address[^\n]*(?:out of range|outside)))(?=[\s\S]*(?im:^[^\n]*descending_slice\.mem[^\n]*address[^\n]*(?:out of range|outside)))
*/
module test_readmem_stops_at_address_outside_selected_slice_without_resuming;
  logic [7:0] ascending[0:7], descending[7:0], control[0:7], binary_control[7:0];
  integer fd;

  initial begin
    foreach (ascending[i]) ascending[i] = 8'hee;
    foreach (descending[i]) descending[i] = 8'hee;
    foreach (control[i]) control[i] = 8'hee;
    foreach (binary_control[i]) binary_control[i] = 8'hee;

    fd = $fopen("legal_slice.mem", "w");
    if (!fd) $fatal(1, "cannot create legal memory file");
    $fdisplay(fd, "@2 c2 @5 c5");
    $fclose(fd);
    $readmemh("legal_slice.mem", control, 2, 5);
    $display("legal edges=%h %h", control[2], control[5]);

    fd = $fopen("legal_binary_slice.mem", "w");
    if (!fd) $fatal(1, "cannot create legal binary memory file");
    $fdisplay(fd, "@5 10000101");
    $fdisplay(fd, "@2 10000010");
    $fclose(fd);
    $readmemb("legal_binary_slice.mem", binary_control, 5, 2);
    $display("legal binary edges=%h %h", binary_control[5], binary_control[2]);

    fd = $fopen("ascending_slice.mem", "w");
    if (!fd) $fatal(1, "cannot create ascending memory file");
    $fdisplay(fd, "@2 a1 @6 d2 @3 b3");
    $fclose(fd);
    $readmemh("ascending_slice.mem", ascending, 2, 5);
    $display("ascending before=%h following=%h excluded=%h",
             ascending[2], ascending[3], ascending[6]);

    fd = $fopen("descending_slice.mem", "w");
    if (!fd) $fatal(1, "cannot create descending memory file");
    $fdisplay(fd, "@5 10100101 @1 11010010 @4 10110011");
    $fclose(fd);
    $readmemb("descending_slice.mem", descending, 5, 2);
    $display("descending before=%h following=%h excluded=%h",
             descending[5], descending[4], descending[1]);
  end
endmodule
