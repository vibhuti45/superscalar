library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.iitb_risc_lib.all;

entity ir_decoder_buffer is
    port (
        -- clock reset
        clock : in std_logic;
        reset : in std_logic;

        imm6_in           : in imm6(decoder_buffer_size-1 downto 0);
        imm9_in            : in imm9(decoder_buffer_size-1 downto 0);
        compliment_in      : in bit_array(decoder_buffer_size-1 downto 0);
        ir_valid_bit_in      : in bit_array(decoder_buffer_size-1 downto 0);
        C_in              : in bit_array(decoder_buffer_size-1 downto 0);
        Z_in               : in bit_array(decoder_buffer_size-1 downto 0);
        pc_in           : in word_array(decoder_buffer_size-1 downto 0);
        ir_op_code_in      : in nibble_array(decoder_buffer_size-1 downto 0);
        destination_tag_in : in operand_array(decoder_buffer_size-1 downto 0);
        destination_tag_valid_in : in bit_array(decoder_buffer_size-1 downto 0);
        operand1_tag_in    : in operand_array(decoder_buffer_size-1 downto 0);
        operand2_tag_in    : in operand_array(decoder_buffer_size-1 downto 0);
        
        imm6_op            : out imm6(decoder_buffer_size-1 downto 0);
        imm9_op            : out imm9(decoder_buffer_size-1 downto 0);
        compliment_op      : out bit_array(decoder_buffer_size-1 downto 0);
        C_op               : out bit_array(decoder_buffer_size-1 downto 0);
        Z_op               : out bit_array(decoder_buffer_size-1 downto 0);
        pc_op           : out word_array(decoder_buffer_size-1 downto 0);
        ir_op_code_op      : out nibble_array(decoder_buffer_size-1 downto 0);
        destination_tag_op : out operand_array(decoder_buffer_size-1 downto 0);
        destination_tag_valid_op : out bit_array(decoder_buffer_size-1 downto 0);
        operand1_tag_op    : out operand_array(decoder_buffer_size-1 downto 0);
        operand2_tag_op    : out operand_array(decoder_buffer_size-1 downto 0);

        ir_valid_bit_op : out bit_array(decoder_buffer_size-1 downto 0)
    );
end ir_decoder_buffer;

architecture behavorial of ir_decoder_buffer is
    type idb_entry is record
        valid: std_logic;
        op_code : std_logic_vector(3 downto 0);
        imm6 : std_logic_vector(5 downto 0);
        imm9 : std_logic_vector(8 downto 0);
        compliment : std_logic;
        C : std_logic;
        Z : std_logic;
        destination_tag : std_logic_vector(2 downto 0);
        destination_tag_valid : std_logic;
        operand1_tag : std_logic_vector(2 downto 0);
        operand2_tag : std_logic_vector(2 downto 0);
        program_counter: std_logic_vector(15 downto 0);
    end record;

    type idb_array is array (0 to decoder_buffer_size - 1) of idb_entry;

    signal ir_decoder_buffer: idb_array ;

begin
    idb_write_process:process(clock)
    begin
        if reset = '1' then
            reset_loop:for i in 0 to decoder_buffer_size - 1 loop
                ir_decoder_buffer(i).valid <= '0';
                ir_decoder_buffer(i).op_code <= b"0000";
                ir_decoder_buffer(i).program_counter <= x"0000";
                ir_decoder_buffer(i).imm6 <= b"000000";
                ir_decoder_buffer(i).imm9 <= b"000000000";
                ir_decoder_buffer(i).compliment <= '0';
                ir_decoder_buffer(i).C <= '0';
                ir_decoder_buffer(i).Z <= '0';
                ir_decoder_buffer(i).destination_tag <= b"000";
                ir_decoder_buffer(i).destination_tag_valid <= '0';
                ir_decoder_buffer(i).operand1_tag <= b"000";
                ir_decoder_buffer(i).operand2_tag <= b"000";
            end loop reset_loop;
        else
            if falling_edge(clock) then
                write_loop:for i in 0 to decoder_buffer_size - 1 loop
                    ir_decoder_buffer(i).valid <= ir_valid_bit_in(i);
                    ir_decoder_buffer(i).op_code <= ir_op_code_in(i);
                    ir_decoder_buffer(i).program_counter <= pc_in(i);
                    ir_decoder_buffer(i).imm6 <= imm6_in(i);
                    ir_decoder_buffer(i).imm9 <= imm9_in(i);
                    ir_decoder_buffer(i).compliment <= compliment_in(i);
                    ir_decoder_buffer(i).C <= C_in(i);
                    ir_decoder_buffer(i).Z <= Z_in(i);
                    ir_decoder_buffer(i).destination_tag <= destination_tag_in(i);
                    ir_decoder_buffer(i).destination_tag_valid <= destination_tag_valid_in(i);
                    ir_decoder_buffer(i).operand1_tag <= operand1_tag_in(i);
                    ir_decoder_buffer(i).operand2_tag <= operand2_tag_in(i);
                end loop write_loop;
            end if;
        end if;
    end process idb_write_process;

    idb_read_process:process(clock)
    begin
        read_loop: for i in 0 to decoder_buffer_size - 1 loop
            pc_op(i) <= ir_decoder_buffer(i).program_counter;
            ir_op_code_op(i) <= ir_decoder_buffer(i).op_code;
            imm6_op(i) <= ir_decoder_buffer(i).imm6;
            imm9_op(i) <= ir_decoder_buffer(i).imm9;
            compliment_op(i) <= ir_decoder_buffer(i).compliment;
            C_op(i) <= ir_decoder_buffer(i).C;
            Z_op(i) <= ir_decoder_buffer(i).Z;
            destination_tag_op(i) <= ir_decoder_buffer(i).destination_tag;
            destination_tag_valid_op(i) <= ir_decoder_buffer(i).destination_tag_valid;
            operand1_tag_op(i) <= ir_decoder_buffer(i).operand1_tag;
            operand2_tag_op(i) <= ir_decoder_buffer(i).operand2_tag;
            ir_valid_bit_op(i) <= ir_decoder_buffer(i).valid;
        end loop read_loop;
    end process idb_read_process;
end architecture behavorial;