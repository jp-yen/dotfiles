set number

" エラーでベルを鳴らさない
set noerrorbells

" 文字コード & 改行コード
:set ts=4
" 文字コードの自動認識
if &encoding !=# 'utf-8'
  set encoding=japan
  set fileencoding=japan
endif
if has('iconv')
  let s:enc_euc = 'euc-jp'
  let s:enc_jis = 'iso-2022-jp'
  " iconvがeucJP-msに対応しているかをチェック
  if iconv("\x87\x64\x87\x6a", 'cp932', 'eucjp-ms') ==# "\xad\xc5\xad\xcb"
    let s:enc_euc = 'eucjp-ms'
    let s:enc_jis = 'iso-2022-jp-3'
  " iconvがJISX0213に対応しているかをチェック
  elseif iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
    let s:enc_euc = 'euc-jisx0213'
    let s:enc_jis = 'iso-2022-jp-3'
  endif
  " fileencodingsを構築
  if &encoding ==# 'utf-8'
    let s:fileencodings_default = &fileencodings
    let &fileencodings = s:enc_jis .','. s:enc_euc .',cp932'
    let &fileencodings = &fileencodings .','. s:fileencodings_default
    unlet s:fileencodings_default
  else
    let &fileencodings = &fileencodings .','. s:enc_jis
    set fileencodings+=utf-8,ucs-2le,ucs-2
    if &encoding =~# '^\(euc-jp\|euc-jisx0213\|eucjp-ms\)$'
      set fileencodings+=cp932
      set fileencodings-=euc-jp
      set fileencodings-=euc-jisx0213
      set fileencodings-=eucjp-ms
      let &encoding = s:enc_euc
      let &fileencoding = s:enc_euc
    else
      let &fileencodings = &fileencodings .','. s:enc_euc
    endif
  endif
  " 定数を処分
  unlet s:enc_euc
  unlet s:enc_jis
endif
" 日本語を含まない場合は fileencoding に encoding を使うようにする
if has('autocmd')
  function! AU_ReCheck_FENC()
    if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n') == 0
      let &fileencoding=&encoding
    endif
  endfunction
  autocmd BufReadPost * call AU_ReCheck_FENC()
endif
" 改行コードの自動認識
set fileformats=unix,dos,mac
" □とか○の文字があってもカーソル位置がずれないようにする
if exists('&ambiwidth')
  set ambiwidth=double
endif

"" 文字コードを指定して開き直す
"" :e ++enc=shift_jis

"" ウィンドウをクリックしたときに visual モードになるのを防ぐ
set mouse-=a

filetype on
if has("audocmd")
    autocmd FileType c,cpp,perl setlocal cindent
    autocmd FileType python setlocal tabstop=4 noexpandtab smarttab=on
endif

"-------Search--------
"インクリメンタルサーチを有効にする
set incsearch

"大文字小文字を区別しない
set ignorecase

"大文字で検索されたら対象を大文字限定にする
set smartcase

"行末まで検索したら行頭に戻る
set wrapscan

"括弧の対応をハイライト
set showmatch

"検索結果をハイライトする
set hlsearch

"ルーラー,行番号を表示
set ruler
set number

"ステータスラインにコマンドを表示
set showcmd

"ステータスラインを常に表示
set laststatus=2

"ファイルナンバー表示
"set statusline=[%n]

"ホスト名表示
set statusline+=%{matchstr(hostname(),'\\w\\+')}:

"ファイル名表示
set statusline+=%<%F

"変更のチェック表示
set statusline+=%m

"読み込み専用かどうか表示
set statusline+=%r

"ヘルプページなら[HELP]と表示
set statusline+=%h

"プレビューウインドウなら[Prevew]と表示
"set statusline+=%w

"これ以降は右寄せ
set statusline+=%=

"現在行数/全行数
set statusline+=[%c\ %l/%L]

"文字コード
"set statusline+=[ASCII:\%06.6b][HEX:\%04.4B]
set statusline+=[HEX:\%04.4B]

"ファイルフォーマット表示
set statusline+=[%{&fileformat}]

"文字コード表示
set statusline+=[%{has('multi_byte')&&\&fileencoding!=''?&fileencoding:&encoding}]

"ファイルタイプ表示
set statusline+=%y

" 色テーマを指定
syntax enable
" どれか入っていないかな？ ない場合は .vim/colors/ へ入れる

" https://github.com/vim/vim/blob/master/runtime/colors/evening.vim :-P
colorscheme evening

" https://github.com/rodnaph/vim-color-schemes/blob/master/colors/koehler.vim
colorscheme koehler

" https://www.vim.org/scripts/script.php?script_id=2465
" wget -O wombat256mod.vim 'https://www.vim.org/scripts/download_script.php?src_id=13400'
colorscheme wombat256mod

" https://romainl.github.io/Apprentice/
" wget https://raw.githubusercontent.com/romainl/Apprentice/master/colors/apprentice.vim
colorscheme apprentice

" https://github.com/karoliskoncevicius/moonshine-vim
" wget https://raw.githubusercontent.com/karoliskoncevicius/moonshine-vim/master/colors/moonshine.vim
colorscheme moonshine

" https://github.com/Haron-Prime/Antares
" wget https://raw.githubusercontent.com/Haron-Prime/Antares/master/colors/antares.vim
colorscheme antares

" 自分でカラースキームを選びたい場合は
" https://colorswat.ch/vim/?welcome=1

"文字コードや改行コードが違っているとファイルを壊すので注意
"vim: set ts=4 fenc=utf-8 ff=unix ft=vimrc : モードライン
