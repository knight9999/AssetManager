package AssetManager::L10N::ja;

use strict;

use base 'AssetManager::L10N';
use vars qw( %Lexicon );

%Lexicon = (
  '_PLUGIN_DESCRIPTION' => 'AssetManagerは、アセットのファイルパスを変更するためのツールです。',
  'list_actions.change_path' => '移動（パスの変更）',
  'validation.too much items, smaller than [_1].' => 'アイテムの選択数が多すぎます。[_1]つ以下にして下さい。',
  'validation.all assets must blongs_to blog [_1] ( [_2] ).' => '移動すべてのアイテムはブログ[_1] (id: [_2])に属している必要があります。',
  'validation.asset [_1] can not moved because of parent.' => '親アイテムのあるアイテム (id: [_1])は移動出来ません。',
  'validation.new path must be start with %r.' => '新しいパスは%rからはじまっていなくてはいけません。例えば、%r/upload/images/。',
  'validation.new path must be end with /.' => '新しいパスは最後が/で終わっていなくてはいけません。例えば、%r/upload/images/。',
  'validation.new path must be different from old path.' => '新しいパスは以前のパスと違っている必要があります。',
  'validation.no root directory [_1].' => 'ルートディレクトリ [_1] が存在しません。',
  'validation.invalid path.' => '不正なパスです',
  'validation.directory [_1] can not be written.' => 'ディレクトリ [_1]に書き込めません。',
  'validation.file [_1] can not be written.' => 'ファイル [_1]を書き込めません。',
  'tmpl.back_to_item_list' => 'アイテム一覧に戻る',
  'tmpl.change_itempath' => 'アイテムの移動(パスの変更)',
  'tmpl.number of target items max [_1]' => '変更対象となるアイテム数(最大は:[_1])', 
  'tmpl.selected item path common part' => '選択したアイテムのパスの共通部分',
  'tmpl.new path common part' => '新しいパスの共通部分(最後は/で終わります)',
  'tmpl.change entries text, text more, excerpt.' => 'エントリーの記事の本文、もっと読む、概要に埋め込まれたurlも変更する',
  'tmpl.change url in item (html file)' => 'アイテム (htmlファイル)に埋め込まれたurlも変更する',
  'tmpl.test commit' => 'テスト実行',
  'tmpl.change' => '変更',
  'tmpl.explain %r' => "<p>※ %rは、ブログ／ウェブサイトのルートを表します。<br />\n"
  . 'AssetManagerプラグインでは、%rから始まるディレクトリにしか移動することは出来ません。</p>',
  'tmpl.complete change' => '変更作業が完了しました',
  'tmpl.rebuild if entries are changed.' => 'Entryを変更している場合は、再構築を忘れないようにしてください。',
  'tmpl.testOK' => 'テストが成功しました',
  
);

1;
