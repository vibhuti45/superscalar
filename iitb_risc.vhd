library ieee;
use std.textio.all; 
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.iitb_risc_lib.all;

entity iitb_risc is
    port (
        -- clock and reset
        clock : in std_logic;
        reset : in std_logic
    );
end iitb_risc;

architecture behavioral of iitb_risc is

    -- ir_memory
    signal ir_ip_to_ifb : word_array(fetch_width-1 downto 0);
    signal pc_ip_to_ifb : word_array(fetch_width-1 downto 0);
    signal ir_valid_to_ibf : bit_array(fetch_width-1 downto 0);

    -- ir_fetch_buffer
    signal ir_ip_to_ir_decoder : word_array(ir_fetch_buffer_size-1 downto 0);
    signal pc_ip_to_ir_decoder : word_array(ir_fetch_buffer_size-1 downto 0);
    signal ir_ip_valid_bit_to_decoder : bit_array(ir_fetch_buffer_size-1 downto 0);

    -- ir decoder
    signal op_code_ip_to_idb : nibble_array(ir_decoder_size-1 downto 0);
    signal ir_ip_valid_bit_to_idb : bit_array(ir_decoder_size-1 downto 0);
    signal pc_ip_to_idb : word_array(ir_decoder_size-1 downto 0);
    signal imm6_ip_to_idb : imm6(ir_decoder_size-1 downto 0);
    signal imm9_ip_to_idb : imm9(ir_decoder_size-1 downto 0);
    signal compliment_ip_to_idb : bit_array(ir_decoder_size-1 downto 0);
    signal C_ip_to_idb : bit_array(ir_decoder_size-1 downto 0);
    signal Z_ip_to_idb : bit_array(ir_decoder_size-1 downto 0);
    signal destination_tag_ip_to_idb :operand_array(ir_decoder_size-1 downto 0);
    signal destination_tag_valid_ip_to_idb : bit_array(ir_decoder_size-1 downto 0);
    signal operand1_tag_ip_to_idb    :operand_array(ir_decoder_size-1 downto 0);
    signal operand2_tag_ip_to_idb    :operand_array(ir_decoder_size-1 downto 0);

    -- ir decoder buffer
    signal imm6_ip_to_rs           : imm6(decoder_buffer_size-1 downto 0);
    signal imm9_ip_to_rs           : imm9(decoder_buffer_size-1 downto 0);
    signal compliment_ip_to_rs      : bit_array(decoder_buffer_size-1 downto 0);
    signal C_ip_to_rs              : bit_array(decoder_buffer_size-1 downto 0);
    signal Z_ip_to_rs               : bit_array(decoder_buffer_size-1 downto 0);
    signal pc_ip_to_rs           : word_array(decoder_buffer_size-1 downto 0);
    signal ir_op_code      : nibble_array(decoder_buffer_size-1 downto 0);
    signal destination_tag_ip_to_rf : operand_array(decoder_buffer_size-1 downto 0);
    signal destination_tag_valid_in_to_rf : bit_array(decoder_buffer_size-1 downto 0);
    signal operand1_tag_ip_to_rf    : operand_array(decoder_buffer_size-1 downto 0);
    signal operand2_tag_ip_to_rf    : operand_array(decoder_buffer_size-1 downto 0);

    signal ir_valid : bit_array(decoder_buffer_size-1 downto 0);

    -- 16 bit adder
    signal pc_in_to_rf : std_logic_vector(15 downto 0);

    -- Register file
    signal PC : std_logic_vector(15 downto 0);
    signal source_operand_1_value_in_rs : word_array(no_operand_1_read_ports - 1 downto 0);
    signal source_operand_2_value_in_rs : word_array(no_operand_2_read_ports - 1 downto 0);
    signal source_operand_1_value_valid_in_rs : bit_array(no_operand_1_read_ports - 1 downto 0);
    signal source_operand_2_value_valid_in_rs : bit_array(no_operand_2_read_ports - 1 downto 0);
    signal destination_operand_tag_in_rs : operand_array(no_reg_read_to_destination_tag_ports - 1 downto 0);

    -- Reservation station
    -- al
    signal ir_valid_al_in_al_pipeline: bit_array(no_al_pipelines - 1 downto 0);
    signal pc_al_in_al_pipeline       :  word_array(no_al_pipelines - 1 downto 0);
    signal op_code_al_in_al_pipeline     :  nibble_array(no_al_pipelines - 1 downto 0);
    signal destination_tag_al_in_al_pipeline :  operand_array(no_al_pipelines - 1 downto 0);
    signal orignal_destination_tag_al_in_al_pipeline :  operand_array(no_al_pipelines - 1 downto 0);
    signal operand_1_value_al_in_al_pipeline :  word_array(no_al_pipelines - 1 downto 0); 
    signal operand_2_value_al_in_al_pipeline :  word_array(no_al_pipelines - 1 downto 0); 
    signal compliment_bit_al_in_al_pipeline  :  bit_array(no_al_pipelines - 1 downto 0);
    signal C_al_in_al_pipeline  :  bit_array(no_al_pipelines - 1 downto 0);
    signal Z_al_in_al_pipeline  :  bit_array(no_al_pipelines - 1 downto 0);

    -- al
    signal ir_valid_ls_in_ls_pipeline: bit_array(no_ls_pipelines - 1 downto 0);
    signal pc_ls_in_ls_pipeline       :  word_array(no_ls_pipelines - 1 downto 0);
    signal op_code_ls_in_ls_pipeline     :  nibble_array(no_ls_pipelines - 1 downto 0);
    signal destination_tag_ls_in_ls_pipeline :  operand_array(no_ls_pipelines - 1 downto 0);
    signal orignal_destination_tag_ls_in_ls_pipeline :  operand_array(no_ls_pipelines - 1 downto 0);
    signal operand_1_value_ls_in_ls_pipeline :  word_array(no_ls_pipelines - 1 downto 0); 
    signal operand_2_value_ls_in_ls_pipeline :  word_array(no_ls_pipelines - 1 downto 0); 
    signal compliment_bit_ls_in_ls_pipeline  :  bit_array(no_ls_pipelines - 1 downto 0);
    signal C_ls_in_ls_pipeline  :  bit_array(no_ls_pipelines - 1 downto 0);
    signal Z_ls_in_ls_pipeline  :  bit_array(no_ls_pipelines - 1 downto 0);

    -- al pipeline
    signal zero_flag_out  : bit_array(no_al_pipelines - 1 downto 0);
    signal carry_flag_out : bit_array(no_al_pipelines - 1 downto 0);
    signal pc_op          : word_array(total_no_pipelines - 1 downto 0):= (others => x"FFFF");
    signal destination_op : word_array(total_no_pipelines - 1 downto 0):= (others => x"0000");
    signal rrf_destination_tag_al_in_al_pipeline : word_array(total_no_pipelines - 1 downto 0):= (others => x"0000");
    signal result         : word_array(total_no_pipelines - 1 downto 0);
    signal valid_operation_op : bit_array(total_no_pipelines - 1 downto 0) := (others => '0');
    signal is_branch          : bit_array(no_al_pipelines - 1 downto 0);

    --ls pipeline
    signal temp_imm6 : std_logic_vector(5 downto 0); 
    signal address_read : std_logic_vector(15 downto 0);
    signal data_0, data_1, data_2 : std_logic_vector(15 downto 0);
    -- Reorder Buffer
    signal valid_bit : std_logic:= '0';
    signal data      : std_logic_vector(15 downto 0);
    signal address   : std_logic_vector(15 downto 0);
    signal mem_reg   : std_logic;
    signal temp_write_en   : std_logic;
    signal mem_reg_ip   : bit_array(total_no_pipelines-1 downto 0);




