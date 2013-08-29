package AssetManager::L10N::ja;

use strict;

use base 'AssetManager::L10N';
use vars qw( %Lexicon );

%Lexicon = (
  '_PLUGIN_DESCRIPTION' => 
'<p>AssetManagerは、アセットのファイルパスを変更するためのツールです。</p>'.
'<p>ブログまたはウェブサイトのアイテム一覧から使用することが出来ます。'.
'アイテムを選んで、アクションから移動（パスの変更）を選択すると、アイテムパスの共通部分が表示されます。'.
'この共通部分を変更することが可能です。</p>'.
'<p>アイテムパスの変更に伴い、エントリーの本文、もっと読む、概要の中で参照されているURLも変更されます。（絶対パスのみが対象）'.
'また、アイテムでhtmlファイルのものの中にアイテムパスの変更の影響を受けるものがあれば、それも変更されます。'.
'エントリーの本文、もっと読む、概要の変更や、アイテムでhtmlファイルのものの中のアイテムパスの変更は、必要がなければチェックを外して下さい。</p>'.
'<p>また、テスト実行がチェックされている場合は、ファイルの書き換え、データベースへの変更は行いません。書き込み権限のチェックだけを行います</p>'.
'<p></p>'.
'<p>Linux上でのみテストを行っています。ファイル書き換え途中でエラーが生じた場合など、復旧が非常に難しいため、本運用では事前にフルバックアップ'.
'をとるなどの対策を行ってから使用してください。また、アイテム数、エントリー数が多すぎる場合は、タイムアウトを起こす可能性があります。WebサーバのTimeout'.
'の設定も十分確認して下さい。</p>'.
'<p>※このプラグインの使用は自己責任になります。いかなる損害が発生しても、保障はいたしません。</p>'.
'<p></p>'.
'<p>mt-configで使用出来るパラメータ</p>'.
'<ul>'.
'<li>AssetManagerMaxSize<p>一度に選択出来るアイテムの数です。デフォルトは50になっています。</p></li>'.
'<li>AssetManagerLocalLogOff<p>1にすると、ローカルログ出力をしなくなります。</p></li>'.
'<li>AssetManagerLocalLogFile<p>デフォルトで、/tmp/に出力しているローカルログディレクトリを変更出来ます。書き込み可能な実在するディレクトリを指定してください。</p></li>'.
'</ul>',
  'list_properties.path' => 'パス',
  'list_actions.change_path' => '移動(パスの変更)',
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
  'tmpl.complete_change_itempath' => 'アイテムの移動完了',
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
