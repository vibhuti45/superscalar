library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.iitb_risc_lib.all;

entity arith_logic_pipeline is 
    port (
        pc_in           : in std_logic_vector(15 downto 0);
        op_code         : in std_logic_vector(3  downto 0);
        operand_1_value : in std_logic_vector(15 downto 0);
        operand_2_value : in std_logic_vector(15 downto 0);
        rrf_destination_tag_in : in std_logic_vector(2 downto 0); 
        destination_in  : in std_logic_vector(2  downto 0);
        valid_operation_in : in std_logic;
        compliment : in std_logic;
        c : in std_logic;
        z : in std_logic;
        carry_flag_in   : in std_logic;
        zero_flag_in    : in std_logic;
        
        zero_flag_out  : out std_logic;
        carry_flag_out  : out std_logic;
        destination_op  : out std_logic_vector(15  downto 0);
        rrf_destination_tag_out : out std_logic_vector(15 downto 0); 
        pc_op           : out std_logic_vector(15 downto 0);
        result              : out std_logic_vector(15 downto 0);
        valid_operation_op : out std_logic;
        is_branch: out std_logic
    );
end arith_logic_pipeline;

architecture behavorial of arith_logic_pipeline is
signal A_in : std_logic_vector(15 downto 0);
signal B_in : std_logic_vector(15 downto 0);
signal B_comp_in : std_logic_vector(15 downto 0);
signal c_in : std_logic;
signal carry_in : std_logic_vector(16 downto 0);
signal z_in : std_logic;
signal compliment_in : std_logic;
signal op_code_in : std_logic_vector(3 downto 0);
signal alu_out : std_logic_vector(15 downto 0);
signal c_flag_out : std_logic;
signal z_flag_out : std_logic;

begin
    inst_alu: entity work.alu
    port map(
        c_bit  => c_in,
        z_bit  => z_in,
        compliment => compliment_in,
        op_code => op_code_in,

        A => A_in,
        B => B_in,
        B_comp => B_comp_in,
        C => carry_in,

        alu_out => alu_out,
        carry => c_flag_out,
        zero  => z_flag_out
    );
    exicution_process:process(alu_out, c_flag_out, z_flag_out, destination_in, pc_in, valid_operation_in)
    begin
        result <= alu_out;
        zero_flag_out <= z_flag_out;
        carry_flag_out <= c_flag_out;
        destination_op(2 downto 0) <= destination_in;
        destination_op(15 downto 3) <= (others => '0');
        rrf_destination_tag_out(2 downto 0) <= rrf_destination_tag_in;
        rrf_destination_tag_out(15 downto 3) <= (others => '0');
        pc_op <= pc_in;
        valid_operation_op <= valid_operation_in;
    end process exicution_process;
    
    alu_process:process(operand_1_value, operand_2_value, op_code, pc_in, compliment, c, z, carry_flag_in, zero_flag_in)
    begin
        -- if op_code = "0010" or op_code = "0001" or op_code = "0000" or op_code = "0011" then
            c_in <= c;
            z_in <= z;
            compliment_in <= compliment;
            op_code_in <= op_code;
            
            A_in <= operand_1_value;
            B_in <= operand_2_value;
            B_comp_in <= not operand_2_value;
            carry_in(0) <= carry_flag_in;
            carry_in(16 downto 1) <= (others => '0');
        -- end if;
    end process alu_process;
end architecture behavorial;