begin
    inst_ir_memory: entity work.ir_memory 
    port map(
        clock => clock,
        pc_in => PC, 
        ir_op => ir_ip_to_ifb, 
        pc_op => pc_ip_to_ifb
    );

    inst_ir_buffer: entity work.ir_fetch_buffer
    port map(
        clock => clock,
        reset => reset,

        ir_in => ir_ip_to_ifb,
        pc_in     => pc_ip_to_ifb,

        ir_op => ir_ip_to_ir_decoder,
        pc_op     => pc_ip_to_ir_decoder
    );

    inst_ir_decoder: entity work.ir_decoder
    port map(
        pc_in => pc_ip_to_ir_decoder,
        ir_in => ir_ip_to_ir_decoder,

        ir_op_code => op_code_ip_to_idb,
        ir_valid_bit_op => ir_ip_valid_bit_to_idb,
        pc_op => pc_ip_to_idb,
        imm6 =>imm6_ip_to_idb,
        imm9 =>imm9_ip_to_idb,
        compliment =>compliment_ip_to_idb,
        C =>C_ip_to_idb,
        Z =>Z_ip_to_idb,
        destination_tag =>destination_tag_ip_to_idb,
        destination_tag_valid => destination_tag_valid_ip_to_idb,
        operand1_tag =>operand1_tag_ip_to_idb,
        operand2_tag =>operand2_tag_ip_to_idb
    );

    inst_ir_decoder_buffer: entity work.ir_decoder_buffer
    port map(
        -- clock reset
        clock => clock,
        reset => reset,
        
        ir_op_code_in => op_code_ip_to_idb,
        ir_valid_bit_in => ir_ip_valid_bit_to_idb,
        pc_in => pc_ip_to_idb,
        imm6_in =>imm6_ip_to_idb,
        imm9_in =>imm9_ip_to_idb,
        compliment_in =>compliment_ip_to_idb,
        C_in =>C_ip_to_idb,
        Z_in =>Z_ip_to_idb,

        destination_tag_in =>destination_tag_ip_to_idb,
        destination_tag_valid_in =>destination_tag_valid_ip_to_idb,
        operand1_tag_in =>operand1_tag_ip_to_idb,
        operand2_tag_in =>operand2_tag_ip_to_idb,

        imm6_op          => imm6_ip_to_rs,
        imm9_op           => imm9_ip_to_rs,
        compliment_op      => compliment_ip_to_rs,
        C_op             => C_ip_to_rs,
        Z_op             => Z_ip_to_rs,
        pc_op         => pc_ip_to_rs,
        ir_op_code_op      => ir_op_code,

        destination_tag_op => destination_tag_ip_to_rf,
        destination_tag_valid_op => destination_tag_valid_in_to_rf,
        operand1_tag_op    => operand1_tag_ip_to_rf,
        operand2_tag_op    => operand2_tag_ip_to_rf,

        ir_valid_bit_op =>ir_valid
    );

    inst_pc_adder_2_bit16_adder: entity work.bit16_adder
    port map(
        A => PC,
        B => x"0004",

        SUM => pc_in_to_rf
    );

    inst_register_file: entity work.register_file
    port map(
        -- clock reset
        clock =>clock,
        reset =>reset,

        -- pc read 
        pc_write_select =>'0',
        pc_input => pc_in_to_rf,
        pc_output => PC,

        -- Operand to value/tag -- for source
        source_operands1_in =>operand1_tag_ip_to_rf,
        source_operands2_in =>operand2_tag_ip_to_rf,
        source_operand_1_value =>source_operand_1_value_in_rs,
        source_operand_1_value_valid =>source_operand_1_value_valid_in_rs,
        source_operand_2_value =>source_operand_2_value_in_rs,
        source_operand_2_value_valid =>source_operand_2_value_valid_in_rs,

        -- Operand to tag      -- for destinaltion
        destination_operand_in =>destination_tag_ip_to_rf,
        destination_operand_in_valid =>destination_tag_valid_in_to_rf,
        destination_operand_out =>destination_operand_tag_in_rs,

        -- ARF data write port
        arf_data => data,
        arf_address => address(2 downto 0),
        arf_tag     =>b"000",
        arf_write_valid => valid_bit,

        -- ARF data write port
        rrf_data => result,
        rrf_tag  => rrf_destination_tag_al_in_al_pipeline,
        rrf_valid => valid_operation_op
    );

    inst_reservation_station: entity work.reservation_station
    port map(
        clock => clock,
        reset => reset,
        al_issue_enable => (others => '1'),
        ls_issue_enable => (others => '1'),

        ir_valid => ir_valid,
        pc_in    => pc_ip_to_rs,
        op_code  => ir_op_code,
        destination_tag => destination_operand_tag_in_rs,
        orignal_destination => destination_tag_ip_to_rf,
        operand_1_value => source_operand_1_value_in_rs,
        operand_2_value => source_operand_2_value_in_rs,
        operand_1_value_valid => source_operand_1_value_valid_in_rs,
        operand_2_value_valid => source_operand_2_value_valid_in_rs,
        compliment_bit => compliment_ip_to_rs,
        imm6 => imm6_ip_to_rs,
        imm9 => imm9_ip_to_rs,
        C => C_ip_to_rs,
        Z => Z_ip_to_rs,

        ir_valid_al =>ir_valid_al_in_al_pipeline,
        pc_al       =>pc_al_in_al_pipeline,
        op_code_al     =>op_code_al_in_al_pipeline,
        destination_tag_al =>destination_tag_al_in_al_pipeline,
        orignal_destination_tag_al =>orignal_destination_tag_al_in_al_pipeline,
        operand_1_value_al =>operand_1_value_al_in_al_pipeline,
        operand_2_value_al =>operand_2_value_al_in_al_pipeline,
        compliment_bit_al  =>compliment_bit_al_in_al_pipeline,
        C_al  =>C_al_in_al_pipeline,
        Z_al  =>Z_al_in_al_pipeline,

        ir_valid_ls =>ir_valid_ls_in_ls_pipeline,
        pc_ls       =>pc_ls_in_ls_pipeline,
        op_code_ls     =>op_code_ls_in_ls_pipeline,
        destination_tag_ls =>destination_tag_ls_in_ls_pipeline,
        orignal_destination_tag_ls =>orignal_destination_tag_ls_in_ls_pipeline,
        operand_1_value_ls =>operand_1_value_ls_in_ls_pipeline,
        operand_2_value_ls =>operand_2_value_ls_in_ls_pipeline,
        compliment_bit_ls  =>compliment_bit_ls_in_ls_pipeline,
        C_ls  =>C_ls_in_ls_pipeline,
        Z_ls  =>Z_ls_in_ls_pipeline,

        tag =>destination_op(0)(2 downto 0),
        value =>result(0),
        valid_bit=>valid_operation_op(0)

    );

    arith_logic_pipeline: for i in 0 to no_al_pipelines - 1 generate
    mem_reg_ip(i) <= '1';
        inst_arith_logic_pipeline: entity work.arith_logic_pipeline
        port map (
            pc_in           => pc_al_in_al_pipeline(i),
            op_code         => op_code_al_in_al_pipeline(i),
            operand_1_value => operand_1_value_al_in_al_pipeline(i),
            operand_2_value => operand_2_value_al_in_al_pipeline(i),
            rrf_destination_tag_in => destination_tag_al_in_al_pipeline(i),
            destination_in  => orignal_destination_tag_al_in_al_pipeline(i),
            valid_operation_in => ir_valid_al_in_al_pipeline(i),
            compliment => compliment_bit_al_in_al_pipeline(i),
            c => C_al_in_al_pipeline(i),
            z => Z_al_in_al_pipeline(i),
            carry_flag_in   => '0',
            zero_flag_in    => '0',
            
            zero_flag_out  => zero_flag_out(i),
            carry_flag_out => carry_flag_out(i),
            destination_op => destination_op(i),
            rrf_destination_tag_out => rrf_destination_tag_al_in_al_pipeline(i),
            pc_op          => pc_op(i),
            result         => result(i),
            valid_operation_op => valid_operation_op(i),
            is_branch => is_branch(i)
        );
    end generate;

    temp_imm6(5 downto 3) <= destination_tag_ls_in_ls_pipeline(0);
    temp_imm6(2) <= compliment_bit_ls_in_ls_pipeline(0);
    temp_imm6(1) <= C_ls_in_ls_pipeline(0);
    temp_imm6(0) <= Z_ls_in_ls_pipeline(0);

    inst_load_store_pipeline: entity work.load_store_pipeline
    port map(
        pc_in           =>pc_ls_in_ls_pipeline(0),
        op_code         =>op_code_ls_in_ls_pipeline(0),
        operand_1_value =>operand_1_value_ls_in_ls_pipeline(0),
        operand_2_value =>operand_2_value_ls_in_ls_pipeline(0),
        imm6         =>temp_imm6,
        destination_in  =>destination_tag_ls_in_ls_pipeline(0),
        valid_operation_in =>ir_valid_ls_in_ls_pipeline(0),
        
        pc_op           => pc_op(2),
        mem_reg => mem_reg_ip(2),
        destination_op => destination_op(2),
        operand_value => data_1,
        address => address_read,
        valid_operation_op => valid_operation_op(2)
    );   

    result(2) <= data_1 when (mem_reg = '1') else data_2;
    temp_write_en <= ((not mem_reg) and valid_bit);
    inst_data_memory: entity work.data_memory
    port map (
        clock => clock,
        address_read => address_read,
        data_output => data_2,
        address_write => address,
        data_in => data,
        write_en => temp_write_en
    );
    inst_reorder_buffer: entity work.reorder_buffer
    port map (
        -- clock reset
        clock =>clock,
        reset =>reset,

        -- from exicution unit 
        valid => valid_operation_op,
        PC    => pc_op,
        value => result,
        address => destination_op,
        mem_reg => mem_reg_ip,

        -- from RF
        pc_in =>pc_ip_to_rs,
        pc_in_valid =>ir_valid,

        valid_op =>valid_bit,
        data     =>data,
        address_op =>address,
        mem_reg_op =>mem_reg
    );

    -- sim_process:process(clock)
    -- variable out_line :line;
    -- variable cycle_count: integer:= 0;
    -- file output_file : text open write_mode is "../../simulation_output.txt";
    -- begin
    --     if falling_edge(clock) then
    --         cycle_count := cycle_count + 1; 
    --         writeline(output_file, out_line);
    --         write(output_file, "Cycle : "); 
    --         write(output_file, integer'image(cycle_count));  
    --         write(out_line, LF); 
    --         writeline(output_file, out_line);
            
            -- write(output_file, "ir_memory_output");
            -- writeline(output_file, out_line);
            -- for i in 0 to fetch_width - 1 loop
            --     write(output_file, "IR : ");
            --     write(output_file, to_string_std_logic_vector(ir_ip_to_ifb(i)));
            --     write(output_file, " PC : ");
            --     write(output_file, to_string_std_logic_vector(pc_ip_to_ifb(i)));
            --     write(output_file, " Valid bit : ");
            --     write(output_file, to_string_std_logic(ir_valid_to_ibf(i)));
            --     writeline(output_file, out_line);
            -- end loop; 

            -- write(output_file, "ir_memory_buffer_output");
            -- writeline(output_file, out_line);
            -- for i in 0 to fetch_width - 1 loop
            --     write(output_file, "IR : ");
            --     write(output_file, to_string_std_logic_vector(ir_ip_to_ir_decoder(i)));
            --     write(output_file, " PC : ");
            --     write(output_file, to_string_std_logic_vector(pc_ip_to_ir_decoder(i)));
            --     write(output_file, " Valid bit : ");
            --     write(output_file, to_string_std_logic(ir_ip_valid_bit_to_decoder(i)));
            --     writeline(output_file, out_line);
            -- end loop; 

            -- write(output_file, "ir_decoder_output");
            -- writeline(output_file, out_line);
            -- for i in 0 to fetch_width - 1 loop
            --     write(output_file, " Valid bit : ");
            --     write(output_file, to_string_std_logic(ir_ip_valid_bit_to_idb(i)));
            --     write(output_file, " PC : ");
            --     write(output_file, to_string_std_logic_vector(pc_ip_to_idb(i)));
            --     write(output_file, " opcode : ");
            --     write(output_file, to_string_std_logic_vector(op_code_ip_to_idb(i)));
            --     write(output_file, " OPR1 : ");
            --     write(output_file, to_string_std_logic_vector(operand1_tag_ip_to_idb(i)));
            --     write(output_file, " OPR2 : ");
            --     write(output_file, to_string_std_logic_vector(operand2_tag_ip_to_idb(i)));
            --     write(output_file, " imm6 : ");
            --     write(output_file, to_string_std_logic_vector(imm6_ip_to_idb(i)));
            --     write(output_file, " imm9 : ");
            --     write(output_file, to_string_std_logic_vector(imm9_ip_to_idb(i)));
            --     write(output_file, " compliment : ");
            --     write(output_file, to_string_std_logic(compliment_ip_to_idb(i)));
            --     write(output_file, " C : ");
            --     write(output_file, to_string_std_logic(C_ip_to_idb(i)));
            --     write(output_file, " Z : ");
            --     write(output_file, to_string_std_logic(Z_ip_to_idb(i)));
            --     write(output_file, " destination_tag : ");
            --     write(output_file, to_string_std_logic_vector(destination_tag_ip_to_idb(i)));
            --     write(output_file, " destination_tag_valid : ");
            --     write(output_file, to_string_std_logic(destination_tag_valid_ip_to_idb(i)));
            --     writeline(output_file, out_line);
            -- end loop; 

            -- write(output_file, "ir_decoder_buffer_output");
            -- writeline(output_file, out_line);
            -- for i in 0 to fetch_width - 1 loop
            --     write(output_file, " Valid bit : ");
            --     write(output_file, to_string_std_logic(ir_valid(i)));
            --     write(output_file, " PC : ");
            --     write(output_file, to_string_std_logic_vector(pc_ip_to_rs(i)));
            --     write(output_file, " opcode : ");
            --     write(output_file, to_string_std_logic_vector(ir_op_code(i)));
            --     write(output_file, " OPR1 : ");
            --     write(output_file, to_string_std_logic_vector(operand1_tag_ip_to_rf(i)));
            --     write(output_file, " OPR2 : ");
            --     write(output_file, to_string_std_logic_vector(operand2_tag_ip_to_rf(i)));
            --     write(output_file, " imm6 : ");
            --     write(output_file, to_string_std_logic_vector(imm6_ip_to_rs(i)));
            --     write(output_file, " imm9 : ");
            --     write(output_file, to_string_std_logic_vector(imm9_ip_to_rs(i)));
            --     write(output_file, " compliment : ");
            --     write(output_file, to_string_std_logic(compliment_ip_to_rs(i)));
            --     write(output_file, " C : ");
            --     write(output_file, to_string_std_logic(C_ip_to_rs(i)));
            --     write(output_file, " Z : ");
            --     write(output_file, to_string_std_logic(Z_ip_to_rs(i)));
            --     write(output_file, " destination_tag : ");
            --     write(output_file, to_string_std_logic_vector(destination_tag_ip_to_rf(i)));
            --     write(output_file, " destination_tag_valid : ");
            --     write(output_file, to_string_std_logic(destination_tag_valid_in_to_rf(i)));
            --     writeline(output_file, out_line);
            -- end loop; 

            -- write(output_file, "register_file_output");
            -- writeline(output_file, out_line);
            -- for i in 0 to fetch_width - 1 loop
            --     write(output_file, " OPR_tag_1_in : ");
            --     write(output_file, to_string_std_logic_vector(operand1_tag_ip_to_rf(i)));
            --     write(output_file, " OPR_1_value : ");
            --     write(output_file, to_string_std_logic_vector(source_operand_1_value_in_rs(i)));
            --     write(output_file, " OPR_1_valid : ");
            --     write(output_file, to_string_std_logic(source_operand_1_value_valid_in_rs(i)));
            --     write(output_file, " OPR_tag_2_in : ");
            --     write(output_file, to_string_std_logic_vector(operand2_tag_ip_to_rf(i)));
            --     write(output_file, " OPR_2_valid : ");
            --     write(output_file, to_string_std_logic(source_operand_2_value_valid_in_rs(i)));
            --     write(output_file, " OPR_2_value : ");
            --     write(output_file, to_string_std_logic_vector(source_operand_2_value_in_rs(i)));
            --     write(output_file, " dest_tag_in : ");
            --     write(output_file, to_string_std_logic_vector(destination_tag_ip_to_rf(i)));
            --     write(output_file, " dest_tag_out : ");
            --     write(output_file, to_string_std_logic_vector(destination_operand_tag_in_rs(i)));
            --     write(output_file, " dest_tag_valid : ");
            --     write(output_file, to_string_std_logic(destination_tag_valid_in_to_rf(i)));
            --     writeline(output_file, out_line);
            -- end loop;

            -- write(output_file, "reservation_station_output (al)");
            -- writeline(output_file, out_line);
            -- for i in 0 to no_al_pipelines - 1 loop
            --     write(output_file, " ir_valid : ");
            --     write(output_file, to_string_std_logic(ir_valid_al_in_al_pipeline(i)));
            --     write(output_file, " pc : ");
            --     write(output_file, to_string_std_logic_vector(pc_al_in_al_pipeline(i)));
            --     write(output_file, " op_code : ");
            --     write(output_file, to_string_std_logic_vector(op_code_al_in_al_pipeline(i)));
            --     write(output_file, " destination_tag : ");
            --     write(output_file, to_string_std_logic_vector(destination_tag_al_in_al_pipeline(i)));
            --     write(output_file, " operand_1_value : ");
            --     write(output_file, to_string_std_logic_vector(operand_1_value_al_in_al_pipeline(i)));
            --     write(output_file, " operand_2_value : ");
            --     write(output_file, to_string_std_logic_vector(operand_2_value_al_in_al_pipeline(i)));
            --     write(output_file, " compliment_bit : ");
            --     write(output_file, to_string_std_logic(compliment_bit_al_in_al_pipeline(i)));
            --     write(output_file, " C : ");
            --     write(output_file, to_string_std_logic(C_al_in_al_pipeline(i)));
            --     write(output_file, " Z : ");
            --     write(output_file, to_string_std_logic(Z_al_in_al_pipeline(i)));
            --     writeline(output_file, out_line);
            -- end loop; 

            -- write(output_file, "reservation_station_output (ls)");
            -- writeline(output_file, out_line);
            -- for i in 0 to no_ls_pipelines - 1 loop
            --     write(output_file, " ir_valid : ");
            --     write(output_file, to_string_std_logic(ir_valid_ls_in_ls_pipeline(i)));
            --     write(output_file, " pc : ");
            --     write(output_file, to_string_std_logic_vector(pc_ls_in_ls_pipeline(i)));
            --     write(output_file, " op_code : ");
            --     write(output_file, to_string_std_logic_vector(op_code_ls_in_ls_pipeline(i)));
            --     write(output_file, " destination_tag : ");
            --     write(output_file, to_string_std_logic_vector(destination_tag_ls_in_ls_pipeline(i)));
            --     write(output_file, " operand_1_value : ");
            --     write(output_file, to_string_std_logic_vector(operand_1_value_ls_in_ls_pipeline(i)));
            --     write(output_file, " operand_2_value : ");
            --     write(output_file, to_string_std_logic_vector(operand_2_value_ls_in_ls_pipeline(i)));
            --     write(output_file, " compliment_bit : ");
            --     write(output_file, to_string_std_logic(compliment_bit_ls_in_ls_pipeline(i)));
            --     write(output_file, " C : ");
            --     write(output_file, to_string_std_logic(C_ls_in_ls_pipeline(i)));
            --     write(output_file, " Z : ");
            --     write(output_file, to_string_std_logic(Z_ls_in_ls_pipeline(i)));
            --     writeline(output_file, out_line);
            -- end loop; 

            -- write(output_file, "Reorder Buffer (ROB)");
            -- writeline(output_file, out_line);
            -- write(output_file, " Valid : ");
            -- write(output_file, to_string_std_logic(valid_bit));
            -- write(output_file, " data : ");
            -- write(output_file, to_string_std_logic_vector(data));
            -- write(output_file, " address : ");
            -- write(output_file, to_string_std_logic_vector(address));
            -- write(output_file, " mem_reg : ");
            -- write(output_file, to_string_std_logic(mem_reg));
            -- writeline(output_file, out_line);
    --     end if;
    -- end process sim_process;
end architecture behavioral;