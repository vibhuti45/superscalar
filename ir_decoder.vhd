library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.iitb_risc_lib.all;

entity ir_decoder is
    port (
        -- Instruction Input
        pc_in           : in word_array(ir_decoder_size-1 downto 0);
        ir_in           : in word_array(ir_decoder_size-1 downto 0);

        imm6            : out imm6(ir_decoder_size-1 downto 0);
        imm9            : out imm9(ir_decoder_size-1 downto 0);
        compliment      : out bit_array(ir_decoder_size-1 downto 0);
        C               : out bit_array(ir_decoder_size-1 downto 0);
        Z               : out bit_array(ir_decoder_size-1 downto 0);
        pc_op           : out word_array(ir_decoder_size-1 downto 0);
        ir_op_code      : out nibble_array(ir_decoder_size-1 downto 0);
        destination_tag : out operand_array(ir_decoder_size-1 downto 0);
        destination_tag_valid : out bit_array(ir_decoder_size-1 downto 0);
        operand1_tag    : out operand_array(ir_decoder_size-1 downto 0);
        operand2_tag    : out operand_array(ir_decoder_size-1 downto 0);

        ir_valid_bit_op : out bit_array(ir_decoder_size-1 downto 0)
    );
end ir_decoder;

architecture behavorial of ir_decoder is
    
begin
    ir_decoder:process(ir_in, pc_in)
    begin
        ir_decoder_loop: for i in 0 to ir_decoder_size - 1 loop
            imm6(i) <= ir_in(i)(5 downto 0);
            imm9(i) <= ir_in(i)(8 downto 0);
            compliment(i) <= ir_in(i)(2);
            C(i) <= ir_in(i)(1);
            Z(i) <= ir_in(i)(0);
            pc_op(i) <= pc_in(i);
            ir_op_code(i) <= ir_in(i)(15 downto 12);
            destination_tag(i) <= ir_in(i)(11 downto 9);
            operand1_tag(i) <= ir_in(i)(8 downto 6);
            operand2_tag(i) <= ir_in(i)(5 downto 3);
            if ir_in(i)(15 downto 12) = x"A" then
                ir_valid_bit_op(i) <= '0';
            else
                ir_valid_bit_op(i) <= '1';
            end if;
        end loop ir_decoder_loop;
    end process ir_decoder;

    setting_destination_tag_valid: process(ir_in)
    begin
        for i in 0 to ir_decoder_size - 1 loop
            case ir_in(i)(15 downto 12) is
                when b"0001" | b"0010" | b"0000" | b"0011" | b"1100" | b"1101" | b"0100" =>
                    destination_tag_valid(i) <= '1';
                when others =>
                    destination_tag_valid(i) <= '0';
            end case ;
        end loop;
    end process setting_destination_tag_valid;
end architecture behavorial;