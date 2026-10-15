/*
:name: test_x_propagation_child
:description: Test X value propagation through child module
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_x_propagation_child.expected
*/
// Test X value propagation through child module
module child(
    input wire [7:0] data_in,
    output reg [7:0] data_out
);
    initial begin
        #1;  // Wait for data_in to be set
        data_out = data_in;
    end
endmodule

module test_x_propagation_child;
    wire [7:0] data_out;
    wire [7:0] explicit_x_out;

    // Instantiate child with unconnected data_in
    child c1(.data_in(), .data_out(data_out));
    child c2(.data_in(8'hxx), .data_out(explicit_x_out));

    initial begin
        #2;  // Wait for child to process
        // The two child instances run at the same time, in no defined order
        // (4.7), so only this block prints.
        $display("[PARENT] open input:     data_out = %h", data_out);
        $display("[PARENT] explicit input: data_out = %h", explicit_x_out);

        // IEEE 1800-2023 23.3.3.3: an unconnected input wire has value 'z.
        // The second instance checks that an explicit X passes through.
        if (data_out === 8'hzz && explicit_x_out === 8'hxx) begin
            $display("TEST PASSED: open input Z and explicit X propagated through child module");
        end else begin
            $fatal(1, "TEST FAILED: open=%h (expected ZZ), explicit=%h (expected XX)",
                   data_out, explicit_x_out);
        end

        $finish;
    end
endmodule
