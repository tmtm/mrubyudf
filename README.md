# mrubyudf

これは mruby で MySQL のユーザー定義関数(UDF)を簡単に作成するためのツールです。

## インストール

```sh
% gem install mrubyudf
```

## 準備

mysql_config コマンドと MySQL のヘッダファイルが必要です。

mysql-8.0.20-linux-glibc2.12-x86_64.tar.xz みたいなファイルを展開した中には入ってるはずです。

それ以外の場合は MySQL 開発環境のインストールが必要になるかも知れません。
Ubuntu の場合は libmysqlclient-dev パッケージをインストールすればいいと思います。

## 使い方


まず mruby をインストールする必要があります。mruby を動的リンクにするためのパッチをあてて make します。

```sh
% git clone git@github.com:mruby/mruby.git
% cd mruby
% patch -p1 < $GEM_HOME/gems/mrubyudf-0.*/misc/mruby-shared.patch
% make
```

うまくいかない場合は頑張ってください。

この mruby ディレクトリを MRUBY_PATH 環境変数に設定しておきます。

```sh
% export MRUBY_PATH=/path/to/mruby
```

関数本体を作ります。ここではフィボナッチ数を返す fib() 関数を fib.rb ファイルとして作ります。

```ruby
LONG_LONG_MAX = 9223372036854775807

def fib(n)
  b = 1
  c = 0
  n.times do
    a, b = b, c
    c = a + b
    raise 'Overflow' if c > LONG_LONG_MAX
  end
  c
end
```

mruby で実行して動きを確かめます。

```sh
% $MRUBY_PATH/bin/mruby -r ./fib.rb -e 'p fib(10)'
55
% $MRUBY_PATH/bin/mruby -r ./fib.rb -e 'p fib(92)'
7540113804746346429
% $MRUBY_PATH/bin/mruby -r ./fib.rb -e 'p fib(93)'
trace (most recent call last):
        [2] -e:1
        [1] -e:6:in fib
-e:9:in fib: Overflow (RuntimeError)
```

関数名、戻り値の型、引数の型等の情報を fib.spec ファイルで次のような感じで作ります。

```ruby
MrubyUdf.function do |f|
  f.name = 'fib'           # 関数名は fib
  f.return_type = Integer  # 戻り値は Integer
  f.arguments = [          # 引数は一つで型は Integer
    Integer
  ]
end
```

コンパイル。

```sh
% mrubyudf fib.spec
```

うまくいけば fib.so ファイルができます。

これを MySQL のプラグインディレクトリにコピーします。

```sh
% mysql_config --plugindir
/usr/local/mysql/lib/plugin
% sudo cp fib.so /usr/local/mysql/lib/plugin/
```

MySQL に組み込みます。一度やっておけば mysqld を再起動しても自動的に組み込まれます。

```sql
% mysql -uroot
mysql> create function fib returns int soname 'fib.so';
```

使ってみます。

```sql
mysql> select fib(10);
+---------+
| fib(10) |
+---------+
|      55 |
+---------+
1 row in set (0.04 sec)

mysql> select fib(92);
+---------------------+
| fib(92)             |
+---------------------+
| 7540113804746346429 |
+---------------------+
1 row in set (0.04 sec)

mysql> select fib(93);
+---------+
| fib(93) |
+---------+
|    NULL |
+---------+
1 row in set (0.04 sec)
```

関数が要らなくなったら破棄します。

```sql
mysql> drop function fib;
```

drop しないで so ファイルを更新したりすると、mysqld が落ちるので注意。

example 配下にテキトーなサンプルがいくつかあります。


## ライセンス

このツール自体は GPL 3 です。

このツールによって作られた so ファイルは、このツールのライセンスとは無関係です。

## 作者

とみたまさひろ <https://twitter.com/tmtms>
