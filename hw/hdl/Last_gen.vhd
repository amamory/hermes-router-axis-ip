------------------------------------------------------------------------------------------------
--
--  DISTRIBUTED HEMPS  - version 5.0
--
--  Research group: GAPH-PUCRS    -    contact   amamory@gmail.com
--
--  Distribution:  June 2020
--
--  Source name:  Last_gen.vhd
--
--  'last' signal generator to keep compability with AXI streaming interface
--  this port is high whenthe last flit is sent
--
----------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.HeMPS_defaults.all;

entity Last_gen is
port(
        clock:    in  std_logic;
        reset:    in  std_logic;
        -- these to the external side
        validL_o: out std_logic;
        lastL_o:  out std_logic;
        dataL_o:  out std_logic_vector(TAM_FLIT-1 downto 0);
        readyL_i: in  std_logic;
        -- these go to the router side
        valid_i:  in  std_logic;
        data_i:   in  std_logic_vector(TAM_FLIT-1 downto 0);
        ready_o:  out  std_logic
);
end Last_gen;

architecture Last_gen of Last_gen is

type state_type is (WAIT_HEADER,HEADER,PKT_SIZE,PAYLOAD,LAST_FLIT);
signal state: state_type;

signal flit_cnt: std_logic_vector(TAM_FLIT-1 downto 0);

begin

    validL_o <= valid_i;
    dataL_o  <= data_i;
    ready_o  <= readyL_i;
    
    process(reset,clock)
    begin
        if reset='1' then
            state<=WAIT_HEADER;
            flit_cnt <= (others => '0'); 
            lastL_o <= '0';
        elsif clock'event and clock='1' then
            case state is
                when WAIT_HEADER => 
                    flit_cnt <= (others => '0'); 
                    lastL_o <= '0';
                    state <= WAIT_HEADER;
                    if readyL_i = '1' and valid_i = '1' then
                        state <= HEADER;
                    end if;
                when HEADER =>
                    state <= HEADER;
                    if readyL_i = '1' and valid_i = '1' then
                        state <= PKT_SIZE;
                    end if;
                when PKT_SIZE =>
                    state <= PKT_SIZE;
                    if readyL_i = '1' and valid_i = '1' then
                        flit_cnt <= data_i;
                        if data_i = x"0001" then
                            state <= LAST_FLIT;
                        else
                            state <= PAYLOAD;
                         end if; 
                    end if;
                when PAYLOAD =>
                    state <= PAYLOAD;
                    if readyL_i = '1' and valid_i = '1' then
                        flit_cnt <= flit_cnt -1;
                        if flit_cnt = x"0002" then
                            state <= LAST_FLIT;
                        end if;
                    end if;
                when LAST_FLIT =>
                    state <= LAST_FLIT;
                    if readyL_i = '1' and valid_i = '1' then
                        state <= WAIT_HEADER;
                        lastL_o <= '1';
                    end if;
                when others => 
                    state <= WAIT_HEADER;
            end case;
        end if;
    end process;

end Last_gen;
