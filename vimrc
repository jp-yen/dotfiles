" エラーでベルを鳴らさない
set noerrorbells

" 文字コード & 改行コード
:set ts=4

" 日本語文字コード自動認識設定
if has('iconv')
  " EUC/JISのバリエーション定義
  let s:enc_euc = 'euc-jp'
  let s:enc_jis = 'iso-2022-jp'
  if iconv("\x87\x64\x87\x6a", 'cp932', 'eucjp-ms') ==# "\xad\xc5\xad\xcb"
    let s:enc_euc = 'eucjp-ms'
    let s:enc_jis = 'iso-2022-jp-3'
  elseif iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
    let s:enc_euc = 'euc-jisx0213'
    let s:enc_jis = 'iso-2022-jp-3'
  endif

  " utf-8 を先頭
  " ※JISは誤認しないので utf-8 より前に
  let &fileencodings = s:enc_jis . ',utf-8,' . s:enc_euc . ',cp932,ucs-bom,latin1'

  unlet s:enc_euc
  unlet s:enc_jis
endif

" 日本語を含まない場合は fileencoding に encoding (utf-8) を使う
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
"" ウィンドウをクリックしたときにカーソルを移動しない
set mouse=
map <LeftMouse> <Nop>

" set mouse= が反映されないので autocmd で設定する
" autocmd に登録されているか確認するには以下のコマンドを実行
" :autocmd VimEnter *
autocmd VimEnter * set mouse=

filetype on
if has("autocmd")
    autocmd FileType c,cpp,perl setlocal cindent
    autocmd FileType python setlocal tabstop=4 noexpandtab smarttab
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

"-------Display-------
"ルーラー,行番号を表示
set ruler
set number

"ステータスラインにコマンドを表示
set showcmd

"ステータスラインを常に表示
set laststatus=2

"-------Display-------
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
silent! colorscheme evening

" https://raw.githubusercontent.com/rodnaph/vim-color-schemes/master/colors/koehler.vim
silent! colorscheme koehler

" https://www.vim.org/scripts/script.php?script_id=2465
" wget -O wombat256mod.vim 'https://www.vim.org/scripts/download_script.php?src_id=13400'
silent! colorscheme wombat256mod

" https://romainl.github.io/Apprentice/
" wget https://raw.githubusercontent.com/romainl/Apprentice/master/colors/apprentice.vim
silent! colorscheme apprentice

" https://github.com/karoliskoncevicius/moonshine-vim
" wget https://raw.githubusercontent.com/karoliskoncevicius/moonshine-vim/master/colors/moonshine.vim
silent! colorscheme moonshine

" https://github.com/Haron-Prime/Antares
" wget https://raw.githubusercontent.com/Haron-Prime/Antares/master/colors/antares.vim
silent! colorscheme antares

" 自分でカラースキームを選びたい場合は
" https://colorswat.ch/vim/?welcome=1

"文字コードや改行コードが違っているとファイルを壊すので注意 モードライン
"vim: set ts=4 fenc=utf-8 ff=unix ft=vimrc :
