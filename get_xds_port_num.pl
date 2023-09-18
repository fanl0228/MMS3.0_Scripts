use strict;
use warnings;
# use windows serial port library
use Win32::SerialPort;

#use this version
use v5.22.1;

# Get the serial port number matching the input pattern
sub get_port_num {
    my ($pattern, $occurence) = @_;
    # command to get the serial COM port
    my $command = qq{wmic path win32_pnpentity get caption > pnp_list.txt};
    `$command`;
    open(my $pnp_file_hndl, "<:encoding(UTF-16)", "pnp_list.txt") or die "Could not open the pnp list";
    open my $utf8_file_hndl, '>:utf8', 'utf8_pnp_list.txt' or die $!;
    print $utf8_file_hndl $_ while <$pnp_file_hndl>;
    close $pnp_file_hndl;
    close $utf8_file_hndl;
    open $utf8_file_hndl, '<', 'utf8_pnp_list.txt' or die $!;
    my @lines = <$utf8_file_hndl>;
    my @com_port_list;
    my @sort_com_port_list;
    my $total_occur = 0;
    for(my $i = 0;$i<scalar @lines;$i++){
        #print($lines[$i]);
        if($lines[$i] =~ m/$pattern/)
        {
            $com_port_list[$total_occur] = $lines[$i];
            $total_occur++;
        }
    }

    if($total_occur < $occurence)
    {
        print("Insufficient occurences\r\n");
        print ($total_occur);
        print("\r\n");
        return 0;
    }
    else
    {
        @sort_com_port_list = sort @com_port_list;
        my @raw_output = $sort_com_port_list[$occurence - 1];
        my $output = $raw_output[0];
        #print $raw_output[0];
        $output =~ s/$pattern \(//;
        $output =~ s/\)//;
        $output =~ s/COM//;
        return ($output);
    }

    close $utf8_file_hndl;
}

# serial port number for AR1XXX Device
my $DUT_xds_port_num = get_port_num("XDS110 Class Application/User UART", 1);
print ($DUT_xds_port_num);



