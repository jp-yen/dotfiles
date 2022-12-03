#!/usr/bin/tcsh
set echo_style both
set USER = `whoami`
set HOST = `uname -n`

set path = ( ~/opt/bin $path )

if ( $?prompt ) then
	set filec
	set ignoreeof
	set history = 1000
	set fignore = ( .o \~ .aux .log )
	set visiblebell

	alias	c	clear
	alias	JP	setenv LANG ja_JP.utf8
	alias	C	unsetenv LANG LC_ALL
	( which \screen  >& /dev/null ) &&	alias	screen	`which \screen` -U
	# cygwin や WSL など、/var/run/screen 問題の回避
	setenv SCREENDIR $HOME/.screen
	if ( ! -d $SCREENDIR ) then
		mkdir $SCREENDIR && chmod 700 $SCREENDIR
	endif

	( which \htop >& /dev/null ) && alias top `which \htop`
	setenv PAGER more
	( which \less >& /dev/null ) && setenv PAGER `which \less`
	setenv LESS "-ReFXsc"

	( which lesspipe >& /dev/null ) && set lesspipe = `which lesspipe` || \
	( which lesspipe.sh >& /dev/null ) && set lesspipe = `which lesspipe.sh`
	setenv LESSOPEN '| '"$lesspipe"' %s'
	unset lessopen

	set esc=`printf "\e"`
	( which \tput >& /dev/null ) && set TPUT = `which \tput`
	if ( $?TPUT ) then
		set clr = "`$TPUT sgr0`"

		# bold / blink
		setenv  LESS_TERMCAP_mb "`$TPUT blink`"
		setenv  LESS_TERMCAP_md "`$TPUT bold`"

		# standout-mode start/end (Info box)
		setenv  LESS_TERMCAP_so "`$TPUT smso`"
		setenv  LESS_TERMCAP_se "`$TPUT rmso`"

		# under-line start/end
		setenv  LESS_TERMCAP_us "`$TPUT smul ; $TPUT setab 4`"
		setenv  LESS_TERMCAP_ue "`$TPUT rmul ; $TPUT op`"

		# all off
		setenv  LESS_TERMCAP_me "$clr"
		setenv  LESS_TERMCAP_zz "$clr"		# dummy for printenv

		# has 256 color mode?
		if (  `$TPUT colors` > 254 ) then
			setenv  LESS_TERMCAP_md "`$TPUT bold ; $TPUT setab 237`"
			setenv  LESS_TERMCAP_so "`$TPUT smso ; $TPUT setab 18 ; $TPUT setaf 229`"
			setenv  LESS_TERMCAP_se "`$TPUT rmso ; $TPUT op`"
			setenv  LESS_TERMCAP_us "`$TPUT smul ; $TPUT setab 4 ; $TPUT setaf 136`"
		endif
		unset TPUT
	else
		set clr = "`printf '\e[0m'`"

		setenv  LESS_TERMCAP_md "$esc"'[1;44m'		# begin bold
		setenv  LESS_TERMCAP_mb "$esc"'[1;5;31m'	# begin blinking
		setenv  LESS_TERMCAP_me "$clr"				# end mode
		setenv  LESS_TERMCAP_so "$esc"'[5;7;229m'	# begin standout-mode - info box
		setenv  LESS_TERMCAP_se "$clr"				# end standout-mode
		setenv  LESS_TERMCAP_us "$esc"'[4m'			# begin underline
		setenv  LESS_TERMCAP_ue "$esc"'[24m'		# end underline
	endif

	set prompt_char = '#'
	if ( ! $?tcsh ) then
		[ `id -u` -ne 0 ] && set prompt_char = '%'
		alias setprompt 'set prompt="${USER}@${HOST}:${cwd}[\\!]${prompt_char} "'
		alias cd 'chdir \!* ; setprompt'
		alias pushd 'pushd \!* ; setprompt'
		alias popd 'popd \!* ; setprompt'
		setprompt
	else
		set autolist
		# csh と tcsh の間で history ファイルに互換性が無いので
		set histfile = ~/.thistory
		# コマンド履歴の保存設定
		set histdup = erase
		# history の表示形式を変更しますが、変更すると過去の
		# .history ファイルの形式も変わり読めなくなります
		# → history がリセットされます
		set history = ( 1000 "%h %Y/%W/%D %T %R\n" )
		set savehist = ( 1000 merge )
		# 連続してログアウトしたり、WLC でログアウトする時に
		# 保存が失敗することがあるので、明示的に保存する
		alias exit "history -M ; history -S ; exec `which \echo`"

		set nobeep
		# パスの重複削除
		set -f path = ( $path )

		# 色付きプロンプト
		[ `id -u` -ne 0 ] && set prompt_char = '\%'
		set in_screen = `echo $TERM | grep screen | wc -l` >& /dev/null
		if ( $in_screen ) then
			set  prompt_color = "$clr$esc"'[32;44;1m'
		else
			set  prompt_color = "$clr$esc"'[48;5;28;93m'
		endif
		set  prompt = '%{'"$prompt_color"'%}%U%n@%m%u:%B%~%b[%h]'"$prompt_char"'%{'$clr'%} '
		set rprompt = '%{'"$prompt_color"'%}%Y-%W-%D %P%{'$clr'%} '
		unset in_screen prompt_color

		alias	ls	ls-F
	endif
	unset esc
	unset clr

	if ( ! -e ~/.ssh-agent ) then
		( which \ssh-agent  >& /dev/null ) &&   `which ssh-agent` -c > ~/.ssh-agent
	endif
	source ~/.ssh-agent

	if ( "$SSH_AGENT_PID" == "" || ! { kill -0 "$SSH_AGENT_PID" } ) then
		( which \ssh-agent  >& /dev/null ) &&   `which ssh-agent` -c > ~/.ssh-agent
		source ~/.ssh-agent
	endif

	ssh-add -l >& /dev/null || ssh-add

	( which \fortune >& /dev/null ) && fortune -a
endif
# for vim
# vim: set ts=4 fenc=utf-8 ff=unix ft=csh :
