// instruction_transaction.sv
// Data container representing an instruction as it flows through verification environment
// split in two: stimulus and observation

class instruction_transaction;
    // stimulus - filled in by sequences/driver
    logic [31:0] instruction;
    logic [31:0] pc;

    // observed fields - filled in by monitor
    logic [4:0] rd_addr;
    logic [31:0] write_data;
    logic        reg_write;

endclass