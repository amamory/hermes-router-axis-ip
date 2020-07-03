-- very simple tb to create an inboud and an outbound transactions.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
USE ieee.numeric_std.ALL; 

entity tb is
end tb;

architecture tb of tb is
    -- change here if you want to send more packets
    --constant N_PACKETS : integer := 4; 
    -- change here if you want to send longer packets
    constant MAX_FLITS : integer := 3;

	signal clock:    std_logic := '0';
	signal reset:    std_logic;  

	-- slave local port
    signal validL_i : std_logic;
    signal dataL_i  : std_logic_vector(31 downto 0);
    signal readyL_o : std_logic;

    -- other slave ports
    signal validE_i : std_logic;
    signal dataE_i  : std_logic_vector(31 downto 0);
    signal readyE_o : std_logic;

    signal validN_i : std_logic;
    signal dataN_i  : std_logic_vector(31 downto 0);
    signal readyN_o : std_logic;

    signal validW_i : std_logic;
    signal dataW_i  : std_logic_vector(31 downto 0);
    signal readyW_o : std_logic;

    signal validS_i : std_logic;
    signal dataS_i  : std_logic_vector(31 downto 0);
    signal readyS_o : std_logic;

	-- master local port
    signal validL_o : std_logic;                    
    signal lastL_o  : std_logic;
    signal dataL_o  : std_logic_vector(31 downto 0);
    signal readyL_i : std_logic;
	
    -- other master ports
    signal validE_o : std_logic;                    
    signal dataE_o  : std_logic_vector(31 downto 0);
    signal readyE_i : std_logic;
            
    signal validW_o : std_logic;                    
    signal dataW_o  : std_logic_vector(31 downto 0);
    signal readyW_i : std_logic;
            
    signal validN_o : std_logic;                    
    signal dataN_o  : std_logic_vector(31 downto 0);
    signal readyN_i : std_logic;
            
    signal validS_o : std_logic;                    
    signal dataS_o  : std_logic_vector(31 downto 0);
    signal readyS_i : std_logic;
            

    type packet_t is array (0 to MAX_FLITS+1) of std_logic_vector(31 downto 0);	
	
	-- send one work according to the AXI Streaming master protocol
	procedure SendFlit(signal clock  : in  std_logic;
	                   constant flit : in  std_logic_vector(31 downto 0);
	                   --- AXI master streaming 
	                   signal data   : out std_logic_vector(31 downto 0);
	                   signal valid  : out std_logic;
	                   signal ready  : in  std_logic
	                   ) is
	begin
		wait until rising_edge(clock);
		-- If both the AXI interface and the router runs at the rising edge, then it is necessary to add 
		--   a delay at the inputs. The solution was to put an inverted in the clock in the Router_Board entity. 
		-- This way the delay is not necessary and it is also not necessary to change the router's vhdl   
        data <= flit;
        valid <= '1';
        wait for 8ns; -- simulate delay at the primary inputs
        while ready /= '1' loop
             wait until falling_edge(clock); -- data is buffered at the falling edge
        end loop;	
	end procedure;
	
	procedure SendPacket(signal clock  : in  std_logic;
                       constant packet : in  packet_t;
                       --- AXI master streaming 
                       signal data   : out std_logic_vector(31 downto 0);
                       signal valid  : out std_logic;
                       signal ready  : in  std_logic
                       ) is
        variable num_flits : integer;
    begin
         -- send header
        SendFlit(clock,packet(0),data,valid,ready);
        -- send size
        SendFlit(clock,packet(1),data,valid,ready);
        num_flits := to_integer(signed(packet(1)));
        -- send payload
        for f in 2 to num_flits+1 loop
            SendFlit(clock,packet(f),data,valid,ready);
        end loop;
      -- end of the packet transfer
        wait until rising_edge(clock);
        wait for 4 ns;
        valid <= '0';
        data <= (others => '0');
        -- wait a while to start the next packet transfer 
        wait for 100 ns;    
    end procedure;

	
