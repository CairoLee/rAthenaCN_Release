use File::Find;
use Cwd;

my $local_dir = getcwd;
my %hash;
my %translate_hash;
my $now_count = 0;

# 开始提取源代码中的字符串
finddepth(\&wanted, "../src");

# 对提取到的内容进行排序
my @keys = sort { $hash{$b} <=> $hash{$a} } keys %hash;

# 开始提取原来translate.conf中的汉化结果
get_translate("../conf/msg_conf/translate.conf");

# 输出
print "data: (\n";

# 先输出一些常规固定的内容
print "\t{\n\t\tsrc: \"^CL_RED^[Fatal Error]^CL_RESET^:\"\n\t\ttarget: \"^CL_RED^[严重错误]^CL_RESET^:\"\n\t},\n";
print "\t{\n\t\tsrc: \"^CL_RED^[Error]^CL_RESET^:\"\n\t\ttarget: \"^CL_RED^[错误]^CL_RESET^:\"\n\t},\n";
print "\t{\n\t\tsrc: \"^CL_CYAN^[Debug]^CL_RESET^:\"\n\t\ttarget: \"^CL_CYAN^[调试]^CL_RESET^:\"\n\t},\n";
print "\t{\n\t\tsrc: \"^CL_YELLOW^[Warning]^CL_RESET^:\"\n\t\ttarget: \"^CL_YELLOW^[警告]^CL_RESET^:\"\n\t},\n";
print "\t{\n\t\tsrc: \"^CL_WHITE^[Notice]^CL_RESET^:\"\n\t\ttarget: \"^CL_WHITE^[提示]^CL_RESET^:\"\n\t},\n";
print "\t{\n\t\tsrc: \"^CL_WHITE^[Info]^CL_RESET^:\"\n\t\ttarget: \"^CL_WHITE^[信息]^CL_RESET^:\"\n\t},\n";
print "\t{\n\t\tsrc: \"^CL_MAGENTA^[SQL]^CL_RESET^:\"\n\t\ttarget: \"^CL_MAGENTA^[数据库]^CL_RESET^:\"\n\t},\n";
print "\t{\n\t\tsrc: \"^CL_GREEN^[Status]^CL_RESET^:\"\n\t\ttarget: \"^CL_GREEN^[状态]^CL_RESET^:\"\n\t}";

# 开始输出从源码中读取到的内容
my $is_first = 0;
for (@keys){
	if (ignore($_) == 1) { next; }
	if ($is_first == 0){ print ",\n"; }
	my $translate = $translate_hash{$_};
	print "\t{\n\t\tsrc: $_\n\t\ttarget: \"$translate\"\n\t}";
	if ($is_first == 1){ $is_first = 0; }
}
print "\n)";

# ==================================================================

# 读取原来的汉化结果
sub get_translate{
	my $confpath = @_[0];
	# 只处理文件
	if(-f "$local_dir/$confpath"){
		open(my $fh, '<', "$local_dir/$confpath") or die "Could not open file '$local_dir/$confpath' $!";
		my $info = "";
		
		while (my $row = <$fh>) {
			$info .= $row;
		}
		close $fh;
		
		my $count = 0;
		while ($info =~ /\t{\n\t\tsrc: (".*?")\n\t\ttarget: "(.*?)"\n\t(},|})/g) {
			$translate_hash{$1} = $2;
			$count += 1;
		}
		return $count;
	}
	return -1;
}

# 转换颜色代码
sub colormark($){
	my $rpl = @_[0];
	$rpl =~ s/\"CL_RESET\"/\^CL_RESET\^/g;
	$rpl =~ s/\"CL_CLS\"/\^CL_CLS\^/g;
	$rpl =~ s/\"CL_CLL\"/\^CL_CLL\^/g;
	$rpl =~ s/\"CL_BOLD\"/\^CL_BOLD\^/g;
	$rpl =~ s/\"CL_NORM\"/\^CL_NORM\^/g;
	$rpl =~ s/\"CL_NORMAL\"/\^CL_NORMAL\^/g;
	$rpl =~ s/\"CL_NONE\"/\^CL_NONE\^/g;
	$rpl =~ s/\"CL_WHITE\"/\^CL_WHITE\^/g;
	$rpl =~ s/\"CL_GRAY\"/\^CL_GRAY\^/g;
	$rpl =~ s/\"CL_RED\"/\^CL_RED\^/g;
	$rpl =~ s/\"CL_GREEN\"/\^CL_GREEN\^/g;
	$rpl =~ s/\"CL_YELLOW\"/\^CL_YELLOW\^/g;
	$rpl =~ s/\"CL_BLUE\"/\^CL_BLUE\^/g;
	$rpl =~ s/\"CL_MAGENTA\"/\^CL_MAGENTA\^/g;
	$rpl =~ s/\"CL_CYAN\"/\^CL_CYAN\^/g;
	return $rpl;
}

