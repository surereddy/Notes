size_str=`ls -l /afc/log/cce* | awk 'BEGIN {totalSize = 0;} {totalSize = $5 + totalSize;} END {  print "Total size of cce logs:", totalSize;}'`;
details_str=`ls -l /afc/log/cce*`;
date_str=`date +%Y-%m-%d-%H:%M:%S`;
echo "$date_str -- $size_str" >> /afc/peter/cce_summary.txt;
echo -e "$date_str \n$details_str\n\n" >> /afc/peter/cce_details.txt;