begin

	reset <= '1', '0' after 100 ns; -- active low

    -- 50 MHz, as the default freq generated by the PS
	process
	begin
		clock <= not clock;
		wait for 10 ns;
		clock <= not clock;
		wait for 10 ns;
	end process;
	
	-- master ports are always ready to receive
	readyE_i <= '1';
	readyN_i <= '1';
	readyW_i <= '1';
	readyS_i <= '1';
	readyL_i <= '1';

    ----------------------------------------------------
    -- testing the flow from the slave port to the Sink LEDs
    ----------------------------------------------------
    process
        -- it sends N_PACKETS packets of max size of of MAX_FLITS 
        --type packet_vet_t is array (0 to N_PACKETS-1, 0 to MAX_FLITS+1) of std_logic_vector(31 downto 0);
        --constant packet_vet : packet_vet_t := 
        --    (
        --        (x"00000101", x"00000001", x"00001234", x"00000000", x"00000000"), -- from the east to local
        --        (x"00000101", x"00000001", x"00004321", x"00000000", x"00000000"), -- from the north to local
        --        (x"00000101", x"00000003", x"11111111", x"22222222", x"33333333"), -- from the west to local 
        --        (x"00000101", x"00000003", x"44444444", x"55555555", x"66666666")  -- from the south to local
        --    );
         variable  packet : packet_t;
	begin
		validL_i <= '0';
		dataL_i <= (others => '0');
		validN_i <= '0';
		dataN_i <= (others => '0');
			validE_i <= '0';
		dataE_i <= (others => '0');
			validW_i <= '0';
		dataW_i <= (others => '0');
			validS_i <= '0';
		dataS_i <= (others => '0');
		wait for 200 ns;
		wait until rising_edge(clock);
		
		-- from the east to local
		packet := (x"00000101", x"00000001", x"00001234", x"00000000", x"00000000");
		SendPacket(clock, packet, dataE_i, validE_i, readyE_o);
		-- from the north to local
        packet := (x"00000101", x"00000001", x"00004321", x"00000000", x"00000000");
        SendPacket(clock, packet, dataN_i, validN_i, readyN_o);
		-- from the west to local
        packet := (x"00000101", x"00000003", x"11111111", x"22222222", x"33333333");
        SendPacket(clock, packet, dataW_i, validW_i, readyW_o);
		-- from the south to local
        packet := (x"00000101", x"00000003", x"44444444", x"55555555", x"66666666");
        SendPacket(clock, packet, dataS_i, validS_i, readyS_o);
		
		-- block here. do not send it again
		wait;
	end process;


 router: entity work.RouterCC
  port map ( 
        clock    => clock,
        reset    => reset,
        -- AXI slave streaming interfaces
        validE_i => validE_i,
        dataE_i  => dataE_i ,
        readyE_o => readyE_o,
                            
        validW_i => validN_i,
        dataW_i  => dataN_i ,
        readyW_o => readyN_o,
                            
        validN_i => validW_i,
        dataN_i  => dataW_i ,
        readyN_o => readyW_o,
                            
        validS_i => validS_i,
        dataS_i  => dataS_i ,
        readyS_o => readyS_o,          

        validL_i => validL_i,
        dataL_i  => dataL_i ,
        readyL_o => readyL_o,

        -- AXI master streaming interfaces
        validE_o => validE_o,
        dataE_o  => dataE_o ,
        readyE_i => readyE_i,

        validW_o => validW_o,
        dataW_o  => dataW_o ,
        readyW_i => readyW_i,

        validN_o => validN_o,
        dataN_o  => dataN_o ,
        readyN_i => readyN_i,

        validS_o => validS_o,
        dataS_o  => dataS_o ,
        readyS_i => readyS_i,

        validL_o => validL_o,
        lastL_o  => lastL_o,
        dataL_o  => dataL_o ,
        readyL_i => readyL_i
	);
	
end tb;

