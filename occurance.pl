#!/usr/bin/perl -X
#
#	Look for re-occurances of lottery numbers.
#
#	   perl occurance.pl lotto_history.data
#
#		Written 01/19/2002 by JSB
#
############
use Time::localtime;


my $datafile = $ARGV[0];
my %num_by_date=([0,0,0,0,0,0]);
my %nums = ();
	# This will tally up "per slot" where each element counts occurances for the particular 1-53 number value.
my @occured=(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
my %date_occ=([0,0,0,0]);
my @highest_priority= ();
my @high_priority	= ();
my @medium_priority = ();
my @low_priority	= ();
my @lowest_priority = ();

if ($datafile eq ""){$datafile = "lotto_history.data";}
open (INFILE, "$datafile") or die "Could not open $datafile\n";
open (OUTFILE, ">sorted.data") or die "Could not open output file for sorted number groups\n";
my $savtot = 127;
my $ctr = 0;		
my $total_days = 0;
my ($lday, $lmonth, $lyear) =  ("","","");	
my $tick = 1;		#Set for limit lotto number range 1-53 currently
my $maxlimit = 53;	# Highest number.	 
my $now_string = ctime();
print "$0 Processing started with $datafile.\n";
while(<INFILE>)
{
	# 5,7,1988,,30,44,17,49,42,15		example
	$ctr++;
	chomp($_);
	$_ =~ s/\t//g;
	$_ =~ s/\t\t//g;
	$_ =~ s/ //g;
	my ($mon, $day, $year, $null, $n1, $n2, $n3, $n4, $n5, $n6) = parse_comma_delimited($_);
	($n1, $n2, $n3, $n4, $n5, $n6) = bubble_sort($n1, $n2, $n3, $n4, $n5, $n6);	# Sort number order smallest to largest.
	$occured[$n1]++;
	$occured[$n2]++;   # Count up the total number of times a particular number occured.
	$occured[$n3]++;
	$occured[$n4]++;
	$occured[$n5]++;
	$occured[$n6]++;

			# Store the last date we saw that particular number.
	($date_occ{"$n1"}[$occured[$n1]][0], $date_occ{"$n1"}[$occured[$n1]][1], $date_occ{"$n1"}[$occured[$n1]][2]) = ($mon,$day,$year);
	($date_occ{"$n2"}[$occured[$n2]][0], $date_occ{"$n2"}[$occured[$n2]][1], $date_occ{"$n2"}[$occured[$n2]][2]) = ($mon,$day,$year);
	($date_occ{"$n3"}[$occured[$n3]][0], $date_occ{"$n3"}[$occured[$n3]][1], $date_occ{"$n3"}[$occured[$n3]][2]) = ($mon,$day,$year);
	($date_occ{"$n4"}[$occured[$n4]][0], $date_occ{"$n4"}[$occured[$n4]][1], $date_occ{"$n4"}[$occured[$n4]][2]) = ($mon,$day,$year);
	($date_occ{"$n5"}[$occured[$n5]][0], $date_occ{"$n5"}[$occured[$n5]][1], $date_occ{"$n5"}[$occured[$n5]][2]) = ($mon,$day,$year);
	($date_occ{"$n6"}[$occured[$n6]][0], $date_occ{"$n6"}[$occured[$n6]][1], $date_occ{"$n6"}[$occured[$n6]][2]) = ($mon,$day,$year);

	$num_by_date{"$mon$day$year"}[0] = $n1;
	$num_by_date{"$mon$day$year"}[1] = $n2;
	$num_by_date{"$mon$day$year"}[2] = $n3;
	$num_by_date{"$mon$day$year"}[3] = $n4;
	$num_by_date{"$mon$day$year"}[4] = $n5;
	$num_by_date{"$mon$day$year"}[5] = $n6;
	print (OUTFILE "$mon,$day,$year,$n1,$n2,$n3,$n4,$n5,$n6\n");
	($lmonth, $lday, $lyear) = ($mon,$day,$year);
	print ".";
}											 
close(INFILE);
close(OUTFILE);


open (OUTFILE, ">occ_by_date.data") or die "Cannot open output file for occurance by date data\n";
open (OUT2, ">listocc_by_date.data") or die "Cannot open file for list occurance by date\n";


foreach $key (sort keys %date_occ)				####################### foreach processing loop.
{
	if($tick++ > $maxlimit){goto LOOP_JUMPOUT_100;}
	print (OUTFILE "$key,");		# The number we are dealing with.
#	print (OUT2 "$key\n");
	print (OUT2 "$key,");
	my($pmonth,$pday,$pyear) = ("05","07","1988");   # Start with first known date to init previous vals.
	my $total_elapsed = 0;		# Add up all elapsed days and divide by...
	my $occ_count	  = 0;		# this number of time this number occured for an average.
	my @stored_elapsed = ();
	my @tally_elapsed = ();
	my ($store_month, $store_day, $store_year) = ("", "", "");
	my $store_datestring = "";

	for($incr = 0; $incr < $occured[$key]; $incr++)
	{
		if(!($date_occ{"$key"}[$incr])){goto JUMP;}
 		my $tyear  = $date_occ{"$key"}[$incr][2];
		my $tmonth = $date_occ{"$key"}[$incr][0];
		my $tday   = $date_occ{"$key"}[$incr][1];
		if(($tyear eq "") or ($tmonth eq "") or ($tday eq "")){goto JUMP;}
		($tmonth,$tday) = fix_datefill($tmonth,$tday);
		print (OUTFILE "$tyear-$tmonth-$tday,");
		my $elapsed_days = get_dayspan($pmonth,$pday,$pyear,$tmonth,$tday,$tyear); # Get elapsed days.	MM/DD/YYYY
		$total_elapsed += $elapsed_days; 
		$occ_count++;
		($pmonth,$pday,$pyear) = ($tmonth,$tday,$tyear);	
		push (@stored_elapsed, $elapsed_days);
#		$tally_elapsed[$elapsed_days]++;	 
#		print (OUT2	   "\t$tyear/$tmonth/$tday,$elapsed_days\n");
#		print (OUT2	   "$elapsed_days,");
		($store_month, $store_day, $store_year)	 = ($tmonth,$tday,$tyear);
		$store_datestring = "$tyear/$tmonth/$tday";

	  JUMP:
	    print (OUTFILE ",");
	}
	print (OUTFILE "\n");
	my $occ_avg = 0;
	eval{$occ_avg = ($total_elapsed / $occ_count);};
#	print (OUT2    "Average number of days between occurances: $occ_avg\n");
	print (OUT2    "$occ_avg,");
#	print (OUT2    "Times number occured: $occ_count\n");
	print (OUT2    "$occ_count,");
#	print (OUT2 "UN-Sorted listing of elapsed days\n");
	@stored_elapsed = bubble_sort(@stored_elapsed);		
	my $arr_len = $#stored_elapsed;
	for($incr = 0; $incr < $arr_len; $incr++)
	{
		my $elapsed_val =  $stored_elapsed[$incr];
		print (OUT2 "$elapsed_val,");	    
		$tally_elapsed[$elapsed_val]++;		# Nth day is element in array, add one up.
	}
#	print (OUT2 "-----\t\t-----\n\n");
	print (OUT2 "$store_datestring\n");		# This is the last seen date in the line of data.
	print "Processing...$key \n";
	$arr_len = $#tally_elapsed;
	my $mode_dayspan = 0;
	my $highest_current_span = 0;
	for($incr = 0; $incr < $arr_len; $incr++)
	{	# Take the array for which the nth element is an elapsed days number, and determine how many
		# times that nth dayspan occured. The nth element with the highest count shows that particular dayspan
		# to have occured the most.
		if($tally_elapsed[$incr] > 0)
		{
			if($tally_elapsed[$incr] > $highest_current_span)
			{	# The element value is greater than the current value.
				$highest_current_span = $tally_elapsed[$incr];
				$mode_dayspan = $incr; #The nth array element has the highest value. Nth is the dayspan.
			}
		}
	}
	my ($nmonth, $nday, $nyear) = ($lmonth, $lday, $lyear);		# The new date or next play date.
	for($incr = 0; $incr < 4; $incr++){($nmonth, $nday, $nyear) = increment_date($nmonth, $nday, $nyear);}	# Get the next play date.
	my $current_value_timespan = get_dayspan($store_month, $store_day, $store_year,$nmonth, $nday, $nyear);
#	my $spannum =  abs($highest_current_span - $current_value_timespan);
	my $spannum =  abs($mode_dayspan - $current_value_timespan);
#	print "key = $key, spannum = $spannum, Mode Dayspan = $mode_dayspan, current timespan = $current_value_timespan,  time range = $store_month, $store_day, $store_year,$nmonth, $nday, $nyear\n";		### deb
	if($spannum < 4)
	{	# Within four days of being "due", high priority.
		push(@highest_priority, $key);
	}elsif($spannum < 7)
		{	
			push(@high_priority, $key);
		}
	elsif($spannum < 11)	
		{
			push(@medium_priority, $key);	#deb print "med pri key = $key\n";
		}
	elsif($spannum < 14)
		{
			push(@low_priority, $key);  
		}else{push(@lowest_priority, $key);}   
}################################################################ End foreach Processing loop.


LOOP_JUMPOUT_100:
close(OUT2);

for($incr = 0; $incr < 53; $incr++)
{	# Now the count for the particular number and exactly how many times it occured.
	print (OUTFILE "$incr, $occured[$incr]\n");	   
}

close(OUTFILE);


foreach $key (sort keys %num_by_date)
{
	($n1, $n2, $n3, $n4, $n5, $n6) = ($num_by_date{$key}[0], $num_by_date{$key}[1],$num_by_date{$key}[2],$num_by_date{$key}[3],$num_by_date{$key}[4],$num_by_date{$key}[5]);
	if($nums{"$n1-$n2-$n3-$n4-$n5-$n6"} ne "")
	{	# Found duplicate		
		my $prev = $nums{"$n1-$n2-$n3-$n4-$n5-$n6"};
		print "********Duplicate found\n";
		print "$key, $num_by_date{$key}[0]-$num_by_date{$key}[1]-$num_by_date{$key}[2]-$num_by_date{$key}[3]-$num_by_date{$key}[4]-$num_by_date{$key}[5]\n";
		print "same as on date 	$prev\n";
	}else{$nums{"$n1-$n2-$n3-$n4-$n5-$n6"} = $key;}
}

foreach $key (sort keys %nums)
{
	if($prev eq $key)
	{
		print "duplicate found: $prev/$key\n";
	}else{$prev = $key;}
}
print "\n$0 processing complete. $ctr total records processed.\n";
open (OUT3, ">results.txt") or die "Cannot open file for final results\n";

print (OUT3 "\tNumber by Priority Report.\n\t-----------$now_string---------------------\n\n\n");

my $incr = 0;

print (OUT3 "Highest Priority:");
@highest_priority = bubble_sort(@highest_priority);
$arr_len = $#highest_priority;
for($incr = 0; $incr < $arr_len; $incr++){print (OUT3 "$highest_priority[$incr],");}
print(OUT3 "$highest_priority[$incr]");
print (OUT3 "\n\n");

print (OUT3 "High Priority:");
@high_priority = bubble_sort(@high_priority);
$arr_len = $#high_priority;
for($incr = 0; $incr < $arr_len; $incr++){print (OUT3 "$high_priority[$incr],");}
print(OUT3 "$high_priority[$incr]");
print (OUT3 "\n\n");


print (OUT3 "Medium Priority:");
@medium_priority = bubble_sort(@medium_priority);
$arr_len = $#medium_priority;
for($incr = 0; $incr < $arr_len; $incr++){print (OUT3 "$medium_priority[$incr],");}
print(OUT3 "$medium_priority[$incr]");		
print (OUT3 "\n\n");

print (OUT3 "Low Priority:");
@low_priority = bubble_sort(@low_priority);
$arr_len = $#low_priority;
for($incr = 0; $incr < $arr_len; $incr++){print (OUT3 "$low_priority[$incr],");}
print(OUT3 "$low_priority[$incr]");
print (OUT3 "\n\n");


print (OUT3 "Lowest Priority:");
@lowest_priority = bubble_sort(@lowest_priority);
$arr_len = $#lowest_priority;
for($incr = 0; $incr < $arr_len; $incr++){print (OUT3 "$lowest_priority[$incr],");}
print(OUT3 "$lowest_priority[$incr]");
print (OUT3 "\n\n");


close(OUT3);

exit(1);	 ##############################


sub parse_comma_delimited
{	# This sub is derived from parse_line but takes only a list with elements
	# seperated by commas.
	my $in_line = $_[0].",";  # Extra comma added to get all of the elements.
	my $comma = ",";
	my ($pos, @tarr, $new_line, $incr, $tempstr, $loop);
	while($in_line =~ m/$comma/g){$loop++;}
	$loop++;
	for($incr = 0; $incr < $loop; $incr++)
	{	
 		$pos = index($in_line, $comma);
		$tempstr = substr($in_line, 0, $pos);
		push (@tarr, $tempstr);
		$pos++;
		$new_line = substr($in_line, $pos);
		$in_line = $new_line;
	}
	return @tarr;
}


sub bubble_sort
{
	my @sortarr = @_;
	my $arr_len = $#sortarr;
	my $first = 0;
	my $last = $arr_len;
	my $sorted = 0;
	while (!($sorted))		# Sorted = 1 when sort complete.
	{
		$sorted = 1;
		for ($incr = $first; $incr < $last; $incr++)
		{
			my $val1 = $sortarr[$incr];
			my $val2 = $sortarr[$incr+1];
			if($val1 > $val2)
			{
				my $hold = $sortarr[$incr];
				$sortarr[$incr] = $sortarr[$incr+1];
				$sortarr[$incr+1] = $hold;
				$sorted = 0;
			}
		}
		$last = $last - 1;
	}
	return @sortarr;
}


sub get_day_count
{	# Get the number of days in a month.
	$tmonth = $_[0];	 
	%hash = (
		"01" => "31",
		"02" => "28", 
		"03" => "31",
		"04" => "30",
		"05" => "31",
		"06" => "30",
		"07" => "31",
		"08" => "31",						
		"09" => "30",
		"10" => "31",
		"11" => "30",
		"12" => "31",
		);
  	$number = $hash{$tmonth};
	return($number);  
}

sub increment_date
{	# Sub will increment the total date value - changing month and even year
	# for those cases where the need arises.
	my ($cmonth, $cday, $cyear)	= @_;
	++$cday;
	if($cday > (get_day_count($cmonth)))
	{
		++$cmonth;
		$cday = "01";
		if($cmonth > 12)
		{	
			++$cyear;
			$cmonth = "01";
		} 
		if(length($cmonth) == 1){$cmonth = "0".$cmonth;}
	}
	if(length($cday) == 1){$cday = "0".$cday;}
	return ($cmonth, $cday, $cyear);
}

sub get_dayspan
{	# Take in six arguements representing two dates and determine the number of 
	# days between the two, inclusive.
	my ($smonth, $sday, $syear, $emonth, $eday, $eyear) = @_;
	my $day_ctr = 0;
	while ("$smonth$sday$syear" ne "$emonth$eday$eyear")
	{
		$day_ctr++;
		if((($smonth eq "03") and ($sday eq "01")) and (($emonth eq "02") and ($eday eq "29"))){goto LOOP_JUMPOFF;}	# Leap year occured, get out.
		($smonth, $sday, $syear) = increment_date($smonth, $sday, $syear);
	#	print ">";
	}
  LOOP_JUMPOFF:
#	print "*\n";
	return($day_ctr);
}

sub fix_datefill
{	# The dates are two digit for month and day, and four for year. This sub will 
	# ensure that the date complies.
	my ($fmonth, $fday) = @_;
	if(length($fmonth) == 1){$fmonth = "0".$fmonth;}
	if(length($fday) == 1){$fday = "0".$fday;}
	return($fmonth, $fday);
}