# 判断是否需要忽略输出这一行到conf中
sub ignore {
	my $rpl = @_[0];
	if ($rpl =~ /"EXPAND_AND_QUOTE\(PACKETVER\)"/){ return 1; }
	
	if ($rpl =~ /^"%s(\\n|)"(\s+|)$/){ return 1; }
	if ($rpl =~ /^"%d(\\n|)"(\s+|)$/){ return 1; }
	if ($rpl =~ /^"\\n"(\s+|)$/){ return 1; }
	return 0;
}

# 每次读取到文件时的处理
# ===========================================================
# 情况一：只有一行内容，没有参数
#         ShowStatus("Loading NPCs...\r");
# 情况二：只有一行内容，有参数
#         ShowStatus("Loading NPC file: %s"CL_CLL"\r", file->name);
# 情况三：由多行内容构成，有参数
#         ShowInfo ("Done loading '"CL_WHITE"%d"CL_RESET"' NPCs:"CL_CLL"\n"
#                   "\t-'"CL_WHITE"%d"CL_RESET"' Warps\n"
#                   "\t-'"CL_WHITE"%d"CL_RESET"' Shops\n"
#                   "\t-'"CL_WHITE"%d"CL_RESET"' Scripts\n"
#                   "\t-'"CL_WHITE"%d"CL_RESET"' Spawn sets\n"
#                   "\t-'"CL_WHITE"%d"CL_RESET"' Mobs Cached\n"
#                   "\t-'"CL_WHITE"%d"CL_RESET"' Mobs Not Cached\n",
#                   npc_id - START_NPC_NUM, npc_warp, npc_shop, npc_script, npc_mob, npc_cache_mob, npc_delay_mob);
# ===========================================================
sub wanted {
	# 只处理文件，目录都不处理
	if(-f "$local_dir/$File::Find::name"){
		# 打开文件
		open(my $fh, '<', "$local_dir/$File::Find::name") or die "Could not open file '$File::Find::name' $!";
		my $no_ending = 0;
		my $cache = "";
		
		# 开始处理每一行的数据
		while (my $row = <$fh>) {
			# 去掉末尾的换行
			chomp $row;
			$row = colormark($row);
			if (ignore($row) == 1){
				next;
			}
			
			# 先试试看单独的一行能不能提取出完整内容来
			if (($row =~ /(ShowDebug|ShowInfo|ShowError|ShowStatus|ShowSQL|ShowNotice|ShowWarning|ShowFatalError)(\s+|)\((\s+|)(".*?(?<!\\)")(\);|,)/i) && ($no_ending == 0)){
				# 如果能，但是hash表中已经有过这个字符串了，那么跳过
				if (exists$hash{'$4'}){
					next;
				}
				# 否则加入到哈希表
				$hash{$4} = $now_count;
				# 这里的$now_count作为值，回头用来排序用的
				$now_count = $now_count + 1;
				# 处理完了这一行也就可以跳过了
				next;
			}
			
			# 如果读取到这一行的时候，发现上一行是不完整的，那么就把这一行当做上一行的补充
			if ($no_ending == 1){
				# 如果这就是带逗号的一行的话，那么执行完这段就算是将上一行残缺的补完了
				if ($row =~ /"(.*?)((?<!\\)",|"\);)/i){
					$cache .= $1;
					$cache = "\"".$cache."\"";
					if (exists$hash{'$cache'}){
						$cache = "";
						# 标记为已经完整了，接下来再读到的行可以按照正常的规则去匹配了
						$no_ending = 0;
						next;
					}
					$hash{$cache} = $now_count;
					$now_count = $now_count + 1;
					$cache = "";
					$no_ending = 0;
				}
				else {
					# 如果不带逗号，那么说明还没完，那么这一行只是上一行的一部分，但是后续还有别的
					$row =~ /"(.*?)(?<!\\)"$/i;
					$cache .= $1;
				}
				next;
			}
			
			# 如果这一行是个不完整的行，那么标记为后续读取到的行可能是这一行的一部分
			if ($row =~ /(ShowDebug|ShowInfo|ShowError|ShowStatus|ShowSQL|ShowNotice|ShowWarning|ShowFatalError)(\s+|)\((\s+|)"(.*?)(?<!\\)"(\s+|)$/i){
				$cache = $4;
				$no_ending = 1;
			}
		}
		close $fh;
	}
}