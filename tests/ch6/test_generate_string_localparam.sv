/*
:name: test_generate_string_localparam
:description: Test: Generate block string localparam access
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.4 27.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_string_localparam.expected
*/
// Test: Generate block string localparam access
// IEEE 1800-2023 §27.5, §6.20.4
// Verifies that string localparams in generate blocks can be accessed

module test_generate_string_localparam;
    parameter int MODE = 0;

    generate
        case (MODE)
            0: begin : mode_zero
                localparam string NAME = "ZERO";
                initial begin
                    $display("MODE 0: NAME = %s", NAME);
                    if (NAME != "ZERO") begin
                        $display("FAIL: Expected NAME='ZERO', got '%s'", NAME);
                        $finish(1);
                    end
                end
            end
            1: begin : mode_one
                localparam string NAME = "ONE";
                initial begin
                    $display("MODE 1: NAME = %s", NAME);
                    if (NAME != "ONE") begin
                        $display("FAIL: Expected NAME='ONE', got '%s'", NAME);
                        $finish(1);
                    end
                end
            end
            default: begin : mode_default
                localparam string NAME = "DEFAULT";
                initial begin
                    $display("DEFAULT MODE: NAME = %s", NAME);
                    if (NAME != "DEFAULT") begin
                        $display("FAIL: Expected NAME='DEFAULT', got '%s'", NAME);
                        $finish(1);
                    end
                end
            end
        endcase
    endgenerate

    initial begin
        #1;
        $display("PASS: Generate string localparam test passed");
        $finish(0);
    end
endmodule
