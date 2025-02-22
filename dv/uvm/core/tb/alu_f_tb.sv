
module alu_f_tb ();

    parameter FLEN = 32; // Floating-point length (32 bits for single-precision)

    logic [31:0]          alu_f_insn_i = 0;
    logic [FLEN-1:0]      alu_f_addr_i = 0;
    logic [FLEN-1:0]      alu_f_rdata1_i = 0;
    logic [FLEN-1:0]      alu_f_rdata2_i = 0;
    logic [FLEN-1:0]      alu_f_wdata_o;
    logic [4:0]           fflags; // Flags for FP control status reg

    // Instantiate the floating-point ALU
    rv0_alu_f alu_f (
        .alu_f_insn_i(alu_f_insn_i),
        .alu_f_addr_i(alu_f_addr_i),
        .alu_f_rdata1_i(alu_f_rdata1_i),
        .alu_f_rdata2_i(alu_f_rdata2_i),
        .alu_f_wdata_o(alu_f_wdata_o),
        .fflags(fflags)
    );

    initial begin
        // Test FADD.S (Floating-point Addition)
        $display("Testing FADD.S...");
        alu_f_insn_i = {7'b0000000, 5'b00001, 5'b00010, 3'b000, 5'b00011, 7'b1010011}; // FADD.S f3, f1, f2
        alu_f_rdata1_i = 32'h3F800000; // 1.0
        alu_f_rdata2_i = 32'h3F800000; // 1.0
        #10;
        $display("FADD.S: 1.0 + 1.0 = %h, fflags = %b", alu_f_wdata_o, fflags);

        alu_f_rdata1_i = 32'h3F000000; // 0.5
        alu_f_rdata2_i = 32'h3E800000; // 0.25
        #10;
        $display("FADD.S: 0.5 + 0.25 = %h, fflags = %b", alu_f_wdata_o, fflags);

        // Test FSUB.S (Floating-point Subtraction)
        $display("Testing FSUB.S...");
        alu_f_insn_i = {7'b0000100, 5'b00001, 5'b00010, 3'b000, 5'b00100, 7'b1010011}; // FSUB.S f4, f1, f2
        alu_f_rdata1_i = 32'h3F800000; // 1.0
        alu_f_rdata2_i = 32'h3F000000; // 0.5
        #10;
        $display("FSUB.S: 1.0 - 0.5 = %h, fflags = %b", alu_f_wdata_o, fflags);

        alu_f_rdata1_i = 32'h3E800000; // 0.25
        alu_f_rdata2_i = 32'h3E000000; // 0.125
        #10;
        $display("FSUB.S: 0.25 - 0.125 = %h, fflags = %b", alu_f_wdata_o, fflags);

        // Test FMIN.S (Floating-point Minimum)
        $display("Testing FMIN.S...");
        alu_f_insn_i = {7'b0010100, 5'b00001, 5'b00010, 3'b000, 5'b00101, 7'b1010011}; // FMIN.S f5, f1, f2
        alu_f_rdata1_i = 32'h3F800000; // 1.0
        alu_f_rdata2_i = 32'h40000000; // 2.0
        #10;
        $display("FMIN.S: min(1.0, 2.0) = %h, fflags = %b", alu_f_wdata_o, fflags);

        alu_f_rdata1_i = 32'hBF400000; // -0.75
        alu_f_rdata2_i = 32'h3F800000; // 1.0
        #10;
        $display("FMIN.S: min(-0.75, 1.0) = %h, fflags = %b", alu_f_wdata_o, fflags);

        // Test FMAX.S (Floating-point Maximum)
        $display("Testing FMAX.S...");
        alu_f_insn_i = {7'b0010100, 5'b00001, 5'b00010, 3'b001, 5'b00110, 7'b1010011}; // FMAX.S f6, f1, f2
        alu_f_rdata1_i = 32'h3F800000; // 1.0
        alu_f_rdata2_i = 32'h40000000; // 2.0
        #10;
        $display("FMAX.S: max(1.0, 2.0) = %h, fflags = %b", alu_f_wdata_o, fflags);

        alu_f_rdata1_i = 32'hBF400000; // -0.75
        alu_f_rdata2_i = 32'h3F800000; // 1.0
        #10;
        $display("FMAX.S: max(-0.75, 1.0) = %h, fflags = %b", alu_f_wdata_o, fflags);

        // Test with special cases (NaN, zero, denormalized numbers)
        $display("Testing special cases...");

        // Test with zero
        alu_f_insn_i = {7'b0000000, 5'b00001, 5'b00010, 3'b000, 5'b00011, 7'b1010011}; // FADD.S f3, f1, f2
        alu_f_rdata1_i = 32'h00000000; // 0.0
        alu_f_rdata2_i = 32'h3F800000; // 1.0
        #10;
        $display("FADD.S: 0.0 + 1.0 = %h, fflags = %b", alu_f_wdata_o, fflags);

        // Test with NaN
        alu_f_insn_i = {7'b0000000, 5'b00001, 5'b00010, 3'b000, 5'b00011, 7'b1010011}; // FADD.S f3, f1, f2
        alu_f_rdata1_i = 32'h7FC00000; // NaN
        alu_f_rdata2_i = 32'h3F800000; // 1.0
        #10;
        $display("FADD.S: NaN + 1.0 = %h, fflags = %b", alu_f_wdata_o, fflags);

        // Test with denormalized number
        alu_f_insn_i = {7'b0000000, 5'b00001, 5'b00010, 3'b000, 5'b00011, 7'b1010011}; // FADD.S f3, f1, f2
        alu_f_rdata1_i = 32'h00000001; // Smallest denormalized number
        alu_f_rdata2_i = 32'h00000001; // Smallest denormalized number
        #10;
        $display("FADD.S: denorm + denorm = %h, fflags = %b", alu_f_wdata_o, fflags);

        // Test FADD.S with positive and negative numbers
        $display("Testing FADD.S with positive and negative numbers...");
        alu_f_insn_i = {7'b0000000, 5'b00001, 5'b00010, 3'b000, 5'b00011, 7'b1010011}; // FADD.S f3, f1, f2
        alu_f_rdata1_i = 32'h40000000; // 2.0
        alu_f_rdata2_i = 32'hC0000000; // -2.0
        #10;
        $display("FADD.S: 2.0 + (-2.0) = %h, fflags = %b", alu_f_wdata_o, fflags);

        // Test FADD.S with large numbers
        alu_f_rdata1_i = 32'h4F000000; // 2.0 * 2^30 (large number)
        alu_f_rdata2_i = 32'h4F000000; // 2.0 * 2^30 (large number)
        #10;
        $display("FADD.S: 2.0 * 2^30 + 2.0 * 2^30 = %h, fflags = %b", alu_f_wdata_o, fflags);

        // Test FADD.S with infinity
        alu_f_rdata1_i = 32'h7F800000; // +Infinity
        alu_f_rdata2_i = 32'h3F800000; // 1.0
        #10;
        $display("FADD.S: +Infinity + 1.0 = %h, fflags = %b", alu_f_wdata_o, fflags);

        // Test FADD.S with NaN and a normal number
        alu_f_rdata1_i = 32'h7FC00000; // NaN
        alu_f_rdata2_i = 32'h3F800000; // 1.0
        #10;
        $display("FADD.S: NaN + 1.0 = %h, fflags = %b", alu_f_wdata_o, fflags);

        // Test FADD.S with two NaNs
        alu_f_rdata1_i = 32'h7FC00000; // NaN
        alu_f_rdata2_i = 32'h7FC00000; // NaN
        #10;
        $display("FADD.S: NaN + NaN = %h, fflags = %b", alu_f_wdata_o, fflags);

        // Test FSUB.S with positive and negative numbers
        $display("Testing FSUB.S with positive and negative numbers...");
        alu_f_insn_i = {7'b0000100, 5'b00001, 5'b00010, 3'b000, 5'b00100, 7'b1010011}; // FSUB.S f4, f1, f2
        alu_f_rdata1_i = 32'h40000000; // 2.0
        alu_f_rdata2_i = 32'hC0000000; // -2.0
        #10;
        $display("FSUB.S: 2.0 - (-2.0) = %h, fflags = %b", alu_f_wdata_o, fflags);

        // Test FSUB.S with large numbers
        alu_f_rdata1_i = 32'h4F000000; // 2.0 * 2^30 (large number)
        alu_f_rdata2_i = 32'h4F000000; // 2.0 * 2^30 (large number)
        #10;
        $display("FSUB.S: 2.0 * 2^30 - 2.0 * 2^30 = %h, fflags = %b", alu_f_wdata_o, fflags);

        // Test FSUB.S with infinity
        alu_f_rdata1_i = 32'h7F800000; // +Infinity
        alu_f_rdata2_i = 32'h3F800000; // 1.0
        #10;
        $display("FSUB.S: +Infinity - 1.0 = %h, fflags = %b", alu_f_wdata_o, fflags);

        // Test FSUB.S with NaN and a normal number
        alu_f_rdata1_i = 32'h7FC00000; // NaN
        alu_f_rdata2_i = 32'h3F800000; // 1.0
        #10;
        $display("FSUB.S: NaN - 1.0 = %h, fflags = %b", alu_f_wdata_o, fflags);

        // Test FSUB.S with two NaNs
        alu_f_rdata1_i = 32'h7FC00000; // NaN
        alu_f_rdata2_i = 32'h7FC00000; // NaN
        #10;
        $display("FSUB.S: NaN - NaN = %h, fflags = %b", alu_f_wdata_o, fflags);

        // Test FMUL.S with positive numbers
        $display("Testing FMUL.S with positive numbers...");
        alu_f_insn_i = {7'b0001000, 5'b00001, 5'b00010, 3'b000, 5'b00011, 7'b1010011}; // FMUL.S f3, f1, f2
        alu_f_rdata1_i = 32'h3F800000; // 1.0
        alu_f_rdata2_i = 32'h40000000; // 2.0
        #10;
        $display("FMUL.S: 1.0 * 2.0 = %h, fflags = %b", alu_f_wdata_o, fflags);

        // Test FMUL.S with positive and negative numbers
        alu_f_rdata1_i = 32'h3F800000; // 1.0
        alu_f_rdata2_i = 32'hBF800000; // -1.0
        #10;
        $display("FMUL.S: 1.0 * (-1.0) = %h, fflags = %b", alu_f_wdata_o, fflags);

        // Test FMUL.S with small numbers
        alu_f_rdata1_i = 32'h3E800000; // 0.25
        alu_f_rdata2_i = 32'h3E800000; // 0.25
        #10;
        $display("FMUL.S: 0.25 * 0.25 = %h, fflags = %b", alu_f_wdata_o, fflags);

        // Test FMUL.S with large numbers
        alu_f_rdata1_i = 32'h4F000000; // 2.0 * 2^30 (large number)
        alu_f_rdata2_i = 32'h4F000000; // 2.0 * 2^30 (large number)
        #10;
        $display("FMUL.S: 2.0 * 2^30 * 2.0 * 2^30 = %h, fflags = %b", alu_f_wdata_o, fflags);

        // Test FMUL.S with zero
        alu_f_rdata1_i = 32'h00000000; // 0.0
        alu_f_rdata2_i = 32'h3F800000; // 1.0
        #10;
        $display("FMUL.S: 0.0 * 1.0 = %h, fflags = %b", alu_f_wdata_o, fflags);

        // Test FMUL.S with infinity
        alu_f_rdata1_i = 32'h7F800000; // +Infinity
        alu_f_rdata2_i = 32'h3F800000; // 1.0
        #10;
        $display("FMUL.S: +Infinity * 1.0 = %h, fflags = %b", alu_f_wdata_o, fflags);

        // Test FMUL.S with NaN and a normal number
        alu_f_rdata1_i = 32'h7FC00000; // NaN
        alu_f_rdata2_i = 32'h3F800000; // 1.0
        #10;
        $display("FMUL.S: NaN * 1.0 = %h, fflags = %b", alu_f_wdata_o, fflags);

        // Test FMUL.S with two NaNs
        alu_f_rdata1_i = 32'h7FC00000; // NaN
        alu_f_rdata2_i = 32'h7FC00000; // NaN
        #10;
        $display("FMUL.S: NaN * NaN = %h, fflags = %b", alu_f_wdata_o, fflags);

        // Test FMUL.S with denormalized numbers
        alu_f_rdata1_i = 32'h00000001; // Smallest denormalized number
        alu_f_rdata2_i = 32'h00000001; // Smallest denormalized number
        #10;
        $display("FMUL.S: denorm * denorm = %h, fflags = %b", alu_f_wdata_o, fflags);

        // Test FMUL.S with positive numbers
        $display("Testing FMUL.S with positive numbers...");
        alu_f_insn_i = {7'b0001000, 5'b00001, 5'b00010, 3'b000, 5'b00011, 7'b1010011}; // FMUL.S f3, f1, f2
        alu_f_rdata1_i = 32'h3F800000; // 1.0
        alu_f_rdata2_i = 32'h40000000; // 2.0
        #10;
        $display("FMUL.S: 1.0 * 2.0 = %h, fflags = %b", alu_f_wdata_o, fflags);

        // Test FMUL.S with positive and negative numbers
        alu_f_rdata1_i = 32'h3F800000; // 1.0
        alu_f_rdata2_i = 32'hBF800000; // -1.0
        #10;
        $display("FMUL.S: 1.0 * (-1.0) = %h, fflags = %b", alu_f_wdata_o, fflags);

        // Test FMUL.S with small numbers
        alu_f_rdata1_i = 32'h3E800000; // 0.25
        alu_f_rdata2_i = 32'h3E800000; // 0.25
        #10;
        $display("FMUL.S: 0.25 * 0.25 = %h, fflags = %b", alu_f_wdata_o, fflags);

        // Test FMUL.S with medium-sized numbers
        alu_f_rdata1_i = 32'h40400000; // 3.0
        alu_f_rdata2_i = 32'h40A00000; // 5.0
        #10;
        $display("FMUL.S: 3.0 * 5.0 = %h, fflags = %b", alu_f_wdata_o, fflags);

        // Test FMUL.S with fractional numbers
        alu_f_rdata1_i = 32'h3F333333; // 0.7
        alu_f_rdata2_i = 32'h3F99999A; // 1.2
        #10;
        $display("FMUL.S: 0.7 * 1.2 = %h, fflags = %b", alu_f_wdata_o, fflags);

        // Test FMUL.S with numbers close to 1.0
        alu_f_rdata1_i = 32'h3F7FFFFF; // Just below 1.0
        alu_f_rdata2_i = 32'h3F800000; // 1.0
        #10;
        $display("FMUL.S: 0.9999999 * 1.0 = %h, fflags = %b", alu_f_wdata_o, fflags);

        // Test FMUL.S with numbers close to 2.0
        alu_f_rdata1_i = 32'h40000000; // 2.0
        alu_f_rdata2_i = 32'h3F800000; // 1.0
        #10;
        $display("FMUL.S: 2.0 * 1.0 = %h, fflags = %b", alu_f_wdata_o, fflags);

        // Test FMUL.S with numbers close to 0.5
        alu_f_rdata1_i = 32'h3F000000; // 0.5
        alu_f_rdata2_i = 32'h3F000000; // 0.5
        #10;
        $display("FMUL.S: 0.5 * 0.5 = %h, fflags = %b", alu_f_wdata_o, fflags);

        $display("All tests completed.");
    end

endmodule